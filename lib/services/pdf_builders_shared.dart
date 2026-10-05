part of 'pdf_service.dart';

// Layout blocks shared by every template family.

pw.Widget _buildTotalRow(
  String label,
  double value, {
  bool isBold = false,
}) {
  return pw.Row(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text(
        label,
        style: isBold ? const pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
      ),
      pw.SizedBox(width: 20),
      pw.Text(
        value.toStringAsFixed(2),
        style: isBold ? const pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
      ),
    ],
  );
}
pw.Widget _buildShipTo(
  String? name,
  String? address,
  String? city,
) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Ship To',
          style: const pw.TextStyle(
            fontSize: 9,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (name != null && name.isNotEmpty)
          pw.Text(name, style: const pw.TextStyle(fontSize: 9)),
        if (address != null && address.isNotEmpty)
          pw.Text(address, style: const pw.TextStyle(fontSize: 9)),
        if (city != null && city.isNotEmpty)
          pw.Text(city, style: const pw.TextStyle(fontSize: 9)),
      ],
    ),
  );
}
pw.Widget _buildSupplyDeclaration(String supplyType, bool underLut) {
  final String declaration;
  if (supplyType == 'EXPORT') {
    declaration = underLut
        ? 'Supply meant for export under LUT without payment of IGST'
        : 'Supply meant for export — IGST payable';
  } else if (supplyType == 'SEZ') {
    declaration = underLut
        ? 'Supply to SEZ unit/developer under LUT without payment of IGST'
        : 'Supply to SEZ unit/developer — IGST payable';
  } else {
    return pw.SizedBox.shrink();
  }

  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(6),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
    ),
    child: pw.Text(declaration, style: const pw.TextStyle(fontSize: 9)),
  );
}
pw.Widget _buildHsnSummary(
  List<InvoiceItem> items,
  bool isIgst,
  String currencyCode,
) {
  final byHsn = <String, ({double taxable, double tax})>{};
  for (final item in items) {
    final code = item.hsnSac.trim();
    if (code.isEmpty) continue;
    final tax = isIgst ? item.igstAmount : item.cgstAmount + item.sgstAmount;
    final current = byHsn[code];
    byHsn[code] = (
      taxable: (current?.taxable ?? 0) + item.taxableAmount,
      tax: (current?.tax ?? 0) + tax,
    );
  }
  if (byHsn.isEmpty) return pw.SizedBox.shrink();

  final codes = byHsn.keys.toList()..sort();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Text(
        'HSN / SAC Summary',
        style: const pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.TableHelper.fromTextArray(
        headerStyle: const pw.TextStyle(
          fontSize: 9,
          fontWeight: pw.FontWeight.bold,
        ),
        cellStyle: const pw.TextStyle(fontSize: 9),
        headers: const ['HSN/SAC', 'Taxable Value', 'Tax'],
        data: [
          for (final code in codes)
            [
              code,
              formatMoney(
                byHsn[code]!.taxable,
                currencyCode: currencyCode,
              ),
              formatMoney(byHsn[code]!.tax, currencyCode: currencyCode),
            ],
        ],
      ),
    ],
  );
}
pw.Widget _buildBankDetails(Business business) {
  final hasBankDetails =
      (business.bankName ?? '').isNotEmpty ||
      (business.bankAccount ?? '').isNotEmpty ||
      (business.bankIfsc ?? '').isNotEmpty;
  if (!hasBankDetails) {
    return pw.SizedBox.shrink();
  }

  return pw.Container(
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'Bank Details',
          style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
        ),
        if ((business.bankName ?? '').isNotEmpty)
          pw.Text('Bank: ${business.bankName}'),
        if ((business.bankAccount ?? '').isNotEmpty)
          pw.Text('Account No: ${business.bankAccount}'),
        if ((business.bankIfsc ?? '').isNotEmpty)
          pw.Text('IFSC: ${business.bankIfsc}'),
      ],
    ),
  );
}
pw.Widget _buildDocumentNotes({String? notes, String? terms}) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if ((notes ?? '').isNotEmpty) ...[
        pw.Text('Notes', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(notes!, style: const pw.TextStyle(fontSize: 10)),
      ],
      if ((notes ?? '').isNotEmpty && (terms ?? '').isNotEmpty)
        pw.SizedBox(height: 12),
      if ((terms ?? '').isNotEmpty) ...[
        pw.Text('Terms', style: const pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 4),
        pw.Text(terms!, style: const pw.TextStyle(fontSize: 10)),
      ],
    ],
  );
}
