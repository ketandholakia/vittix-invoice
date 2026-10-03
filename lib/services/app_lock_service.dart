import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import '../core/storage/secure_key_value_store.dart';

/// Stores and verifies the app-lock PIN in platform secure storage.
///
/// Only a salted SHA-256 digest is persisted, so the raw digits never hit disk
/// and a leaked store cannot reveal the PIN directly. Biometric unlock is
/// delegated to the platform via `local_auth`.
class AppLockService {
  static const _pinHashKey = 'app_lock_pin_hash';
  static const _salt = 'vittix-app-lock';

  final SecureKeyValueStore _storage;
  final LocalAuthentication _biometrics;

  AppLockService(this._storage, {LocalAuthentication? biometrics})
    : _biometrics = biometrics ?? LocalAuthentication();

  static String hashPin(String pin) =>
      sha256.convert(utf8.encode('$_salt:$pin')).toString();

  Future<bool> hasPin() async => (await _storage.read(_pinHashKey)) != null;

  Future<void> setPin(String pin) => _storage.write(_pinHashKey, hashPin(pin));

  Future<void> clearPin() => _storage.delete(_pinHashKey);

  Future<bool> verifyPin(String pin) async =>
      (await _storage.read(_pinHashKey)) == hashPin(pin);

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
