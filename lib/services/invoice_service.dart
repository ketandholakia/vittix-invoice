import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/daos/business_dao.dart';
import '../database/daos/invoice_dao.dart';
import '../database/daos/product_dao.dart';
import '../core/utils/invoice_number.dart';
import '../core/utils/invoice_type.dart';
import '../core/utils/money.dart';
import 'document_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

final invoiceServiceProvider = Provider<InvoiceService>((ref) {
  return InvoiceService(
    db: ref.watch(databaseProvider),
    activityDao: ref.watch(customerActivityDaoProvider),
    invoiceDao: ref.watch(invoiceDaoProvider),
    businessDao: ref.watch(businessDaoProvider),
    productDao: ref.watch(productDaoProvider),
  );
});

class InvoiceService
    extends DocumentServiceBase<Invoice, InvoiceItem, InvoicesCompanion, InvoiceItemsCompanion> {
  InvoiceService({
    required super.db,
    required super.activityDao,
    required this.invoiceDao,
    required this.businessDao,
    required this.productDao,
  });

  final InvoiceDao invoiceDao;
  final BusinessDao businessDao;
  final ProductDao productDao;

  @override
  String get entityType => 'INVOICE';

  @override
  String get editEventType => 'INVOICE_EDIT';

  @override
  String get docNoun => 'Invoice';

  @override
  String get dateLabel => 'due date';

  @override
  String get contactEventType => 'INVOICE_REMINDER';

  @override
  String get contactTitle => 'Customer contacted about invoice';

  @override
  bool get contactTouchesUpdatedAt => false;

  @override
  String contactNote(String number) => 'Invoice $number reminder recorded';

  @override
  Future<Invoice?> getDocument(int id) => invoiceDao.getInvoiceById(id);

  @override
  Future<List<InvoiceItem>> getItems(int documentId) =>
      invoiceDao.getItemsForInvoice(documentId);

  @override
  Future<Business?> getBusiness(int businessId) =>
      businessDao.getBusinessById(businessId);

  @override
  String seriesFormatOf(Business? business, InvoicesCompanion companion) {
    // Bills of Supply (composition / unregistered / exempt supplies) run on
    // their own series so they never consume tax-invoice sequence numbers.
    final isBos = companion.invoiceType.value == billOfSupplyType;
    return InvoiceNumberGenerator.normalizeFormat(
      isBos ? business?.billOfSupplySeriesFormat : business?.invoiceSeriesFormat,
      fallback: isBos
          ? InvoiceNumberGenerator.defaultBillOfSupplyFormat
          : InvoiceNumberGenerator.defaultInvoiceFormat,
    );
  }

  @override
  DateTime dateOf(InvoicesCompanion companion) => companion.invoiceDate.value;

  @override
  int businessIdOfCompanion(InvoicesCompanion companion) => companion.businessId.value;

  @override
  Future<int> insertWithGeneratedNumber({
    required InvoicesCompanion companion,
    required String format,
    required DateTime date,
  }) => invoiceDao.insertInvoiceWithGeneratedNumber(
    invoice: companion,
    format: format,
    date: date,
  );

  @override
  Future<void> insertItemForDocument({
    required int documentId,
    required InvoiceItemsCompanion item,
  }) => invoiceDao.insertInvoiceItem(
    item.copyWith(invoiceId: drift.Value(documentId)),
  );

  @override
  Future<void> deleteItems(int documentId) =>
      invoiceDao.deleteItemsForInvoice(documentId);

  @override
  Future<void> deleteDocumentRow(int documentId) =>
      invoiceDao.deleteInvoice(documentId);

  @override
  Future<bool> updateDocument(Invoice document) =>
      invoiceDao.updateInvoice(document);

  @override
  Invoice buildUpdatedDocument(Invoice existing, InvoicesCompanion companion) {
    final nextCurrencyCode = companion.currencyCode.present
        ? companion.currencyCode.value
        : existing.currencyCode;
    return existing.copyWith(
      customerId: companion.customerId.value,
      currencyCode: nextCurrencyCode,
      invoiceDate: companion.invoiceDate.value,
      dueDate: companion.dueDate,
      invoiceType: companion.invoiceType.value,
      supplyType: companion.supplyType.value,
      placeOfSupply: companion.placeOfSupply.value,
      subtotal: companion.subtotal.value,
      discountAmount: companion.discountAmount.value,
      taxableAmount: companion.taxableAmount.value,
      cgstAmount: companion.cgstAmount.value,
      sgstAmount: companion.sgstAmount.value,
      igstAmount: companion.igstAmount.value,
      cessAmount: companion.cessAmount.value,
      totalAmount: companion.totalAmount.value,
      roundOffAmount: companion.roundOffAmount.present
          ? companion.roundOffAmount.value
          : existing.roundOffAmount,
      amountInWords: companion.amountInWords,
      notes: companion.notes,
      terms: companion.terms,
      isIgst: companion.isIgst.value,
      reverseCharge: companion.reverseCharge.present
          ? companion.reverseCharge.value
          : existing.reverseCharge,
      shipToName: companion.shipToName,
      shipToAddress: companion.shipToAddress,
      shipToCity: companion.shipToCity,
      exportWithLut: companion.exportWithLut.present
          ? companion.exportWithLut.value
          : existing.exportWithLut,
      tdsSection: companion.tdsSection,
      tdsRate: companion.tdsRate.present
          ? companion.tdsRate.value
          : existing.tdsRate,
      tdsAmount: companion.tdsAmount.present
          ? companion.tdsAmount.value
          : existing.tdsAmount,
      tcsSection: companion.tcsSection,
      tcsRate: companion.tcsRate.present
          ? companion.tcsRate.value
          : existing.tcsRate,
      tcsAmount: companion.tcsAmount.present
          ? companion.tcsAmount.value
          : existing.tcsAmount,
      updatedAt: DateTime.now(),
    );
  }

  @override
  InvoicesCompanion duplicatedCompanion({
    required Invoice source,
    required DateTime duplicateDate,
  }) {
    return InvoicesCompanion.insert(
      businessId: source.businessId,
      customerId: source.customerId,
      invoiceNumber: 'PENDING',
      invoiceDate: duplicateDate,
      invoiceType: source.invoiceType,
      supplyType: source.supplyType,
      placeOfSupply: source.placeOfSupply,
      subtotal: source.subtotal,
      taxableAmount: source.taxableAmount,
      totalAmount: source.totalAmount,
      roundOffAmount: drift.Value(source.roundOffAmount),
      dueDate: drift.Value(source.dueDate),
      isIgst: drift.Value(source.isIgst),
      reverseCharge: drift.Value(source.reverseCharge),
      shipToName: drift.Value(source.shipToName),
      shipToAddress: drift.Value(source.shipToAddress),
      shipToCity: drift.Value(source.shipToCity),
      exportWithLut: drift.Value(source.exportWithLut),
      tdsSection: drift.Value(source.tdsSection),
      tdsRate: drift.Value(source.tdsRate),
      tdsAmount: drift.Value(source.tdsAmount),
      tcsSection: drift.Value(source.tcsSection),
      tcsRate: drift.Value(source.tcsRate),
      tcsAmount: drift.Value(source.tcsAmount),
      discountAmount: drift.Value(source.discountAmount),
      cgstAmount: drift.Value(source.cgstAmount),
      sgstAmount: drift.Value(source.sgstAmount),
      igstAmount: drift.Value(source.igstAmount),
      cessAmount: drift.Value(source.cessAmount),
      amountPaid: const drift.Value(0),
      amountInWords: drift.Value(source.amountInWords),
      notes: drift.Value(source.notes),
      terms: drift.Value(source.terms),
      status: const drift.Value('DRAFT'),
      createdAt: duplicateDate,
      updatedAt: duplicateDate,
    ).copyWith(currencyCode: drift.Value(source.currencyCode));
  }

  @override
  InvoiceItemsCompanion itemCompanionFrom(InvoiceItem source, {required int documentId}) {
    return InvoiceItemsCompanion.insert(
      invoiceId: documentId,
      name: source.name,
      hsnSac: source.hsnSac,
      unit: source.unit,
      quantity: source.quantity,
      rate: source.rate,
      taxableAmount: source.taxableAmount,
      gstRate: source.gstRate,
      totalAmount: source.totalAmount,
      productId: drift.Value(source.productId),
      discountPct: drift.Value(source.discountPct),
      cgstRate: drift.Value(source.cgstRate),
      sgstRate: drift.Value(source.sgstRate),
      igstRate: drift.Value(source.igstRate),
      cessRate: drift.Value(source.cessRate),
      cgstAmount: drift.Value(source.cgstAmount),
      sgstAmount: drift.Value(source.sgstAmount),
      igstAmount: drift.Value(source.igstAmount),
      cessAmount: drift.Value(source.cessAmount),
      sortOrder: drift.Value(source.sortOrder),
    );
  }

  @override
  Invoice documentCopyWithStatus(Invoice document, String status) =>
      document.copyWith(status: status, updatedAt: DateTime.now());

  @override
  Invoice documentCopyWithTemplate(Invoice document, int? templateId) =>
      document.copyWith(templateId: drift.Value(templateId), updatedAt: DateTime.now());

  @override
  Invoice documentCopyWithTouched(Invoice document) =>
      document.copyWith(updatedAt: DateTime.now());

  @override
  DocumentInfo infoOf(Invoice document) => (
    id: document.id,
    businessId: document.businessId,
    customerId: document.customerId,
    number: document.invoiceNumber,
    totalAmount: document.totalAmount,
    dueDate: document.dueDate,
  );

  @override
  void validateStatusTransition(Invoice document, String status) {
    if (document.status == 'CANCELLED' && status != 'CANCELLED') {
      throw Exception('Cancelled invoices cannot be reopened');
    }
    if (document.status == 'PAID' && status != 'PAID') {
      throw Exception('Paid invoices cannot be moved to another status');
    }
    if (status == 'CANCELLED' && document.amountPaid > 0) {
      throw Exception('Invoices with recorded payments cannot be cancelled');
    }
  }

  @override
  void validateEdit(Invoice document) {
    switch (document.status) {
      case 'DRAFT':
        return;
      case 'PAID':
        throw Exception('Paid invoices cannot be edited');
      case 'CANCELLED':
        throw Exception('Cancelled invoices cannot be edited');
      default:
        // SENT / PARTIALLY_PAID: an issued document is corrected with a note.
        throw Exception(
          'Issued invoices cannot be edited — raise a credit note instead',
        );
    }
  }

  @override
  void validateDelete(Invoice document) {
    if (document.status != 'DRAFT') {
      throw Exception(
        'Issued invoices must be cancelled, not deleted, to keep the number series intact',
      );
    }
    if (document.amountPaid > 0) {
      throw Exception('Invoices with recorded payments cannot be deleted');
    }
  }

  /// Payments may only be recorded against a live (non-cancelled) invoice.
  void _assertPaymentsAllowed(Invoice invoice) {
    if (invoice.status == 'CANCELLED') {
      throw Exception('Payments cannot be recorded on a cancelled invoice');
    }
  }

  @override
  Future<void> applyItemSideEffects({
    required int documentId,
    required InvoiceItemsCompanion item,
  }) async {
    // A credit note returns goods, so stock goes back up; invoices and debit
    // notes take stock out.
    final document =
        await invoiceDao.getInvoiceById(documentId);
    final returnsToStock = document?.invoiceType == creditNoteType;

    await _recordStockChange(
      productId: item.productId.present ? item.productId.value : null,
      quantityDelta:
          returnsToStock ? item.quantity.value : -item.quantity.value,
      reason: returnsToStock ? 'CREDIT_NOTE' : 'INVOICE',
      documentId: documentId,
    );
  }

  @override
  Future<void> reverseItemEffects({
    required int documentId,
    required InvoiceItem item,
  }) async {
    final document =
        await invoiceDao.getInvoiceById(documentId);
    final returnedToStock = document?.invoiceType == creditNoteType;

    await _recordStockChange(
      productId: item.productId,
      quantityDelta: returnedToStock ? -item.quantity : item.quantity,
      reason: 'INVOICE_REVERSAL',
      documentId: documentId,
    );
  }

  // ---- public API (document-specific names) ----

  Future<int> createInvoiceWithItems(
    InvoicesCompanion invoice,
    List<InvoiceItemsCompanion> items,
  ) => createWithItems(companion: invoice, items: items);

  Future<int> duplicateInvoice(int invoiceId) => duplicate(invoiceId);

  Future<void> updateInvoiceWithItems(
    Invoice existingInvoice,
    InvoicesCompanion invoice,
    List<InvoiceItemsCompanion> items,
  ) => updateWithItems(existingInvoice, invoice, items);

  Future<void> updateInvoiceStatus(int invoiceId, String status) =>
      updateStatus(invoiceId, status);

  Future<void> updateInvoiceTemplate(int invoiceId, int? templateId) =>
      updateTemplate(invoiceId, templateId);

  Future<void> deleteInvoice(int invoiceId) => delete(invoiceId);

  Future<void> markInvoiceReminderSent(int invoiceId) => markContacted(invoiceId);

  // ---- credit & debit notes ----

  static const creditNoteType = 'CREDIT_NOTE';
  static const debitNoteType = 'DEBIT_NOTE';

  String creditNoteSeriesFormatOf(Business? business) =>
      InvoiceNumberGenerator.normalizeFormat(
        business?.creditNoteSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultCreditNoteFormat,
      );

  String debitNoteSeriesFormatOf(Business? business) =>
      InvoiceNumberGenerator.normalizeFormat(
        business?.debitNoteSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultDebitNoteFormat,
      );

  /// Raises a draft credit note against an issued invoice, copying its parties
  /// and lines. Returns the new document id.
  Future<int> createCreditNote(int invoiceId) =>
      _createAdjustmentNote(invoiceId, creditNoteType);

  /// Raises a draft debit note against an issued invoice (e.g. an undercharge).
  Future<int> createDebitNote(int invoiceId) =>
      _createAdjustmentNote(invoiceId, debitNoteType);

  Future<int> _createAdjustmentNote(int invoiceId, String noteType) async {
    final dao = invoiceDao;
    final source = await dao.getInvoiceById(invoiceId);
    if (source == null) throw Exception('Invoice not found');
    if (source.invoiceType == creditNoteType ||
        source.invoiceType == debitNoteType) {
      throw Exception('A credit or debit note cannot be adjusted again');
    }
    if (source.status == 'DRAFT') {
      throw Exception('Issue the invoice before raising a note against it');
    }
    if (source.status == 'CANCELLED') {
      throw Exception('Cancelled invoices cannot be adjusted');
    }

    final items = await dao.getItemsForInvoice(invoiceId);
    final business = await getBusiness(source.businessId);
    final noteDate = DateTime.now();
    final format = noteType == creditNoteType
        ? creditNoteSeriesFormatOf(business)
        : debitNoteSeriesFormatOf(business);

    final companion = InvoicesCompanion.insert(
      businessId: source.businessId,
      customerId: source.customerId,
      invoiceNumber: 'PENDING',
      invoiceDate: noteDate,
      invoiceType: noteType,
      supplyType: source.supplyType,
      placeOfSupply: source.placeOfSupply,
      subtotal: source.subtotal,
      discountAmount: drift.Value(source.discountAmount),
      taxableAmount: source.taxableAmount,
      cgstAmount: drift.Value(source.cgstAmount),
      sgstAmount: drift.Value(source.sgstAmount),
      igstAmount: drift.Value(source.igstAmount),
      cessAmount: drift.Value(source.cessAmount),
      totalAmount: source.totalAmount,
      roundOffAmount: drift.Value(source.roundOffAmount),
      isIgst: drift.Value(source.isIgst),
      referenceInvoiceId: drift.Value(source.id),
      reverseCharge: drift.Value(source.reverseCharge),
      shipToName: drift.Value(source.shipToName),
      shipToAddress: drift.Value(source.shipToAddress),
      shipToCity: drift.Value(source.shipToCity),
      exportWithLut: drift.Value(source.exportWithLut),
      tdsSection: drift.Value(source.tdsSection),
      tdsRate: drift.Value(source.tdsRate),
      tdsAmount: drift.Value(source.tdsAmount),
      tcsSection: drift.Value(source.tcsSection),
      tcsRate: drift.Value(source.tcsRate),
      tcsAmount: drift.Value(source.tcsAmount),
      amountInWords: drift.Value(source.amountInWords),
      notes: drift.Value('Against ${source.invoiceNumber}'),
      status: const drift.Value('DRAFT'),
      createdAt: noteDate,
      updatedAt: noteDate,
    ).copyWith(currencyCode: drift.Value(source.currencyCode));

    final noteItems = items
        .map((item) => itemCompanionFrom(item, documentId: 0))
        .toList();

    return createWithItems(
      companion: companion,
      items: noteItems,
      formatOverride: format,
    );
  }

  // ---- payment domain (invoice only) ----

  String _statusFromPayments(Invoice invoice, double amountPaid) {
    if (amountPaid >= invoice.totalAmount) return 'PAID';
    if (amountPaid > 0) return 'PARTIALLY_PAID';
    if (invoice.status == 'PAID' || invoice.status == 'PARTIALLY_PAID') return 'SENT';
    return invoice.status;
  }

  Future<void> _refreshInvoicePaymentState(int invoiceId, InvoiceDao dao) async {
    // Re-read inside the caller's transaction: writing back a row loaded before
    // the transaction started would clobber any concurrent change.
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final payments = await dao.getPaymentsForInvoice(invoiceId);
    final amountPaid = round2(
      payments.fold<double>(0, (sum, p) => sum + _signedPaymentAmount(p)),
    );
    final nextStatus = _statusFromPayments(invoice, amountPaid);

    await dao.updateInvoice(
      invoice.copyWith(
        amountPaid: amountPaid,
        status: nextStatus,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> recordPayment(
    int invoiceId,
    double paymentAmount, {
    DateTime? paidAt,
    String? mode,
    String? reference,
    String? note,
  }) async {
    if (paymentAmount <= 0) throw Exception('Payment amount must be greater than zero');
    final dao = invoiceDao;
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    _assertPaymentsAllowed(invoice);

    await db.transaction(() async {
      await dao.insertInvoicePayment(
        InvoicePaymentsCompanion.insert(
          invoiceId: invoiceId,
          amount: round2(paymentAmount),
          kind: const drift.Value('PAYMENT'),
          paidAt: paidAt ?? DateTime.now(),
          mode: drift.Value(mode),
          reference: drift.Value(reference),
          note: drift.Value(note),
          createdAt: DateTime.now(),
        ),
      );
      await _refreshInvoicePaymentState(invoiceId, dao);
    });
  }

  Future<void> updatePayment({
    required int invoiceId,
    required int paymentId,
    required double amount,
    required DateTime paidAt,
    String? mode,
    String? reference,
    String? note,
  }) async {
    if (amount <= 0) throw Exception('Payment amount must be greater than zero');
    final dao = invoiceDao;
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    _assertPaymentsAllowed(invoice);

    final payments = await dao.getPaymentsForInvoice(invoiceId);
    final payment = payments.firstWhere(
      (e) => e.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );
    if (payment.kind == 'VOID') throw Exception('Voided payments cannot be edited');

    final otherTotal = payments
        .where((e) => e.id != paymentId)
        .fold<double>(0, (s, e) => s + _signedPaymentAmount(e));
    final nextAmountPaid = round2(otherTotal + (payment.kind == 'REFUND' ? -amount : amount));
    if (payment.kind == 'REFUND' && nextAmountPaid < 0) {
      throw Exception('Refund exceeds balance');
    }

    await db.transaction(() async {
      await dao.updateInvoicePayment(
        payment.copyWith(
          amount: round2(amount),
          paidAt: paidAt,
          mode: drift.Value(mode),
          reference: drift.Value(reference),
          note: drift.Value(note),
        ),
      );
      await _refreshInvoicePaymentState(invoiceId, dao);
    });
  }

  Future<void> voidPayment({required int invoiceId, required int paymentId}) async {
    final dao = invoiceDao;
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    _assertPaymentsAllowed(invoice);

    final payments = await dao.getPaymentsForInvoice(invoiceId);
    final payment = payments.firstWhere(
      (e) => e.id == paymentId,
      orElse: () => throw Exception('Payment not found'),
    );
    if (payment.kind == 'VOID') throw Exception('Payment is already voided');

    await db.transaction(() async {
      await dao.updateInvoicePayment(payment.copyWith(kind: 'VOID'));
      await _refreshInvoicePaymentState(invoiceId, dao);
    });
  }

  Future<void> recordRefund({
    required int invoiceId,
    required double refundAmount,
    DateTime? paidAt,
    String? mode,
    String? reference,
    String? note,
  }) async {
    if (refundAmount <= 0) throw Exception('Refund amount must be greater than zero');
    final dao = invoiceDao;
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    _assertPaymentsAllowed(invoice);
    if (refundAmount > invoice.amountPaid) throw Exception('Refund amount exceeds balance');

    await db.transaction(() async {
      await dao.insertInvoicePayment(
        InvoicePaymentsCompanion.insert(
          invoiceId: invoiceId,
          amount: round2(refundAmount),
          kind: const drift.Value('REFUND'),
          paidAt: paidAt ?? DateTime.now(),
          mode: drift.Value(mode),
          reference: drift.Value(reference),
          note: drift.Value(note),
          createdAt: DateTime.now(),
        ),
      );
      await _refreshInvoicePaymentState(invoiceId, dao);
    });
  }

  Future<void> deletePayment({required int invoiceId, required int paymentId}) async {
    final dao = invoiceDao;
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    _assertPaymentsAllowed(invoice);

    await db.transaction(() async {
      if (await dao.deleteInvoicePayment(paymentId) == 0) {
        throw Exception('Payment not found');
      }
      await _refreshInvoicePaymentState(invoiceId, dao);
    });
  }

  /// Records a stock movement for a linked product. The ledger owns the
  /// balance (see [ProductDao.recordStockMovement]); nothing is clamped.
  Future<void> _recordStockChange({
    required int? productId,
    required double quantityDelta,
    required String reason,
    required int documentId,
  }) async {
    if (productId == null || quantityDelta == 0) return;
    final product = await productDao.getProductById(productId);
    if (product == null || product.isService) return;

    await productDao.recordStockMovement(
      productId: productId,
      quantityDelta: quantityDelta,
      reason: reason,
      documentType: entityType,
      documentId: documentId,
    );
  }

  double _signedPaymentAmount(InvoicePayment payment) {
    if (payment.kind == 'REFUND') return -payment.amount;
    if (payment.kind == 'VOID') return 0;
    return payment.amount;
  }
}
