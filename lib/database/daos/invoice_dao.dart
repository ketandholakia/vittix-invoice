import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/invoices.dart';
import '../tables/invoice_items.dart';
import '../tables/invoice_payments.dart';
import '../../core/utils/invoice_number.dart';

part 'invoice_dao.g.dart';

@DriftAccessor(tables: [Invoices, InvoiceItems, InvoicePayments])
class InvoiceDao extends DatabaseAccessor<AppDatabase> with _$InvoiceDaoMixin {
  InvoiceDao(super.db);

  Future<List<Invoice>> getInvoicesForBusiness(int businessId) =>
      (select(invoices)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Future<List<Invoice>> getInvoicesForCustomer(int customerId) =>
      (select(invoices)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Future<Invoice?> getInvoiceById(int id) =>
      (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<InvoiceItem>> getItemsForInvoice(int invoiceId) =>
      (select(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).get();

  Future<List<InvoiceItem>> getItemsForInvoices(List<int> invoiceIds) {
    if (invoiceIds.isEmpty) {
      return Future.value(const []);
    }

    return (select(invoiceItems)
          ..where((t) => t.invoiceId.isIn(invoiceIds))
          ..orderBy([(t) => OrderingTerm.asc(t.invoiceId)]))
        .get();
  }

  Future<List<InvoicePayment>> getPaymentsForInvoice(int invoiceId) =>
      (select(invoicePayments)
            ..where((t) => t.invoiceId.equals(invoiceId))
            ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
          .get();

  Future<List<InvoicePayment>> getPaymentsForInvoices(List<int> invoiceIds) {
    if (invoiceIds.isEmpty) {
      return Future.value(const []);
    }

    return (select(invoicePayments)
          ..where((t) => t.invoiceId.isIn(invoiceIds))
          ..orderBy([
            (t) => OrderingTerm.desc(t.paidAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .get();
  }

  Future<int> insertInvoice(InvoicesCompanion invoice) =>
      into(invoices).insert(invoice);
  Future<int> insertInvoiceItem(InvoiceItemsCompanion item) =>
      into(invoiceItems).insert(item);
  Future<int> insertInvoicePayment(InvoicePaymentsCompanion payment) =>
      into(invoicePayments).insert(payment);
  Future<bool> updateInvoicePayment(InvoicePayment payment) =>
      update(invoicePayments).replace(payment);
  Future<int> deleteInvoicePayment(int paymentId) =>
      (delete(invoicePayments)..where((t) => t.id.equals(paymentId))).go();
  Future<int> deleteItemsForInvoice(int invoiceId) =>
      (delete(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).go();

  Future<int> nextSequenceForBusiness({
    required int businessId,
    required String format,
    required DateTime date,
  }) async {
    final existingNumbers =
        await (select(invoices)..where((t) => t.businessId.equals(businessId)))
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

  Future<bool> updateInvoice(Invoice invoice) =>
      update(invoices).replace(invoice);
  Future<int> deleteInvoice(int id) =>
      (delete(invoices)..where((t) => t.id.equals(id))).go();
}
