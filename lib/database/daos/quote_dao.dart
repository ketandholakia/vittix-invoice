import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/quotes.dart';
import '../tables/quote_items.dart';
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

  Future<List<Quote>> getQuotesForCustomer(int customerId) =>
      (select(quotes)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Future<Quote?> getQuoteById(int id) =>
      (select(quotes)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<QuoteItem>> getItemsForQuote(int quoteId) =>
      (select(quoteItems)..where((t) => t.quoteId.equals(quoteId))).get();

  Future<int> insertQuote(QuotesCompanion quote) => into(quotes).insert(quote);
  Future<int> insertQuoteItem(QuoteItemsCompanion item) =>
      into(quoteItems).insert(item);
  Future<int> deleteItemsForQuote(int quoteId) =>
      (delete(quoteItems)..where((t) => t.quoteId.equals(quoteId))).go();

  Future<int> nextSequenceForBusiness({
    required int businessId,
    required String format,
    required DateTime date,
  }) async {
    final existingNumbers =
        await (select(quotes)..where((t) => t.businessId.equals(businessId)))
            .map((row) => row.invoiceNumber)
            .get();

    var maxSequence = 0;
    for (final number in existingNumbers) {
      if (!InvoiceNumberGenerator.matchesFormat(number, format, date)) {
        continue;
      }
      final sequence = InvoiceNumberGenerator.extractSequenceFromFormat(
        number,
        format,
        date,
      );
      if (sequence > maxSequence) {
        maxSequence = sequence;
      }
    }

    return maxSequence + 1;
  }

  Future<bool> updateQuote(Quote quote) => update(quotes).replace(quote);
  Future<int> deleteQuote(int id) =>
      (delete(quotes)..where((t) => t.id.equals(id))).go();
}
