import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import '../app_database.dart';
import '../tables/quotes.dart';
import '../tables/quote_items.dart';
import '../document_sequence_allocator.dart';
import '../../core/utils/invoice_number.dart';

part 'quote_dao.g.dart';

@DriftAccessor(tables: [Quotes, QuoteItems])
class QuoteDao extends DatabaseAccessor<AppDatabase> with _$QuoteDaoMixin {
  QuoteDao(super.db);

  Future<List<Quote>> getQuotesForBusiness(int businessId) =>
      (select(quotes)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Stream<List<Quote>> watchQuotesForBusiness(int businessId) =>
      (select(quotes)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .watch();

  Future<List<Quote>> getQuotesForCustomer(int customerId) =>
      (select(quotes)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Stream<List<Quote>> watchQuotesForCustomer(int customerId) =>
      (select(quotes)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .watch();

  Future<Quote?> getQuoteById(int id) =>
      (select(quotes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Quote?> watchQuoteById(int id) =>
      (select(quotes)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<QuoteItem>> getItemsForQuote(int quoteId) =>
      (select(quoteItems)..where((t) => t.quoteId.equals(quoteId))).get();

  Stream<List<QuoteItem>> watchItemsForQuote(int quoteId) =>
      (select(quoteItems)..where((t) => t.quoteId.equals(quoteId))).watch();

  Future<int> insertQuote(QuotesCompanion quote) => into(quotes).insert(quote);

  /// Allocates the next sequence from the per-business counter and inserts
  /// the quote with a generated number in one atomic unit. Callers must run
  /// this inside a transaction. Handles collisions with legacy numbers the
  /// same way as [InvoiceDao.insertInvoiceWithGeneratedNumber].
  Future<int> insertQuoteWithGeneratedNumber({
    required QuotesCompanion quote,
    required String format,
    required DateTime date,
  }) async {
    final businessId = quote.businessId.value;
    final allocator = DocumentSequenceAllocator(db);
    var sequence = await allocator.allocateNext(
      businessId: businessId,
      docType: DocumentSequenceAllocator.quoteDocType,
      format: format,
      date: date,
    );
    try {
      return await into(quotes).insert(
        quote.copyWith(
          invoiceNumber: Value(
            InvoiceNumberGenerator.generateFromFormat(format, sequence, date),
          ),
        ),
      );
    } on SqliteException {
      final maxSequence = await _scanMaxSequence(
        businessId: businessId,
        format: format,
        date: date,
      );
      await allocator.setSequence(
        businessId: businessId,
        docType: DocumentSequenceAllocator.quoteDocType,
        format: format,
        date: date,
        sequence: maxSequence,
      );
      return into(quotes).insert(
        quote.copyWith(
          invoiceNumber: Value(
            InvoiceNumberGenerator.generateFromFormat(
              format,
              maxSequence + 1,
              date,
            ),
          ),
        ),
      );
    }
  }

  Future<int> insertQuoteItem(QuoteItemsCompanion item) =>
      into(quoteItems).insert(item);
  Future<int> deleteItemsForQuote(int quoteId) =>
      (delete(quoteItems)..where((t) => t.quoteId.equals(quoteId))).go();

  Future<int> _scanMaxSequence({
    required int businessId,
    required String format,
    required DateTime date,
  }) async {
    final existingNumbers = await (select(quotes)
          ..where((t) => t.businessId.equals(businessId)))
        .map((row) => (
              invoiceNumber: row.invoiceNumber,
              invoiceDate: row.invoiceDate,
            ))
        .get();

    final maxByKey = DocumentSequenceBackfill.computeMaxSequences(
      format: format,
      documents: existingNumbers,
    );
    final fiscalYear = InvoiceNumberGenerator.financialYear(date);
    return maxByKey[DocumentSequenceBackfill.keyFor(fiscalYear, format)] ?? 0;
  }

  Future<bool> updateQuote(Quote quote) => update(quotes).replace(quote);
  Future<int> deleteQuote(int id) =>
      (delete(quotes)..where((t) => t.id.equals(id))).go();
}
