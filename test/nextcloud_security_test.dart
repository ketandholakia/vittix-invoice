import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/providers/nextcloud_provider.dart';
import 'package:vittix_invoice/services/nextcloud_service.dart';

class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

void main() {
  group('NextcloudConfigNotifier migration', () {
    test('migrates legacy plaintext credentials and clears the prefs keys',
        () async {
      SharedPreferences.setMockInitialValues({
        'nextcloud_url': 'https://cloud.example.com',
        'nextcloud_username': 'backup-user',
        'nextcloud_password': 'legacy-app-password',
      });
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();

      final notifier = NextcloudConfigNotifier(prefs, storage);
      await notifier.load();

      expect(notifier.state.serverUrl, 'https://cloud.example.com');
      expect(notifier.state.username, 'backup-user');
      expect(notifier.state.password, 'legacy-app-password');
      expect(storage.values['nextcloud_url'], 'https://cloud.example.com');
      expect(storage.values['nextcloud_username'], 'backup-user');
      expect(storage.values['nextcloud_password'], 'legacy-app-password');
      expect(prefs.getString('nextcloud_url'), isNull);
      expect(prefs.getString('nextcloud_username'), isNull);
      expect(prefs.getString('nextcloud_password'), isNull);
    });

    test('loads credentials from secure storage with no legacy keys', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore()
        ..values['nextcloud_url'] = 'https://nc.example.com'
        ..values['nextcloud_username'] = 'user'
        ..values['nextcloud_password'] = 'secret';

      final notifier = NextcloudConfigNotifier(prefs, storage);
      await notifier.load();

      expect(notifier.state.serverUrl, 'https://nc.example.com');
      expect(notifier.state.username, 'user');
      expect(notifier.state.password, 'secret');
      expect(prefs.getString('nextcloud_password'), isNull);
    });

    test('updateConfig persists to secure storage and never to prefs',
        () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();

      final notifier = NextcloudConfigNotifier(prefs, storage);
      await notifier.load();
      notifier.updateConfig(
        const NextcloudConfig(
          serverUrl: 'https://cloud.example.com',
          username: 'new-user',
          password: 'new-password',
        ),
      );
      await notifier.flush();

      expect(notifier.state.password, 'new-password');
      expect(storage.values['nextcloud_url'], 'https://cloud.example.com');
      expect(storage.values['nextcloud_username'], 'new-user');
      expect(storage.values['nextcloud_password'], 'new-password');
      expect(prefs.getString('nextcloud_password'), isNull);
    });

    test('clearConfig removes credentials from secure storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore()
        ..values['nextcloud_url'] = 'https://cloud.example.com'
        ..values['nextcloud_username'] = 'user'
        ..values['nextcloud_password'] = 'secret';

      final notifier = NextcloudConfigNotifier(prefs, storage);
      await notifier.load();
      notifier.clearConfig();
      await notifier.flush();

      expect(notifier.state.serverUrl, isEmpty);
      expect(notifier.state.username, isEmpty);
      expect(notifier.state.password, isEmpty);
      expect(storage.values, isEmpty);
    });
  });

  group('NextcloudService URL enforcement', () {
    test('accepts https URLs', () {
      expect(
        NextcloudService.validateServerUrl('https://cloud.example.com'),
        isNull,
      );
    });

    test('rejects plain http URLs with an actionable message', () {
      final error = NextcloudService.validateServerUrl('http://cloud.example.com');
      expect(error, isNotNull);
      expect(error, contains('https'));
    });

    test('rejects malformed URLs', () {
      expect(
        NextcloudService.validateServerUrl('ftp://cloud.example.com'),
        isNotNull,
      );
      expect(NextcloudService.validateServerUrl(''), isNotNull);
    });

    test('normalizes schemeless URLs to https', () {
      final url = NextcloudService.buildBaseUrl(
        const NextcloudConfig(
          serverUrl: 'cloud.example.com',
          username: 'user',
          password: 'pass',
        ),
      );
      expect(url, 'https://cloud.example.com/remote.php/webdav/');
    });

    test('throws a clear error for http URLs', () {
      expect(
        () => NextcloudService.buildBaseUrl(
          const NextcloudConfig(
            serverUrl: 'http://cloud.example.com',
            username: 'user',
            password: 'pass',
          ),
        ),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            contains('https'),
          ),
        ),
      );
    });
  });
}