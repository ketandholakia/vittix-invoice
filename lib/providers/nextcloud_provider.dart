import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/storage/secure_key_value_store.dart';
import 'shared_preferences_provider.dart';

// Re-exported so existing imports of this file keep resolving the shared
// secure-storage abstraction.
export '../core/storage/secure_key_value_store.dart';

class NextcloudConfig {
  final String serverUrl;
  final String username;
  final String password;

  const NextcloudConfig({
    required this.serverUrl,
    required this.username,
    required this.password,
  });

  NextcloudConfig copyWith({
    String? serverUrl,
    String? username,
    String? password,
  }) {
    return NextcloudConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }

  bool get isValid =>
      serverUrl.isNotEmpty && username.isNotEmpty && password.isNotEmpty;
}

class NextcloudConfigNotifier extends StateNotifier<NextcloudConfig> {
  final SharedPreferences _prefs;
  final SecureKeyValueStore _storage;

  static const _urlKey = 'nextcloud_url';
  static const _usernameKey = 'nextcloud_username';
  static const _passwordKey = 'nextcloud_password';

  Future<void> _pendingWrites = Future.value();

  NextcloudConfigNotifier(this._prefs, this._storage)
      : super(const NextcloudConfig(serverUrl: '', username: '', password: '')) {
    unawaited(_migrateAndLoad());
  }

  Future<void> _migrateAndLoad() async {
    // One-time migration: read the plaintext SharedPreferences copy (if any),
    // move it into secure storage, and clear the plaintext keys afterwards.
    final legacyUrl = _prefs.getString(_urlKey);
    final legacyUsername = _prefs.getString(_usernameKey);
    final legacyPassword = _prefs.getString(_passwordKey);
    final hasLegacy = (legacyUrl ?? legacyUsername ?? legacyPassword) != null;

    final storedUrl = await _storage.read(_urlKey);
    final storedUsername = await _storage.read(_usernameKey);
    final storedPassword = await _storage.read(_passwordKey);

    final url = storedUrl ?? legacyUrl ?? '';
    final username = storedUsername ?? legacyUsername ?? '';
    final password = storedPassword ?? legacyPassword ?? '';

    if (hasLegacy) {
      await _writeToStorage(url: url, username: username, password: password);
      await _prefs.remove(_urlKey);
      await _prefs.remove(_usernameKey);
      await _prefs.remove(_passwordKey);
    }

    state = NextcloudConfig(
      serverUrl: url,
      username: username,
      password: password,
    );
  }

  void updateConfig(NextcloudConfig config) {
    state = config;
    _enqueueWrite(() => _writeToStorage(
          url: config.serverUrl,
          username: config.username,
          password: config.password,
        ));
  }

  void clearConfig() {
    state = const NextcloudConfig(serverUrl: '', username: '', password: '');
    _enqueueWrite(() async {
      await _storage.delete(_urlKey);
      await _storage.delete(_usernameKey);
      await _storage.delete(_passwordKey);
    });
  }

  Future<void> _writeToStorage({
    required String url,
    required String username,
    required String password,
  }) async {
    await _storage.write(_urlKey, url);
    await _storage.write(_usernameKey, username);
    await _storage.write(_passwordKey, password);
  }

  void _enqueueWrite(Future<void> Function() write) {
    _pendingWrites = _pendingWrites.then((_) async {
      try {
        await write();
      } catch (_) {
        // Secure storage failures should not crash the UI; the config load
        // on next startup will re-read whichever keys persisted.
      }
    });
  }

  /// Exposed for tests: completes once the one-time migration and initial
  /// secure storage load have finished.
  @visibleForTesting
  Future<void> load() => _migrateAndLoad();

  /// Exposed for tests: completes once all queued secure storage writes have
  /// settled.
  @visibleForTesting
  Future<void> flush() => _pendingWrites;
}

final nextcloudConfigProvider =
    StateNotifierProvider<NextcloudConfigNotifier, NextcloudConfig>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final storage = ref.watch(secureKeyValueStoreProvider);
  return NextcloudConfigNotifier(prefs, storage);
});