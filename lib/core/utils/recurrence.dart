/// Supported recurring-invoice frequencies.
enum RecurrenceFrequency { weekly, monthly, quarterly, yearly }

extension RecurrenceFrequencyCode on RecurrenceFrequency {
  /// Stored value (kept in the database).
  String get code => switch (this) {
    RecurrenceFrequency.weekly => 'WEEKLY',
    RecurrenceFrequency.monthly => 'MONTHLY',
    RecurrenceFrequency.quarterly => 'QUARTERLY',
    RecurrenceFrequency.yearly => 'YEARLY',
  };

  String get label => switch (this) {
    RecurrenceFrequency.weekly => 'Weekly',
    RecurrenceFrequency.monthly => 'Monthly',
    RecurrenceFrequency.quarterly => 'Quarterly',
    RecurrenceFrequency.yearly => 'Yearly',
  };

  static RecurrenceFrequency fromCode(String code) => switch (code) {
    'WEEKLY' => RecurrenceFrequency.weekly,
    'QUARTERLY' => RecurrenceFrequency.quarterly,
    'YEARLY' => RecurrenceFrequency.yearly,
    _ => RecurrenceFrequency.monthly,
  };
}

/// Maps a stored frequency code back to the enum (unknown codes → monthly).
RecurrenceFrequency recurrenceFrequencyFromCode(String code) =>
    RecurrenceFrequencyCode.fromCode(code);

/// Advances [date] by one [frequency] step.
///
/// Month-based steps clamp to the last valid day (31 Jan + 1 month = 28/29 Feb)
/// instead of rolling into the next month.
DateTime advanceByFrequency(DateTime date, String frequency) {
  switch (frequency) {
    case 'WEEKLY':
      return date.add(const Duration(days: 7));
    case 'QUARTERLY':
      return _addMonths(date, 3);
    case 'YEARLY':
      return _addMonths(date, 12);
    case 'MONTHLY':
    default:
      return _addMonths(date, 1);
  }
}

/// The next run date on or after [today] for a schedule sitting at [from],
/// stepping forward as many times as needed to catch up.
DateTime nextRunOnOrAfter(DateTime from, DateTime today, String frequency) {
  var next = from;
  // Bounded so a nonsense input can never spin forever.
  for (var i = 0; i < 600 && next.isBefore(today); i++) {
    next = advanceByFrequency(next, frequency);
  }
  return next;
}

/// Advances [date] by one [frequency] step while keeping the schedule's
/// [anchorDay] (day of month of the first run).
///
/// Month-based steps land on the anchor day clamped to the target month's
/// length, so a schedule anchored on the 31st clamps to 28/29 February but
/// recovers to the 31st in March instead of drifting to the 28th forever.
/// [anchorDay] of 0 (pre-migration rows and weekly schedules) falls back to
/// plain [advanceByFrequency].
DateTime advanceFromAnchor(DateTime date, String frequency, int anchorDay) {
  if (anchorDay <= 0 || anchorDay > 31) {
    return advanceByFrequency(date, frequency);
  }
  switch (frequency) {
    case 'WEEKLY':
      return date.add(const Duration(days: 7));
    case 'QUARTERLY':
      return _addMonthsOnAnchor(date, 3, anchorDay);
    case 'YEARLY':
      return _addMonthsOnAnchor(date, 12, anchorDay);
    case 'MONTHLY':
    default:
      return _addMonthsOnAnchor(date, 1, anchorDay);
  }
}

DateTime _addMonthsOnAnchor(DateTime date, int months, int anchorDay) {
  final targetMonth = date.month + months;
  final year = date.year + ((targetMonth - 1) ~/ 12);
  final month = ((targetMonth - 1) % 12) + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = anchorDay.clamp(1, lastDayOfMonth);
  return DateTime(year, month, day);
}

DateTime _addMonths(DateTime date, int months) {
  final targetMonth = date.month + months;
  final year = date.year + ((targetMonth - 1) ~/ 12);
  final month = ((targetMonth - 1) % 12) + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
  return DateTime(year, month, day);
}
