part of 'pdf_service.dart';

// Classic layout builders for invoices and quotes.

pw.Widget _buildQuoteTotals(
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
pw.Widget _buildHeader(
  Business business,
  Invoice invoice,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  final logo = _getLogoImage(business);
  final titleSize = layout.headerTitleSize(config.headerDensity);
  final gap = layout.headerGap(config.headerDensity);

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
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
              ] else if (isGstEnabled) ...[
                pw.Text(
                  '${business.city}, ${GstStates.labelFor(business.stateCode)}',
                ),
                if (business.gstin.isNotEmpty)
                  pw.Text(
                    'GSTIN: ${business.gstin}',
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
                    style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${config.invoiceNoLabel}: ${invoice.invoiceNumber}',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                '${config.dateLabel}: ${formatDateNumeric(invoice.invoiceDate)}',
              ),
              if (config.showDueDate && invoice.dueDate != null)
                pw.Text(
                  'Due Date: ${formatDateNumeric(invoice.dueDate!)}',
                ),
              if (config.showPlaceOfSupply)
                pw.Text(
                  'Place of Supply: '
                  '${GstStates.labelFor(invoice.placeOfSupply)}',
                ),
            ],
          ),
        ],
      ),
      pw.Divider(),
    ],
  );
}
pw.Widget _buildQuoteHeader(
  Business business,
  Quote quote,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
  final logo = _getLogoImage(business);
  final titleSize = layout.headerTitleSize(config.headerDensity);
  final gap = layout.headerGap(config.headerDensity);

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
pw.Widget _buildParties(
  Business business,
  Customer customer,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);

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
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          if (customer.address != null) pw.Text(customer.address!),
          if (customer.city != null) pw.Text(customer.city!),
          if (isGstEnabled && customer.stateCode != null)
            pw.Text(GstStates.labelFor(customer.stateCode)),
          if (isGstEnabled && customer.gstin != null)
            pw.Text(
              'GSTIN: ${customer.gstin}',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          if (customer.pan != null && customer.pan!.isNotEmpty)
            pw.Text(
              'PAN: ${customer.pan}',
              style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
        ],
      ),
    ],
  );
}
pw.Widget _buildAddresses(
  Business business,
  Customer customer,
  bool isGstEnabled,
  InvoiceTemplateConfig config,
) {
  final logo = _getLogoImage(business);
  final brandColor = layout.brandColorFor(business, config);

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
            pw.Text('${business.city}, ${GstStates.labelFor(business.stateCode)}'),
        ],
      ),
    ],
  );
}
pw.Widget _buildQuoteDetails(
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
            style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
          pw.Text(
            '${config.dateLabel}: ${formatDateNumeric(quote.invoiceDate)}',
          ),
        ],
      ),
    ],
  );
}
pw.Widget _buildItemsTable(
  List<InvoiceItem> items,
  bool isIgst,
  bool isGstEnabled,
  Business business,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
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
    border: layout.tableBorderFor(config),
    headerStyle: const pw.TextStyle(
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
pw.Widget _buildQuoteItemTable(
  List<QuoteItem> items,
  bool isGstEnabled,
  Business business,
  InvoiceTemplateConfig config,
) {
  final brandColor = layout.brandColorFor(business, config);
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
    border: layout.tableBorderFor(config),
    headerStyle: const pw.TextStyle(
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
pw.Widget _buildTotals(
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
              if (invoice.discountAmount != 0) pw.Text('Discount:'),
              pw.Text('Taxable Amount:'),
              if (!invoice.isIgst) pw.Text('Total CGST:'),
              if (!invoice.isIgst) pw.Text('Total SGST:'),
              if (invoice.isIgst) pw.Text('Total IGST:'),
            ],
            if (invoice.tcsAmount != 0) pw.Text('TCS:'),
            if (invoice.tdsAmount != 0) pw.Text('Less: TDS:'),
            if (invoice.roundOffAmount != 0) pw.Text('Round Off:'),
            if (invoice.reverseCharge) pw.Text('Reverse charge:'),
            pw.Text(
              'Grand Total:',
              style: const pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (showAmountInWords) ...[
              pw.SizedBox(height: 8),
              pw.Text(
                'Amount in Words:',
                style: const pw.TextStyle(fontWeight: pw.FontWeight.bold),
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
                  invoice.subtotal,
                  currencyCode: invoice.currencyCode,
                ),
              ),
              if (invoice.discountAmount != 0)
                pw.Text(
                  '-${formatMoney(
                    invoice.discountAmount,
                    currencyCode: invoice.currencyCode,
                  )}',
                ),
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
            if (invoice.tcsAmount != 0)
              pw.Text(
                formatMoney(
                  invoice.tcsAmount,
                  currencyCode: invoice.currencyCode,
                ),
              ),
            if (invoice.tdsAmount != 0)
              pw.Text(
                '-${formatMoney(
                  invoice.tdsAmount,
                  currencyCode: invoice.currencyCode,
                )}',
              ),
            if (invoice.roundOffAmount != 0)
              pw.Text(
                formatMoney(
                  invoice.roundOffAmount,
                  currencyCode: invoice.currencyCode,
                ),
              ),
            if (invoice.reverseCharge) pw.Text('Yes'),
            pw.Text(
              formatMoney(
                invoice.totalAmount,
                currencyCode: invoice.currencyCode,
              ),
              style: const pw.TextStyle(
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
                style: const pw.TextStyle(
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
                style: const pw.TextStyle(
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
pw.Widget _buildQuoteFooter(
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
                style: const pw.TextStyle(
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
                style: const pw.TextStyle(
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
              data: layout.buildUpiQrPayload(
                businessName: business.name,
                upiId: business.upiId,
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
pw.Widget _buildInvoiceFooter(
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
                style: const pw.TextStyle(
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
                style: const pw.TextStyle(
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
                  data: layout.buildUpiQrPayload(
                    businessName: business.name,
                    upiId: business.upiId,
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
