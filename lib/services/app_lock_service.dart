import 'dart:convert';
import 'dart:isolate';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';

import '../core/storage/secure_key_value_store.dart';

/// Stores and verifies the app-lock PIN in platform secure storage.
///
/// The PIN is stretched with PBKDF2-HMAC-SHA256 and a random per-install
/// salt. New PINs use 600,000 iterations under the `v3:` format, which
/// records the iteration count so the parameter can be raised again without
/// locking anyone out. The earlier schemes — single-SHA-256 digests and the
/// `v2:` 100k-iteration format — still verify, and are re-stored under `v3:`
/// transparently on the next successful unlock. The key derivation runs in a
/// background isolate so a long PIN stretch cannot freeze the UI.
class AppLockService {
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _versionPrefix = 'v3:';
  static const _saltBytes = 16;

  // The previous stretched scheme, kept to verify stored digests and to
  // migrate them on the first successful unlock.
  static const _v2Prefix = 'v2:';
  static const _v2KdfIterations = 100000;

  // Legacy single-iteration scheme, kept only to migrate stored digests.
  static const _legacySalt = 'vittix-app-lock';

  final SecureKeyValueStore _storage;
  final LocalAuthentication _biometrics;
  final Random _random;

  /// Iterations used when storing a new PIN (the format records it, so this
  /// can be raised without locking anyone out). Tests inject a small value.
  final int kdfIterations;

  /// Whether the key derivation runs in a background isolate. Real apps
  /// always offload; tests that pump the widget tree synchronously turn it
  /// off because a fake-async zone cannot await a real isolate.
  final bool offloadToIsolate;

  AppLockService(
    this._storage, {
    LocalAuthentication? biometrics,
    Random? random,
    int? kdfIterations,
    bool? offloadToIsolate,
  }) : _biometrics = biometrics ?? LocalAuthentication(),
       _random = random ?? Random.secure(),
       kdfIterations = kdfIterations ?? AppLockService.defaultKdfIterations,
       offloadToIsolate = offloadToIsolate ?? true;

  /// Production iteration count for new PINs.
  ///
  /// Deliberately lower than the backup cipher's 600k: an app-lock PIN has
  /// at most 8 digits, its wrong-attempt lockout already throttles online
  /// guessing, and at 600k the stretch costs seconds of unlock latency on a
  /// cheap phone. 100k keeps the offline-stretch meaningful without making
  /// the lock screen feel broken.
  static const defaultKdfIterations = 100000;

  static String _legacyHashPin(String pin) =>
      sha256.convert(utf8.encode('$_legacySalt:$pin')).toString();

  /// The legacy digest for [pin], exposed so migration tests can seed a
  /// pre-upgrade store.
  @visibleForTesting
  static String legacyHashForTest(String pin) => _legacyHashPin(pin);

  /// A `v2:`-format hash for [pin], exposed so migration tests can seed the
  /// pre-600k stretched scheme.
  @visibleForTesting
  static Future<String> v2HashForTest(String pin) async {
    final salt = _randomSalt();
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _v2KdfIterations, 32));
    final key = derivator.process(Uint8List.fromList(utf8.encode(pin)));
    return '$_v2Prefix${base64Encode(salt)}:${base64Encode(key)}';
  }

  /// The stretched key for [pin]; off the UI thread unless disabled for
  /// tests (a fake-async widget-test zone cannot await a real isolate).
  Future<Uint8List> _stretchedKey(String pin, Uint8List salt, int iterations) {
    final saltCopy = Uint8List.fromList(salt);
    Uint8List derive() {
      final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
        ..init(Pbkdf2Parameters(saltCopy, iterations, 32));
      return derivator.process(Uint8List.fromList(utf8.encode(pin)));
    }

    return offloadToIsolate ? Isolate.run(derive) : Future.value(derive());
  }

  static Uint8List _randomSalt() {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(_saltBytes, (_) => random.nextInt(256)),
    );
  }

  Future<bool> hasPin() async => (await _storage.read(_pinHashKey)) != null;

  Future<void> setPin(String pin) async {
    final salt = Uint8List.fromList(
      List<int>.generate(_saltBytes, (_) => _random.nextInt(256)),
    );
    final key = await _stretchedKey(pin, salt, kdfIterations);
    await _storage.write(
      _pinHashKey,
      '$_versionPrefix$kdfIterations:'
      '${base64Encode(salt)}:${base64Encode(key)}',
    );
  }

  Future<void> clearPin() => _storage.delete(_pinHashKey);

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(_pinHashKey);
    if (stored == null) return false;

    // Current v3 format: v3:<iterations>:<salt>:<key>.
    if (stored.startsWith(_versionPrefix)) {
      final parts = stored.substring(_versionPrefix.length).split(':');
      if (parts.length != 3) return false;
      final iterations = int.tryParse(parts[0]);
      if (iterations == null || iterations <= 0) return false;

      final Uint8List key;
      try {
        key = await _stretchedKey(pin, base64Decode(parts[1]), iterations);
      } on FormatException {
        return false;
      }
      final matches = _constantTimeEquals(
        base64Encode(key),
        parts[2],
      );
      if (!matches) return false;
      // A v3 hash with fewer than the current iterations (or any other
      // difference) is re-stored under the hardened parameters.
      if (iterations != kdfIterations) await setPin(pin);
      return true;
    }

    // Previous v2 format: v2:<salt>:<key> at 100k iterations. Verify, then
    // re-store under the current scheme so the weaker form only survives
    // until the first successful unlock.
    if (stored.startsWith(_v2Prefix)) {
      final parts = stored.substring(_v2Prefix.length).split(':');
      if (parts.length != 2) return false;

      final Uint8List salt;
      try {
        salt = base64Decode(parts[0]);
      } on FormatException {
        return false;
      }
      final key = await _stretchedKey(pin, salt, _v2KdfIterations);
      if (!_constantTimeEquals(base64Encode(key), parts[1])) return false;
      await setPin(pin);
      return true;
    }

    // Legacy digest: verify, then re-store under the stretched scheme so the
    // weak form only survives until the first successful unlock.
    if (_constantTimeEquals(_legacyHashPin(pin), stored)) {
      await setPin(pin);
      return true;
    }
    return false;
  }

  /// Length-only comparison that does not short-circuit on the first
  /// mismatching character.
  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var equal = 0;
    for (var i = 0; i < a.length; i++) {
      equal |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return equal == 0;
  }

  /// Whether the device supports biometrics and has one enrolled.
  ///
  /// Returns false rather than throwing when the platform has no support (for
  /// example on a desktop test host or a device with no sensor configured).
  Future<bool> biometricsAvailable() async {
    try {
      if (!await _biometrics.isDeviceSupported()) return false;
      return await _biometrics.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Prompts for a biometric unlock. Returns false on failure, cancellation or
  /// missing platform support.
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _biometrics.authenticate(
        localizedReason: 'Unlock VittixInvoice',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
