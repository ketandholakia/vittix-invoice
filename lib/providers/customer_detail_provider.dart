import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final customerDetailProvider =
    StreamProvider.autoDispose.family<Customer?, int>(
      (ref, customerId) =>
          ref.watch(customerDaoProvider).watchCustomerById(customerId),
    );

final customerInvoicesProvider =
    StreamProvider.autoDispose.family<List<Invoice>, int>(
      (ref, customerId) =>
          ref.watch(invoiceDaoProvider).watchInvoicesForCustomer(customerId),
    );

final customerQuotesProvider =
    StreamProvider.autoDispose.family<List<Quote>, int>(
      (ref, customerId) =>
          ref.watch(quoteDaoProvider).watchQuotesForCustomer(customerId),
    );

final customerInvoicePaymentsProvider =
    StreamProvider.autoDispose.family<List<InvoicePayment>, int>(
      (ref, customerId) async* {
        final invoices = await ref.watch(customerInvoicesProvider(customerId).future);
        final invoiceIds = invoices.map((invoice) => invoice.id).toList();
        if (invoiceIds.isEmpty) {
          yield const [];
          return;
        }
        final dao = ref.watch(invoiceDaoProvider);
        yield* dao.watchPaymentsForInvoices(invoiceIds);
      },
    );