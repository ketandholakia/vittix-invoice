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

DateTime _addMonths(DateTime date, int months) {
  final targetMonth = date.month + months;
  final year = date.year + ((targetMonth - 1) ~/ 12);
  final month = ((targetMonth - 1) % 12) + 1;
  final lastDayOfMonth = DateTime(year, month + 1, 0).day;
  final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
  return DateTime(year, month, day);
}
