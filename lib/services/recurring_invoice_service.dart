import 'package:drift/drift.dart';
import 'package:flutter/material.dart' show DateUtils;

import '../core/utils/amount_in_words.dart';
import '../core/utils/document_totals.dart';
import '../core/utils/due_dates.dart';
import '../core/utils/gst_calculator.dart';
import '../core/utils/money.dart';
import '../core/utils/recurrence.dart';
import '../database/app_database.dart';
import '../database/daos/invoice_dao.dart';
import '../database/daos/recurring_invoice_dao.dart';
import 'invoice_service.dart';

/// Schedules that repeat an issued invoice as a fresh draft.
class RecurringInvoiceService {
  final InvoiceDao invoiceDao;
  final RecurringInvoiceDao _recurringDao;
  final InvoiceService invoiceService;

  /// Whether generated drafts round the payable amount to a whole rupee.
  /// Mirrors the invoice form's round-off preference at generation time.
  final bool applyRoundOff;

  /// How many missed periods a single schedule may catch up in one run, so
  /// an app left closed for a year generates at most this many drafts per
  /// day until it has caught up.
  static const _maxCatchUpPerSchedule = 12;

  RecurringInvoiceService({
    required this.invoiceDao,
    required this._recurringDao,
    required this.invoiceService,
    this.applyRoundOff = true,
  });

  RecurringInvoiceDao get _dao => _recurringDao;

  Future<List<RecurringInvoice>> listForBusiness(int businessId) =>
      _dao.getForBusiness(businessId);

  Future<RecurringInvoice?> activeForSource(int invoiceId) =>
      _dao.getActiveForSource(invoiceId);

  /// Starts repeating [invoiceId] every [frequency]. The source must be an
  /// issued invoice — a draft has not been sent, so there is nothing to repeat.
  ///
  /// The first run's day of month is stored as the anchor: month-based
  /// schedules land on that day (clamped to the month's length) so a 31st
  /// schedule recovers after a short month instead of drifting.
  Future<int> startRecurrence({
    required int invoiceId,
    required RecurrenceFrequency frequency,
    DateTime? firstRunDate,
  }) async {
    final invoice = await invoiceDao.getInvoiceById(invoiceId);
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
        anchorDay: Value(start.day),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Stops a schedule. The invoices it already generated are left alone.
  Future<void> stopRecurrence(int id) => _dao.deleteRecurrence(id);

  /// Generates a draft for every due schedule — one dated draft per missed
  /// period rather than silently skipping — capped at
  /// [_maxCatchUpPerSchedule] drafts per schedule per run, so an app left
  /// closed for a long time catches up over consecutive runs instead of
  /// producing an unbounded batch.
  ///
  /// Returns how many drafts were created. Errors on a single schedule are
  /// reported by the caller and never stop the others.
  Future<int> runDue({DateTime? now}) async {
    final today = DateUtils.dateOnly(now ?? DateTime.now());
    final due = await _dao.getDue(today);

    var generated = 0;
    for (final recurrence in due) {
      final source = await invoiceDao.getInvoiceById(recurrence.sourceInvoiceId);
      if (source == null) {
        // The source is gone; a schedule without a source can never run.
        await stopRecurrence(recurrence.id);
        continue;
      }

      final sourceLines = await invoiceDao.getItemsForInvoice(source.id);
      var cursor = recurrence.nextRunDate;
      for (var period = 0;
          period < _maxCatchUpPerSchedule && !cursor.isAfter(today);
          period++) {
        // The next date is pure math, so it can be computed up front and
        // committed in the same transaction as the draft it enables.
        final nextCursor = advanceFromAnchor(
          cursor,
          recurrence.frequency,
          recurrence.anchorDay,
        );
        await _generatePeriod(recurrence, source, sourceLines, cursor, nextCursor);
        cursor = nextCursor;
        generated++;
      }
    }

    return generated;
  }

  /// One atomic period: the draft insert and the schedule advance commit or
  /// roll back together, so a failed generation leaves neither behind.
  Future<void> _generatePeriod(
    RecurringInvoice recurrence,
    Invoice source,
    List<InvoiceItem> sourceLines,
    DateTime runDate,
    DateTime nextRunDate,
  ) {
    return invoiceService.db.transaction(() async {
      await invoiceService.createInvoiceWithItems(
        _draftCompanion(source, sourceLines, runDate),
        _rebuiltItems(source, sourceLines),
      );
      await _dao.updateRecurrence(
        recurrence.copyWith(nextRunDate: nextRunDate),
      );
    });
  }

  /// The draft for one period: dated on the run date, carrying the source's
  /// payment term, with all amounts rebuilt from the source lines.
  InvoicesCompanion _draftCompanion(
    Invoice source,
    List<InvoiceItem> sourceLines,
    DateTime runDate,
  ) {
    final totals = _recomputeTotals(source, sourceLines);
    final grandTotal = totals.grandTotal;
    final stamp = DateTime.now();
    return InvoicesCompanion.insert(
      businessId: source.businessId,
      customerId: source.customerId,
      invoiceNumber: 'PENDING',
      invoiceDate: runDate,
      dueDate: Value(
        dueDateForCopy(
          sourceInvoiceDate: source.invoiceDate,
          sourceDueDate: source.dueDate,
          newInvoiceDate: runDate,
        ),
      ),
      invoiceType: source.invoiceType,
      supplyType: source.supplyType,
      placeOfSupply: source.placeOfSupply,
      subtotal: totals.subtotal,
      discountAmount: Value(totals.discount),
      taxableAmount: totals.taxable,
      cgstAmount: Value(totals.cgst),
      sgstAmount: Value(totals.sgst),
      igstAmount: Value(totals.igst),
      cessAmount: Value(totals.cess),
      totalAmount: grandTotal,
      roundOffAmount: Value(totals.roundOff),
      isIgst: Value(source.isIgst),
      reverseCharge: Value(source.reverseCharge),
      shipToName: Value(source.shipToName),
      shipToAddress: Value(source.shipToAddress),
      shipToCity: Value(source.shipToCity),
      exportWithLut: Value(source.exportWithLut),
      tdsSection: Value(source.tdsSection),
      tdsRate: Value(source.tdsRate),
      tdsAmount: Value(totals.tdsAmount),
      tcsSection: Value(source.tcsSection),
      tcsRate: Value(source.tcsRate),
      tcsAmount: Value(totals.tcsAmount),
      amountInWords: Value(AmountInWords.convert(grandTotal)),
      notes: Value(source.notes),
      terms: Value(source.terms),
      status: const Value('DRAFT'),
      createdAt: stamp,
      updatedAt: stamp,
    ).copyWith(currencyCode: Value(source.currencyCode));
  }

  /// Rebuilds every source line through the same path the invoice form uses
  /// ([GstCalculator.splitLine], i.e. the form's recomputeItemTax), honoring
  /// the document's supply type and zero-rating exports/SEZ supplies under
  /// LUT. Rate, quantity and the item discount come from the source line
  /// untouched; the tax split and line total are recomputed.
  List<InvoiceItemsCompanion> _rebuiltItems(
    Invoice source,
    List<InvoiceItem> sourceLines,
  ) {
    final zeroRated = _isZeroRated(source);
    return [
      for (final item in sourceLines)
        () {
          final split = GstCalculator.splitLine(
            taxableAmount: item.taxableAmount,
            gstRate: zeroRated ? 0 : item.gstRate,
            isInterState: source.isIgst,
            cessRate: item.cessRate,
          );
          return invoiceService.itemCompanionFrom(item, documentId: 0).copyWith(
                cgstRate: Value(split.cgstRate),
                sgstRate: Value(split.sgstRate),
                igstRate: Value(split.igstRate),
                cgstAmount: Value(split.cgstAmount),
                sgstAmount: Value(split.sgstAmount),
                igstAmount: Value(split.igstAmount),
                cessAmount: Value(split.cessAmount),
                totalAmount: Value(split.totalAmount),
              );
        }(),
    ];
  }

  /// Exports and SEZ supplies declared under a Letter of Undertaking are
  /// zero-rated, exactly as the form treats them at save time.
  bool _isZeroRated(Invoice source) =>
      source.exportWithLut &&
      (source.supplyType == 'EXPORT' || source.supplyType == 'SEZ');

  /// Recomputes the document totals from the source lines, the same way the
  /// form totals a document at save time (TDS/TCS recomputed from the source
  /// rates, round-off per the app preference).
  DocumentTotals _recomputeTotals(
    Invoice source,
    List<InvoiceItem> sourceLines,
  ) {
    final zeroRated = _isZeroRated(source);
    final lineTotals = [
      for (final item in sourceLines)
        () {
          final split = GstCalculator.splitLine(
            taxableAmount: item.taxableAmount,
            gstRate: zeroRated ? 0 : item.gstRate,
            isInterState: source.isIgst,
            cessRate: item.cessRate,
          );
          final gross = round2(item.quantity * item.rate);
          return (
            gross: gross,
            discount: round2(gross - item.taxableAmount),
            taxable: item.taxableAmount,
            cgst: split.cgstAmount,
            sgst: split.sgstAmount,
            igst: split.igstAmount,
            cess: split.cessAmount,
          );
        }(),
    ];

    final base = computeDocumentTotals(lineTotals);
    return computeDocumentTotals(
      lineTotals,
      tdsAmount: round2(base.taxable * source.tdsRate / 100),
      tcsAmount: round2(base.taxable * source.tcsRate / 100),
      applyRoundOff: applyRoundOff,
    );
  }
}
