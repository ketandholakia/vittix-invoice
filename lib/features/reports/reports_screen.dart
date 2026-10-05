import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/gstr1_export.dart';
import '../../core/utils/gstr1_validation.dart';
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

part 'reports_screen_exports.dart';
part 'reports_screen_data.dart';
part 'reports_screen_widgets.dart';

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
                          : _exportGstr1,
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
}
