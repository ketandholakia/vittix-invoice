class InvoiceNumberGenerator {
  static const defaultInvoiceFormat = 'INV-{FY}-{SEQ4}';
  static const defaultQuoteFormat = 'QT-{FY}-{SEQ4}';
  static const defaultCreditNoteFormat = 'CN-{FY}-{SEQ4}';
  static const defaultDebitNoteFormat = 'DN-{FY}-{SEQ4}';
  static const defaultBillOfSupplyFormat = 'BOS-{FY}-{SEQ4}';

  static String financialYear(DateTime date) {
    final startYear = date.month >= 4 ? date.year : date.year - 1;
    return '${_twoDigit(startYear)}${_twoDigit(startYear + 1)}';
  }

  static String _twoDigit(int year) => (year % 100).toString().padLeft(2, '0');

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

  /// Month used by [validateFormat] for length sampling: September has the
  /// longest month name and the widest 2-digit day, so a format that passes
  /// here passes all year.
  static final _validationSampleDate = DateTime(2026, 9, 30);

  /// Sequence used by [validateFormat] for worst-case width sampling.
  static const _validationSampleSequence = 123456;

  /// GST Rule 46 caps invoice numbers at 16 characters.
  static const maxInvoiceNumberLength = 16;

  /// Validates a series format against the GST numbering rules. Returns null
  /// when the format is usable, or a human-readable reason it is not:
  ///
  /// - at least one sequence token (`{SEQ}`…`{SEQ6}`) is required,
  /// - at least one of `{FY}` / `{YYYY}` is required so the series never
  ///   repeats across financial years,
  /// - a 6-digit sample must fit within [maxInvoiceNumberLength],
  /// - only letters, digits, `-` and `/` may appear outside the tokens.
  ///
  /// A blank format is valid — it falls back to the built-in default.
  static String? validateFormat(String format) {
    final trimmed = format.trim();
    if (trimmed.isEmpty) return null;

    final tokenPattern = RegExp(
      r'\{(FY|YYYY|YY|MM|M|DD|MON|MONTH|SEQ6|SEQ5|SEQ4|SEQ3|SEQ2|SEQ)\}',
    );
    final tokens = tokenPattern.allMatches(trimmed).map((m) => m.group(0)!);

    if (!tokens.any((token) => token.startsWith('{SEQ'))) {
      return 'Format must include a sequence token like {SEQ4}.';
    }
    final hasYearAnchor = tokens.any(
      (token) => token == '{FY}' || token == '{YYYY}',
    );
    if (!hasYearAnchor) {
      return 'Format must include {FY} or {YYYY} so numbers do not repeat '
          'across financial years.';
    }

    final residual = trimmed.replaceAll(tokenPattern, '');
    if (RegExp(r'[^A-Za-z0-9/-]').hasMatch(residual)) {
      return 'Only letters, digits, hyphens and slashes may appear outside '
          'the tokens.';
    }

    final sample = generateFromFormat(
      trimmed,
      _validationSampleSequence,
      _validationSampleDate,
    );
    if (sample.length > maxInvoiceNumberLength) {
      return 'Generated numbers would be ${sample.length} characters — the '
          'maximum is $maxInvoiceNumberLength (GST Rule 46).';
    }
    return null;
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
