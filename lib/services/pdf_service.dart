import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/utils/invoice_balance.dart';
import '../core/utils/money_formatter.dart';
import '../database/app_database.dart';
import '../database/tables/businesses.dart';
import '../models/invoice_template_config.dart';
import 'dart:io';

class PdfService {
  static PdfPageFormat _pageFormatFor(String paperSize) {
    switch (paperSize.toLowerCase()) {
      case 'a5':
        return PdfPageFormat.a5;
      case 'thermal':
        return const PdfPageFormat(80 * PdfPageFormat.mm, double.infinity);
      case 'a4':
      default:
        return PdfPageFormat.a4;
    }
  }

  static PdfColor _parseColor(String hexString, PdfColor fallback) {
    if (hexString.isEmpty) return fallback;
    try {
      final hexCode = hexString.replaceAll('#', '');
      if (hexCode.length == 6) {
        return PdfColor.fromInt(int.parse(hexCode, radix: 16) | 0xFF000000);
      } else if (hexCode.length == 8) {
        return PdfColor.fromInt(int.parse(hexCode, radix: 16));
      }
    } catch (_) {}
    return fallback;
  }

  static PdfColor _getBrandColor(Business business, InvoiceTemplateConfig config) {
    if (config.primaryColor.isNotEmpty) {
      return _parseColor(config.primaryColor, PdfColors.indigo);
    }
    return business.brandColor != null
        ? PdfColor.fromInt(business.brandColor!)
        : PdfColors.indigo;
  }

  static pw.MemoryImage? _getLogoImage(Business business) {
    if (business.logoPath != null && File(business.logoPath!).existsSync()) {
      return pw.MemoryImage(File(business.logoPath!).readAsBytesSync());
    }
    return null;
  }

  static Future<pw.ThemeData?> _getThemeForFont(String? fontFamily) async {
    if (fontFamily == null || fontFamily.isEmpty) return null;
    pw.Font? baseFont;
    pw.Font? boldFont;
    switch (fontFamily) {
      case 'Open Sans':
        baseFont = await PdfGoogleFonts.openSansRegular();
        boldFont = await PdfGoogleFonts.openSansBold();
        break;
      case 'Lato':
        baseFont = await PdfGoogleFonts.latoRegular();
        boldFont = await PdfGoogleFonts.latoBold();
        break;
      case 'Montserrat':
        baseFont = await PdfGoogleFonts.montserratRegular();
        boldFont = await PdfGoogleFonts.montserratBold();
        break;
      default:
        baseFont = await PdfGoogleFonts.robotoRegular();
        boldFont = await PdfGoogleFonts.robotoBold();
    }
    return pw.ThemeData.withFont(base: baseFont, bold: boldFont);
  }

  static Future<Uint8List> generateInvoice({
    required Business business,
    required Customer customer,
    required Invoice invoice,
    required List<InvoiceItem> items,
    bool isGstEnabled = true,
    bool showBankDetails = false,
    InvoiceTemplateConfig? templateConfig,
  }) async {
    final config =
        templateConfig ??
        InvoiceTemplateConfig.defaults(
          id: 'legacy_invoice',
          name: 'Legacy Invoice',
          layoutFamily: business.invoiceTemplate,
        );
    final pdf = pw.Document();
    final isModern =
        (templateConfig?.layoutFamily ?? business.invoiceTemplate) == 'MODERN';
    final isElegant =
        (templateConfig?.layoutFamily ?? business.invoiceTemplate) == 'ELEGANT';
    final pageFormat = _pageFormatFor(config.paperSize);
    final spacing = config.layoutSpacing;
    final theme = await _getThemeForFont(config.fontFamily);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(isModern || isElegant ? 24 : 32),
        theme: theme,
        pageTheme: pw.PageTheme(
          buildBackground: config.watermarkText?.isNotEmpty == true
              ? (context) => pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Watermark(
                      child: pw.Text(
                        config.watermarkText!,
                        style: pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 80,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
              : null,
        ),
        build: (context) {
          return [
            isElegant
                ? _buildElegantHeader(business, invoice.invoiceType, config.titleLabel, invoice.invoiceNumber, invoice.invoiceDate, config)
                : isModern
                    ? _buildModernInvoiceHeader(
                        business,
                        invoice,
                        isGstEnabled,
                        config,
                      )
                    : _buildHeader(business, invoice, isGstEnabled, config),
            pw.SizedBox(height: spacing),
            isElegant
                ? _buildElegantParties(business, customer, isGstEnabled, config)
                : isModern
                    ? _buildModernParties(
                        business,
                        customer,
                        isGstEnabled,
                        invoice,
                        config,
                      )
                    : _buildParties(business, customer, isGstEnabled, config),
            pw.SizedBox(height: spacing),
            _buildItemsTable(
              items,
              invoice.isIgst,
              isGstEnabled,
              business,
              config,
            ),
            pw.SizedBox(height: spacing),
            _buildTotals(invoice, isGstEnabled, compact: isModern, config: config),
            if (showBankDetails) ...[
              pw.SizedBox(height: spacing),
              _buildBankDetails(business),
            ],
            if ((invoice.notes ?? '').isNotEmpty ||
                (invoice.terms ?? '').isNotEmpty) ...[
              pw.SizedBox(height: spacing),
              _buildDocumentNotes(notes: invoice.notes, terms: invoice.terms),
            ],
            pw.SizedBox(height: spacing * 2),
            _buildInvoiceFooter(business, invoice, config),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static Future<Uint8List> generateQuotePdf({
    required Business business,
    required Customer customer,
    required Quote quote,
    required List<QuoteItem> items,
    required bool isGstEnabled,
    bool showBankDetails = false,
    InvoiceTemplateConfig? templateConfig,
  }) async {
    final config =
        templateConfig ??
        InvoiceTemplateConfig.defaults(
          id: 'legacy_quote',
          name: 'Legacy Quote',
          layoutFamily: business.quoteTemplate,
        );
    final pdf = pw.Document();
    final isModern =
        (templateConfig?.layoutFamily ?? business.quoteTemplate) == 'MODERN';
    final isElegant =
        (templateConfig?.layoutFamily ?? business.quoteTemplate) == 'ELEGANT';
    final pageFormat = _pageFormatFor(config.paperSize);
    final spacing = config.layoutSpacing;
    final theme = await _getThemeForFont(config.fontFamily);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: pw.EdgeInsets.all(isModern || isElegant ? 24 : 32),
        theme: theme,
        pageTheme: pw.PageTheme(
          buildBackground: config.watermarkText?.isNotEmpty == true
              ? (context) => pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Watermark(
                      child: pw.Text(
                        config.watermarkText!,
                        style: pw.TextStyle(
                          color: PdfColors.grey300,
                          fontSize: 80,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                  )
              : null,
        ),
        build: (context) => [
          isElegant
              ? _buildElegantHeader(business, 'QUOTE', config.titleLabel, quote.invoiceNumber, quote.invoiceDate, config)
              : isModern
                  ? _buildModernQuoteHeader(business, quote, isGstEnabled, config)
                  : _buildQuoteHeader(business, quote, isGstEnabled, config),
          pw.SizedBox(height: spacing),
          isElegant
              ? _buildElegantParties(business, customer, isGstEnabled, config)
              : _buildAddresses(business, customer, isGstEnabled, config),
          pw.SizedBox(height: spacing),
          _buildQuoteDetails(quote, isGstEnabled, config),
          pw.SizedBox(height: spacing),
          _buildQuoteItemTable(items, isGstEnabled, business, config),
          pw.SizedBox(height: spacing),
          _buildQuoteTotals(quote, isGstEnabled, compact: isModern, config: config),
          if (showBankDetails) ...[
          pw.SizedBox(height: spacing),
            _buildBankDetails(business),
          ],
          if ((quote.notes ?? '').isNotEmpty ||
              (quote.terms ?? '').isNotEmpty) ...[
            pw.SizedBox(height: isModern ? 12 : 20),
            _buildDocumentNotes(notes: quote.notes, terms: quote.terms),
          ],
          pw.SizedBox(height: spacing * 2),
          _buildQuoteFooter(business, quote, config),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildQuoteTotals(
    Quote quote,
    bool isGstEnabled, {
    bool compact = false,
    InvoiceTemplateConfig? config,
  }) {
    final showAmountInWords = config?.showAmountInWords ?? true;
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _buildTotalRow('Subtotal:', quote.subtotal),
          if (isGstEnabled) ...[
            if (quote.cgstAmount > 0) _buildTotalRow('CGST:', quote.cgstAmount),
            if (quote.sgstAmount > 0) _buildTotalRow('SGST:', quote.sgstAmount),
            if (quote.igstAmount > 0) _buildTotalRow('IGST:', quote.igstAmount),
            if (quote.cessAmount > 0) _buildTotalRow('Cess:', quote.cessAmount),
          ],
          pw.SizedBox(width: compact ? 140 : 200, child: pw.Divider()),
          _buildTotalRow('Grand Total:', quote.totalAmount, isBold: true),
          if (showAmountInWords && quote.amountInWords != null) ...[
            pw.SizedBox(height: 8),
            pw.Text(
              'Amount in words: ${quote.amountInWords}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ],
      ),
    );
  }

  static pw.Widget _buildModernInvoiceHeader(
    Business business,
    Invoice invoice,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final logo = _getLogoImage(business);
    final titleSize = _headerTitleSize(config.headerDensity);
    final subtitleSize = _headerSubtitleSize(config.headerDensity);
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
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    invoice.invoiceDate.toIso8601String().split('T')[0],
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

  static pw.Widget _buildModernQuoteHeader(
    Business business,
    Quote quote,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final logo = _getLogoImage(business);
    final titleSize = _headerTitleSize(config.headerDensity);
    final subtitleSize = _headerSubtitleSize(config.headerDensity);
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
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                quote.invoiceDate.toIso8601String().split('T')[0],
                style: const pw.TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildModernParties(
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
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
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

  static pw.Widget _buildTotalRow(
    String label,
    double value, {
    bool isBold = false,
  }) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(
          label,
          style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        ),
        pw.SizedBox(width: 20),
        pw.Text(
          value.toStringAsFixed(2),
          style: isBold ? pw.TextStyle(fontWeight: pw.FontWeight.bold) : null,
        ),
      ],
    );
  }

  static pw.Widget _buildHeader(
    Business business,
    Invoice invoice,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final logo = _getLogoImage(business);
    final titleSize = _headerTitleSize(config.headerDensity);
    final gap = _headerGap(config.headerDensity);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(logo, fit: pw.BoxFit.contain),
              )
            else
              pw.Text(
                business.name,
                style: pw.TextStyle(
                  fontSize: titleSize,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
            if (invoice.invoiceType == 'QUOTE')
              pw.Text(
                'QUOTE',
                style: pw.TextStyle(
                  fontSize: titleSize,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              )
            else
              pw.Text(
                config.titleLabel,
                style: pw.TextStyle(
                  fontSize: titleSize,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
          ],
        ),
        pw.SizedBox(height: gap),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (logo != null)
                  pw.Text(
                    business.name,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: brandColor,
                    ),
                  ),
                pw.Text(business.address),
                if (business.businessType == BusinessType.unregistered) ...[
                  pw.Text(business.city),
                  if (business.pan != null && business.pan!.isNotEmpty)
                    pw.Text(
                      'PAN: ${business.pan}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                ] else if (isGstEnabled) ...[
                  pw.Text(
                    '${business.city}, State Code: ${business.stateCode}',
                  ),
                  if (business.gstin.isNotEmpty)
                    pw.Text(
                      'GSTIN: ${business.gstin}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  if (business.businessType == BusinessType.compositionScheme)
                    pw.Text(
                      'Composition Taxable Person, not eligible to collect tax on supplies',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey700,
                      ),
                    ),
                ] else ...[
                  pw.Text(business.city),
                  if (business.pan != null && business.pan!.isNotEmpty)
                    pw.Text(
                      'PAN: ${business.pan}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                ],
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  '${config.invoiceNoLabel}: ${invoice.invoiceNumber}',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  '${config.dateLabel}: ${invoice.invoiceDate.toIso8601String().split('T')[0]}',
                ),
                if (config.showDueDate && invoice.dueDate != null)
                  pw.Text(
                    'Due Date: ${invoice.dueDate!.toIso8601String().split('T')[0]}',
                  ),
                if (config.showPlaceOfSupply)
                  pw.Text('Place of Supply: ${invoice.placeOfSupply}'),
              ],
            ),
          ],
        ),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildQuoteHeader(
    Business business,
    Quote quote,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final logo = _getLogoImage(business);
    final titleSize = _headerTitleSize(config.headerDensity);
    final gap = _headerGap(config.headerDensity);

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Container(
                width: 80,
                height: 80,
                child: pw.Image(logo, fit: pw.BoxFit.contain),
              )
            else
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
              style: pw.TextStyle(
                fontSize: titleSize,
                fontWeight: pw.FontWeight.bold,
                color: brandColor,
              ),
            ),
          ],
        ),
        pw.SizedBox(height: gap),
        pw.Divider(),
      ],
    );
  }

  static pw.Widget _buildParties(
    Business business,
    Customer customer,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              config.billToLabel,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: brandColor,
              ),
            ),
            pw.Text(
              customer.name,
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            if (customer.address != null) pw.Text(customer.address!),
            if (customer.city != null) pw.Text(customer.city!),
            if (isGstEnabled && customer.stateCode != null)
              pw.Text('State Code: ${customer.stateCode}'),
            if (isGstEnabled && customer.gstin != null)
              pw.Text(
                'GSTIN: ${customer.gstin}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
            if (customer.pan != null && customer.pan!.isNotEmpty)
              pw.Text(
                'PAN: ${customer.pan}',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildAddresses(
    Business business,
    Customer customer,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final logo = _getLogoImage(business);
    final brandColor = _getBrandColor(business, config);

    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            if (logo != null)
              pw.Text(
                business.name,
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: brandColor,
                ),
              ),
            pw.Text(business.address),
            if (isGstEnabled)
              pw.Text('${business.city}, State Code: ${business.stateCode}'),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildQuoteDetails(
    Quote quote,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              '${config.invoiceNoLabel}: ${quote.invoiceNumber}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              '${config.dateLabel}: ${quote.invoiceDate.toLocal().toString().split(' ')[0]}',
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildItemsTable(
    List<InvoiceItem> items,
    bool isIgst,
    bool isGstEnabled,
    Business business,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final showHsn =
        isGstEnabled && config.showHsn && config.itemColumns.contains('hsn');
    final showQty = config.itemColumns.contains('qty');
    final showRate = config.itemColumns.contains('rate');
    final showGst =
        isGstEnabled && config.showGst && config.itemColumns.contains('gst');
    final showAmount = config.itemColumns.contains('amount');

    final headers = [
      '#',
      'Description',
      if (showHsn) 'HSN/SAC',
      if (showQty) 'Qty',
      if (showRate) 'Rate',
      if (showGst) 'GST',
      if (showAmount) 'Amount',
    ];

    final data = items.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value;
      final gstAmount = isIgst
          ? item.igstAmount
          : item.cgstAmount + item.sgstAmount;
      return [
        '${i + 1}',
        item.name,
        if (showHsn) item.hsnSac,
        if (showQty) '${item.quantity}',
        if (showRate) item.rate.toStringAsFixed(2),
        if (showGst) gstAmount.toStringAsFixed(2),
        if (showAmount) item.totalAmount.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: _tableBorder(config),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: brandColor),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerLeft,
        if (showHsn) 2: pw.Alignment.centerLeft,
        if (showQty) (showHsn ? 3 : 2): pw.Alignment.centerRight,
        if (showRate)
          (showHsn ? (showQty ? 4 : 3) : (showQty ? 3 : 2)):
              pw.Alignment.centerRight,
        if (showGst)
          (showHsn
                  ? (showQty ? (showRate ? 5 : 4) : (showRate ? 4 : 3))
                  : (showQty ? (showRate ? 4 : 3) : (showRate ? 3 : 2))):
              pw.Alignment.centerRight,
        if (showAmount)
          (showHsn
                  ? (showQty
                        ? (showRate ? (showGst ? 6 : 5) : (showGst ? 5 : 4))
                        : (showRate ? (showGst ? 5 : 4) : (showGst ? 4 : 3)))
                  : (showQty
                        ? (showRate ? (showGst ? 5 : 4) : (showGst ? 4 : 3))
                        : (showRate ? (showGst ? 4 : 3) : (showGst ? 3 : 2)))):
              pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildQuoteItemTable(
    List<QuoteItem> items,
    bool isGstEnabled,
    Business business,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final showHsn =
        isGstEnabled && config.showHsn && config.itemColumns.contains('hsn');
    final showQty = config.itemColumns.contains('qty');
    final showRate = config.itemColumns.contains('rate');
    final showGst =
        isGstEnabled && config.showGst && config.itemColumns.contains('gst');
    final showAmount = config.itemColumns.contains('amount');

    final headers = [
      'Item',
      if (showHsn) 'HSN/SAC',
      if (showQty) 'Qty',
      if (showRate) 'Rate',
      if (showGst) 'GST',
      if (showAmount) 'Total',
    ];

    final data = items.map((item) {
      return [
        item.name,
        if (showHsn) item.hsnSac,
        if (showQty) '${item.quantity} ${item.unit}',
        if (showRate) item.rate.toStringAsFixed(2),
        if (showGst) item.gstRate.toStringAsFixed(1),
        if (showAmount) item.totalAmount.toStringAsFixed(2),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: _tableBorder(config),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: pw.BoxDecoration(color: brandColor),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        if (isGstEnabled) 1: pw.Alignment.centerLeft,
        isGstEnabled ? 2 : 1: pw.Alignment.centerRight,
        isGstEnabled ? 3 : 2: pw.Alignment.centerRight,
        if (isGstEnabled) 4: pw.Alignment.centerRight,
        isGstEnabled ? 5 : 3: pw.Alignment.centerRight,
      },
    );
  }

  static pw.Widget _buildTotals(
    Invoice invoice,
    bool isGstEnabled, {
    bool compact = false,
    InvoiceTemplateConfig? config,
  }) {
    final showAmountInWords = config?.showAmountInWords ?? true;
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.end,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (isGstEnabled) ...[
                pw.Text('Subtotal:'),
                if (!invoice.isIgst) pw.Text('Total CGST:'),
                if (!invoice.isIgst) pw.Text('Total SGST:'),
                if (invoice.isIgst) pw.Text('Total IGST:'),
              ],
              pw.Text(
                'Grand Total:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              if (showAmountInWords) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Amount in Words:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(
                  invoice.amountInWords ?? '',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ],
          ),
          pw.SizedBox(width: compact ? 20 : 32),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              if (isGstEnabled) ...[
                pw.Text(
                  formatMoney(
                    invoice.taxableAmount,
                    currencyCode: invoice.currencyCode,
                  ),
                ),
                if (!invoice.isIgst)
                  pw.Text(
                    formatMoney(
                      invoice.cgstAmount,
                      currencyCode: invoice.currencyCode,
                    ),
                  ),
                if (!invoice.isIgst)
                  pw.Text(
                    formatMoney(
                      invoice.sgstAmount,
                      currencyCode: invoice.currencyCode,
                    ),
                  ),
                if (invoice.isIgst)
                  pw.Text(
                    formatMoney(
                      invoice.igstAmount,
                      currencyCode: invoice.currencyCode,
                    ),
                  ),
              ],
              pw.Text(
                formatMoney(
                  invoice.totalAmount,
                  currencyCode: invoice.currencyCode,
                ),
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              pw.SizedBox(height: 8),
              if (invoice.amountPaid > 0) ...[
                pw.Text(
                  'Amount Paid: ${formatMoney(invoice.amountPaid, currencyCode: invoice.currencyCode)}',
                  style: const pw.TextStyle(color: PdfColors.green),
                ),
                pw.Text(
                  'Balance Due: ${formatMoney(invoiceBalanceDue(invoice), currencyCode: invoice.currencyCode)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
                if (invoiceOverpaidAmount(invoice) > 0)
                  pw.Text(
                    'Overpaid: ${formatMoney(invoiceOverpaidAmount(invoice), currencyCode: invoice.currencyCode)}',
                    style: const pw.TextStyle(color: PdfColors.blue),
                  ),
              ] else ...[
                pw.Text(
                  'Amount Paid: ${formatMoney(0, currencyCode: invoice.currencyCode)}',
                ),
                pw.Text(
                  'Balance Due: ${formatMoney(invoice.totalAmount, currencyCode: invoice.currencyCode)}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildBankDetails(Business business) {
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
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
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

  static pw.Widget _buildQuoteFooter(
    Business business,
    Quote quote,
    InvoiceTemplateConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  config.termsText.isNotEmpty
                      ? config.termsText
                      : 'Terms & Conditions:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                if ((quote.terms ?? '').isNotEmpty)
                  pw.Text(quote.terms!, style: const pw.TextStyle(fontSize: 9))
                else ...[
                  pw.Text(
                    '1. Subject to local jurisdiction.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    '2. This is a quotation, not an invoice.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'For ${business.name}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 30),
                if (config.showSignature)
                  pw.Text(
                    'Authorized Signatory',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                if (config.showSignature)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8),
                    width: 120,
                    height: 1,
                    color: PdfColors.black,
                  ),
              ],
            ),
          ],
        ),
        if (config.showQrCode) ...[
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.BarcodeWidget(
                barcode: pw.Barcode.qrCode(),
                data: _buildUpiQrPayload(
                  business: business,
                  amount: quote.totalAmount,
                  invoiceNumber: quote.invoiceNumber,
                ),
                width: 72,
                height: 72,
              ),
            ],
          ),
        ],
        if ((config.footerText ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              config.footerText!,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ],
    );
  }

  static pw.Widget _buildInvoiceFooter(
    Business business,
    Invoice invoice,
    InvoiceTemplateConfig config,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  config.termsText.isNotEmpty
                      ? config.termsText
                      : 'Declaration:',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                if ((invoice.terms ?? '').isNotEmpty)
                  pw.Text(invoice.terms!, style: const pw.TextStyle(fontSize: 9))
                else ...[
                  pw.Text(
                    'We declare that this invoice shows the actual price of',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                  pw.Text(
                    'the goods described and that all particulars are true and correct.',
                    style: const pw.TextStyle(fontSize: 9),
                  ),
                ],
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'For ${business.name}',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                pw.SizedBox(height: 30),
                if (config.showSignature)
                  pw.Text(
                    'Authorized Signatory',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                if (config.showSignature)
                  pw.Container(
                    margin: const pw.EdgeInsets.only(top: 8),
                    width: 120,
                    height: 1,
                    color: PdfColors.black,
                  ),
              ],
            ),
          ],
        ),
        if (config.showQrCode && (business.upiId ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                children: [
                  pw.Text('Scan to Pay via UPI', style: const pw.TextStyle(fontSize: 8)),
                  pw.SizedBox(height: 4),
                  pw.BarcodeWidget(
                    barcode: pw.Barcode.qrCode(),
                    data: _buildUpiQrPayload(
                      business: business,
                      amount: invoiceBalanceDue(invoice),
                      invoiceNumber: invoice.invoiceNumber,
                    ),
                    width: 72,
                    height: 72,
                  ),
                ]
              )
            ],
          ),
        ],
        if ((config.footerText ?? '').isNotEmpty) ...[
          pw.SizedBox(height: 8),
          pw.Center(
            child: pw.Text(
              config.footerText!,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
            ),
          ),
        ],
      ],
    );
  }

  static double _headerTitleSize(String density) {
    switch (density) {
      case 'COMPACT':
        return 20;
      case 'SPACIOUS':
        return 28;
      default:
        return 24;
    }
  }

  static double _headerSubtitleSize(String density) {
    switch (density) {
      case 'COMPACT':
        return 9;
      case 'SPACIOUS':
        return 12;
      default:
        return 11;
    }
  }

  static double _headerGap(String density) {
    switch (density) {
      case 'COMPACT':
        return 4;
      case 'SPACIOUS':
        return 12;
      default:
        return 8;
    }
  }

  /// Returns a [pw.TableBorder] matching the template's `tableBorderStyle`.
  static pw.TableBorder _tableBorder(InvoiceTemplateConfig config) {
    switch (config.tableBorderStyle) {
      case 'ROWS_ONLY':
        return pw.TableBorder(
          horizontalInside: pw.BorderSide(
            color: PdfColors.grey300,
            width: config.borderThickness,
          ),
          bottom: pw.BorderSide(
            color: PdfColors.grey300,
            width: config.borderThickness,
          ),
        );
      case 'NONE':
        return const pw.TableBorder();
      case 'FULL':
      default:
        return pw.TableBorder.all(
          color: PdfColors.grey300,
          width: config.borderThickness,
        );
    }
  }

  static String _buildUpiQrPayload({
    required Business business,
    required double amount,
    required String invoiceNumber,
  }) {
    final upiId = business.upiId?.trim();
    if (upiId == null || upiId.isEmpty) {
      return '${business.name} | $invoiceNumber | ${amount.toStringAsFixed(2)}';
    }

    final pa = Uri.encodeComponent(upiId);
    final pn = Uri.encodeComponent(business.name);
    final tn = Uri.encodeComponent('Invoice $invoiceNumber');
    final am = amount.toStringAsFixed(2);
    return 'upi://pay?pa=$pa&pn=$pn&tn=$tn&am=$am&cu=INR';
  }

  static pw.Widget _buildDocumentNotes({String? notes, String? terms}) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if ((notes ?? '').isNotEmpty) ...[
          pw.Text('Notes', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(notes!, style: const pw.TextStyle(fontSize: 10)),
        ],
        if ((notes ?? '').isNotEmpty && (terms ?? '').isNotEmpty)
          pw.SizedBox(height: 12),
        if ((terms ?? '').isNotEmpty) ...[
          pw.Text('Terms', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 4),
          pw.Text(terms!, style: const pw.TextStyle(fontSize: 10)),
        ],
      ],
    );
  }

  static pw.Widget _buildElegantHeader(
    Business business,
    String type,
    String titleLabel,
    String invoiceNumber,
    DateTime date,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
    final logo = _getLogoImage(business);
    final titleSize = _headerTitleSize(config.headerDensity);

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
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'Date: ${date.toIso8601String().split('T')[0]}',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Divider(color: brandColor, thickness: 1.5),
      ],
    );
  }

  static pw.Widget _buildElegantParties(
    Business business,
    Customer customer,
    bool isGstEnabled,
    InvoiceTemplateConfig config,
  ) {
    final brandColor = _getBrandColor(business, config);
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
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
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
}
