import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/quote_service.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final quoteListProvider = StreamProvider.autoDispose<List<Quote>>((ref) {
  final dao = ref.watch(quoteDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return Stream.value(const []);
  return dao.watchQuotesForBusiness(activeBusinessId);
});

final quoteDetailProvider = StreamProvider.autoDispose.family<Quote?, int>(
  (ref, quoteId) => ref.watch(quoteDaoProvider).watchQuoteById(quoteId),
);

final quoteProvider = Provider<QuoteService>((ref) {
  return ref.watch(quoteServiceProvider);
});

/// Search/status/expiry filter for the quote list, memoized per filter instance.
class QuoteListFilter {
  final String query;
  final String statusFilter;
  final bool expiringSoonOnly;
  final bool expiredOnly;

  const QuoteListFilter({
    this.query = '',
    this.statusFilter = 'ALL',
    this.expiringSoonOnly = false,
    this.expiredOnly = false,
  });

  @override
  bool operator ==(Object other) =>
      other is QuoteListFilter &&
      other.query == query &&
      other.statusFilter == statusFilter &&
      other.expiringSoonOnly == expiringSoonOnly &&
      other.expiredOnly == expiredOnly;

  @override
  int get hashCode => Object.hash(query, statusFilter, expiringSoonOnly, expiredOnly);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool isQuoteExpiringSoon(Quote quote, {DateTime? now}) {
  if (quote.dueDate == null || quote.status == 'CONVERTED') return false;
  final reference = now ?? DateTime.now();
  final validUntil = _dateOnly(quote.dueDate!);
  final daysRemaining = validUntil.difference(_dateOnly(reference)).inDays;
  return daysRemaining >= 0 && daysRemaining <= 7;
}

bool isQuoteExpired(Quote quote, {DateTime? now}) {
  if (quote.dueDate == null || quote.status == 'CONVERTED') return false;
  final reference = now ?? DateTime.now();
  return _dateOnly(quote.dueDate!).isBefore(_dateOnly(reference));
}

List<Quote> applyQuoteListFilter(List<Quote> quotes, QuoteListFilter filter, {DateTime? now}) {
  return quotes.where((quote) {
    final matchesQuery =
        filter.query.isEmpty ||
        quote.invoiceNumber.toLowerCase().contains(filter.query) ||
        quote.status.toLowerCase().contains(filter.query);
    final matchesStatus =
        filter.statusFilter == 'ALL' || quote.status == filter.statusFilter;
    final matchesExpiringSoon =
        !filter.expiringSoonOnly || isQuoteExpiringSoon(quote, now: now);
    final matchesExpired = !filter.expiredOnly || isQuoteExpired(quote, now: now);
    return matchesQuery && matchesStatus && matchesExpiringSoon && matchesExpired;
  }).toList();
}

final filteredQuoteListProvider =
    StreamProvider.autoDispose.family<List<Quote>, QuoteListFilter>(
      (ref, filter) async* {
        final quotes = await ref.watch(quoteListProvider.future);
        yield applyQuoteListFilter(quotes, filter);
      },
    );
