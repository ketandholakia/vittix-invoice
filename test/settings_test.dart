
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
  group('ReminderSettings', () {
    test('uses notification defaults and persists cadence choices', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      addTearDown(container.dispose);

      expect(container.read(reminderNotificationsEnabledProvider), isTrue);
      expect(
        container.read(reminderNotificationOffsetsProvider),
        equals([-7, -3, -1, 0, 1, 3]),
      );

      container
          .read(reminderNotificationsEnabledProvider.notifier)
          .setEnabled(false);
      container.read(reminderNotificationOffsetsProvider.notifier).setOffsets([
        -3,
        0,
        2,
      ]);

      expect(
        sharedPreferences.getBool('reminder_notifications_enabled'),
        isFalse,
      );
      expect(
        sharedPreferences.getStringList('reminder_notification_offsets'),
        equals(['-3', '0', '2']),
      );
    });
  });
}
