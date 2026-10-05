// The Profit & Margin report section. Reads the full book through uncapped
// DAO queries — like the GSTR-1 export, a margin report must never silently
// truncate at the invoice list's UI window.

part of 'reports_screen.dart';

class _MarginSection extends ConsumerStatefulWidget {
  const _MarginSection({required this.range, required this.currencyCode});

  final DateTimeRange? range;
  final String currencyCode;

  @override
  ConsumerState<_MarginSection> createState() => _MarginSectionState();
}

class _MarginSectionState extends ConsumerState<_MarginSection> {
  Future<MarginReport>? _future;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    // The watched list providers act as refresh signals only — a new invoice
    // or a product price change recomputes the report — while the numbers
    // themselves come from the uncapped DAO queries.
    ref.listenManual(invoiceListProvider, (_, _) {
      if (mounted) setState(() => _future = null);
    });
    ref.listenManual(productListProvider, (_, _) {
      if (mounted) setState(() => _future = null);
    });
  }

  @override
  void didUpdateWidget(covariant _MarginSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.range != oldWidget.range ||
        widget.currencyCode != oldWidget.currencyCode) {
      setState(() => _future = null);
    }
  }

  Future<MarginReport> _load() async {
    final businessId = ref.read(activeBusinessIdProvider);
    if (businessId == null) {
      return const MarginReport(
        invoiceRows: [],
        customerRows: [],
        productRows: [],
        totalRevenue: 0,
        totalCogs: 0,
        noCostBasisLineCount: 0,
      );
    }
    final invoiceDao = ref.read(invoiceDaoProvider);
    final range = widget.range;
    final invoices = range == null
        ? await invoiceDao.getInvoicesForBusiness(businessId)
        : await invoiceDao.getInvoicesForBusinessBetween(
            businessId,
            range.start,
            range.end,
          );
    final items = await invoiceDao.getItemsForInvoices(
      invoices.map((invoice) => invoice.id).toList(),
    );
    final products = await ref
        .read(productDaoProvider)
        .getProductsForBusiness(businessId);
    final customers = await ref
        .read(customerDaoProvider)
        .getCustomersForBusiness(businessId);
    return computeMarginReport(
      invoices: invoices,
      items: items,
      products: products,
      customers: customers,
    );
  }

  String _money(double amount) =>
      formatMoneyForBusiness(amount, widget.currencyCode);

  Future<void> _export(MarginReport report) async {
    setState(() => _isExporting = true);
    try {
      String pct(double margin) =>
          report.totalRevenue == 0 ? '' : '${(margin / report.totalRevenue * 100).toStringAsFixed(1)}%';

      final rows = <List<String>>[
        const ['Section', 'TOTALS'],
        [
          'Revenue',
          'COGS',
          'Margin',
          'Margin %',
          'Lines without cost basis',
        ],
        [
          report.totalRevenue.toStringAsFixed(2),
          report.totalCogs.toStringAsFixed(2),
          report.totalMargin.toStringAsFixed(2),
          pct(report.totalMargin),
          report.noCostBasisLineCount.toString(),
        ],
        const [],
        const ['Section', 'INVOICES'],
        const ['Invoice No', 'Date', 'Customer', 'Revenue', 'COGS', 'Margin',
          'No-cost-basis lines'],
        for (final row in report.invoiceRows)
          [
            row.invoiceNumber,
            row.invoiceDate.toIso8601String().split('T')[0],
            row.customerName,
            row.revenue.toStringAsFixed(2),
            row.cogs.toStringAsFixed(2),
            row.margin.toStringAsFixed(2),
            row.noCostBasisLines.toString(),
          ],
        const [],
        const ['Section', 'CUSTOMERS'],
        const ['Customer', 'Invoices', 'Revenue', 'COGS', 'Margin',
          'No-cost-basis lines'],
        for (final row in report.customerRows)
          [
            row.customerName,
            row.invoiceCount.toString(),
            row.revenue.toStringAsFixed(2),
            row.cogs.toStringAsFixed(2),
            row.margin.toStringAsFixed(2),
            row.noCostBasisLines.toString(),
          ],
        const [],
        const ['Section', 'PRODUCTS'],
        const ['Product', 'Quantity', 'Revenue', 'COGS', 'Margin',
          'No cost basis'],
        for (final row in report.productRows)
          [
            row.productName,
            row.quantity.toStringAsFixed(2),
            row.revenue.toStringAsFixed(2),
            row.cogs.toStringAsFixed(2),
            row.margin.toStringAsFixed(2),
            row.noCostBasis ? 'yes' : 'no',
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'margin_report.csv',
        subject: 'Profit & Margin Report',
        text: 'Profit and margin report export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profit & Margin',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        FutureBuilder<MarginReport>(
          future: _future ??= _load(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            final report = snapshot.data!;
            if (report.isEmpty) {
              return const Text('No issued invoices in this range.');
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ReportTile(
                  title: 'Revenue (taxable)',
                  value: _money(report.totalRevenue),
                  subtitle:
                      'Issued invoices in range, GST excluded. Credit notes '
                      'reduce revenue.',
                ),
                _ReportTile(
                  title: 'Cost of goods sold',
                  value: _money(report.totalCogs),
                  subtitle: 'Line quantity x product purchase price.',
                ),
                _ReportTile(
                  title: 'Gross margin',
                  value:
                      '${_money(report.totalMargin)} '
                      '(${report.marginPercent.toStringAsFixed(1)}%)',
                  subtitle: report.totalMargin < 0
                      ? 'Negative margin: costs exceed revenue in this range.'
                      : null,
                ),
                if (report.noCostBasisLineCount > 0)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      '${report.noCostBasisLineCount} line(s) sell products '
                      'with no purchase price set — their cost is unknown, '
                      'so the margin above is an upper bound.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Top Customers',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final row in report.customerRows.take(5))
                  _ReportTile(
                    title: row.customerName,
                    value: _money(row.margin),
                    subtitle:
                        'Revenue ${_money(row.revenue)} | COGS '
                        '${_money(row.cogs)} | ${row.invoiceCount} '
                        'document(s)'
                        '${row.noCostBasisLines > 0 ? ' | ${row.noCostBasisLines} line(s) without cost basis' : ''}',
                  ),
                const SizedBox(height: 8),
                Text(
                  'Top Products',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                for (final row in report.productRows.take(5))
                  _ReportTile(
                    title:
                        '${row.productName}${row.noCostBasis ? ' *' : ''}',
                    value: _money(row.margin),
                    subtitle:
                        'Qty ${row.quantity.toStringAsFixed(2)} | Revenue '
                        '${_money(row.revenue)} | COGS ${_money(row.cogs)}',
                  ),
                if (report.productRows.any((row) => row.noCostBasis))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '* products with no purchase price on file.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    onPressed: _isExporting ? null : () => _export(report),
                    icon: const Icon(Icons.download),
                    label: Text(
                      _isExporting ? 'Exporting...' : 'Export Margin Report',
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
