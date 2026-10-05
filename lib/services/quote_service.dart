import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/daos/business_dao.dart';
import '../database/daos/quote_dao.dart';
import '../core/utils/invoice_number.dart';
import 'document_service.dart';
import 'invoice_service.dart';
import '../providers/database_provider.dart';

final quoteServiceProvider = Provider<QuoteService>((ref) {
  return QuoteService(
    db: ref.watch(databaseProvider),
    activityDao: ref.watch(customerActivityDaoProvider),
    quoteDao: ref.watch(quoteDaoProvider),
    businessDao: ref.watch(businessDaoProvider),
    invoiceService: ref.watch(invoiceServiceProvider),
  );
});

class QuoteService
    extends DocumentServiceBase<Quote, QuoteItem, QuotesCompanion, QuoteItemsCompanion> {
  QuoteService({
    required super.db,
    required super.activityDao,
    required this.quoteDao,
    required this.businessDao,
    required this.invoiceService,
  });

  final QuoteDao quoteDao;
  final BusinessDao businessDao;

  /// Used by quote conversion to run the invoice create flow (and its stock
  /// side effects) through the shared document core.
  final InvoiceService invoiceService;

  @override
  String get entityType => 'QUOTE';

  @override
  String get editEventType => 'QUOTE_EDIT';

  @override
  String get docNoun => 'Quote';

  @override
  String get dateLabel => 'valid until';

  @override
  String get contactEventType => 'QUOTE_CONTACT';

  @override
  String get contactTitle => 'Customer contacted about quote';

  @override
  bool get contactTouchesUpdatedAt => true;

  @override
  String contactNote(String number) => 'Quote $number follow-up recorded';

  @override
  Future<Quote?> getDocument(int id) => quoteDao.getQuoteById(id);

  @override
  Future<List<QuoteItem>> getItems(int documentId) =>
      quoteDao.getItemsForQuote(documentId);

  @override
  Future<Business?> getBusiness(int businessId) =>
      businessDao.getBusinessById(businessId);

  @override
  String seriesFormatOf(Business? business) => InvoiceNumberGenerator.normalizeFormat(
    business?.quoteSeriesFormat,
    fallback: InvoiceNumberGenerator.defaultQuoteFormat,
  );

  @override
  DateTime dateOf(QuotesCompanion companion) => companion.invoiceDate.value;

  @override
  int businessIdOfCompanion(QuotesCompanion companion) => companion.businessId.value;

  @override
  Future<int> insertWithGeneratedNumber({
    required QuotesCompanion companion,
    required String format,
    required DateTime date,
  }) => quoteDao.insertQuoteWithGeneratedNumber(
    quote: companion,
    format: format,
    date: date,
  );

  @override
  Future<void> insertItemForDocument({
    required int documentId,
    required QuoteItemsCompanion item,
  }) => quoteDao.insertQuoteItem(
    item.copyWith(quoteId: drift.Value(documentId)),
  );

  @override
  Future<void> deleteItems(int documentId) =>
      quoteDao.deleteItemsForQuote(documentId);

  @override
  Future<void> deleteDocumentRow(int documentId) =>
      quoteDao.deleteQuote(documentId);

  @override
  Future<bool> updateDocument(Quote document) =>
      quoteDao.updateQuote(document);

  @override
  Quote buildUpdatedDocument(Quote existing, QuotesCompanion companion) {
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
  QuotesCompanion duplicatedCompanion({
    required Quote source,
    required DateTime duplicateDate,
  }) {
    return QuotesCompanion.insert(
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
      amountInWords: drift.Value(source.amountInWords),
      notes: drift.Value(source.notes),
      terms: drift.Value(source.terms),
      status: const drift.Value('DRAFT'),
      createdAt: duplicateDate,
      updatedAt: duplicateDate,
    ).copyWith(currencyCode: drift.Value(source.currencyCode));
  }

  @override
  QuoteItemsCompanion itemCompanionFrom(QuoteItem source, {required int documentId}) {
    return QuoteItemsCompanion.insert(
      quoteId: documentId,
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
  Quote documentCopyWithStatus(Quote document, String status) =>
      document.copyWith(status: status, updatedAt: DateTime.now());

  @override
  Quote documentCopyWithTemplate(Quote document, int? templateId) =>
      document.copyWith(templateId: drift.Value(templateId), updatedAt: DateTime.now());

  @override
  Quote documentCopyWithTouched(Quote document) => document.copyWith(updatedAt: DateTime.now());

  @override
  DocumentInfo infoOf(Quote document) => (
    id: document.id,
    businessId: document.businessId,
    customerId: document.customerId,
    number: document.invoiceNumber,
    totalAmount: document.totalAmount,
    dueDate: document.dueDate,
  );

  @override
  void validateStatusTransition(Quote document, String status) {
    if (document.status == 'CONVERTED' && status != 'CONVERTED') {
      throw Exception('Converted quotes cannot be moved to another status');
    }
  }

  @override
  void validateDelete(Quote document) {
    if (document.status == 'CONVERTED') {
      throw Exception('Converted quotes cannot be deleted');
    }
  }

  @override
  void validateEdit(Quote document) {
    if (document.status == 'CONVERTED') {
      throw Exception('Converted quotes cannot be edited');
    }
  }

  @override
  Future<void> applyItemSideEffects({
    required int documentId,
    required QuoteItemsCompanion item,
  }) async {
    // Quotes do not touch product stock.
  }

  @override
  Future<void> reverseItemEffects({required int documentId, required QuoteItem item}) async {
    // Quotes do not touch product stock.
  }

  // ---- public API (document-specific names) ----

  Future<int> createQuoteWithItems(
    QuotesCompanion quote,
    List<QuoteItemsCompanion> items,
  ) => createWithItems(companion: quote, items: items);

  Future<int> duplicateQuote(int quoteId) => duplicate(quoteId);

  Future<void> updateQuoteWithItems(
    Quote existingQuote,
    QuotesCompanion quote,
    List<QuoteItemsCompanion> items,
  ) => updateWithItems(existingQuote, quote, items);

  Future<void> updateQuoteStatus(int quoteId, String status) => updateStatus(quoteId, status);

  Future<void> updateQuoteTemplate(int quoteId, int? templateId) =>
      updateTemplate(quoteId, templateId);

  Future<void> deleteQuote(int quoteId) => delete(quoteId);

  Future<void> markQuoteContacted(int quoteId) => markContacted(quoteId);

  Future<int> convertToInvoice(int quoteId) async {
    final quote = await quoteDao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');
    if (quote.status == 'CONVERTED') {
      throw Exception('Quote has already been converted to an invoice');
    }
    final currencyCode = quote.currencyCode;

    final items = await quoteDao.getItemsForQuote(quoteId);
    final conversionDate = DateTime.now();

    final invoiceCompanion = InvoicesCompanion.insert(
      businessId: quote.businessId,
      customerId: quote.customerId,
      invoiceNumber: 'PENDING',
      invoiceDate: conversionDate,
      invoiceType: 'TAX_INVOICE',
      supplyType: quote.supplyType,
      placeOfSupply: quote.placeOfSupply,
      subtotal: quote.subtotal,
      taxableAmount: quote.taxableAmount,
      totalAmount: quote.totalAmount,
      isIgst: drift.Value(quote.isIgst),
      exportWithLut: drift.Value(quote.exportWithLut),
      tdsSection: drift.Value(quote.tdsSection),
      tdsRate: drift.Value(quote.tdsRate),
      tdsAmount: drift.Value(quote.tdsAmount),
      tcsSection: drift.Value(quote.tcsSection),
      tcsRate: drift.Value(quote.tcsRate),
      tcsAmount: drift.Value(quote.tcsAmount),
      discountAmount: drift.Value(quote.discountAmount),
      cgstAmount: drift.Value(quote.cgstAmount),
      sgstAmount: drift.Value(quote.sgstAmount),
      igstAmount: drift.Value(quote.igstAmount),
      cessAmount: drift.Value(quote.cessAmount),
      amountInWords: drift.Value(quote.amountInWords),
      notes: drift.Value(quote.notes),
      terms: drift.Value(quote.terms),
      status: const drift.Value('DRAFT'),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).copyWith(currencyCode: drift.Value(currencyCode));

    // The invoice service rewrites the item document ids on insert; the
    // placeholder here keeps the mapper shape identical to its other uses.
    final invoiceItems = items
        .map((item) => _invoiceItemCompanionFromQuoteItem(item, invoiceId: 0))
        .toList();

    final invoiceId = await db.transaction(() async {
      final createdId = await invoiceService.createInvoiceWithItems(
        invoiceCompanion,
        invoiceItems,
      );
      await quoteDao.updateQuote(quote.copyWith(status: 'CONVERTED'));
      return createdId;
    });

    return invoiceId;
  }

  InvoiceItemsCompanion _invoiceItemCompanionFromQuoteItem(
    QuoteItem source, {
    required int invoiceId,
  }) {
    return InvoiceItemsCompanion.insert(
      invoiceId: invoiceId,
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
}
