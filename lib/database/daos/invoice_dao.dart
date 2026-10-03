import 'package:drift/drift.dart';
import 'package:sqlite3/sqlite3.dart' show SqliteException;
import '../app_database.dart';
import '../tables/invoices.dart';
import '../tables/invoice_items.dart';
import '../tables/invoice_payments.dart';
import '../document_sequence_allocator.dart';
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

  /// Every invoice for the business dated within [from]..[to] inclusive,
  /// uncapped. Compliance exports and reports must read the full book — the
  /// watched list providers cap at `invoiceListPageSize` for UI performance,
  /// and a capped GSTR-1 export would silently drop documents.
  Future<List<Invoice>> getInvoicesForBusinessBetween(
    int businessId,
    DateTime from,
    DateTime to,
  ) =>
      (select(invoices)
            ..where(
              (t) =>
                  t.businessId.equals(businessId) &
                  t.invoiceDate.isBetweenValues(from, to),
            )
            ..orderBy([(t) => OrderingTerm.asc(t.invoiceDate)]))
          .get();

  Stream<List<Invoice>> watchInvoicesForBusiness(int businessId, {int? limit}) {
    final query = select(invoices)
      ..where((t) => t.businessId.equals(businessId))
      ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]);
    if (limit != null) {
      query.limit(limit);
    }
    return query.watch();
  }

  Future<List<Invoice>> getInvoicesForCustomer(int customerId) =>
      (select(invoices)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Stream<List<Invoice>> watchInvoicesForCustomer(int customerId) =>
      (select(invoices)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .watch();

  Future<Invoice?> getInvoiceById(int id) =>
      (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();

  Stream<Invoice?> watchInvoiceById(int id) =>
      (select(invoices)..where((t) => t.id.equals(id))).watchSingleOrNull();

  Future<List<InvoiceItem>> getItemsForInvoice(int invoiceId) =>
      (select(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).get();

  Stream<List<InvoiceItem>> watchItemsForInvoice(int invoiceId) =>
      (select(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).watch();

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

  Stream<List<InvoicePayment>> watchPaymentsForInvoice(int invoiceId) =>
      (select(invoicePayments)
            ..where((t) => t.invoiceId.equals(invoiceId))
            ..orderBy([(t) => OrderingTerm.desc(t.paidAt)]))
          .watch();

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

  Stream<List<InvoicePayment>> watchPaymentsForInvoices(List<int> invoiceIds) {
    if (invoiceIds.isEmpty) {
      return const Stream.empty();
    }

    return (select(invoicePayments)
          ..where((t) => t.invoiceId.isIn(invoiceIds))
          ..orderBy([
            (t) => OrderingTerm.desc(t.paidAt),
            (t) => OrderingTerm.desc(t.id),
          ]))
        .watch();
  }

  Future<int> insertInvoice(InvoicesCompanion invoice) =>
      into(invoices).insert(invoice);

  /// Allocates the next sequence from the per-business counter and inserts
  /// the invoice with a generated number in one atomic unit. Callers must
  /// run this inside a transaction. If the allocated number collides with a
  /// legacy number created before counters existed (or under an older
  /// format), the counter is resynced from the stored documents and the
  /// insert is retried once.
  Future<int> insertInvoiceWithGeneratedNumber({
    required InvoicesCompanion invoice,
    required String format,
    required DateTime date,
  }) async {
    final businessId = invoice.businessId.value;
    final allocator = DocumentSequenceAllocator(db);
    var sequence = await allocator.allocateNext(
      businessId: businessId,
      docType: DocumentSequenceAllocator.invoiceDocType,
      format: format,
      date: date,
    );
    try {
      return await into(invoices).insert(
        invoice.copyWith(
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
        docType: DocumentSequenceAllocator.invoiceDocType,
        format: format,
        date: date,
        sequence: maxSequence,
      );
      return into(invoices).insert(
        invoice.copyWith(
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

  Future<int> _scanMaxSequence({
    required int businessId,
    required String format,
    required DateTime date,
  }) async {
    final existingNumbers = await (select(invoices)
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

  Future<bool> updateInvoice(Invoice invoice) =>
      update(invoices).replace(invoice);
  Future<int> deleteInvoice(int id) =>
      (delete(invoices)..where((t) => t.id.equals(id))).go();
}
