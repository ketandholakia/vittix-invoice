import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateUtils;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/recurrence.dart';
import '../database/app_database.dart';
import '../database/daos/recurring_invoice_dao.dart';
import '../providers/database_provider.dart';
import '../providers/invoice_provider.dart';

/// Schedules that repeat an issued invoice as a fresh draft.
class RecurringInvoiceService {
  final Ref _ref;

  RecurringInvoiceService(this._ref);

  RecurringInvoiceDao get _dao => _ref.read(recurringInvoiceDaoProvider);

  Future<List<RecurringInvoice>> listForBusiness(int businessId) =>
      _dao.getForBusiness(businessId);

  Future<RecurringInvoice?> activeForSource(int invoiceId) =>
      _dao.getActiveForSource(invoiceId);

  /// Starts repeating [invoiceId] every [frequency]. The source must be an
  /// issued invoice — a draft has not been sent, so there is nothing to repeat.
  Future<int> startRecurrence({
    required int invoiceId,
    required RecurrenceFrequency frequency,
    DateTime? firstRunDate,
  }) async {
    final invoice = await _ref
        .read(invoiceDaoProvider)
        .getInvoiceById(invoiceId);
    if (invoice == null) throw Exception('Invoice not found');
    if (invoice.status == 'DRAFT') {
      throw Exception('Issue the invoice before making it recurring');
    }
    if (invoice.invoiceType == 'CREDIT_NOTE' ||
        invoice.invoiceType == 'DEBIT_NOTE') {
      throw Exception('Credit and debit notes cannot be made recurring');
    }

    final existing = await _dao.getActiveForSource(invoiceId);
    if (existing != null) {
      throw Exception('This invoice is already recurring');
    }

    final start = DateUtils.dateOnly(firstRunDate ?? DateTime.now());
    return _dao.insertRecurrence(
      RecurringInvoicesCompanion.insert(
        businessId: invoice.businessId,
        sourceInvoiceId: invoiceId,
        frequency: Value(frequency.code),
        nextRunDate: start,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Stops a schedule. The invoices it already generated are left alone.
  Future<void> stopRecurrence(int id) => _dao.deleteRecurrence(id);

  /// Generates a draft for every schedule that is due and advances it.
  ///
  /// Returns how many drafts were created. Errors on a single schedule are
  /// reported by the caller and never stop the others.
  Future<int> runDue({DateTime? now}) async {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final due = await _dao.getDue(today);

    var generated = 0;
    for (final recurrence in due) {
      final invoiceDao = _ref.read(invoiceDaoProvider);
      final source = await invoiceDao.getInvoiceById(recurrence.sourceInvoiceId);
      if (source == null) {
        // The source is gone; a schedule without a source can never run.
        await stopRecurrence(recurrence.id);
        continue;
      }

      final items = await invoiceDao.getItemsForInvoice(source.id);
      final stamp = DateTime.now();
      final companion = InvoicesCompanion.insert(
        businessId: source.businessId,
        customerId: source.customerId,
        invoiceNumber: 'PENDING',
        invoiceDate: today,
        dueDate: Value(source.dueDate),
        invoiceType: source.invoiceType,
        supplyType: source.supplyType,
        placeOfSupply: source.placeOfSupply,
        subtotal: source.subtotal,
        discountAmount: Value(source.discountAmount),
        taxableAmount: source.taxableAmount,
        cgstAmount: Value(source.cgstAmount),
        sgstAmount: Value(source.sgstAmount),
        igstAmount: Value(source.igstAmount),
        cessAmount: Value(source.cessAmount),
        totalAmount: source.totalAmount,
        roundOffAmount: Value(source.roundOffAmount),
        isIgst: Value(source.isIgst),
        reverseCharge: Value(source.reverseCharge),
        shipToName: Value(source.shipToName),
        shipToAddress: Value(source.shipToAddress),
        shipToCity: Value(source.shipToCity),
        exportWithLut: Value(source.exportWithLut),
        tdsSection: Value(source.tdsSection),
        tdsRate: Value(source.tdsRate),
        tdsAmount: Value(source.tdsAmount),
        tcsSection: Value(source.tcsSection),
        tcsRate: Value(source.tcsRate),
        tcsAmount: Value(source.tcsAmount),
        amountInWords: Value(source.amountInWords),
        notes: Value(source.notes),
        terms: Value(source.terms),
        status: const Value('DRAFT'),
        createdAt: stamp,
        updatedAt: stamp,
      ).copyWith(currencyCode: Value(source.currencyCode));

      final invoiceService = _ref.read(invoiceProvider);
      await invoiceService.createInvoiceWithItems(
        companion,
        [
          for (final item in items)
            invoiceService.itemCompanionFrom(item, documentId: 0),
        ],
      );

      await _dao.updateRecurrence(
        recurrence.copyWith(
          // Always step forward at least once, so a schedule can never
          // generate a second draft for the same date.
          nextRunDate: nextRunOnOrAfter(
            advanceByFrequency(recurrence.nextRunDate, recurrence.frequency),
            today,
            recurrence.frequency,
          ),
        ),
      );
      generated++;
    }

    return generated;
  }
}
