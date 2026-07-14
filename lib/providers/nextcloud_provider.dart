import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'shared_preferences_provider.dart';

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
  static const _urlKey = 'nextcloud_url';
  static const _usernameKey = 'nextcloud_username';
  static const _passwordKey = 'nextcloud_password';

  NextcloudConfigNotifier(this._prefs)
      : super(NextcloudConfig(
          serverUrl: _prefs.getString(_urlKey) ?? '',
          username: _prefs.getString(_usernameKey) ?? '',
          password: _prefs.getString(_passwordKey) ?? '',
        ));

  void updateConfig(NextcloudConfig config) {
    state = config;
    _prefs.setString(_urlKey, config.serverUrl);
    _prefs.setString(_usernameKey, config.username);
    _prefs.setString(_passwordKey, config.password);
  }

  void clearConfig() {
    state = const NextcloudConfig(serverUrl: '', username: '', password: '');
    _prefs.remove(_urlKey);
    _prefs.remove(_usernameKey);
    _prefs.remove(_passwordKey);
  }
}

final nextcloudConfigProvider =
    StateNotifierProvider<NextcloudConfigNotifier, NextcloudConfig>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return NextcloudConfigNotifier(prefs);
});
