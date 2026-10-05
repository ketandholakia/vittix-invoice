part of 'pdf_service.dart';

// Modern layout header and parties blocks.

pw.Widget _buildModernInvoiceHeader(
  Business business,
  Invoice invoice,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  final logo = _getLogoImage(business);
  final titleSize = layout.headerTitleSize(config.headerDensity);
  final subtitleSize = layout.headerSubtitleSize(config.headerDensity);
  return pw.Container(
    padding: pw.EdgeInsets.all(
      config.headerDensity == 'COMPACT'
          ? 12
          : config.headerDensity == 'SPACIOUS'
              ? 20
              : 16,
    ),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Row(
              children: [
                if (logo != null)
                  pw.Container(
                    width: 48,
                    height: 48,
                    child: pw.Image(logo, fit: pw.BoxFit.contain),
                  ),
                if (logo != null) pw.SizedBox(width: 12),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      business.name,
                      style: pw.TextStyle(
                        fontSize: titleSize,
                        fontWeight: pw.FontWeight.bold,
                        color: brandColor,
                      ),
                    ),
                    pw.Text(
                      config.titleLabel,
                      style: pw.TextStyle(fontSize: subtitleSize),
                    ),
                  ],
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  invoice.invoiceNumber,
                  style: const pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  formatDateNumeric(invoice.invoiceDate),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ],
    ),
  );
}
pw.Widget _buildModernQuoteHeader(
  Business business,
  Quote quote,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  final logo = _getLogoImage(business);
  final titleSize = layout.headerTitleSize(config.headerDensity);
  final subtitleSize = layout.headerSubtitleSize(config.headerDensity);
  return pw.Container(
    padding: pw.EdgeInsets.all(
      config.headerDensity == 'COMPACT'
          ? 12
          : config.headerDensity == 'SPACIOUS'
              ? 20
              : 16,
    ),
    decoration: pw.BoxDecoration(
      color: PdfColors.grey100,
      border: pw.Border.all(color: PdfColors.grey300),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            if (logo != null)
              pw.Container(
                width: 48,
                height: 48,
                child: pw.Image(logo, fit: pw.BoxFit.contain),
              ),
            if (logo != null) pw.SizedBox(width: 12),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  business.name,
                  style: pw.TextStyle(
                    fontSize: titleSize,
                    fontWeight: pw.FontWeight.bold,
                    color: brandColor,
                  ),
                ),
                pw.Text(
                  config.titleLabel,
                  style: pw.TextStyle(fontSize: subtitleSize),
                ),
              ],
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              quote.invoiceNumber,
              style: const pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              formatDateNumeric(quote.invoiceDate),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ],
    ),
  );
}
pw.Widget _buildModernParties(
  Business business,
  Customer customer,
  bool isGstEnabled,
  Invoice invoice,
  InvoiceTemplateConfig config,
) {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Expanded(
        child: _buildParties(business, customer, isGstEnabled, config),
      ),
      pw.SizedBox(width: 12),
      pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.all(12),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Summary',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 6),
              pw.Text('Invoice: ${invoice.invoiceNumber}'),
              pw.Text(
                'Total: ${formatMoney(invoice.totalAmount, currencyCode: invoice.currencyCode)}',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
