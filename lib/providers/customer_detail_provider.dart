import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final customerDetailProvider =
    FutureProvider.family<Customer?, int>((ref, customerId) async {
  return ref.watch(customerDaoProvider).getCustomerById(customerId);
});

final customerInvoicesProvider =
    FutureProvider.family<List<Invoice>, int>((ref, customerId) async {
  return ref.watch(invoiceDaoProvider).getInvoicesForCustomer(customerId);
});

final customerQuotesProvider =
    FutureProvider.family<List<Quote>, int>((ref, customerId) async {
  return ref.watch(quoteDaoProvider).getQuotesForCustomer(customerId);
});

final customerInvoicePaymentsProvider =
    FutureProvider.family<List<InvoicePayment>, int>((ref, customerId) async {
  final invoices = await ref.watch(customerInvoicesProvider(customerId).future);
  final invoiceIds = invoices.map((invoice) => invoice.id).toList();
  return ref.watch(invoiceDaoProvider).getPaymentsForInvoices(invoiceIds);
});
