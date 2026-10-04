import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../providers/reminder_provider.dart';
import 'reminder_scheduling.dart';

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

    final details = const NotificationDetails(
      android: AndroidNotificationDetails(
        'reminder_notifications',
        'Reminder Notifications',
        channelDescription: 'Invoice due and quote expiry reminders',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
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

  tz.TZDateTime _scheduledAt(DateTime date, int offsetDays) =>
      scheduledReminderAt(date, offsetDays);

  int _notificationId(String kind, int entityId, int offsetDays) =>
      notificationIdFor(
        isQuote: kind == 'quote',
        entityId: entityId,
        offsetDays: offsetDays,
      );

  String _invoiceTitle(InvoiceReminderItem item) => invoiceReminderTitle(
    overdue: item.isOverdue,
    invoiceNumber: item.invoice.invoiceNumber,
  );

  String _invoiceBody(InvoiceReminderItem item) => invoiceReminderBody(
    customerName: item.customer!.name,
    balanceDue: item.balanceDue,
    currencyCode: item.invoice.currencyCode,
    invoiceNumber: item.invoice.invoiceNumber,
  );

  String _quoteTitle(QuoteReminderItem item) => quoteReminderTitle(
    expired: item.isExpired,
    quoteNumber: item.quote.invoiceNumber,
  );

  String _quoteBody(QuoteReminderItem item) => quoteReminderBody(
    customerName: item.customer!.name,
    totalAmount: item.quote.totalAmount,
    currencyCode: item.quote.currencyCode,
    quoteNumber: item.quote.invoiceNumber,
  );
}
