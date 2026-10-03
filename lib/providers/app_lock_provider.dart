import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/storage/secure_key_value_store.dart';
import '../services/app_lock_service.dart';
import 'shared_preferences_provider.dart';

const _appLockEnabledKey = 'app_lock_enabled';
const _appLockFailedAttemptsKey = 'app_lock_failed_attempts';
const _appLockLockoutUntilKey = 'app_lock_lockout_until';

/// Wrong PINs allowed before the lockout kicks in.
const _maxFailedAttempts = 5;

/// Lockout after the 5th wrong attempt, doubling per extra attempt up to
/// [_lockoutCeiling].
const _baseLockout = Duration(seconds: 30);
const _lockoutCeiling = Duration(minutes: 15);

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
      // Disabling the lock also forgives any outstanding throttle state.
      await _prefs.remove(_appLockFailedAttemptsKey);
      await _prefs.remove(_appLockLockoutUntilKey);
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

  int get _failedAttempts => _prefs.getInt(_appLockFailedAttemptsKey) ?? 0;

  DateTime? get _lockoutUntil {
    final epochMs = _prefs.getInt(_appLockLockoutUntilKey);
    return epochMs == null ? null : DateTime.fromMillisecondsSinceEpoch(epochMs);
  }

  /// How much longer a wrong-attempt lockout blocks PIN entry, if any.
  ///
  /// Persisted, so force-killing the app does not reset an attacker's
  /// countdown.
  Duration get lockoutRemaining {
    final until = _lockoutUntil;
    if (until == null) return Duration.zero;
    final remaining = until.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Future<void> _resetThrottle() async {
    await _prefs.remove(_appLockFailedAttemptsKey);
    await _prefs.remove(_appLockLockoutUntilKey);
  }

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
  ///
  /// After too many wrong attempts the PIN is refused outright — even a
  /// correct one — until the lockout expires.
  Future<bool> unlock(String pin) async {
    if (lockoutRemaining > Duration.zero) return false;
    if (!await _service.verifyPin(pin)) {
      await _registerFailedAttempt();
      return false;
    }
    await _resetThrottle();
    state = false;
    return true;
  }

  Future<void> _registerFailedAttempt() async {
    final attempts = _failedAttempts + 1;
    await _prefs.setInt(_appLockFailedAttemptsKey, attempts);
    if (attempts >= _maxFailedAttempts) {
      // A wrong attempt past the threshold stacks a doubling penalty from
      // now; attempts during a running lockout never reach this (they are
      // refused before verification).
      var lockout = _baseLockout * (1 << (attempts - _maxFailedAttempts));
      if (lockout > _lockoutCeiling) lockout = _lockoutCeiling;
      await _prefs.setInt(
        _appLockLockoutUntilKey,
        DateTime.now().add(lockout).millisecondsSinceEpoch,
      );
    }
  }

  /// Unlocks after a successful platform biometric authentication. Callers must
  /// only invoke this once the biometric prompt has actually succeeded.
  void unlockWithBiometrics() {
    if (!_enabled) return;
    unawaited(_resetThrottle());
    state = false;
  }
}
