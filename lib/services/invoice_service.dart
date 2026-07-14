import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/daos/product_dao.dart';
import '../database/daos/invoice_dao.dart';
import '../providers/customer_activity_provider.dart';
import '../providers/database_provider.dart';
import '../providers/invoice_provider.dart';
import '../core/utils/invoice_number.dart';

final invoiceServiceProvider = Provider<InvoiceService>((ref) => InvoiceService(ref));

class InvoiceService {
  final Ref _ref;

  InvoiceService(this._ref);

  String _statusFromPayments(Invoice invoice, double amountPaid) {
    if (amountPaid >= invoice.totalAmount) return 'PAID';
    if (amountPaid > 0) return 'PARTIALLY_PAID';
    if (invoice.status == 'PAID' || invoice.status == 'PARTIALLY_PAID') return 'SENT';
    return invoice.status;
  }

  Future<void> _refreshInvoicePaymentState(Invoice invoice, InvoiceDao dao) async {
    final payments = await dao.getPaymentsForInvoice(invoice.id);
    final amountPaid = payments.fold<double>(0, (sum, p) => sum + _signedPaymentAmount(p));
    final nextStatus = _statusFromPayments(invoice, amountPaid);

    await dao.updateInvoice(
      invoice.copyWith(
        amountPaid: amountPaid,
        status: nextStatus,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<int> createInvoiceWithItems(InvoicesCompanion invoice, List<InvoiceItemsCompanion> items) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final businessDao = _ref.read(businessDaoProvider);
    final productDao = _ref.read(productDaoProvider);
    final now = invoice.invoiceDate.value;

    final invoiceId = await db.transaction(() async {
      final business = await businessDao.getBusinessById(invoice.businessId.value);
      final format = InvoiceNumberGenerator.normalizeFormat(
        business?.invoiceSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
      );
      final nextSequence = await dao.nextSequenceForBusiness(
        businessId: invoice.businessId.value,
        format: format,
        date: now,
      );
      final invoiceWithNumber = invoice.copyWith(
        invoiceNumber: drift.Value(InvoiceNumberGenerator.generateFromFormat(format, nextSequence, now)),
      );
      final createdInvoiceId = await dao.insertInvoice(invoiceWithNumber);

      for (final item in items) {
        await dao.insertInvoiceItem(item.copyWith(invoiceId: drift.Value(createdInvoiceId)));
        await _applyStockChangeForInvoiceItem(
          productDao,
          productId: item.productId.present ? item.productId.value : null,
          quantity: item.quantity.value,
          deltaMultiplier: -1,
        );
      }
      return createdInvoiceId;
    });

    _ref.invalidate(invoiceListProvider);
    return invoiceId;
  }

  Future<int> duplicateInvoice(int invoiceId) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final businessDao = _ref.read(businessDaoProvider);
    final productDao = _ref.read(productDaoProvider);

    final sourceInvoice = await dao.getInvoiceById(invoiceId);
    if (sourceInvoice == null) throw Exception('Invoice not found');
    final sourceItems = await dao.getItemsForInvoice(invoiceId);
    final duplicateDate = DateTime.now();

    final duplicatedInvoiceId = await db.transaction(() async {
      final business = await businessDao.getBusinessById(sourceInvoice.businessId);
      final format = InvoiceNumberGenerator.normalizeFormat(
        business?.invoiceSeriesFormat,
        fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
      );
      final nextSequence = await dao.nextSequenceForBusiness(
        businessId: sourceInvoice.businessId,
        format: format,
        date: duplicateDate,
      );

      final duplicatedInvoice = InvoicesCompanion.insert(
        businessId: sourceInvoice.businessId,
        customerId: sourceInvoice.customerId,
        invoiceNumber: InvoiceNumberGenerator.generateFromFormat(format, nextSequence, duplicateDate),
        invoiceDate: duplicateDate,
        invoiceType: sourceInvoice.invoiceType,
        supplyType: sourceInvoice.supplyType,
        placeOfSupply: sourceInvoice.placeOfSupply,
        subtotal: sourceInvoice.subtotal,
        taxableAmount: sourceInvoice.taxableAmount,
        totalAmount: sourceInvoice.totalAmount,
        dueDate: drift.Value(sourceInvoice.dueDate),
        isIgst: drift.Value(sourceInvoice.isIgst),
        discountAmount: drift.Value(sourceInvoice.discountAmount),
        cgstAmount: drift.Value(sourceInvoice.cgstAmount),
        sgstAmount: drift.Value(sourceInvoice.sgstAmount),
        igstAmount: drift.Value(sourceInvoice.igstAmount),
        cessAmount: drift.Value(sourceInvoice.cessAmount),
        amountPaid: const drift.Value(0),
        amountInWords: drift.Value(sourceInvoice.amountInWords),
        notes: drift.Value(sourceInvoice.notes),
        terms: drift.Value(sourceInvoice.terms),
        status: const drift.Value('DRAFT'),
        createdAt: duplicateDate,
        updatedAt: duplicateDate,
      ).copyWith(currencyCode: drift.Value(sourceInvoice.currencyCode));

      final createdInvoiceId = await dao.insertInvoice(duplicatedInvoice);

      for (final item in sourceItems) {
        await dao.insertInvoiceItem(
          InvoiceItemsCompanion.insert(
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
          ),
        );
        await _applyStockChangeForInvoiceItem(
          productDao,
          productId: item.productId,
          quantity: item.quantity,
          deltaMultiplier: -1,
        );
      }
      return createdInvoiceId;
    });

    _ref.invalidate(invoiceListProvider);
    return duplicatedInvoiceId;
  }

  Future<void> updateInvoiceWithItems(Invoice existingInvoice, InvoicesCompanion invoice, List<InvoiceItemsCompanion> items) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final activityDao = _ref.read(customerActivityDaoProvider);
    final productDao = _ref.read(productDaoProvider);
    
    final previousItems = await dao.getItemsForInvoice(existingInvoice.id);
    final nextCurrencyCode = invoice.currencyCode.present ? invoice.currencyCode.value : existingInvoice.currencyCode;

    await db.transaction(() async {
      await dao.updateInvoice(
        existingInvoice.copyWith(
          customerId: invoice.customerId.value,
          currencyCode: nextCurrencyCode,
          invoiceDate: invoice.invoiceDate.value,
          dueDate: invoice.dueDate,
          invoiceType: invoice.invoiceType.value,
          supplyType: invoice.supplyType.value,
          placeOfSupply: invoice.placeOfSupply.value,
          subtotal: invoice.subtotal.value,
          discountAmount: invoice.discountAmount.value,
          taxableAmount: invoice.taxableAmount.value,
          cgstAmount: invoice.cgstAmount.value,
          sgstAmount: invoice.sgstAmount.value,
          igstAmount: invoice.igstAmount.value,
          cessAmount: invoice.cessAmount.value,
          totalAmount: invoice.totalAmount.value,
          amountInWords: invoice.amountInWords,
          notes: invoice.notes,
          terms: invoice.terms,
          isIgst: invoice.isIgst.value,
          updatedAt: DateTime.now(),
        ),
      );

      await dao.deleteItemsForInvoice(existingInvoice.id);
      for (final pItem in previousItems) {
        await _applyStockChangeForInvoiceItem(productDao, productId: pItem.productId, quantity: pItem.quantity, deltaMultiplier: 1);
      }
      for (final item in items) {
        await dao.insertInvoiceItem(item.copyWith(invoiceId: drift.Value(existingInvoice.id)));
        await _applyStockChangeForInvoiceItem(productDao, productId: item.productId.present ? item.productId.value : null, quantity: item.quantity.value, deltaMultiplier: -1);
      }
    });

    final currentInvoice = (await dao.getInvoiceById(existingInvoice.id))!;
    final newItems = await dao.getItemsForInvoice(existingInvoice.id);
    
    final changeSummary = _describeInvoiceEdit(
      previousCustomerId: existingInvoice.customerId,
      currentCustomerId: currentInvoice.customerId,
      previousTotal: existingInvoice.totalAmount,
      currentTotal: currentInvoice.totalAmount,
      previousDueDate: existingInvoice.dueDate,
      currentDueDate: currentInvoice.dueDate,
      previousItemCount: previousItems.length,
      currentItemCount: newItems.length,
    );

    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: currentInvoice.businessId,
        customerId: currentInvoice.customerId,
        eventType: 'INVOICE_EDIT',
        entityType: const drift.Value('INVOICE'),
        entityId: drift.Value(currentInvoice.id),
        title: 'Invoice updated',
        note: drift.Value(changeSummary),
        createdAt: DateTime.now(),
      ),
    );
    
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(existingInvoice.id));
    _ref.invalidate(customerActivityProvider(currentInvoice.customerId));
  }

  Future<void> recordPayment(int invoiceId, double paymentAmount) async {
    if (paymentAmount <= 0) throw Exception('Payment amount must be greater than zero');
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    await db.transaction(() async {
      await dao.insertInvoicePayment(
        InvoicePaymentsCompanion.insert(
          invoiceId: invoiceId,
          amount: paymentAmount,
          kind: const drift.Value('PAYMENT'),
          paidAt: DateTime.now(),
          createdAt: DateTime.now(),
        ),
      );
      await _refreshInvoicePaymentState(invoice, dao);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> updatePayment({required int invoiceId, required int paymentId, required double amount, required DateTime paidAt, String? note}) async {
    if (amount <= 0) throw Exception('Payment amount must be greater than zero');
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final payments = await dao.getPaymentsForInvoice(invoiceId);
    final payment = payments.firstWhere((e) => e.id == paymentId, orElse: () => throw Exception('Payment not found'));
    if (payment.kind == 'VOID') throw Exception('Voided payments cannot be edited');

    final otherTotal = payments.where((e) => e.id != paymentId).fold<double>(0, (s, e) => s + _signedPaymentAmount(e));
    final nextAmountPaid = otherTotal + (payment.kind == 'REFUND' ? -amount : amount);
    if (payment.kind == 'REFUND' && nextAmountPaid < 0) throw Exception('Refund exceeds balance');

    await db.transaction(() async {
      await dao.updateInvoicePayment(payment.copyWith(amount: amount, paidAt: paidAt, note: drift.Value(note)));
      await _refreshInvoicePaymentState(invoice, dao);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> voidPayment({required int invoiceId, required int paymentId}) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    final payments = await dao.getPaymentsForInvoice(invoiceId);
    final payment = payments.firstWhere((e) => e.id == paymentId, orElse: () => throw Exception('Payment not found'));
    if (payment.kind == 'VOID') throw Exception('Payment is already voided');

    await db.transaction(() async {
      await dao.updateInvoicePayment(payment.copyWith(kind: 'VOID'));
      await _refreshInvoicePaymentState(invoice, dao);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> recordRefund({required int invoiceId, required double refundAmount, String? note}) async {
    if (refundAmount <= 0) throw Exception('Refund amount must be greater than zero');
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    if (refundAmount > invoice.amountPaid) throw Exception('Refund amount exceeds balance');

    await db.transaction(() async {
      await dao.insertInvoicePayment(
        InvoicePaymentsCompanion.insert(
          invoiceId: invoiceId,
          amount: refundAmount,
          kind: const drift.Value('REFUND'),
          paidAt: DateTime.now(),
          note: drift.Value(note),
          createdAt: DateTime.now(),
        ),
      );
      await _refreshInvoicePaymentState(invoice, dao);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> deletePayment({required int invoiceId, required int paymentId}) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    await db.transaction(() async {
      if (await dao.deleteInvoicePayment(paymentId) == 0) throw Exception('Payment not found');
      await _refreshInvoicePaymentState(invoice, dao);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> updateInvoiceStatus(int invoiceId, String status) async {
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    if (invoice.status == 'PAID' && status != 'PAID') throw Exception('Paid invoices cannot be moved to another status');
    if (status == 'CANCELLED' && invoice.amountPaid > 0) throw Exception('Invoices with recorded payments cannot be cancelled');

    await dao.updateInvoice(invoice.copyWith(status: status, updatedAt: DateTime.now()));
    _ref.invalidate(invoiceListProvider);
  }

  Future<void> updateInvoiceTemplate(int invoiceId, int? templateId) async {
    final dao = _ref.read(invoiceDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    await dao.updateInvoice(invoice.copyWith(templateId: drift.Value(templateId), updatedAt: DateTime.now()));
    _ref.invalidate(invoiceListProvider);
  }

  Future<void> deleteInvoice(int invoiceId) async {
    final db = _ref.read(databaseProvider);
    final dao = _ref.read(invoiceDaoProvider);
    final productDao = _ref.read(productDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    if (invoice.amountPaid > 0 || invoice.status == 'PAID') throw Exception('Invoices with recorded payments cannot be deleted');

    final items = await dao.getItemsForInvoice(invoiceId);
    await db.transaction(() async {
      for (final item in items) {
        await _applyStockChangeForInvoiceItem(productDao, productId: item.productId, quantity: item.quantity, deltaMultiplier: 1);
      }
      await dao.deleteInvoice(invoiceId);
    });
    _ref.invalidate(invoiceListProvider);
    _ref.invalidate(invoicePaymentsProvider(invoiceId));
  }

  Future<void> markInvoiceReminderSent(int invoiceId) async {
    final dao = _ref.read(invoiceDaoProvider);
    final activityDao = _ref.read(customerActivityDaoProvider);
    final invoice = await dao.getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');

    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: invoice.businessId,
        customerId: invoice.customerId,
        eventType: 'INVOICE_REMINDER',
        entityType: const drift.Value('INVOICE'),
        entityId: drift.Value(invoice.id),
        title: 'Customer contacted about invoice',
        note: drift.Value('Invoice ${invoice.invoiceNumber} reminder recorded'),
        createdAt: DateTime.now(),
      ),
    );
    _ref.invalidate(customerActivityProvider(invoice.customerId));
  }

  String _describeInvoiceEdit({
    required int previousCustomerId, required int currentCustomerId,
    required double previousTotal, required double currentTotal,
    required DateTime? previousDueDate, required DateTime? currentDueDate,
    required int previousItemCount, required int currentItemCount,
  }) {
    final parts = <String>[];
    if (previousCustomerId != currentCustomerId) parts.add('customer changed');
    if (previousTotal != currentTotal) parts.add('total ${previousTotal.toStringAsFixed(2)} -> ${currentTotal.toStringAsFixed(2)}');
    if (previousDueDate != currentDueDate) parts.add('due date ${previousDueDate?.toIso8601String().split('T')[0] ?? 'none'} -> ${currentDueDate?.toIso8601String().split('T')[0] ?? 'none'}');
    if (previousItemCount != currentItemCount) parts.add('items $previousItemCount -> $currentItemCount');
    return parts.isEmpty ? 'Invoice details refreshed' : 'Invoice edited: ${parts.join(', ')}';
  }

  Future<void> _applyStockChangeForInvoiceItem(
    ProductDao productDao, {
    required int? productId, required double quantity, required double deltaMultiplier,
  }) async {
    if (productId == null || quantity == 0) return;
    final product = await productDao.getProductById(productId);
    if (product == null || product.isService) return;

    final nextStock = product.stockQuantity + (quantity * deltaMultiplier);
    await productDao.updateProduct(product.copyWith(stockQuantity: nextStock < 0 ? 0.0 : nextStock));
  }

  double _signedPaymentAmount(InvoicePayment payment) {
    if (payment.kind == 'REFUND') return -payment.amount;
    if (payment.kind == 'VOID') return 0;
    return payment.amount;
  }
}
