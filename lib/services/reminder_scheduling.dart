import 'package:timezone/timezone.dart' as tz;

import '../core/utils/money_formatter.dart';

/// Pure scheduling math for reminder notifications.
///
/// Extracted from `ReminderNotificationService` so the cadence arithmetic and
/// notification id allocation are unit-testable without the notification
/// plugin (which only works on a device).
///
/// Notification ids encode `kind + entityId + offset` so re-syncing the same
/// reminder replaces the previous schedule instead of stacking a duplicate.
/// The offset is shifted by [offsetIdShift], keeping ids collision-free for
/// cadence offsets in -50..49 days (the app default is -7..3).
const int _invoiceIdBase = 1000000;
const int _quoteIdBase = 2000000;
const int offsetIdShift = 50;
const int _offsetIdStride = 100;

/// The 9:00 reminder moment for a due date shifted by [offsetDays] (negative
/// offsets land before the due date).
tz.TZDateTime scheduledReminderAt(DateTime dueDate, int offsetDays) {
  final base = tz.TZDateTime(tz.local, dueDate.year, dueDate.month, dueDate.day, 9);
  return base.add(Duration(days: offsetDays));
}

int notificationIdFor({
  required bool isQuote,
  required int entityId,
  required int offsetDays,
}) {
  final kindBase = isQuote ? _quoteIdBase : _invoiceIdBase;
  return kindBase + entityId * _offsetIdStride + (offsetDays + offsetIdShift);
}

String invoiceReminderTitle({
  required bool overdue,
  required String invoiceNumber,
}) => overdue
    ? 'Invoice overdue: $invoiceNumber'
    : 'Invoice due soon: $invoiceNumber';

String invoiceReminderBody({
  required String customerName,
  required double balanceDue,
  required String currencyCode,
  required String invoiceNumber,
}) =>
    '$customerName owes ${formatMoney(balanceDue, currencyCode: currencyCode)} '
    'for invoice $invoiceNumber.';

String quoteReminderTitle({
  required bool expired,
  required String quoteNumber,
}) => expired ? 'Quote expired: $quoteNumber' : 'Quote expiring soon: $quoteNumber';

String quoteReminderBody({
  required String customerName,
  required double totalAmount,
  required String currencyCode,
  required String quoteNumber,
}) =>
    '$customerName has quote $quoteNumber '
    'for ${formatMoney(totalAmount, currencyCode: currencyCode)}.';
