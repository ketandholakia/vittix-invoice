part of 'pdf_service.dart';

// Elegant layout header and parties blocks.

pw.Widget _buildElegantHeader(
  Business business,
  String type,
  String titleLabel,
  String invoiceNumber,
  DateTime date,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  final logo = _getLogoImage(business);
  final titleSize = layout.headerTitleSize(config.headerDensity);

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      if (logo != null)
        pw.Container(
          height: 60,
          child: pw.Image(logo, fit: pw.BoxFit.contain),
        ),
      pw.SizedBox(height: 12),
      pw.Text(
        business.name.toUpperCase(),
        style: pw.TextStyle(
          fontSize: titleSize,
          fontWeight: pw.FontWeight.bold,
          color: brandColor,
          letterSpacing: 2,
        ),
      ),
      pw.SizedBox(height: 4),
      pw.Text(business.address, style: const pw.TextStyle(fontSize: 10)),
      if (business.city.isNotEmpty)
        pw.Text(business.city, style: const pw.TextStyle(fontSize: 10)),
      pw.SizedBox(height: 24),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        children: [
          pw.Text(
            type == 'QUOTE' ? 'QUOTE' : titleLabel.toUpperCase(),
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: brandColor,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      pw.SizedBox(height: 8),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'No: $invoiceNumber',
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            'Date: ${formatDateNumeric(date)}',
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      pw.Divider(color: brandColor, thickness: 1.5),
    ],
  );
}
pw.Widget _buildElegantParties(
  Business business,
  Customer customer,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(vertical: 16),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                config.billToLabel.toUpperCase(),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                  fontSize: 10,
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                customer.name,
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
              ),
              if (customer.address != null) pw.Text(customer.address!),
              if (customer.city != null) pw.Text(customer.city!),
            ],
          ),
        ),
        if (isGstEnabled && (customer.gstin != null || business.gstin.isNotEmpty))
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'TAX DETAILS',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: brandColor,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (business.gstin.isNotEmpty)
                  pw.Text('Our GSTIN: ${business.gstin}', textAlign: pw.TextAlign.right),
                if (customer.gstin != null)
                  pw.Text('Customer GSTIN: ${customer.gstin}', textAlign: pw.TextAlign.right),
              ],
            ),
          ),
      ],
    ),
  );
}
