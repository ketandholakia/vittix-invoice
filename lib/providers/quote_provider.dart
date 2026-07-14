import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import 'database_provider.dart';
import 'customer_activity_provider.dart';
import 'invoice_provider.dart';
import 'shared_preferences_provider.dart';
import '../core/utils/invoice_number.dart';

final quoteListProvider = FutureProvider<List<Quote>>((ref) async {
  final dao = ref.watch(quoteDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return [];
  return dao.getQuotesForBusiness(activeBusinessId);
});

final quoteProvider = Provider<QuoteNotifier>((ref) {
  return QuoteNotifier(ref);
});

final quoteDetailProvider = FutureProvider.family<Quote?, int>((ref, quoteId) async {
  final dao = ref.watch(quoteDaoProvider);
  return dao.getQuoteById(quoteId);
});

class QuoteNotifier {
  final Ref _ref;

  QuoteNotifier(this._ref);

  Future<int> createQuoteWithItems(
    QuotesCompanion quote,
    List<QuoteItemsCompanion> items,
  ) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(quoteDaoProvider);
    final businessDao = _ref.read(businessDaoProvider);
    final now = quote.invoiceDate.value;

    final quoteId = await db.transaction(() async {
      final business = await businessDao.getBusinessById(quote.businessId.value);
      final format = InvoiceNumberGenerator.normalizeFormat(
        business?.quoteSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultQuoteFormat,
      );
      final nextSequence = await dao.nextSequenceForBusiness(
        businessId: quote.businessId.value,
        format: format,
        date: now,
      );
      final quoteWithNumber = quote.copyWith(
        invoiceNumber: drift.Value(
          InvoiceNumberGenerator.generateFromFormat(format, nextSequence, now),
        ),
        currencyCode: quote.currencyCode,
      );
      final createdQuoteId = await dao.insertQuote(quoteWithNumber);

      for (final item in items) {
        await dao.insertQuoteItem(
          item.copyWith(quoteId: drift.Value(createdQuoteId)),
        );
      }

      return createdQuoteId;
    });

    _ref.invalidate(quoteListProvider);
    return quoteId;
  }

  Future<int> duplicateQuote(int quoteId) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(quoteDaoProvider);
    final businessDao = _ref.read(businessDaoProvider);

    final sourceQuote = await dao.getQuoteById(quoteId);
    if (sourceQuote == null) throw Exception('Quote not found');

    final sourceItems = await dao.getItemsForQuote(quoteId);
    final duplicateDate = DateTime.now();
    final currencyCode = sourceQuote.currencyCode;

    final duplicatedQuoteId = await db.transaction(() async {
      final business = await businessDao.getBusinessById(sourceQuote.businessId);
      final format = InvoiceNumberGenerator.normalizeFormat(
        business?.quoteSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultQuoteFormat,
      );
      final nextSequence = await dao.nextSequenceForBusiness(
        businessId: sourceQuote.businessId,
        format: format,
        date: duplicateDate,
      );

      final duplicatedQuote = QuotesCompanion.insert(
        businessId: sourceQuote.businessId,
        customerId: sourceQuote.customerId,
        invoiceNumber: InvoiceNumberGenerator.generateFromFormat(
          format,
          nextSequence,
          duplicateDate,
        ),
        invoiceDate: duplicateDate,
        invoiceType: sourceQuote.invoiceType,
        supplyType: sourceQuote.supplyType,
        placeOfSupply: sourceQuote.placeOfSupply,
        subtotal: sourceQuote.subtotal,
        taxableAmount: sourceQuote.taxableAmount,
        totalAmount: sourceQuote.totalAmount,
        dueDate: drift.Value(sourceQuote.dueDate),
        isIgst: drift.Value(sourceQuote.isIgst),
        discountAmount: drift.Value(sourceQuote.discountAmount),
        cgstAmount: drift.Value(sourceQuote.cgstAmount),
        sgstAmount: drift.Value(sourceQuote.sgstAmount),
        igstAmount: drift.Value(sourceQuote.igstAmount),
        cessAmount: drift.Value(sourceQuote.cessAmount),
        amountInWords: drift.Value(sourceQuote.amountInWords),
        notes: drift.Value(sourceQuote.notes),
        terms: drift.Value(sourceQuote.terms),
        status: const drift.Value('DRAFT'),
        createdAt: duplicateDate,
        updatedAt: duplicateDate,
      ).copyWith(currencyCode: drift.Value(currencyCode));

      final createdQuoteId = await dao.insertQuote(duplicatedQuote);

      for (final item in sourceItems) {
        await dao.insertQuoteItem(
          QuoteItemsCompanion.insert(
            quoteId: createdQuoteId,
            name: item.name,
            hsnSac: item.hsnSac,
            unit: item.unit,
            quantity: item.quantity,
            rate: item.rate,
            taxableAmount: item.taxableAmount,
            gstRate: item.gstRate,
            totalAmount: item.totalAmount,
            productId: drift.Value(item.productId),
            discountPct: drift.Value(item.discountPct),
            cgstRate: drift.Value(item.cgstRate),
            sgstRate: drift.Value(item.sgstRate),
            igstRate: drift.Value(item.igstRate),
            cessRate: drift.Value(item.cessRate),
            cgstAmount: drift.Value(item.cgstAmount),
            sgstAmount: drift.Value(item.sgstAmount),
            igstAmount: drift.Value(item.igstAmount),
            cessAmount: drift.Value(item.cessAmount),
            sortOrder: drift.Value(item.sortOrder),
          ),
        );
      }

      return createdQuoteId;
    });

    _ref.invalidate(quoteListProvider);
    return duplicatedQuoteId;
  }

  Future<void> updateQuoteWithItems(
    Quote existingQuote,
    QuotesCompanion quote,
    List<QuoteItemsCompanion> items,
  ) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(quoteDaoProvider);
    final activityDao = _ref.read(customerActivityDaoProvider);
    final previousItems = await dao.getItemsForQuote(existingQuote.id);
    final previousItemCount = previousItems.length;
    final previousCustomerId = existingQuote.customerId;
    final previousTotal = existingQuote.totalAmount;
    final previousDueDate = existingQuote.dueDate;
    final nextCurrencyCode = quote.currencyCode.present
        ? quote.currencyCode.value
        : existingQuote.currencyCode;

    await db.transaction(() async {
      await dao.updateQuote(
        existingQuote.copyWith(
          customerId: quote.customerId.value,
          currencyCode: nextCurrencyCode,
          invoiceDate: quote.invoiceDate.value,
          dueDate: quote.dueDate,
          invoiceType: quote.invoiceType.value,
          supplyType: quote.supplyType.value,
          placeOfSupply: quote.placeOfSupply.value,
          subtotal: quote.subtotal.value,
          discountAmount: quote.discountAmount.value,
          taxableAmount: quote.taxableAmount.value,
          cgstAmount: quote.cgstAmount.value,
          sgstAmount: quote.sgstAmount.value,
          igstAmount: quote.igstAmount.value,
          cessAmount: quote.cessAmount.value,
          totalAmount: quote.totalAmount.value,
          amountInWords: quote.amountInWords,
          notes: quote.notes,
          terms: quote.terms,
          isIgst: quote.isIgst.value,
          updatedAt: DateTime.now(),
        ),
      );

      await dao.deleteItemsForQuote(existingQuote.id);
      for (final item in items) {
        await dao.insertQuoteItem(
          item.copyWith(quoteId: drift.Value(existingQuote.id)),
        );
      }
    });

    final updatedQuote = await dao.getQuoteById(existingQuote.id);
    final currentQuote =
        updatedQuote ??
        existingQuote.copyWith(
          customerId: quote.customerId.value,
          currencyCode: nextCurrencyCode,
          invoiceDate: quote.invoiceDate.value,
          dueDate: quote.dueDate,
          invoiceType: quote.invoiceType.value,
          supplyType: quote.supplyType.value,
          placeOfSupply: quote.placeOfSupply.value,
          subtotal: quote.subtotal.value,
          discountAmount: quote.discountAmount.value,
          taxableAmount: quote.taxableAmount.value,
          cgstAmount: quote.cgstAmount.value,
          sgstAmount: quote.sgstAmount.value,
          igstAmount: quote.igstAmount.value,
          cessAmount: quote.cessAmount.value,
          totalAmount: quote.totalAmount.value,
          amountInWords: quote.amountInWords,
          notes: quote.notes,
          terms: quote.terms,
          isIgst: quote.isIgst.value,
          updatedAt: DateTime.now(),
        );
    final newItems = await dao.getItemsForQuote(existingQuote.id);
    final changeSummary = _describeQuoteEdit(
      previousCustomerId: previousCustomerId,
      currentCustomerId: currentQuote.customerId,
      previousTotal: previousTotal,
      currentTotal: currentQuote.totalAmount,
      previousDueDate: previousDueDate,
      currentDueDate: currentQuote.dueDate,
      previousItemCount: previousItemCount,
      currentItemCount: newItems.length,
    );
    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: currentQuote.businessId,
        customerId: currentQuote.customerId,
        eventType: 'QUOTE_EDIT',
        entityType: const drift.Value('QUOTE'),
        entityId: drift.Value(currentQuote.id),
        title: 'Quote updated',
        note: drift.Value(changeSummary),
        createdAt: DateTime.now(),
      ),
    );
    _ref.invalidate(quoteListProvider);
    _ref.invalidate(customerActivityProvider(currentQuote.customerId));
  }

  Future<int> convertToInvoice(int quoteId) async {
    final db = _ref.read(databaseProvider);
    final quoteDao = _ref.read(quoteDaoProvider);
    final invoiceDao = _ref.read(invoiceDaoProvider);
    final businessDao = _ref.read(businessDaoProvider);

    final quote = await quoteDao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');
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

    final invoiceId = await db.transaction(() async {
      final business = await businessDao.getBusinessById(quote.businessId);
      final format = InvoiceNumberGenerator.normalizeFormat(
        business?.invoiceSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
      );
      final nextInvoiceSequence = await invoiceDao.nextSequenceForBusiness(
        businessId: quote.businessId,
        format: format,
        date: conversionDate,
      );
      final numberedInvoiceCompanion = invoiceCompanion.copyWith(
        invoiceNumber: drift.Value(
          InvoiceNumberGenerator.generateFromFormat(
            format,
            nextInvoiceSequence,
            conversionDate,
          ),
        ),
        currencyCode: drift.Value(quote.currencyCode),
      );
      final createdInvoiceId = await invoiceDao.insertInvoice(
        numberedInvoiceCompanion,
      );

      for (final item in items) {
        final invoiceItemCompanion = InvoiceItemsCompanion.insert(
          invoiceId: createdInvoiceId,
          name: item.name,
          hsnSac: item.hsnSac,
          unit: item.unit,
          quantity: item.quantity,
          rate: item.rate,
          taxableAmount: item.taxableAmount,
          gstRate: item.gstRate,
          totalAmount: item.totalAmount,
          productId: drift.Value(item.productId),
          discountPct: drift.Value(item.discountPct),
          cgstRate: drift.Value(item.cgstRate),
          sgstRate: drift.Value(item.sgstRate),
          igstRate: drift.Value(item.igstRate),
          cessRate: drift.Value(item.cessRate),
          cgstAmount: drift.Value(item.cgstAmount),
          sgstAmount: drift.Value(item.sgstAmount),
          igstAmount: drift.Value(item.igstAmount),
          cessAmount: drift.Value(item.cessAmount),
          sortOrder: drift.Value(item.sortOrder),
        );
        await invoiceDao.insertInvoiceItem(invoiceItemCompanion);
      }

      await quoteDao.updateQuote(quote.copyWith(status: 'CONVERTED'));
      return createdInvoiceId;
    });

    _ref.invalidate(quoteListProvider);
    _ref.invalidate(invoiceListProvider);

    return invoiceId;
  }

  Future<void> updateQuoteStatus(int quoteId, String status) async {
    final dao = _ref.read(quoteDaoProvider);
    final quote = await dao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');
    if (quote.status == 'CONVERTED' && status != 'CONVERTED') {
      throw Exception('Converted quotes cannot be moved to another status');
    }

    await dao.updateQuote(
      quote.copyWith(status: status, updatedAt: DateTime.now()),
    );
    _ref.invalidate(quoteListProvider);
  }

  Future<void> updateQuoteTemplate(int quoteId, int? templateId) async {
    final dao = _ref.read(quoteDaoProvider);
    final quote = await dao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');

    await dao.updateQuote(
      quote.copyWith(templateId: drift.Value(templateId), updatedAt: DateTime.now()),
    );
    _ref.invalidate(quoteListProvider);
  }

  Future<void> deleteQuote(int quoteId) async {
    final dao = _ref.read(quoteDaoProvider);
    final quote = await dao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');
    if (quote.status == 'CONVERTED') {
      throw Exception('Converted quotes cannot be deleted');
    }

    await dao.deleteQuote(quoteId);
    _ref.invalidate(quoteListProvider);
  }

  Future<void> markQuoteContacted(int quoteId) async {
    final dao = _ref.read(quoteDaoProvider);
    final activityDao = _ref.read(customerActivityDaoProvider);
    final quote = await dao.getQuoteById(quoteId);
    if (quote == null) throw Exception('Quote not found');

    await dao.updateQuote(quote.copyWith(updatedAt: DateTime.now()));
    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: quote.businessId,
        customerId: quote.customerId,
        eventType: 'QUOTE_CONTACT',
        entityType: const drift.Value('QUOTE'),
        entityId: drift.Value(quote.id),
        title: 'Customer contacted about quote',
        note: drift.Value('Quote ${quote.invoiceNumber} follow-up recorded'),
        createdAt: DateTime.now(),
      ),
    );
    _ref.invalidate(quoteListProvider);
  }

  String _describeQuoteEdit({
    required int previousCustomerId,
    required int currentCustomerId,
    required double previousTotal,
    required double currentTotal,
    required DateTime? previousDueDate,
    required DateTime? currentDueDate,
    required int previousItemCount,
    required int currentItemCount,
  }) {
    final parts = <String>[];
    if (previousCustomerId != currentCustomerId) {
      parts.add('customer changed');
    }
    if (previousTotal != currentTotal) {
      parts.add(
        'total ${previousTotal.toStringAsFixed(2)} -> ${currentTotal.toStringAsFixed(2)}',
      );
    }
    if (previousDueDate != currentDueDate) {
      final oldDue = previousDueDate?.toIso8601String().split('T')[0] ?? 'none';
      final newDue = currentDueDate?.toIso8601String().split('T')[0] ?? 'none';
      parts.add('valid until $oldDue -> $newDue');
    }
    if (previousItemCount != currentItemCount) {
      parts.add('items $previousItemCount -> $currentItemCount');
    }
    if (parts.isEmpty) {
      return 'Quote details refreshed';
    }
    return 'Quote edited: ${parts.join(', ')}';
  }
}
