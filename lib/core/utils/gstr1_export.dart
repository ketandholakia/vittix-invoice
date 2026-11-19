import '../../database/app_database.dart';
import 'invoice_status.dart';
import 'invoice_type.dart';

/// B2CL/CDNUR threshold: inter-state supplies and notes to unregistered
/// recipients above this invoice value are reported document-wise, not
/// consolidated.
const double b2clInvoiceValueThreshold = 250000;

/// Gross invoice value: the document's own total before the buyer's TDS
/// deduction. GST return rows must carry the gross value; receivables keep
/// using [Invoice.totalAmount], which is net of TDS.
double grossInvoiceValue(Invoice invoice) => invoice.totalAmount + invoice.tdsAmount;

/// Builds a GSTR-1 style, sectioned summary an accountant can work from:
///
/// - B2B invoice rows (registered recipients, gross document value),
/// - B2CL for large inter-state supplies to unregistered recipients,
/// - B2CS consolidated rate-wise from line items for the rest, with credit
///   notes netted and debit notes added,
/// - an EXP/SEZ section for export supplies,
/// - CDNR credit/debit note rows (registered recipients) and CDNUR rows
///   (unregistered recipients above the B2CL threshold),
/// - a documents-issued section per number series, where cancelled
///   documents are reported and nowhere else,
/// - an HSN-wise summary.
///
/// Returns rows ready for CSV sharing. Draft documents are excluded
/// everywhere; Bills of Supply (exempt / composition supplies) never appear
/// — composition filers report through GSTR-4, not GSTR-1.
List<List<String>> buildGstr1Rows({
  required List<Customer> customers,
  required List<Invoice> invoices,
  required List<InvoiceItem> items,
  required int businessStateCode,
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

  bool isForeignSupply(Invoice invoice) =>
      invoice.supplyType == 'EXPORT' || invoice.supplyType == 'SEZ';

  bool isTaxableSupply(Invoice invoice) =>
      !isAdjustmentNote(invoice.invoiceType) &&
      !isForeignSupply(invoice) &&
      invoice.invoiceType != billOfSupplyType;

  /// Large inter-state supply to an unregistered recipient: reported
  /// document-wise in B2CL rather than consolidated in B2CS.
  bool isB2clSupply(Invoice invoice) =>
      isTaxableSupply(invoice) &&
      gstinOf(invoice) == null &&
      invoice.placeOfSupply != businessStateCode &&
      grossInvoiceValue(invoice) > b2clInvoiceValueThreshold;

  String rateLabel(double rate) =>
      rate % 1 == 0 ? rate.toStringAsFixed(0) : rate.toString();

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
    if (!isTaxableSupply(invoice)) continue;
    final gstin = gstinOf(invoice);
    if (gstin == null) continue;
    rows.add([
      gstin,
      customerById[invoice.customerId]?.name ?? '',
      invoice.invoiceNumber,
      date(invoice.invoiceDate),
      money(grossInvoiceValue(invoice)),
      money(invoice.taxableAmount),
      money(invoice.cgstAmount),
      money(invoice.sgstAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
    ]);
  }

  // --- B2CL: large inter-state supplies to unregistered recipients ---------
  rows.add(const []);
  rows.add(['Section', 'B2CL']);
  rows.add([
    'Receiver',
    'Invoice No',
    'Date',
    'Invoice Value',
    'Taxable',
    'IGST',
    'Cess',
    'Place of Supply',
  ]);
  for (final invoice in counted) {
    if (!isB2clSupply(invoice)) continue;
    rows.add([
      customerById[invoice.customerId]?.name ?? '',
      invoice.invoiceNumber,
      date(invoice.invoiceDate),
      money(grossInvoiceValue(invoice)),
      money(invoice.taxableAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
      invoice.placeOfSupply.toString(),
    ]);
  }

  // --- B2CS: unregistered, consolidated rate-wise from the lines -----------
  //
  // The rate-wise split must come from the line items, not the invoice
  // totals: a single document can carry lines at several GST rates, and a
  // blended per-invoice rate is not a valid B2CS key. Credit notes to
  // unregistered recipients reduce their buckets; debit notes add.
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
  void addB2csLine(Invoice invoice, InvoiceItem item, double sign) {
    final key =
        '${invoice.placeOfSupply}|${rateLabel(item.gstRate)}';
    final bucket = b2cs.putIfAbsent(key, () => [0, 0, 0, 0, 0]);
    bucket[0] += sign * item.taxableAmount;
    bucket[1] += sign * item.cgstAmount;
    bucket[2] += sign * item.sgstAmount;
    bucket[3] += sign * item.igstAmount;
    bucket[4] += sign * item.cessAmount;
  }

  for (final invoice in counted) {
    if (!isTaxableSupply(invoice)) continue;
    if (gstinOf(invoice) != null) continue; // registered -> B2B
    if (isB2clSupply(invoice)) continue; // large inter-state -> B2CL
    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      addB2csLine(invoice, item, 1);
    }
  }
  for (final invoice in counted) {
    if (!isAdjustmentNote(invoice.invoiceType)) continue;
    if (isForeignSupply(invoice)) continue; // adjusts EXP/SEZ, stays in CDNR
    if (gstinOf(invoice) != null) continue; // registered -> CDNR
    if (grossInvoiceValue(invoice) > b2clInvoiceValueThreshold) {
      continue; // large unregistered note -> CDNUR
    }
    final sign = invoice.invoiceType == 'CREDIT_NOTE' ? -1.0 : 1.0;
    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      addB2csLine(invoice, item, sign);
    }
  }
  final b2csKeys = b2cs.keys.toList()..sort();
  for (final key in b2csKeys) {
    final bucket = b2cs[key]!;
    // A note can net a bucket down to zero; an all-zero row is noise.
    if (bucket.every((value) => value == 0)) continue;
    final parts = key.split('|');
    rows.add([
      parts[0],
      parts[1],
      money(bucket[0]),
      money(bucket[1]),
      money(bucket[2]),
      money(bucket[3]),
      money(bucket[4]),
    ]);
  }

  // --- EXP/SEZ: export supplies ---------------------------------------------
  // Type encodes the GSTR-1 payment category: WPAY (with payment of tax) or
  // WOPAY (under LUT, zero-rated). Port/shipping-bill columns are left blank
  // because the app does not capture them.
  rows.add(const []);
  rows.add(['Section', 'EXP/SEZ']);
  rows.add([
    'Type',
    'GSTIN',
    'Invoice No',
    'Date',
    'Port Code',
    'Shipping Bill',
    'Taxable',
    'IGST',
    'Cess',
  ]);
  for (final invoice in counted) {
    if (isAdjustmentNote(invoice.invoiceType)) continue;
    if (invoice.invoiceType == billOfSupplyType) continue;
    if (!isForeignSupply(invoice)) continue;
    final category = invoice.supplyType == 'SEZ' ? 'SEZ' : 'EXP';
    final payment = invoice.exportWithLut ? 'WOPAY' : 'WPAY';
    rows.add([
      '$category-$payment',
      gstinOf(invoice) ?? '',
      invoice.invoiceNumber,
      date(invoice.invoiceDate),
      '',
      '',
      money(invoice.taxableAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
    ]);
  }

  // --- CDNR: notes to registered recipients ---------------------------------
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
    if (gstinOf(invoice) == null) continue; // unregistered -> CDNUR/B2CS
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
      money(grossInvoiceValue(invoice)),
      money(invoice.taxableAmount),
      money(invoice.cgstAmount),
      money(invoice.sgstAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
    ]);
  }

  // --- CDNUR: large notes to unregistered recipients ------------------------
  rows.add(const []);
  rows.add(['Section', 'CDNUR']);
  rows.add([
    'Note No',
    'Type',
    'Date',
    'Receiver',
    'Note Value',
    'Taxable',
    'CGST',
    'SGST',
    'IGST',
    'Cess',
    'Place of Supply',
  ]);
  for (final invoice in counted) {
    if (!isAdjustmentNote(invoice.invoiceType)) continue;
    if (isForeignSupply(invoice)) continue;
    if (gstinOf(invoice) != null) continue; // registered -> CDNR
    if (grossInvoiceValue(invoice) <= b2clInvoiceValueThreshold) {
      continue; // small unregistered note -> nets into B2CS
    }
    rows.add([
      invoice.invoiceNumber,
      invoice.invoiceType,
      date(invoice.invoiceDate),
      customerById[invoice.customerId]?.name ?? '',
      money(grossInvoiceValue(invoice)),
      money(invoice.taxableAmount),
      money(invoice.cgstAmount),
      money(invoice.sgstAmount),
      money(invoice.igstAmount),
      money(invoice.cessAmount),
      invoice.placeOfSupply.toString(),
    ]);
  }

  // --- Documents issued: one row per number series --------------------------
  // Cancelled documents are reported here and nowhere else. Drafts were
  // never issued and Bills of Supply never reach GSTR-1.
  rows.add(const []);
  rows.add(['Section', 'Documents issued']);
  rows.add(['Series', 'First Number', 'Last Number', 'Total', 'Cancelled']);
  final issued = invoices
      .where((invoice) =>
          invoice.status != 'DRAFT' &&
          invoice.invoiceType != billOfSupplyType)
      .toList();
  final seriesGroups = <String, List<Invoice>>{};
  for (final invoice in issued) {
    // The series is the type plus the number's non-numeric prefix, so a
    // format change mid-year starts a new series row.
    final prefix = invoice.invoiceNumber
        .replaceFirst(RegExp(r'\d+$'), '');
    final key = '${invoice.invoiceType}|$prefix';
    seriesGroups.putIfAbsent(key, () => []).add(invoice);
  }
  final seriesKeys = seriesGroups.keys.toList()..sort();
  for (final key in seriesKeys) {
    final group = seriesGroups[key]!
      ..sort((a, b) {
        final bySequence = _sequenceOf(a).compareTo(_sequenceOf(b));
        return bySequence != 0
            ? bySequence
            : a.invoiceNumber.compareTo(b.invoiceNumber);
      });
    rows.add([
      key.split('|')[0],
      group.first.invoiceNumber,
      group.last.invoiceNumber,
      group.length.toString(),
      group.where((invoice) => invoice.status == 'CANCELLED').length.toString(),
    ]);
  }

  // --- HSN-wise summary ----------------------------------------------------
  rows.add(const []);
  rows.add(['Section', 'HSN']);
  rows.add(['HSN/SAC', 'UQC', 'Taxable', 'CGST', 'SGST', 'IGST', 'Cess']);
  final hsn = <String, List<double>>{};
  for (final invoice in counted) {
    if (invoice.invoiceType == billOfSupplyType) continue;
    final sign = invoice.invoiceType == 'CREDIT_NOTE' ? -1 : 1;
    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      final code = item.hsnSac.trim().isEmpty
          ? 'UNSPECIFIED'
          : item.hsnSac.trim();
      final key = '$code|${uqcForUnit(item.unit)}';
      final bucket = hsn.putIfAbsent(key, () => [0, 0, 0, 0, 0]);
      bucket[0] += sign * item.taxableAmount;
      bucket[1] += sign * item.cgstAmount;
      bucket[2] += sign * item.sgstAmount;
      bucket[3] += sign * item.igstAmount;
      bucket[4] += sign * item.cessAmount;
    }
  }
  final hsnKeys = hsn.keys.toList()..sort();
  for (final key in hsnKeys) {
    final bucket = hsn[key]!;
    rows.add([
      key.split('|')[0],
      key.split('|')[1],
      money(bucket[0]),
      money(bucket[1]),
      money(bucket[2]),
      money(bucket[3]),
      money(bucket[4]),
    ]);
  }

  return rows;
}

/// The numeric suffix of a document number (0 when it has none), used to
/// order documents inside their series for the documents-issued section.
int _sequenceOf(Invoice invoice) {
  final match = RegExp(r'(\d+)$').firstMatch(invoice.invoiceNumber);
  return int.tryParse(match?.group(1) ?? '') ?? 0;
}

/// The UQC (quantity unit code) set accepted by the GSTR-1 HSN summary.
const _uqcCodes = {
  'BAG', 'BAL', 'BDL', 'BKL', 'BOU', 'BOX', 'BTL', 'BUN', 'CAN', 'CBM',
  'CCM', 'CMS', 'CTN', 'DOZ', 'DRM', 'GGK', 'GMS', 'GRS', 'GYD', 'KGS',
  'KLR', 'KME', 'LTR', 'MLT', 'MTR', 'MTS', 'NOS', 'PAC', 'PCS', 'PRS',
  'QTL', 'ROL', 'SET', 'SQF', 'SQM', 'TBS', 'TGM', 'THD', 'TON', 'TUB',
  'UGS', 'UNT', 'YDS',
};

/// The app's UOM catalogue uses a few codes that differ from the UQC set.
const _uomToUqc = {'KG': 'KGS', 'GRM': 'GMS', 'CM': 'CMS', 'ML': 'MLT'};

/// Maps a document line's unit to the UQC the GSTR-1 HSN summary expects.
/// Unknown or missing units report as OTH rather than blocking the export.
String uqcForUnit(String unit) {
  final code = unit.trim().toUpperCase();
  if (code.isEmpty) return 'OTH';
  return _uomToUqc[code] ?? (_uqcCodes.contains(code) ? code : 'OTH');
}
