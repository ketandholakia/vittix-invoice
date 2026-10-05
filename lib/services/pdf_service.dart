import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../core/constants/gst_states.dart';
import '../core/utils/formatting.dart';
import '../core/utils/invoice_balance.dart';
import '../core/utils/money_formatter.dart';
import '../database/app_database.dart';
import '../database/tables/businesses.dart';
import '../core/utils/billing_mode.dart';
import '../core/utils/invoice_type.dart';
import '../models/invoice_template_config.dart';
import 'pdf_layout.dart' as layout;
import 'dart:io';

part 'pdf_theme.dart';
part 'pdf_builders_classic.dart';
part 'pdf_builders_modern.dart';
part 'pdf_builders_elegant.dart';
part 'pdf_builders_shared.dart';

class PdfService {

  /// Cached font bytes so the assets are only read from disk once.


  /// Indic fallbacks, applied to every theme so Gujarati/Devanagari names are
  /// never dropped from a printed document.

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
    final pageFormat = layout.pageFormatFor(config.paperSize);
    final spacing = config.layoutSpacing;
    final theme = await _getThemeForFont(config.fontFamily);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(isModern || isElegant ? 24 : 32),
          theme: theme,
          buildBackground: config.watermarkText?.isNotEmpty == true
              ? (context) => pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Watermark(
                      child: pw.Text(
                        config.watermarkText!,
                        style: const pw.TextStyle(
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
            if (invoice.shipToName != null ||
                invoice.shipToAddress != null ||
                invoice.shipToCity != null) ...[
              pw.SizedBox(height: spacing / 2),
              _buildShipTo(
                invoice.shipToName,
                invoice.shipToAddress,
                invoice.shipToCity,
              ),
            ],
            if (invoice.supplyType == 'EXPORT' ||
                invoice.supplyType == 'SEZ') ...[
              pw.SizedBox(height: spacing / 2),
              _buildSupplyDeclaration(
                invoice.supplyType,
                invoice.exportWithLut,
              ),
            ],
            if (invoice.invoiceType == billOfSupplyType &&
                business.businessType == BusinessType.compositionScheme) ...[
              pw.SizedBox(height: spacing / 2),
              _buildCompositionDeclaration(),
            ],
            pw.SizedBox(height: spacing),
            _buildItemsTable(
              items,
              invoice.isIgst,
              isGstEnabled,
              business,
              config,
            ),
            if (isGstEnabled && items.isNotEmpty) ...[
              pw.SizedBox(height: spacing),
              _buildHsnSummary(items, invoice.isIgst, invoice.currencyCode),
            ],
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
    final pageFormat = layout.pageFormatFor(config.paperSize);
    final spacing = config.layoutSpacing;
    final theme = await _getThemeForFont(config.fontFamily);

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          pageFormat: pageFormat,
          margin: pw.EdgeInsets.all(isModern || isElegant ? 24 : 32),
          theme: theme,
          buildBackground: config.watermarkText?.isNotEmpty == true
              ? (context) => pw.FullPage(
                    ignoreMargins: true,
                    child: pw.Watermark(
                      child: pw.Text(
                        config.watermarkText!,
                        style: const pw.TextStyle(
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
          if (quote.shipToName != null ||
              quote.shipToAddress != null ||
              quote.shipToCity != null) ...[
            pw.SizedBox(height: spacing / 2),
            _buildShipTo(
              quote.shipToName,
              quote.shipToAddress,
              quote.shipToCity,
            ),
          ],
          if (quote.supplyType == 'EXPORT' || quote.supplyType == 'SEZ') ...[
            pw.SizedBox(height: spacing / 2),
            _buildSupplyDeclaration(quote.supplyType, quote.exportWithLut),
          ],
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













  /// Optional ship-to (delivery) block when it differs from the customer.

  /// Export / SEZ declaration printed on the invoice.

  /// HSN/SAC-wise summary of the taxable value and tax, as required for
  /// GSTR-1 style reporting.







}
