import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:pointycastle/export.dart';

/// Passphrase-based encryption for backup payloads.
///
/// The key is derived from the passphrase with PBKDF2-HMAC-SHA256 (random
/// salt) and the payload is sealed with AES-256-GCM, so a wrong passphrase or
/// a tampered file fails to decrypt instead of silently restoring garbage.
///
/// New backups use 600,000 iterations and record the count in the envelope
/// (`kdfIterations`), so the parameter can be raised again later without
/// breaking old files: envelopes without the field decrypt with the original
/// 100,000 iterations. Both the key derivation and the AES work run in a
/// background isolate so a long passphrase cannot freeze the UI.
class BackupCipher {
  static const _marker = 'vittixEncrypted';
  static const _version = 2;
  static const _kdfIterations = 600000;
  static const _legacyKdfIterations = 100000;
  static const _keyBytes = 32;
  static const _nonceBytes = 12;

  /// A passphrase must resist offline brute force; anything shorter than 8
  /// characters is rejected outright.
  static const minimumPassphraseLength = 8;

  static bool isEncrypted(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map && decoded[_marker] == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns a JSON envelope containing the encrypted [plaintext].
  ///
  /// Throws [ArgumentError] when [passphrase] is shorter than
  /// [minimumPassphraseLength] characters.
  static Future<String> encrypt(
    String plaintext,
    String passphrase, {
    @visibleForTesting int? kdfIterations,
  }) async {
    _assertPassphrase(passphrase);
    final iterations = kdfIterations ?? _kdfIterations;
    return Isolate.run(() => encryptSync(plaintext, passphrase, iterations));
  }

  /// Decrypts an envelope produced by [encrypt].
  ///
  /// Throws [FormatException] when the payload is not an encrypted backup, the
  /// passphrase is wrong, or the data has been tampered with.
  static Future<String> decrypt(String envelope, String passphrase) async {
    return Isolate.run(() => decryptSync(envelope, passphrase));
  }

  static void _assertPassphrase(String passphrase) {
    if (passphrase.length < minimumPassphraseLength) {
      throw ArgumentError(
        'The backup passphrase must be at least $minimumPassphraseLength '
        'characters long.',
      );
    }
  }

  /// Synchronous sealing, kept for tests and isolate bodies. Production
  /// callers rely on the default iteration count.
  static String encryptSync(
    String plaintext,
    String passphrase, [
    int? iterations,
  ]) {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(_nonceBytes);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(
            deriveKeySync(passphrase, salt, iterations ?? _kdfIterations),
          ),
          128,
          nonce,
          Uint8List(0),
        ),
      );
    final sealed = cipher.process(Uint8List.fromList(utf8.encode(plaintext)));

    return jsonEncode({
      _marker: true,
      'version': _version,
      'kdfIterations': iterations ?? _kdfIterations,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'payload': base64Encode(sealed),
    });
  }

  /// Synchronous opening, kept for tests and isolate bodies. Envelopes
  /// without a `kdfIterations` field (the original format) decrypt with the
  /// legacy 100k iterations.
  static String decryptSync(String envelope, String passphrase) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(envelope);
    } catch (_) {
      throw const FormatException('Not an encrypted backup');
    }
    if (decoded is! Map || decoded[_marker] != true) {
      throw const FormatException('Not an encrypted backup');
    }

    final iterations = decoded['kdfIterations'] is int
        ? decoded['kdfIterations'] as int
        : _legacyKdfIterations;
    final salt = base64Decode(decoded['salt'] as String);
    final nonce = base64Decode(decoded['nonce'] as String);
    final payload = base64Decode(decoded['payload'] as String);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(deriveKeySync(passphrase, salt, iterations)),
          128,
          nonce,
          Uint8List(0),
        ),
      );

    try {
      return utf8.decode(cipher.process(payload));
    } catch (_) {
      throw const FormatException(
        'Wrong passphrase, or the backup is damaged',
      );
    }
  }

  /// Builds an envelope in the original (pre-iteration-count) format, used by
  /// migration tests to prove old backups still decrypt.
  @visibleForTesting
  static String legacyEnvelopeForTest(String plaintext, String passphrase) {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(_nonceBytes);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(deriveKeySync(passphrase, salt, _legacyKdfIterations)),
          128,
          nonce,
          Uint8List(0),
        ),
      );
    final sealed = cipher.process(Uint8List.fromList(utf8.encode(plaintext)));

    return jsonEncode({
      _marker: true,
      'version': 1,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'payload': base64Encode(sealed),
    });
  }

  static Uint8List deriveKeySync(
    String passphrase,
    Uint8List salt,
    int iterations,
  ) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, iterations, _keyBytes));
    return derivator.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
