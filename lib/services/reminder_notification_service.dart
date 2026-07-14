import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/utils/money_formatter.dart';
import '../providers/reminder_provider.dart';

class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance =
      ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final zoneInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zoneInfo.identifier));

    const androidSettings = AndroidInitializationSettings('ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(settings: initSettings);
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestExactAlarmsPermission();
  }

  Future<void> syncReminders({
    required ReminderCenterData data,
    required List<int> offsets,
    required bool enabled,
  }) async {
    await initialize();
    await _plugin.cancelAll();

    if (!enabled || offsets.isEmpty || data.totalCount == 0) {
      return;
    }

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_notifications',
        'Reminder Notifications',
        channelDescription: 'Invoice due and quote expiry reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);

    for (final item in data.invoiceReminders) {
      final dueDate = item.invoice.dueDate;
      if (dueDate == null) continue;
      for (final offset in offsets) {
        final scheduledAt = _scheduledAt(dueDate, offset);
        if (!scheduledAt.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: _notificationId('invoice', item.invoice.id, offset),
          title: _invoiceTitle(item),
          body: _invoiceBody(item),
          scheduledDate: scheduledAt,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'invoice:${item.invoice.id}',
        );
      }
    }

    for (final item in data.quoteReminders) {
      final dueDate = item.quote.dueDate;
      if (dueDate == null) continue;
      for (final offset in offsets) {
        final scheduledAt = _scheduledAt(dueDate, offset);
        if (!scheduledAt.isAfter(now)) continue;
        await _plugin.zonedSchedule(
          id: _notificationId('quote', item.quote.id, offset),
          title: _quoteTitle(item),
          body: _quoteBody(item),
          scheduledDate: scheduledAt,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: 'quote:${item.quote.id}',
        );
      }
    }
  }

  tz.TZDateTime _scheduledAt(DateTime date, int offsetDays) {
    final base = tz.TZDateTime(tz.local, date.year, date.month, date.day, 9);
    return base.add(Duration(days: offsetDays));
  }

  int _notificationId(String kind, int entityId, int offsetDays) {
    final kindBase = kind == 'invoice' ? 1000000 : 2000000;
    return kindBase + entityId * 100 + (offsetDays + 50);
  }

  String _invoiceTitle(InvoiceReminderItem item) {
    return item.isOverdue
        ? 'Invoice overdue: ${item.invoice.invoiceNumber}'
        : 'Invoice due soon: ${item.invoice.invoiceNumber}';
  }

  String _invoiceBody(InvoiceReminderItem item) {
    final customer = item.customer!;
    return '${customer.name} owes ${formatMoney(item.balanceDue, currencyCode: item.invoice.currencyCode)} '
        'for invoice ${item.invoice.invoiceNumber}.';
  }

  String _quoteTitle(QuoteReminderItem item) {
    return item.isExpired
        ? 'Quote expired: ${item.quote.invoiceNumber}'
        : 'Quote expiring soon: ${item.quote.invoiceNumber}';
  }

  String _quoteBody(QuoteReminderItem item) {
    final customer = item.customer!;
    return '${customer.name} has quote ${item.quote.invoiceNumber} '
        'for ${formatMoney(item.quote.totalAmount, currencyCode: item.quote.currencyCode)}.';
  }
}
