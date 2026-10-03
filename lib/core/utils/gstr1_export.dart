import '../../database/app_database.dart';
import 'invoice_status.dart';

/// Builds a GSTR-1 style, sectioned summary an accountant can work from:
/// B2B invoice rows, a B2CS (unregistered) consolidation, CDNR credit/debit
/// note rows, and an HSN-wise summary.
///
/// Returns rows ready for CSV sharing. Draft and cancelled documents are
/// excluded, and credit notes reduce the HSN totals.
List<List<String>> buildGstr1Rows({
  required List<Customer> customers,
  required List<Invoice> invoices,
  required List<InvoiceItem> items,
}) {
  final customerById = {for (final customer in customers) customer.id: customer};
  final itemsByInvoice = <int, List<InvoiceItem>>{};
  for (final item in items) {
    itemsByInvoice.putIfAbsent(item.invoiceId, () => []).add(item);
  }

  final counted = invoices
      .where((invoice) => isInvoiceCountedInTotals(invoice.status))
      .toList()
    ..sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));

  String money(double value) => value.toStringAsFixed(2);
  String date(DateTime value) => value.toIso8601String().split('T')[0];
  String? gstinOf(Invoice invoice) {
    final gstin = customerById[invoice.customerId]?.gstin?.trim();
    return (gstin == null || gstin.isEmpty) ? null : gstin;
  }

  final rows = <List<String>>[];

  // --- B2B: registered recipients ------------------------------------------
  rows.add(['Section', 'B2B']);
  rows.add([
    'GSTIN',
    'Receiver',
    'Invoice No',
    'Date',
    'Invoice Value',
    'Taxable',
    'CGST',
    'SGST',
    'IGST',
    'Cess',
  ]);
  for (final invoice in counted) {
    if (isAdjustmentNote(invoice.invoiceType)) continue;
    final gstin = gstinOf(invoice);
    if (gstin == null) continue;
    rows.add([
      gstin,
      customerById[invoice.customerId]?.name ?? '',
      invoice.invoiceNumber,
      date(invoice.invoiceDate),
      money(invoice.totalAmount),
      money(invoice.taxableAmount),
      money(invoice.cgstAmount),
      money(invoice.sgstAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
    ]);
  }

  // --- B2CS: unregistered, consolidated by place of supply and rate --------
  rows.add(const []);
  rows.add(['Section', 'B2CS']);
  rows.add([
    'Place of Supply',
    'Rate %',
    'Taxable',
    'CGST',
    'SGST',
    'IGST',
    'Cess',
  ]);
  final b2cs = <String, List<double>>{};
  for (final invoice in counted) {
    if (isAdjustmentNote(invoice.invoiceType)) continue;
    if (gstinOf(invoice) != null) continue;
    final tax =
        invoice.cgstAmount + invoice.sgstAmount + invoice.igstAmount;
    final rate = invoice.taxableAmount == 0
        ? 0.0
        : (tax / invoice.taxableAmount) * 100;
    final key = '${invoice.placeOfSupply}|${rate.toStringAsFixed(1)}';
    final bucket = b2cs.putIfAbsent(key, () => [0, 0, 0, 0, 0]);
    bucket[0] += invoice.taxableAmount;
    bucket[1] += invoice.cgstAmount;
    bucket[2] += invoice.sgstAmount;
    bucket[3] += invoice.igstAmount;
    bucket[4] += invoice.cessAmount;
  }
  for (final entry in b2cs.entries) {
    final parts = entry.key.split('|');
    rows.add([
      parts[0],
      parts[1],
      money(entry.value[0]),
      money(entry.value[1]),
      money(entry.value[2]),
      money(entry.value[3]),
      money(entry.value[4]),
    ]);
  }

  // --- CDNR: credit / debit notes ------------------------------------------
  rows.add(const []);
  rows.add(['Section', 'CDNR']);
  rows.add([
    'Note No',
    'Type',
    'Date',
    'GSTIN',
    'Receiver',
    'Against',
    'Note Value',
    'Taxable',
    'CGST',
    'SGST',
    'IGST',
    'Cess',
  ]);
  for (final invoice in counted) {
    if (!isAdjustmentNote(invoice.invoiceType)) continue;
    final reference = invoice.referenceInvoiceId == null
        ? ''
        : invoices
              .firstWhere(
                (candidate) => candidate.id == invoice.referenceInvoiceId,
                orElse: () => invoice,
              )
              .invoiceNumber;
    rows.add([
      invoice.invoiceNumber,
      invoice.invoiceType,
      date(invoice.invoiceDate),
      gstinOf(invoice) ?? '',
      customerById[invoice.customerId]?.name ?? '',
      reference,
      money(invoice.totalAmount),
      money(invoice.taxableAmount),
      money(invoice.cgstAmount),
      money(invoice.sgstAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
    ]);
  }

  // --- HSN-wise summary ----------------------------------------------------
  rows.add(const []);
  rows.add(['Section', 'HSN']);
  rows.add(['HSN/SAC', 'Taxable', 'CGST', 'SGST', 'IGST', 'Cess']);
  final hsn = <String, List<double>>{};
  for (final invoice in counted) {
    final sign = invoice.invoiceType == 'CREDIT_NOTE' ? -1 : 1;
    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      final code = item.hsnSac.trim().isEmpty
          ? 'UNSPECIFIED'
          : item.hsnSac.trim();
      final bucket = hsn.putIfAbsent(code, () => [0, 0, 0, 0, 0]);
      bucket[0] += sign * item.taxableAmount;
      bucket[1] += sign * item.cgstAmount;
      bucket[2] += sign * item.sgstAmount;
      bucket[3] += sign * item.igstAmount;
      bucket[4] += sign * item.cessAmount;
    }
  }
  final hsnCodes = hsn.keys.toList()..sort();
  for (final code in hsnCodes) {
    final bucket = hsn[code]!;
    rows.add([
      code,
      money(bucket[0]),
      money(bucket[1]),
      money(bucket[2]),
      money(bucket[3]),
      money(bucket[4]),
    ]);
  }

  return rows;
}
