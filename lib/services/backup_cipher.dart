import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

/// Passphrase-based encryption for backup payloads.
///
/// The key is derived from the passphrase with PBKDF2-HMAC-SHA256 (random salt,
/// 100k iterations) and the payload is sealed with AES-256-GCM, so a wrong
/// passphrase or a tampered file fails to decrypt instead of silently restoring
/// garbage. The envelope is self-describing, so a restore can tell an encrypted
/// backup from a plaintext one.
class BackupCipher {
  static const _marker = 'vittixEncrypted';
  static const _version = 1;
  static const _kdfIterations = 100000;
  static const _keyBytes = 32;
  static const _nonceBytes = 12;

  static bool isEncrypted(String payload) {
    try {
      final decoded = jsonDecode(payload);
      return decoded is Map && decoded[_marker] == true;
    } catch (_) {
      return false;
    }
  }

  /// Returns a JSON envelope containing the encrypted [plaintext].
  static String encrypt(String plaintext, String passphrase) {
    final salt = _randomBytes(16);
    final nonce = _randomBytes(_nonceBytes);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        true,
        AEADParameters(
          KeyParameter(_deriveKey(passphrase, salt)),
          128,
          nonce,
          Uint8List(0),
        ),
      );
    final sealed = cipher.process(Uint8List.fromList(utf8.encode(plaintext)));

    return jsonEncode({
      _marker: true,
      'version': _version,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'payload': base64Encode(sealed),
    });
  }

  /// Decrypts an envelope produced by [encrypt].
  ///
  /// Throws [FormatException] when the payload is not an encrypted backup, the
  /// passphrase is wrong, or the data has been tampered with.
  static String decrypt(String envelope, String passphrase) {
    final dynamic decoded;
    try {
      decoded = jsonDecode(envelope);
    } catch (_) {
      throw const FormatException('Not an encrypted backup');
    }
    if (decoded is! Map || decoded[_marker] != true) {
      throw const FormatException('Not an encrypted backup');
    }

    final salt = base64Decode(decoded['salt'] as String);
    final nonce = base64Decode(decoded['nonce'] as String);
    final payload = base64Decode(decoded['payload'] as String);

    final cipher = GCMBlockCipher(AESEngine())
      ..init(
        false,
        AEADParameters(
          KeyParameter(_deriveKey(passphrase, salt)),
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

  static Uint8List _deriveKey(String passphrase, Uint8List salt) {
    final derivator = PBKDF2KeyDerivator(HMac(SHA256Digest(), 64))
      ..init(Pbkdf2Parameters(salt, _kdfIterations, _keyBytes));
    return derivator.process(Uint8List.fromList(utf8.encode(passphrase)));
  }

  static Uint8List _randomBytes(int length) {
    final random = Random.secure();
    return Uint8List.fromList(
      List<int>.generate(length, (_) => random.nextInt(256)),
    );
  }
}
