import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pointycastle/export.dart';

import '../core/storage/secure_key_value_store.dart';

/// Stores and verifies the app-lock PIN in platform secure storage.
///
/// The PIN is stretched with PBKDF2-HMAC-SHA256 (100k iterations, random
/// per-install salt — the same parameters the encrypted backups use), so a
/// leaked store cannot reveal even a 4-digit PIN at brute-force speed. Pins
/// stored by the earlier single-SHA-256 scheme are verified and transparently
/// upgraded on the next successful unlock. Biometric unlock is delegated to
/// the platform via `local_auth`.
class AppLockService {
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _versionPrefix = 'v2:';
  static const _kdfIterations = 100000;
  static const _saltBytes = 16;

  // Legacy single-iteration scheme, kept only to migrate stored digests.
  static const _legacySalt = 'vittix-app-lock';

  final SecureKeyValueStore _storage;
  final LocalAuthentication _biometrics;
  final Random _random;

  AppLockService(
    this._storage, {
    LocalAuthentication? biometrics,
    Random? random,
  }) : _biometrics = biometrics ?? LocalAuthentication(),
       _random = random ?? Random.secure();

  static String _legacyHashPin(String pin) =>
      sha256.convert(utf8.encode('$_legacySalt:$pin')).toString();

  /// The legacy digest for [pin], exposed so migration tests can seed a
  /// pre-upgrade store.
  @visibleForTesting
  static String legacyHashForTest(String pin) => _legacyHashPin(pin);

  String _encodePin(String pin, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _kdfIterations, 32));
    final key = derivator.process(Uint8List.fromList(utf8.encode(pin)));
    return '$_versionPrefix${base64Encode(salt)}:${base64Encode(key)}';
  }

  Uint8List _newSalt() => Uint8List.fromList(
    List<int>.generate(_saltBytes, (_) => _random.nextInt(256)),
  );

  Future<bool> hasPin() async => (await _storage.read(_pinHashKey)) != null;

  Future<void> setPin(String pin) =>
      _storage.write(_pinHashKey, _encodePin(pin, _newSalt()));

  Future<void> clearPin() => _storage.delete(_pinHashKey);

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(_pinHashKey);
    if (stored == null) return false;

    if (stored.startsWith(_versionPrefix)) {
      final parts = stored.substring(_versionPrefix.length).split(':');
      if (parts.length != 2) return false;
      try {
        final salt = base64Decode(parts[0]);
        return _constantTimeEquals(_encodePin(pin, salt), stored);
      } on FormatException {
        return false;
      }
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
