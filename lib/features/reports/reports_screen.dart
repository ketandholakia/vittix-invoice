import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/gstr1_export.dart';
import '../../core/utils/invoice_balance.dart';
import '../../core/utils/stock_status.dart';
import '../../core/utils/invoice_status.dart';
import '../../database/app_database.dart';
import '../../providers/business_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/quote_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/share_service.dart';
import 'customer_statement_report.dart';

enum ReportRange { currentMonth, allTime, custom }

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  ReportRange _range = ReportRange.currentMonth;
  bool _isExportingInvoices = false;
  bool _isExportingGstr1 = false;
  bool _isExportingQuotes = false;
  bool _isExportingCustomerSummary = false;
  bool _isExportingCustomerStatement = false;
  bool _isExportingReceivablesAging = false;
  bool _isExportingHsnSummary = false;
  bool _isExportingQuoteConversion = false;
  bool _isExportingQuoteQueue = false;
  DateTime? _customStartDate;
  DateTime? _customEndDate;

  DateTimeRange? get _selectedRange {
    final now = DateTime.now();
    switch (_range) {
      case ReportRange.currentMonth:
        return DateTimeRange(
          start: DateTime(now.year, now.month, 1),
          end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
        );
      case ReportRange.allTime:
        return null;
      case ReportRange.custom:
        if (_customStartDate == null || _customEndDate == null) {
          return null;
        }
        return DateTimeRange(
          start: _customStartDate!,
          end: DateTime(
            _customEndDate!.year,
            _customEndDate!.month,
            _customEndDate!.day,
            23,
            59,
            59,
          ),
        );
    }
  }

  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialRange =
        _selectedRange ??
        DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );
    if (picked == null) return;

    setState(() {
      _customStartDate = picked.start;
      _customEndDate = picked.end;
      _range = ReportRange.custom;
    });
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    // Drafts are not issued and cancelled invoices are void, so neither may
    // contribute to any report total.
    final counted = invoices.where(
      (invoice) => isInvoiceCountedInTotals(invoice.status),
    );
    final selectedRange = _selectedRange;
    if (selectedRange == null) {
      return counted.toList();
    }

    return counted
        .where(
          (invoice) =>
              !invoice.invoiceDate.isBefore(selectedRange.start) &&
              !invoice.invoiceDate.isAfter(selectedRange.end),
        )
        .toList();
  }

  List<Quote> _filterQuotes(List<Quote> quotes) {
    final selectedRange = _selectedRange;
    if (selectedRange == null) {
      return quotes;
    }

    return quotes
        .where(
          (quote) =>
              !quote.invoiceDate.isBefore(selectedRange.start) &&
              !quote.invoiceDate.isAfter(selectedRange.end),
        )
        .toList();
  }

  Future<void> _exportInvoices(List<Invoice> invoices) async {
    setState(() => _isExportingInvoices = true);
    try {
      final rows = <List<String>>[
        [
          'Invoice Number',
          'Date',
          'Due Date',
          'Status',
          'Subtotal',
          'Taxable Amount',
          'CGST',
          'SGST',
          'IGST',
          'Cess',
          'Total Amount',
          'Amount Paid',
          'Balance Due',
        ],
        for (final invoice in invoices)
          [
            invoice.invoiceNumber,
            invoice.invoiceDate.toIso8601String().split('T')[0],
            invoice.dueDate?.toIso8601String().split('T')[0] ?? '',
            invoice.status,
            invoice.subtotal.toStringAsFixed(2),
            invoice.taxableAmount.toStringAsFixed(2),
            invoice.cgstAmount.toStringAsFixed(2),
            invoice.sgstAmount.toStringAsFixed(2),
            invoice.igstAmount.toStringAsFixed(2),
            invoice.cessAmount.toStringAsFixed(2),
            invoice.totalAmount.toStringAsFixed(2),
            invoice.amountPaid.toStringAsFixed(2),
            invoiceBalanceDue(invoice).toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'invoice_report.csv',
        subject: 'Invoice Report',
        text: 'Invoice report export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingInvoices = false);
      }
    }
  }

  Future<void> _exportGstr1(List<Invoice> invoices) async {
    setState(() => _isExportingGstr1 = true);
    try {
      final businessId = ref.read(activeBusinessIdProvider);
      final customers = businessId == null
          ? const <Customer>[]
          : await ref
                .read(customerDaoProvider)
                .getCustomersForBusiness(businessId);
      final items = await ref
          .read(invoiceDaoProvider)
          .getItemsForInvoices(invoices.map((invoice) => invoice.id).toList());

      final rows = buildGstr1Rows(
        customers: customers,
        invoices: invoices,
        items: items,
      );

      await ShareService.shareCsv(
        rows,
        'gstr1_summary.csv',
        subject: 'GSTR-1 Summary',
        text: 'GSTR-1 style summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingGstr1 = false);
      }
    }
  }

  Future<void> _exportQuotes(List<Quote> quotes) async {
    setState(() => _isExportingQuotes = true);
    try {
      final rows = <List<String>>[
        [
          'Quote Number',
          'Date',
          'Valid Until',
          'Status',
          'Subtotal',
          'Taxable Amount',
          'CGST',
          'SGST',
          'IGST',
          'Cess',
          'Total Amount',
        ],
        for (final quote in quotes)
          [
            quote.invoiceNumber,
            quote.invoiceDate.toIso8601String().split('T')[0],
            quote.dueDate?.toIso8601String().split('T')[0] ?? '',
            quote.status,
            quote.subtotal.toStringAsFixed(2),
            quote.taxableAmount.toStringAsFixed(2),
            quote.cgstAmount.toStringAsFixed(2),
            quote.sgstAmount.toStringAsFixed(2),
            quote.igstAmount.toStringAsFixed(2),
            quote.cessAmount.toStringAsFixed(2),
            quote.totalAmount.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'quote_report.csv',
        subject: 'Quote Report',
        text: 'Quote report export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuotes = false);
      }
    }
  }

  Future<void> _exportCustomerSummary(
    List<_CustomerReportRow> customerRows,
  ) async {
    setState(() => _isExportingCustomerSummary = true);
    try {
      final rows = <List<String>>[
        ['Customer', 'Invoices', 'Sales', 'Collected', 'Pending'],
        for (final row in customerRows)
          [
            row.customerName,
            row.invoiceCount.toString(),
            row.sales.toStringAsFixed(2),
            row.collected.toStringAsFixed(2),
            row.pending.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'customer_sales_summary.csv',
        subject: 'Customer Sales Summary',
        text: 'Customer sales summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCustomerSummary = false);
      }
    }
  }

  Future<void> _exportCustomerStatement(
    List<CustomerStatementRow> rows,
  ) async {
    setState(() => _isExportingCustomerStatement = true);
    try {
      final csvRows = <List<String>>[
        [
          'Customer',
          'Date',
          'Entry Type',
          'Document',
          'Amount',
          'Running Balance',
          'Note',
        ],
        for (final row in rows) row.toCsvRow(),
      ];

      await ShareService.shareCsv(
        csvRows,
        'customer_statement.csv',
        subject: 'Customer Statement',
        text: 'Customer statement export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCustomerStatement = false);
      }
    }
  }

  Future<void> _exportReceivablesAging(
    List<_ReceivablesAgingRow> agingRows,
  ) async {
    setState(() => _isExportingReceivablesAging = true);
    try {
      final rows = <List<String>>[
        [
          'Customer',
          'Open Invoices',
          'Current',
          '1-30 Days',
          '31-60 Days',
          '61-90 Days',
          '90+ Days',
          'Total Due',
        ],
        for (final row in agingRows)
          [
            row.customerName,
            row.invoiceCount.toString(),
            row.current.toStringAsFixed(2),
            row.days1To30.toStringAsFixed(2),
            row.days31To60.toStringAsFixed(2),
            row.days61To90.toStringAsFixed(2),
            row.daysOver90.toStringAsFixed(2),
            row.totalDue.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'receivables_aging.csv',
        subject: 'Receivables Aging',
        text: 'Receivables aging export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingReceivablesAging = false);
      }
    }
  }

  Future<void> _exportHsnSummary(List<_HsnReportRow> hsnRows) async {
    setState(() => _isExportingHsnSummary = true);
    try {
      final rows = <List<String>>[
        ['HSN/SAC', 'Item Count', 'Taxable', 'CGST', 'SGST', 'IGST', 'Cess'],
        for (final row in hsnRows)
          [
            row.hsnSac,
            row.itemCount.toString(),
            row.taxable.toStringAsFixed(2),
            row.cgst.toStringAsFixed(2),
            row.sgst.toStringAsFixed(2),
            row.igst.toStringAsFixed(2),
            row.cess.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'hsn_tax_summary.csv',
        subject: 'HSN Tax Summary',
        text: 'HSN and tax summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingHsnSummary = false);
      }
    }
  }

  Future<void> _exportQuoteConversionSummary(
    List<_QuoteConversionRow> rows,
  ) async {
    setState(() => _isExportingQuoteConversion = true);
    try {
      final csvRows = <List<String>>[
        ['Customer', 'Quotes', 'Converted', 'Conversion Rate', 'Rejected'],
        for (final row in rows)
          [
            row.customerName,
            row.quoteCount.toString(),
            row.convertedCount.toString(),
            '${row.conversionRate.toStringAsFixed(2)}%',
            row.rejectedCount.toString(),
          ],
      ];

      await ShareService.shareCsv(
        csvRows,
        'quote_conversion_summary.csv',
        subject: 'Quote Conversion Summary',
        text: 'Quote conversion summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuoteConversion = false);
      }
    }
  }

  Future<void> _exportQuoteQueue(List<_QuoteQueueRow> rows) async {
    setState(() => _isExportingQuoteQueue = true);
    try {
      final csvRows = <List<String>>[
        [
          'Customer',
          'Quote',
          'Status',
          'Quote Date',
          'Last Contact',
          'Age Days',
        ],
        for (final row in rows)
          [
            row.customerName,
            row.quoteNumber,
            row.status,
            row.quoteDate,
            row.lastContact,
            row.ageDays.toString(),
          ],
      ];

      await ShareService.shareCsv(
        csvRows,
        'quote_queue.csv',
        subject: 'Quote Follow-up Queue',
        text: 'Quote follow-up queue export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuoteQueue = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoiceListProvider);
    final quotesAsync = ref.watch(quoteListProvider);
    final activeBusinessId = ref.watch(activeBusinessIdProvider);
    final activeBusiness = ref.watch(activeBusinessProvider).valueOrNull;
    String money(double amount) =>
        formatMoneyForBusiness(amount, activeBusiness?.currencyCode ?? 'INR');

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: invoicesAsync.when(
        data: (allInvoices) {
          final allQuotes = quotesAsync.valueOrNull ?? const <Quote>[];
          final invoices = _filterInvoices(allInvoices);
          final quotes = _filterQuotes(allQuotes);

          // Credit notes reduce what was billed, so their component totals are
          // subtracted; notes are also not receivables.
          double signed(double amount, Invoice invoice) =>
              signedInvoiceTotal(amount, invoice.invoiceType);

          final salesTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.totalAmount, invoice),
          );
          final taxableTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.taxableAmount, invoice),
          );
          final collectedTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + invoice.amountPaid,
          );
          final pendingTotal = invoices
              .where((invoice) => !isAdjustmentNote(invoice.invoiceType))
              .fold<double>(
                0,
                (sum, invoice) => sum + invoiceBalanceDue(invoice),
              );
          final cgstTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.cgstAmount, invoice),
          );
          final sgstTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.sgstAmount, invoice),
          );
          final igstTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.igstAmount, invoice),
          );
          final cessTotal = invoices.fold<double>(
            0,
            (sum, invoice) => sum + signed(invoice.cessAmount, invoice),
          );

          return FutureBuilder<_OperationalReportData>(
            future: _loadOperationalReportData(
              businessId: activeBusinessId,
              invoices: invoices,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final operationalData =
                  snapshot.data ?? const _OperationalReportData();
              final statementRows = operationalData.customerStatementRows;
              final agingSummary = _ReceivablesAgingSummary.fromRows(
                operationalData.receivablesAgingRows,
              );

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  SegmentedButton<ReportRange>(
                    segments: const [
                      ButtonSegment(
                        value: ReportRange.currentMonth,
                        label: Text('Current Month'),
                      ),
                      ButtonSegment(
                        value: ReportRange.allTime,
                        label: Text('All Time'),
                      ),
                      ButtonSegment(
                        value: ReportRange.custom,
                        label: Text('Custom'),
                      ),
                    ],
                    selected: {_range},
                    onSelectionChanged: (selection) {
                      final nextRange = selection.first;
                      if (nextRange == ReportRange.custom &&
                          (_customStartDate == null ||
                              _customEndDate == null)) {
                        _pickCustomRange();
                        return;
                      }
                      setState(() => _range = nextRange);
                    },
                  ),
                  if (_range == ReportRange.custom) ...[
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _pickCustomRange,
                        icon: const Icon(Icons.date_range),
                        label: Text(
                          _selectedRange == null
                              ? 'Pick Date Range'
                              : '${formatDate(_selectedRange!.start)} to ${formatDate(_selectedRange!.end)}',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  _ReportTile(
                    title: 'Invoice Count',
                    value: invoices.length.toString(),
                  ),
                  _ReportTile(
                    title: 'Quote Count',
                    value: quotes.length.toString(),
                  ),
                  _ReportTile(
                    title: 'Quote Conversion Rate',
                    value: quotes.isEmpty
                        ? '0%'
                        : '${((quotes.where((quote) => quote.status == 'CONVERTED').length / quotes.length) * 100).toStringAsFixed(0)}%',
                  ),
                  _ReportTile(
                    title: 'Sales Total',
                    value: money(salesTotal),
                  ),
                  _ReportTile(
                    title: 'Taxable Total',
                    value: money(taxableTotal),
                  ),
                  _ReportTile(
                    title: 'Collected',
                    value: money(collectedTotal),
                  ),
                  _ReportTile(
                    title: 'Pending',
                    value: money(pendingTotal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Receivables Aging',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (operationalData.receivablesAgingRows.isEmpty)
                    const Text('No outstanding receivables in this range.')
                  else ...[
                    _ReportTile(
                      title: 'Current',
                      value: money(agingSummary.current),
                    ),
                    _ReportTile(
                      title: '1-30 Days',
                      value: money(agingSummary.days1To30),
                    ),
                    _ReportTile(
                      title: '31-60 Days',
                      value: money(agingSummary.days31To60),
                    ),
                    _ReportTile(
                      title: '61-90 Days',
                      value: money(agingSummary.days61To90),
                    ),
                    _ReportTile(
                      title: '90+ Days',
                      value: money(agingSummary.daysOver90),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'By Customer',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...operationalData.receivablesAgingRows.map(
                      (row) => _ReportTile(
                        title: '${row.customerName} (${row.invoiceCount})',
                        value: money(row.totalDue),
                        subtitle:
                            'Current ${money(row.current)} | 1-30 ${money(row.days1To30)} | 31-60 ${money(row.days31To60)} | 61-90 ${money(row.days61To90)} | 90+ ${money(row.daysOver90)}',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _isExportingReceivablesAging
                            ? null
                            : () => _exportReceivablesAging(
                                operationalData.receivablesAgingRows,
                              ),
                        icon: const Icon(Icons.download),
                        label: Text(
                          _isExportingReceivablesAging
                              ? 'Exporting...'
                              : 'Export Aging',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Text(
                    'Tax Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ReportTile(
                    title: 'CGST',
                    value: money(cgstTotal),
                  ),
                  _ReportTile(
                    title: 'SGST',
                    value: money(sgstTotal),
                  ),
                  _ReportTile(
                    title: 'IGST',
                    value: money(igstTotal),
                  ),
                  _ReportTile(
                    title: 'Cess',
                    value: money(cessTotal),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Customer Sales',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (operationalData.customerRows.isEmpty)
                    const Text('No customer sales in this range.')
                  else
                    ...operationalData.customerRows.map(
                      (row) => _ReportTile(
                        title: '${row.customerName} (${row.invoiceCount})',
                        value: money(row.sales),
                        subtitle:
                            'Collected ${money(row.collected)} | Pending ${money(row.pending)}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingCustomerSummary
                          ? null
                          : () => _exportCustomerSummary(
                              operationalData.customerRows,
                            ),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExportingCustomerSummary
                            ? 'Exporting...'
                            : 'Export Customer Summary',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Customer Statements',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (statementRows.isEmpty)
                    const Text('No customer statement data in this range.')
                  else ...[
                    ...statementRows.take(12).map(
                      (row) => _ReportTile(
                        title: '${row.customerName} - ${row.entryType}',
                        value: money(row.runningBalance),
                        subtitle:
                            '${formatDate(row.entryDate)} | ${row.documentNumber} | ${row.note}',
                      ),
                    ),
                    if (statementRows.length > 12)
                      Text(
                        '+ ${statementRows.length - 12} more entries',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingCustomerStatement
                          ? null
                          : () => _exportCustomerStatement(statementRows),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExportingCustomerStatement
                            ? 'Exporting...'
                            : 'Export Statements',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'HSN / SAC Tax Summary',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (operationalData.hsnRows.isEmpty)
                    const Text('No HSN / SAC data in this range.')
                  else
                    ...operationalData.hsnRows.map(
                      (row) => _ReportTile(
                        title: '${row.hsnSac} (${row.itemCount})',
                        value: money(row.taxable),
                        subtitle:
                            'CGST ${money(row.cgst)} | SGST ${money(row.sgst)} | IGST ${money(row.igst)} | Cess ${money(row.cess)}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingHsnSummary
                          ? null
                          : () => _exportHsnSummary(operationalData.hsnRows),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExportingHsnSummary
                            ? 'Exporting...'
                            : 'Export HSN Summary',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quote Conversion',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (operationalData.quoteConversionRows.isEmpty)
                    const Text('No quote conversion data in this range.')
                  else
                    ...operationalData.quoteConversionRows.map(
                      (row) => _ReportTile(
                        title: '${row.customerName} (${row.quoteCount})',
                        value:
                            '${row.conversionRate.toStringAsFixed(0)}% converted',
                        subtitle:
                            'Converted ${row.convertedCount} | Rejected ${row.rejectedCount}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingQuoteConversion
                          ? null
                          : () => _exportQuoteConversionSummary(
                              operationalData.quoteConversionRows,
                            ),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExportingQuoteConversion
                            ? 'Exporting...'
                            : 'Export Conversion Summary',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Quote Follow-up Queue',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (operationalData.quoteQueueRows.isEmpty)
                    const Text('No stale quotes in this range.')
                  else
                    ...operationalData.quoteQueueRows.map(
                      (row) => _ReportTile(
                        title: '${row.customerName} - ${row.quoteNumber}',
                        value: '${row.ageDays}d',
                        subtitle:
                            '${row.status} | Quote ${row.quoteDate} | Last contact ${row.lastContact}',
                      ),
                    ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingQuoteQueue
                          ? null
                          : () => _exportQuoteQueue(
                              operationalData.quoteQueueRows,
                            ),
                      icon: const Icon(Icons.download),
                      label: Text(
                        _isExportingQuoteQueue
                            ? 'Exporting...'
                            : 'Export Follow-up Queue',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Low Stock',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (!ref.watch(lowStockWarningsEnabledProvider))
                    const Text(
                      'Low stock warnings are turned off (see Settings).',
                    )
                  else
                    ref
                        .watch(productListProvider)
                        .maybeWhen(
                          data: (products) {
                            final low = products
                                .where(isProductLowStock)
                                .toList();
                            if (low.isEmpty) {
                              return const Text(
                                'No products at or below their reorder level.',
                              );
                            }
                            return Column(
                              children: [
                                for (final product in low.take(10))
                                  _ReportTile(
                                    title:
                                        '${product.name} (${lowStockLabel(product)})',
                                    value:
                                        '${product.stockQuantity.toStringAsFixed(2)} / reorder ${product.reorderLevel.toStringAsFixed(2)}',
                                  ),
                                if (low.length > 10)
                                  _ReportTile(
                                    title: 'And ${low.length - 10} more',
                                    value: '',
                                  ),
                              ],
                            );
                          },
                          orElse: () => const SizedBox.shrink(),
                        ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _isExportingGstr1
                          ? null
                          : () => _exportGstr1(invoices),
                      icon: const Icon(Icons.receipt_long),
                      label: Text(
                        _isExportingGstr1
                            ? 'Exporting...'
                            : 'Export GSTR-1 Summary',
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _isExportingInvoices
                              ? null
                              : () => _exportInvoices(invoices),
                          icon: const Icon(Icons.download),
                          label: Text(
                            _isExportingInvoices
                                ? 'Exporting...'
                                : 'Export Invoices',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _isExportingQuotes
                              ? null
                              : () => _exportQuotes(quotes),
                          icon: const Icon(Icons.download),
                          label: Text(
                            _isExportingQuotes
                                ? 'Exporting...'
                                : 'Export Quotes',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Future<_OperationalReportData> _loadOperationalReportData({
    required int? businessId,
    required List<Invoice> invoices,
  }) async {
    if (businessId == null || invoices.isEmpty) {
      return const _OperationalReportData();
    }

    final customerDao = ref.read(customerDaoProvider);
    final invoiceDao = ref.read(invoiceDaoProvider);
    final customers = await customerDao.getCustomersForBusiness(businessId);
    final items = await invoiceDao.getItemsForInvoices(
      invoices.map((invoice) => invoice.id).toList(),
    );
    final payments = await invoiceDao.getPaymentsForInvoices(
      invoices.map((invoice) => invoice.id).toList(),
    );

    final customerNameById = {
      for (final customer in customers) customer.id: customer.name,
    };
    final customerAggregates = <int, _CustomerAccumulator>{};
    final receivablesAgingAggregates = <int, _ReceivablesAgingAccumulator>{};
    final quoteAggregates = <int, _QuoteConversionAccumulator>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final invoice in invoices) {
      final balanceDue = invoiceBalanceDue(invoice);
      final isNote = isAdjustmentNote(invoice.invoiceType);
      final accumulator = customerAggregates.putIfAbsent(
        invoice.customerId,
        () => _CustomerAccumulator(
          customerName: customerNameById[invoice.customerId] ?? 'Unknown',
        ),
      );
      // Notes adjust an existing invoice rather than being one themselves, and
      // a credit note reduces the customer's sales.
      if (!isNote) accumulator.invoiceCount += 1;
      accumulator.sales +=
          signedInvoiceTotal(invoice.totalAmount, invoice.invoiceType);
      accumulator.collected += invoice.amountPaid;
      if (!isNote) accumulator.pending += balanceDue;

      if (!isNote && balanceDue > 0) {
        final agingAccumulator = receivablesAgingAggregates.putIfAbsent(
          invoice.customerId,
          () => _ReceivablesAgingAccumulator(
            customerName: customerNameById[invoice.customerId] ?? 'Unknown',
          ),
        );
        agingAccumulator.invoiceCount += 1;

        final dueDate = invoice.dueDate;
        final daysOverdue = dueDate == null
            ? 0
            : today
                  .difference(
                    DateTime(dueDate.year, dueDate.month, dueDate.day),
                  )
                  .inDays;
        agingAccumulator.addBalance(
          balanceDue: balanceDue,
          daysOverdue: daysOverdue,
        );
      }
    }

    final quotes = await ref
        .read(quoteDaoProvider)
        .getQuotesForBusiness(businessId);
    final selectedRange = _selectedRange;
    for (final quote in quotes) {
      if (selectedRange != null &&
          (quote.invoiceDate.isBefore(selectedRange.start) ||
              quote.invoiceDate.isAfter(selectedRange.end))) {
        continue;
      }
      final accumulator = quoteAggregates.putIfAbsent(
        quote.customerId,
        () => _QuoteConversionAccumulator(
          customerName: customerNameById[quote.customerId] ?? 'Unknown',
        ),
      );
      accumulator.quoteCount += 1;
      if (quote.status == 'CONVERTED') {
        accumulator.convertedCount += 1;
      } else if (quote.status == 'REJECTED') {
        accumulator.rejectedCount += 1;
      }
    }

    final hsnAggregates = <String, _HsnAccumulator>{};
    for (final item in items) {
      final hsnKey = item.hsnSac.isEmpty ? 'UNSPECIFIED' : item.hsnSac;
      final accumulator = hsnAggregates.putIfAbsent(
        hsnKey,
        () => _HsnAccumulator(hsnSac: hsnKey),
      );
      accumulator.itemCount += 1;
      accumulator.taxable += item.taxableAmount;
      accumulator.cgst += item.cgstAmount;
      accumulator.sgst += item.sgstAmount;
      accumulator.igst += item.igstAmount;
      accumulator.cess += item.cessAmount;
    }

    final customerRows =
        customerAggregates.values
            .map(
              (value) => _CustomerReportRow(
                customerName: value.customerName,
                invoiceCount: value.invoiceCount,
                sales: value.sales,
                collected: value.collected,
                pending: value.pending,
              ),
            )
            .toList()
          ..sort((a, b) => b.sales.compareTo(a.sales));

    final customerStatementRows = buildCustomerStatementRows(
      customers: customers,
      invoices: invoices,
      payments: payments,
    );

    final hsnRows =
        hsnAggregates.values
            .map(
              (value) => _HsnReportRow(
                hsnSac: value.hsnSac,
                itemCount: value.itemCount,
                taxable: value.taxable,
                cgst: value.cgst,
                sgst: value.sgst,
                igst: value.igst,
                cess: value.cess,
              ),
            )
            .toList()
          ..sort((a, b) => b.taxable.compareTo(a.taxable));

    final receivablesAgingRows =
        receivablesAgingAggregates.values
            .map(
              (value) => _ReceivablesAgingRow(
                customerName: value.customerName,
                invoiceCount: value.invoiceCount,
                current: value.current,
                days1To30: value.days1To30,
                days31To60: value.days31To60,
                days61To90: value.days61To90,
                daysOver90: value.daysOver90,
              ),
            )
            .toList()
          ..sort((a, b) => b.totalDue.compareTo(a.totalDue));

    final quoteConversionRows =
        quoteAggregates.values
            .map(
              (value) => _QuoteConversionRow(
                customerName: value.customerName,
                quoteCount: value.quoteCount,
                convertedCount: value.convertedCount,
                rejectedCount: value.rejectedCount,
                conversionRate: value.quoteCount == 0
                    ? 0
                    : (value.convertedCount / value.quoteCount) * 100,
              ),
            )
            .toList()
          ..sort((a, b) => b.conversionRate.compareTo(a.conversionRate));

    final quoteQueueRows =
        quotes
            .where(
              (quote) =>
                  quote.status != 'CONVERTED' && quote.status != 'REJECTED',
            )
            .where(
              (quote) => DateTime.now().difference(quote.updatedAt).inDays >= 3,
            )
            .map(
              (quote) => _QuoteQueueRow(
                customerName: customerNameById[quote.customerId] ?? 'Unknown',
                quoteNumber: quote.invoiceNumber,
                status: quote.status,
                quoteDate: quote.invoiceDate.toIso8601String().split('T')[0],
                lastContact: quote.updatedAt.toIso8601String().split('T')[0],
                ageDays: DateTime.now().difference(quote.updatedAt).inDays,
              ),
            )
            .toList()
          ..sort((a, b) => b.ageDays.compareTo(a.ageDays));

    return _OperationalReportData(
      customerRows: customerRows,
      customerStatementRows: customerStatementRows,
      receivablesAgingRows: receivablesAgingRows,
      hsnRows: hsnRows,
      quoteConversionRows: quoteConversionRows,
      quoteQueueRows: quoteQueueRows,
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _ReportTile({required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _OperationalReportData {
  final List<_CustomerReportRow> customerRows;
  final List<CustomerStatementRow> customerStatementRows;
  final List<_ReceivablesAgingRow> receivablesAgingRows;
  final List<_HsnReportRow> hsnRows;
  final List<_QuoteConversionRow> quoteConversionRows;
  final List<_QuoteQueueRow> quoteQueueRows;

  const _OperationalReportData({
    this.customerRows = const [],
    this.customerStatementRows = const [],
    this.receivablesAgingRows = const [],
    this.hsnRows = const [],
    this.quoteConversionRows = const [],
    this.quoteQueueRows = const [],
  });
}

class _CustomerAccumulator {
  final String customerName;
  int invoiceCount = 0;
  double sales = 0;
  double collected = 0;
  double pending = 0;

  _CustomerAccumulator({required this.customerName});
}

class _CustomerReportRow {
  final String customerName;
  final int invoiceCount;
  final double sales;
  final double collected;
  final double pending;

  const _CustomerReportRow({
    required this.customerName,
    required this.invoiceCount,
    required this.sales,
    required this.collected,
    required this.pending,
  });
}

class _ReceivablesAgingAccumulator {
  final String customerName;
  int invoiceCount = 0;
  double current = 0;
  double days1To30 = 0;
  double days31To60 = 0;
  double days61To90 = 0;
  double daysOver90 = 0;

  _ReceivablesAgingAccumulator({required this.customerName});

  void addBalance({required double balanceDue, required int daysOverdue}) {
    if (daysOverdue <= 0) {
      current += balanceDue;
    } else if (daysOverdue <= 30) {
      days1To30 += balanceDue;
    } else if (daysOverdue <= 60) {
      days31To60 += balanceDue;
    } else if (daysOverdue <= 90) {
      days61To90 += balanceDue;
    } else {
      daysOver90 += balanceDue;
    }
  }
}

class _ReceivablesAgingRow {
  final String customerName;
  final int invoiceCount;
  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double daysOver90;

  double get totalDue =>
      current + days1To30 + days31To60 + days61To90 + daysOver90;

  const _ReceivablesAgingRow({
    required this.customerName,
    required this.invoiceCount,
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
  });
}

class _ReceivablesAgingSummary {
  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double daysOver90;

  const _ReceivablesAgingSummary({
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
  });

  factory _ReceivablesAgingSummary.fromRows(List<_ReceivablesAgingRow> rows) {
    return _ReceivablesAgingSummary(
      current: rows.fold<double>(0, (sum, row) => sum + row.current),
      days1To30: rows.fold<double>(0, (sum, row) => sum + row.days1To30),
      days31To60: rows.fold<double>(0, (sum, row) => sum + row.days31To60),
      days61To90: rows.fold<double>(0, (sum, row) => sum + row.days61To90),
      daysOver90: rows.fold<double>(0, (sum, row) => sum + row.daysOver90),
    );
  }
}

class _HsnAccumulator {
  final String hsnSac;
  int itemCount = 0;
  double taxable = 0;
  double cgst = 0;
  double sgst = 0;
  double igst = 0;
  double cess = 0;

  _HsnAccumulator({required this.hsnSac});
}

class _HsnReportRow {
  final String hsnSac;
  final int itemCount;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;

  const _HsnReportRow({
    required this.hsnSac,
    required this.itemCount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
  });
}

class _QuoteConversionAccumulator {
  final String customerName;
  int quoteCount = 0;
  int convertedCount = 0;
  int rejectedCount = 0;

  _QuoteConversionAccumulator({required this.customerName});
}

class _QuoteConversionRow {
  final String customerName;
  final int quoteCount;
  final int convertedCount;
  final int rejectedCount;
  final double conversionRate;

  const _QuoteConversionRow({
    required this.customerName,
    required this.quoteCount,
    required this.convertedCount,
    required this.rejectedCount,
    required this.conversionRate,
  });
}

class _QuoteQueueRow {
  final String customerName;
  final String quoteNumber;
  final String status;
  final String quoteDate;
  final String lastContact;
  final int ageDays;

  const _QuoteQueueRow({
    required this.customerName,
    required this.quoteNumber,
    required this.status,
    required this.quoteDate,
    required this.lastContact,
    required this.ageDays,
  });
}
