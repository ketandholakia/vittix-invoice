import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/secure_key_value_store.dart';
import '../services/app_lock_service.dart';
import 'shared_preferences_provider.dart';

const _appLockEnabledKey = 'app_lock_enabled';

final appLockServiceProvider = Provider<AppLockService>(
  (ref) => AppLockService(ref.watch(secureKeyValueStoreProvider)),
);

/// Whether the user has turned the app lock on.
final appLockEnabledProvider =
    StateNotifierProvider<AppLockEnabledNotifier, bool>((ref) {
  return AppLockEnabledNotifier(ref.watch(sharedPreferencesProvider));
});

class AppLockEnabledNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;

  AppLockEnabledNotifier(this._prefs)
      : super(_prefs.getBool(_appLockEnabledKey) == true);

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    if (enabled) {
      await _prefs.setBool(_appLockEnabledKey, true);
    } else {
      await _prefs.remove(_appLockEnabledKey);
    }
  }
}

/// Whether the UI is currently locked.
///
/// Fails closed: when the lock is enabled the app starts locked until the
/// correct PIN is entered.
final appLockedProvider = StateNotifierProvider<AppLockController, bool>((ref) {
  return AppLockController(
    ref.watch(sharedPreferencesProvider),
    ref.watch(appLockServiceProvider),
  );
});

class AppLockController extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  final AppLockService _service;

  AppLockController(this._prefs, this._service)
      : super(_prefs.getBool(_appLockEnabledKey) == true) {
    unawaited(_resolveInitialState());
  }

  bool get _enabled => _prefs.getBool(_appLockEnabledKey) == true;

  /// If the lock is not enabled (or has no PIN yet) start unlocked.
  Future<void> _resolveInitialState() async {
    if (!_enabled) {
      state = false;
      return;
    }
    state = await _service.hasPin();
  }

  /// Locks the app when it goes to the background. No-op when the lock is off.
  void lock() {
    if (_enabled) state = true;
  }

  /// Unlocks when [pin] matches. Returns whether it succeeded.
  Future<bool> unlock(String pin) async {
    if (!await _service.verifyPin(pin)) return false;
    state = false;
    return true;
  }

  /// Unlocks after a successful platform biometric authentication. Callers must
  /// only invoke this once the biometric prompt has actually succeeded.
  void unlockWithBiometrics() {
    if (!_enabled) return;
    state = false;
  }
}
