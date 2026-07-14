class InvoiceNumberGenerator {
  static const defaultInvoiceFormat = 'INV-{FY}-{SEQ4}';
  static const defaultQuoteFormat = 'QT-{FY}-{SEQ4}';

  static String financialYear(DateTime date) {
    return date.month >= 4
        ? '${date.year % 100}${(date.year + 1) % 100}'
        : '${(date.year - 1) % 100}${date.year % 100}';
  }

  static String normalizeFormat(String? format, {required String fallback}) {
    final trimmed = format?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }

  static String generateFromFormat(
    String format,
    int sequence,
    DateTime date,
  ) {
    final normalized = normalizeFormat(format, fallback: defaultInvoiceFormat);
    return normalized
        .replaceAll('{FY}', financialYear(date))
        .replaceAll('{YYYY}', date.year.toString())
        .replaceAll('{YY}', (date.year % 100).toString().padLeft(2, '0'))
        .replaceAll('{MM}', date.month.toString().padLeft(2, '0'))
        .replaceAll('{M}', date.month.toString())
        .replaceAll('{DD}', date.day.toString().padLeft(2, '0'))
        .replaceAll('{MON}', _monthShort(date.month))
        .replaceAll('{MONTH}', _monthLong(date.month))
        .replaceAll('{SEQ6}', sequence.toString().padLeft(6, '0'))
        .replaceAll('{SEQ5}', sequence.toString().padLeft(5, '0'))
        .replaceAll('{SEQ4}', sequence.toString().padLeft(4, '0'))
        .replaceAll('{SEQ3}', sequence.toString().padLeft(3, '0'))
        .replaceAll('{SEQ2}', sequence.toString().padLeft(2, '0'))
        .replaceAll('{SEQ}', sequence.toString());
  }

  static bool matchesFormat(
    String documentNumber,
    String format,
    DateTime date,
  ) {
    final regex = RegExp(_formatToRegex(format, date));
    return regex.hasMatch(documentNumber);
  }

  static int extractSequenceFromFormat(
    String documentNumber,
    String format,
    DateTime date,
  ) {
    final regex = RegExp(_formatToRegex(format, date));
    final match = regex.firstMatch(documentNumber);
    if (match == null) return 0;
    return int.tryParse(match.namedGroup('seq') ?? '') ?? 0;
  }

  static String samplePreview(String format, DateTime date) {
    return generateFromFormat(format, 1, date);
  }

  static String generate(String prefix, int lastNumber, DateTime date) {
    return generateFromFormat('$prefix-{FY}-{SEQ4}', lastNumber + 1, date);
  }

  static int extractSequence(String documentNumber) {
    final match = RegExp(r'(\d+)$').firstMatch(documentNumber);
    return int.tryParse(match?.group(1) ?? '') ?? 0;
  }

  static String _formatToRegex(String format, DateTime date) {
    final normalized = normalizeFormat(format, fallback: defaultInvoiceFormat);
    final escaped = RegExp.escape(normalized);
    return '^${escaped
        .replaceAll(r'\{FY\}', RegExp.escape(financialYear(date)))
        .replaceAll(r'\{YYYY\}', RegExp.escape(date.year.toString()))
        .replaceAll(
          r'\{YY\}',
          RegExp.escape((date.year % 100).toString().padLeft(2, '0')),
        )
        .replaceAll(
          r'\{MM\}',
          RegExp.escape(date.month.toString().padLeft(2, '0')),
        )
        .replaceAll(r'\{M\}', RegExp.escape(date.month.toString()))
        .replaceAll(
          r'\{DD\}',
          RegExp.escape(date.day.toString().padLeft(2, '0')),
        )
        .replaceAll(r'\{MON\}', RegExp.escape(_monthShort(date.month)))
        .replaceAll(r'\{MONTH\}', RegExp.escape(_monthLong(date.month)))
        .replaceAll(r'\{SEQ6\}', r'(?<seq>\d{6})')
        .replaceAll(r'\{SEQ5\}', r'(?<seq>\d{5})')
        .replaceAll(r'\{SEQ4\}', r'(?<seq>\d{4})')
        .replaceAll(r'\{SEQ3\}', r'(?<seq>\d{3})')
        .replaceAll(r'\{SEQ2\}', r'(?<seq>\d{2})')
        .replaceAll(r'\{SEQ\}', r'(?<seq>\d+)')}\$';
  }

  static String _monthShort(int month) {
    const values = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return values[month - 1];
  }

  static String _monthLong(int month) {
    const values = [
      'JANUARY',
      'FEBRUARY',
      'MARCH',
      'APRIL',
      'MAY',
      'JUNE',
      'JULY',
      'AUGUST',
      'SEPTEMBER',
      'OCTOBER',
      'NOVEMBER',
      'DECEMBER',
    ];
    return values[month - 1];
  }
}
