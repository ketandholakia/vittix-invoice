import 'package:drift/drift.dart';

import '../core/utils/invoice_number.dart';

/// O(1) allocation of document numbers via the `document_sequences` table.
///
/// All calls are expected to happen inside a caller-owned transaction so
/// that the counter bump and the document insert commit atomically.
class DocumentSequenceAllocator {
  static const invoiceDocType = 'INV';
  static const quoteDocType = 'QT';

  final DatabaseConnectionUser db;

  DocumentSequenceAllocator(this.db);

  Future<int> allocateNext({
    required int businessId,
    required String docType,
    required String format,
    required DateTime date,
  }) async {
    final fiscalYear = InvoiceNumberGenerator.financialYear(date);
    await db.customStatement(
      'INSERT OR IGNORE INTO document_sequences '
      '(business_id, doc_type, fiscal_year, format, sequence) '
      'VALUES (?, ?, ?, ?, 0)',
      [businessId, docType, fiscalYear, format],
    );
    await db.customStatement(
      'UPDATE document_sequences SET sequence = sequence + 1 '
      'WHERE business_id = ? AND doc_type = ? AND fiscal_year = ? '
      'AND format = ?',
      [businessId, docType, fiscalYear, format],
    );
    final result = await db
        .customSelect(
          'SELECT sequence FROM document_sequences '
          'WHERE business_id = ? AND doc_type = ? AND fiscal_year = ? '
          'AND format = ?',
          variables: [
            Variable(businessId),
            Variable(docType),
            Variable(fiscalYear),
            Variable(format),
          ],
        )
        .getSingle();
    return result.read<int>('sequence');
  }

  /// Sets the counter to a known value (used after a legacy-collision resync
  /// and by the v19 backfill).
  Future<void> setSequence({
    required int businessId,
    required String docType,
    required String format,
    required DateTime date,
    required int sequence,
  }) async {
    final fiscalYear = InvoiceNumberGenerator.financialYear(date);
    await db.customStatement(
      'INSERT OR IGNORE INTO document_sequences '
      '(business_id, doc_type, fiscal_year, format, sequence) '
      'VALUES (?, ?, ?, ?, ?)',
      [businessId, docType, fiscalYear, format, sequence],
    );
    await db.customStatement(
      'UPDATE document_sequences SET sequence = ? '
      'WHERE business_id = ? AND doc_type = ? AND fiscal_year = ? '
      'AND format = ?',
      [sequence, businessId, docType, fiscalYear, format],
    );
  }
}

/// Computes the legacy scan result (max sequence per fiscal year) for a set
/// of documents under a single format. Shared by the v19 migration backfill
/// and the DAO-level collision resync so both stay in lock-step.
class DocumentSequenceBackfill {
  static const _keySeparator = '\u0001';

  static String keyFor(String fiscalYear, String format) =>
      '$fiscalYear$_keySeparator$format';

  static String fiscalYearFromKey(String key) {
    final separator = key.indexOf(_keySeparator);
    if (separator < 0) return key;
    return key.substring(0, separator);
  }

  static String formatFromKey(String key) {
    final separator = key.indexOf(_keySeparator);
    if (separator < 0) return key;
    return key.substring(separator + 1);
  }

  /// Returns `fiscalYear -> format -> max sequence` in a single map keyed by
  /// [keyFor]. Mirrors `InvoiceNumberGenerator.matchesFormat` semantics:
  /// only documents matching the format for their own date are counted.
  static Map<String, int> computeMaxSequences({
    required String format,
    required List<({String invoiceNumber, DateTime invoiceDate})> documents,
  }) {
    final maxByKey = <String, int>{};
    for (final document in documents) {
      if (!InvoiceNumberGenerator.matchesFormat(
        document.invoiceNumber,
        format,
        document.invoiceDate,
      )) {
        continue;
      }
      final sequence = InvoiceNumberGenerator.extractSequenceFromFormat(
        document.invoiceNumber,
        format,
        document.invoiceDate,
      );
      final fiscalYear = InvoiceNumberGenerator.financialYear(
        document.invoiceDate,
      );
      final key = keyFor(fiscalYear, format);
      final current = maxByKey[key] ?? 0;
      if (sequence > current) {
        maxByKey[key] = sequence;
      }
    }
    return maxByKey;
  }
}
