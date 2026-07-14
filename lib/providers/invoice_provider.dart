import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/daos/product_dao.dart';
import '../database/daos/invoice_dao.dart';
import 'customer_activity_provider.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';
import '../core/utils/invoice_number.dart';
import '../services/invoice_service.dart';
final invoiceListProvider = FutureProvider<List<Invoice>>((ref) async {
  final dao = ref.watch(invoiceDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return [];
  return dao.getInvoicesForBusiness(activeBusinessId);
});


final invoiceProvider = Provider<InvoiceService>((ref) {
  return ref.watch(invoiceServiceProvider);
});

final invoicePaymentsProvider = FutureProvider.family<List<InvoicePayment>, int>((ref, invoiceId) async {
  final dao = ref.watch(invoiceDaoProvider);
  return dao.getPaymentsForInvoice(invoiceId);
});

final invoiceDetailProvider = FutureProvider.family<Invoice?, int>((ref, invoiceId) async {
  final dao = ref.watch(invoiceDaoProvider);
  return dao.getInvoiceById(invoiceId);
});
