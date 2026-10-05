import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/invoice_balance.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';
import '../services/invoice_service.dart';
import '../services/recurring_invoice_service.dart';

/// Load cap for the invoice list stream. The screen filters within this
/// window (search-driven narrowing); beyond it the newest 500 invoices are
/// the operating set for lists, dashboard and reminder center.
const invoiceListPageSize = 500;

final invoiceListProvider = StreamProvider.autoDispose<List<Invoice>>((ref) {
  final dao = ref.watch(invoiceDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return Stream.value(const []);
  return dao.watchInvoicesForBusiness(
    activeBusinessId,
    limit: invoiceListPageSize,
  );
});

final invoiceProvider = Provider<InvoiceService>((ref) {
  return ref.watch(invoiceServiceProvider);
});

final recurringInvoiceProvider = Provider<RecurringInvoiceService>((ref) {
  return RecurringInvoiceService(
    invoiceDao: ref.watch(invoiceDaoProvider),
    recurringDao: ref.watch(recurringInvoiceDaoProvider),
    invoiceService: ref.watch(invoiceProvider),
  );
});

/// The active recurring schedule for an invoice, if there is one.
final invoiceRecurrenceProvider =
    FutureProvider.family<RecurringInvoice?, int>((ref, invoiceId) {
      return ref.read(recurringInvoiceProvider).activeForSource(invoiceId);
    });

final invoicePaymentsProvider =
    StreamProvider.autoDispose.family<List<InvoicePayment>, int>(
      (ref, invoiceId) =>
          ref.watch(invoiceDaoProvider).watchPaymentsForInvoice(invoiceId),
    );

final invoiceDetailProvider =
    StreamProvider.autoDispose.family<Invoice?, int>(
      (ref, invoiceId) =>
          ref.watch(invoiceDaoProvider).watchInvoiceById(invoiceId),
    );

final invoiceItemsProvider =
    StreamProvider.autoDispose.family<List<InvoiceItem>, int>(
      (ref, invoiceId) =>
          ref.watch(invoiceDaoProvider).watchItemsForInvoice(invoiceId),
    );

/// Search/status filter for the invoice list, memoized per filter instance.
class InvoiceListFilter {
  final String query;
  final String statusFilter;
  final bool overdueOnly;

  const InvoiceListFilter({
    this.query = '',
    this.statusFilter = 'ALL',
    this.overdueOnly = false,
  });

  @override
  bool operator ==(Object other) =>
      other is InvoiceListFilter &&
      other.query == query &&
      other.statusFilter == statusFilter &&
      other.overdueOnly == overdueOnly;

  @override
  int get hashCode => Object.hash(query, statusFilter, overdueOnly);
}

List<Invoice> applyInvoiceListFilter(List<Invoice> invoices, InvoiceListFilter filter) {
  return invoices.where((invoice) {
    final matchesQuery =
        filter.query.isEmpty ||
        invoice.invoiceNumber.toLowerCase().contains(filter.query) ||
        invoice.status.toLowerCase().contains(filter.query);
    final matchesStatus =
        filter.statusFilter == 'ALL' || invoice.status == filter.statusFilter;
    final isOverdue =
        invoice.dueDate != null &&
        invoiceBalanceDue(invoice) > 0 &&
        invoice.dueDate!.isBefore(DateTime.now());
    final matchesOverdue = !filter.overdueOnly || isOverdue;
    return matchesQuery && matchesStatus && matchesOverdue;
  }).toList();
}

final filteredInvoiceListProvider =
    StreamProvider.autoDispose.family<List<Invoice>, InvoiceListFilter>(
      (ref, filter) async* {
        final invoices = await ref.watch(invoiceListProvider.future);
        yield applyInvoiceListFilter(invoices, filter);
      },
    );
