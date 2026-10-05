import '../../database/app_database.dart';
import 'invoice_status.dart';
import 'money.dart';

/// One invoice's margin contribution.
class MarginInvoiceRow {
  const MarginInvoiceRow({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.invoiceDate,
    required this.customerName,
    required this.revenue,
    required this.cogs,
    required this.margin,
    required this.noCostBasisLines,
  });

  final int invoiceId;
  final String invoiceNumber;
  final DateTime invoiceDate;
  final String customerName;
  final double revenue;
  final double cogs;
  final double margin;
  final int noCostBasisLines;
}

/// Margin aggregated per customer.
class MarginCustomerRow {
  const MarginCustomerRow({
    required this.customerId,
    required this.customerName,
    required this.invoiceCount,
    required this.revenue,
    required this.cogs,
    required this.margin,
    required this.noCostBasisLines,
  });

  final int customerId;
  final String customerName;
  final int invoiceCount;
  final double revenue;
  final double cogs;
  final double margin;
  final int noCostBasisLines;
}

/// Margin aggregated per product.
class MarginProductRow {
  const MarginProductRow({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.revenue,
    required this.cogs,
    required this.margin,
    required this.noCostBasis,
  });

  final int? productId;
  final String productName;
  final double quantity;
  final double revenue;
  final double cogs;
  final double margin;

  /// True when any line of this product had no purchase price, so its COGS
  /// (and therefore its margin) is understated rather than wrong.
  final bool noCostBasis;
}

/// The full margin report for a period.
class MarginReport {
  const MarginReport({
    required this.invoiceRows,
    required this.customerRows,
    required this.productRows,
    required this.totalRevenue,
    required this.totalCogs,
    required this.noCostBasisLineCount,
  });

  final List<MarginInvoiceRow> invoiceRows;
  final List<MarginCustomerRow> customerRows;
  final List<MarginProductRow> productRows;
  final double totalRevenue;
  final double totalCogs;

  /// Lines whose product had no purchase price; their COGS contributes zero,
  /// so the reported margin for those lines is an upper bound.
  final int noCostBasisLineCount;

  double get totalMargin => round2(totalRevenue - totalCogs);

  double get marginPercent =>
      totalRevenue == 0 ? 0 : (totalMargin / totalRevenue) * 100;

  bool get isEmpty => invoiceRows.isEmpty;
}

/// Computes the profit/margin report over issued documents.
///
/// Revenue is the taxable amount (GST is money the business collects, not
/// earns); COGS is line quantity times the product's purchase price. Credit
/// notes reverse both their revenue and their COGS. Lines whose product has
/// no cost basis contribute revenue but zero COGS and are counted in
/// [MarginReport.noCostBasisLineCount] so the report can say so explicitly.
/// Every money boundary is rounded with [round2] so the report reconciles
/// with the invoice totals to the paise.
MarginReport computeMarginReport({
  required List<Invoice> invoices,
  required List<InvoiceItem> items,
  required List<Product> products,
  required List<Customer> customers,
}) {
  final productById = {for (final product in products) product.id: product};
  final customerById = {for (final customer in customers) customer.id: customer};

  final counted = invoices
      .where((invoice) => isInvoiceCountedInTotals(invoice.status))
      .toList()
    ..sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));

  final itemsByInvoice = <int, List<InvoiceItem>>{};
  for (final item in items) {
    itemsByInvoice.putIfAbsent(item.invoiceId, () => []).add(item);
  }

  final invoiceRows = <MarginInvoiceRow>[];
  final customersAgg = <int, List<double>>{}; // count, revenue, cogs, noCost
  final productsAgg = <int?, List<dynamic>>{}; // name, qty, revenue, cogs, noCost
  var totalRevenue = 0.0;
  var totalCogs = 0.0;
  var noCostBasisLineCount = 0;

  for (final invoice in counted) {
    var invoiceRevenue = 0.0;
    var invoiceCogs = 0.0;
    var invoiceNoCost = 0;
    final customerAgg = customersAgg.putIfAbsent(
      invoice.customerId,
      () => [0.0, 0.0, 0.0, 0.0], // count, revenue, cogs, noCostBasis lines
    );
    customerAgg[0] += 1;

    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      final sign = invoice.invoiceType == 'CREDIT_NOTE' ? -1.0 : 1.0;
      final product = item.productId == null
          ? null
          : productById[item.productId!];
      final hasCostBasis = product?.purchasePrice != null;

      final revenue = round2(sign * item.taxableAmount);
      final cogs = hasCostBasis
          ? round2(sign * item.quantity * product!.purchasePrice!)
          : 0.0;
      if (!hasCostBasis) {
        invoiceNoCost += 1;
        noCostBasisLineCount += 1;
        customerAgg[3] += 1;
      }

      invoiceRevenue = round2(invoiceRevenue + revenue);
      invoiceCogs = round2(invoiceCogs + cogs);
      customerAgg[1] = round2(customerAgg[1] + revenue);
      customerAgg[2] = round2(customerAgg[2] + cogs);

      final productAgg = productsAgg.putIfAbsent(item.productId, () =>
          [item.name, 0.0, 0.0, 0.0, false]);
      productAgg[1] = round2((productAgg[1] as double) + sign * item.quantity);
      productAgg[2] = round2((productAgg[2] as double) + revenue);
      productAgg[3] = round2((productAgg[3] as double) + cogs);
      if (!hasCostBasis) productAgg[4] = true;
    }

    invoiceRows.add(
      MarginInvoiceRow(
        invoiceId: invoice.id,
        invoiceNumber: invoice.invoiceNumber,
        invoiceDate: invoice.invoiceDate,
        customerName: customerById[invoice.customerId]?.name ?? '',
        revenue: invoiceRevenue,
        cogs: invoiceCogs,
        margin: round2(invoiceRevenue - invoiceCogs),
        noCostBasisLines: invoiceNoCost,
      ),
    );
    totalRevenue = round2(totalRevenue + invoiceRevenue);
    totalCogs = round2(totalCogs + invoiceCogs);
  }

  final customerRows = customersAgg.entries.map((entry) {
    final agg = entry.value;
    return MarginCustomerRow(
      customerId: entry.key,
      customerName: customerById[entry.key]?.name ?? '',
      invoiceCount: agg[0].toInt(),
      revenue: agg[1],
      cogs: agg[2],
      margin: round2(agg[1] - agg[2]),
      noCostBasisLines: agg[3].toInt(),
    );
  }).toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));

  final productRows = productsAgg.entries.map((entry) {
    final agg = entry.value;
    return MarginProductRow(
      productId: entry.key,
      productName: agg[0] as String,
      quantity: agg[1] as double,
      revenue: agg[2] as double,
      cogs: agg[3] as double,
      margin: round2((agg[2] as double) - (agg[3] as double)),
      noCostBasis: agg[4] as bool,
    );
  }).toList()
    ..sort((a, b) => b.revenue.compareTo(a.revenue));

  return MarginReport(
    invoiceRows: invoiceRows,
    customerRows: customerRows,
    productRows: productRows,
    totalRevenue: totalRevenue,
    totalCogs: totalCogs,
    noCostBasisLineCount: noCostBasisLineCount,
  );
}
