import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/storage/secure_key_value_store.dart';
import 'package:vittix_invoice/features/lock/lock_screen.dart';
import 'package:vittix_invoice/providers/app_lock_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';
import 'package:vittix_invoice/services/app_lock_service.dart';

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
  group('AppLockService', () {
    test('stores only a hashed PIN and verifies it', () async {
      final storage = FakeSecureKeyValueStore();
      final service = AppLockService(storage);

      expect(await service.hasPin(), isFalse);

      await service.setPin('1234');

      expect(await service.hasPin(), isTrue);
      expect(storage.values.values, isNot(contains('1234')));
      expect(await service.verifyPin('1234'), isTrue);
      expect(await service.verifyPin('4321'), isFalse);

      await service.clearPin();
      expect(await service.hasPin(), isFalse);
    });

    test('stretches the PIN with a random per-install salt', () async {
      final storage = FakeSecureKeyValueStore();
      final service = AppLockService(storage);

      await service.setPin('1234');
      final first = storage.values.values.single;
      expect(first.startsWith('v2:'), isTrue);
      expect(first, isNot(contains('1234')));

      // A re-set of the same PIN must not reproduce the same digest.
      await service.setPin('1234');
      expect(storage.values.values.single, isNot(first));
      expect(await service.verifyPin('1234'), isTrue);
    });

    test('verifies and upgrades a legacy single-SHA-256 digest', () async {
      final storage = FakeSecureKeyValueStore();
      final legacy = AppLockService.legacyHashForTest('1234');
      await storage.write('app_lock_pin_hash', legacy);
      final service = AppLockService(storage);

      expect(await service.verifyPin('4321'), isFalse);
      expect(storage.values.values.single, legacy, reason: 'no upgrade on a wrong PIN');

      expect(await service.verifyPin('1234'), isTrue);
      final upgraded = storage.values.values.single;
      expect(upgraded.startsWith('v2:'), isTrue,
          reason: 'legacy digest is replaced after a successful unlock');
      expect(await service.verifyPin('1234'), isTrue);
      expect(await service.verifyPin('4321'), isFalse);
    });
  });

  group('AppLockController', () {
    test('starts locked when enabled and unlocks with the right PIN', () async {
      SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();
      await AppLockService(storage).setPin('2468');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureKeyValueStoreProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(appLockedProvider), isTrue);

      final controller = container.read(appLockedProvider.notifier);
      expect(await controller.unlock('0000'), isFalse);
      expect(container.read(appLockedProvider), isTrue);

      expect(await controller.unlock('2468'), isTrue);
      expect(container.read(appLockedProvider), isFalse);

      controller.lock();
      expect(container.read(appLockedProvider), isTrue);
    });

    test('stays unlocked when the lock is not enabled', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureKeyValueStoreProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(appLockedProvider), isFalse);

      container.read(appLockedProvider.notifier).lock();
      expect(container.read(appLockedProvider), isFalse);
    });

    test('locks out after too many wrong attempts, even with the right PIN',
        () async {
      SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();
      await AppLockService(storage).setPin('2468');

      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          secureKeyValueStoreProvider.overrideWithValue(storage),
        ],
      );
      addTearDown(container.dispose);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final controller = container.read(appLockedProvider.notifier);
      for (var i = 0; i < 5; i++) {
        expect(await controller.unlock('0000'), isFalse);
      }

      expect(controller.lockoutRemaining, greaterThan(Duration.zero));
      // The correct PIN is refused while the lockout runs.
      expect(await controller.unlock('2468'), isFalse);
      expect(container.read(appLockedProvider), isTrue);

      // Once the lockout has expired (simulated by backdating the deadline),
      // the correct PIN unlocks and clears the throttle counters.
      await prefs.setInt('app_lock_lockout_until',
          DateTime.now().subtract(const Duration(seconds: 1)).millisecondsSinceEpoch);
      expect(controller.lockoutRemaining, Duration.zero);
      expect(await controller.unlock('2468'), isTrue);
      expect(container.read(appLockedProvider), isFalse);
      expect(prefs.getInt('app_lock_failed_attempts'), isNull);
    });
  });

  group('LockScreen', () {
    testWidgets('rejects a wrong PIN and hides once unlocked', (tester) async {
      SharedPreferences.setMockInitialValues({'app_lock_enabled': true});
      final prefs = await SharedPreferences.getInstance();
      final storage = FakeSecureKeyValueStore();
      await AppLockService(storage).setPin('1234');

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
            secureKeyValueStoreProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(home: LockScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Enter your PIN'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text('Incorrect PIN'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();
      expect(find.text('Enter your PIN'), findsNothing);
    });
  });
}
