import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:vittix_invoice/services/reminder_scheduling.dart';

void main() {
  setUpAll(() {
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.UTC);
  });

  group('scheduledReminderAt', () {
    test('anchors every offset to 9:00 on the due date', () {
      final due = DateTime(2026, 6, 20, 15, 30);

      final onDay = scheduledReminderAt(due, 0);
      expect(onDay.year, 2026);
      expect(onDay.month, 6);
      expect(onDay.day, 20);
      expect(onDay.hour, 9);

      final threeBefore = scheduledReminderAt(due, -3);
      expect(threeBefore.day, 17);
      expect(threeBefore.hour, 9);

      final weekAfter = scheduledReminderAt(due, 7);
      expect(weekAfter.day, 27);
    });

    test('negative offsets cross month boundaries', () {
      final due = DateTime(2026, 7, 2);
      expect(scheduledReminderAt(due, -7), tz.TZDateTime(tz.local, 2026, 6, 25, 9));
    });
  });

  group('notificationIdFor', () {
    test('encodes kind, entity, and offset without collisions', () {
      final invoiceA = notificationIdFor(
        isQuote: false,
        entityId: 42,
        offsetDays: -3,
      );
      final invoiceB = notificationIdFor(
        isQuote: false,
        entityId: 42,
        offsetDays: -7,
      );
      final invoiceOtherEntity = notificationIdFor(
        isQuote: false,
        entityId: 43,
        offsetDays: -3,
      );
      final quote = notificationIdFor(
        isQuote: true,
        entityId: 42,
        offsetDays: -3,
      );

      expect(invoiceA, isNot(invoiceB));
      expect(invoiceA, isNot(invoiceOtherEntity));
      expect(invoiceA, isNot(quote));

      // Re-syncing the same reminder reuses the same id so the platform
      // replaces the pending schedule instead of stacking duplicates.
      expect(
        notificationIdFor(isQuote: false, entityId: 42, offsetDays: -3),
        invoiceA,
      );
    });

    test('stays collision-free across the app cadence range', () {
      // Default cadence is -7..3; ids must also stay unique over the whole
      // documented -50..49 envelope per entity.
      final ids = <int>{};
      for (var offset = -50; offset <= 49; offset++) {
        ids.add(
          notificationIdFor(isQuote: false, entityId: 7, offsetDays: offset),
        );
      }
      expect(ids, hasLength(100));

      final quoteIds = <int>{};
      for (var offset = -50; offset <= 49; offset++) {
        quoteIds.add(
          notificationIdFor(isQuote: true, entityId: 7, offsetDays: offset),
        );
      }
      // Quote ids never overlap invoice ids.
      expect(ids.intersection(quoteIds), isEmpty);
    });

    test('adjacent entities never collide either', () {
      final a = notificationIdFor(isQuote: false, entityId: 1, offsetDays: 49);
      final b = notificationIdFor(isQuote: false, entityId: 2, offsetDays: -50);
      expect(a, isNot(b));
    });
  });

  group('reminder copy', () {
    test('invoice title and body reflect overdue state and currency', () {
      expect(
        invoiceReminderTitle(overdue: true, invoiceNumber: 'INV-1'),
        'Invoice overdue: INV-1',
      );
      expect(
        invoiceReminderTitle(overdue: false, invoiceNumber: 'INV-1'),
        'Invoice due soon: INV-1',
      );
      expect(
        invoiceReminderBody(
          customerName: 'Mehta & Sons',
          balanceDue: 1200.5,
          currencyCode: 'INR',
          invoiceNumber: 'INV-1',
        ),
        contains('Mehta & Sons owes'),
      );
      expect(
        invoiceReminderBody(
          customerName: 'X',
          balanceDue: 1200.5,
          currencyCode: 'INR',
          invoiceNumber: 'INV-1',
        ),
        contains('for invoice INV-1.'),
      );
    });

    test('quote title and body reflect expiry state', () {
      expect(
        quoteReminderTitle(expired: true, quoteNumber: 'QT-9'),
        'Quote expired: QT-9',
      );
      expect(
        quoteReminderTitle(expired: false, quoteNumber: 'QT-9'),
        'Quote expiring soon: QT-9',
      );
      expect(
        quoteReminderBody(
          customerName: 'Mehta & Sons',
          totalAmount: 500,
          currencyCode: 'INR',
          quoteNumber: 'QT-9',
        ),
        startsWith('Mehta & Sons has quote QT-9 for'),
      );
    });
  });
}
