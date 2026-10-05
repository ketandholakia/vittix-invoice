part of 'template_manager_screen.dart';

// Template preview/thumbnail PDF builders and their caches.

Future<Uint8List> _buildTemplatePreviewPdf({
  required Business business,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
  required bool isGstEnabled,
  required bool showBankDetails,
}) {
  final previewBusiness = business.copyWith(
    invoiceTemplate: config.layoutFamily,
    quoteTemplate: config.layoutFamily,
    brandColor: drift.Value(_previewBrandColor(config.primaryColor)),
    bankName: config.showBankDetails
        ? drift.Value(business.bankName ?? 'Example Bank')
        : const drift.Value(null),
    bankAccount: config.showBankDetails
        ? drift.Value(business.bankAccount ?? '1234567890')
        : const drift.Value(null),
    bankIfsc: config.showBankDetails
        ? drift.Value(business.bankIfsc ?? 'EXAMP001')
        : const drift.Value(null),
  );

  if (scope == TemplateScope.quote) {
    return PdfService.generateQuotePdf(
      business: previewBusiness,
      customer: _previewCustomer(previewBusiness.id),
      quote: _previewQuote(previewBusiness.id),
      items: _previewQuoteItems(),
      isGstEnabled: isGstEnabled && config.showGst,
      showBankDetails: showBankDetails && config.showBankDetails,
      templateConfig: config,
    );
  }

  return PdfService.generateInvoice(
    business: previewBusiness,
    customer: _previewCustomer(previewBusiness.id),
    invoice: _previewInvoice(previewBusiness.id),
    items: _previewInvoiceItems(),
    isGstEnabled: isGstEnabled && config.showGst,
    showBankDetails: showBankDetails && config.showBankDetails,
    templateConfig: config,
  );
}

final Map<String, Future<Uint8List>> _templatePreviewPdfCache =
    <String, Future<Uint8List>>{};

Customer _previewCustomer(int businessId) => Customer(
  id: 1,
  businessId: businessId,
  name: 'Customer Name',
  gstin: '29ABCDE1234F1Z5',
  pan: null,
  address: 'address line 1',
  city: 'Bengaluru',
  stateCode: 29,
  pincode: '560001',
  phone: '9876543210',
  email: 'customer@email.com',
  isActive: true,
  createdAt: DateTime(2026, 6, 30),
);

Invoice _previewInvoice(int businessId) => Invoice(
  id: 1,
  businessId: businessId,
  customerId: 1,
  invoiceNumber: 'INV-2017-17/100',
  currencyCode: 'INR',
  invoiceDate: DateTime(2026, 6, 30),
  dueDate: DateTime(2026, 7, 7),
  invoiceType: 'TAX',
  supplyType: 'GOODS',
  placeOfSupply: 29,
  subtotal: 300,
  discountAmount: 0,
  taxableAmount: 300,
  cgstAmount: 27,
  sgstAmount: 27,
  igstAmount: 0,
  cessAmount: 0,
  totalAmount: 354,
  roundOffAmount: 0,
  amountPaid: 0,
  amountInWords: 'Rupees Three Hundred Fifty Four Only',
  notes: 'Preview sample',
  terms: 'Thank you for your business.',
  status: 'UNPAID',
  isIgst: false,
  reverseCharge: false,
  exportWithLut: false,
  tdsRate: 0,
  tdsAmount: 0,
  tcsRate: 0,
  tcsAmount: 0,
  createdAt: DateTime(2026, 6, 30),
  updatedAt: DateTime(2026, 6, 30),
);

List<InvoiceItem> _previewInvoiceItems() => const [
  InvoiceItem(
    id: 1,
    invoiceId: 1,
    productId: null,
    name: 'Item 1',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 0,
  ),
  InvoiceItem(
    id: 2,
    invoiceId: 1,
    productId: null,
    name: 'Item 2',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 1,
  ),
  InvoiceItem(
    id: 3,
    invoiceId: 1,
    productId: null,
    name: 'Item 3',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 2,
  ),
];

Quote _previewQuote(int businessId) => Quote(
  id: 1,
  businessId: businessId,
  customerId: 1,
  invoiceNumber: 'QUO-2017-17/100',
  currencyCode: 'INR',
  invoiceDate: DateTime(2026, 6, 30),
  dueDate: DateTime(2026, 7, 7),
  invoiceType: 'QUOTE',
  supplyType: 'GOODS',
  placeOfSupply: 29,
  subtotal: 300,
  discountAmount: 0,
  taxableAmount: 300,
  cgstAmount: 27,
  sgstAmount: 27,
  igstAmount: 0,
  cessAmount: 0,
  totalAmount: 354,
  roundOffAmount: 0,
  amountInWords: 'Rupees Three Hundred Fifty Four Only',
  notes: 'Preview sample',
  terms: 'Quote valid for 7 days.',
  status: 'DRAFT',
  isIgst: false,
  reverseCharge: false,
  exportWithLut: false,
  tdsRate: 0,
  tdsAmount: 0,
  tcsRate: 0,
  tcsAmount: 0,
  createdAt: DateTime(2026, 6, 30),
  updatedAt: DateTime(2026, 6, 30),
);

List<QuoteItem> _previewQuoteItems() => const [
  QuoteItem(
    id: 1,
    quoteId: 1,
    productId: null,
    name: 'Item 1',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 0,
  ),
  QuoteItem(
    id: 2,
    quoteId: 1,
    productId: null,
    name: 'Item 2',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 1,
  ),
  QuoteItem(
    id: 3,
    quoteId: 1,
    productId: null,
    name: 'Item 3',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 2,
  ),
];

int? _previewBrandColor(String colorHex) {
  final hex = colorHex.replaceFirst('#', '');
  if (hex.length != 6) return null;
  return int.tryParse('FF$hex', radix: 16);
}

Color _parseColor(String value, Color fallback) {
  final hex = value.replaceFirst('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  return fallback;
}

Future<Uint8List> _buildTemplateThumbnail({
  required int businessId,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
}) async {
  final pdf = await _buildTemplatePreviewPdf(
    business: Business(
      id: businessId,
      name: 'Your Organization Name',
      gstin: '29ABCDE1234F1Z5',
      pan: null,
      businessType: BusinessType.gstRegistered,
      address: '23/1 Demo Street',
      city: 'Bengaluru',
      stateCode: 29,
      pincode: '560001',
      phone: '9876543210',
      email: 'hello@example.com',
      logoPath: null,
      bankName: 'Example Bank',
      bankAccount: '1234567890',
      bankIfsc: 'EXAMP001',
      upiId: null,
      currencyCode: 'INR',
      invoiceTemplate: config.layoutFamily,
      quoteTemplate: config.layoutFamily,
      invoiceSeriesFormat: 'INV-{FY}-{SEQ4}',
      quoteSeriesFormat: 'QT-{FY}-{SEQ4}',
      creditNoteSeriesFormat: 'CN-{FY}-{SEQ4}',
      debitNoteSeriesFormat: 'DN-{FY}-{SEQ4}',
billOfSupplySeriesFormat: 'BOS-{FY}-{SEQ4}',
      defaultInvoiceTemplateId: null,
      defaultQuoteTemplateId: null,
      brandColor: _previewBrandColor(config.primaryColor),
      isActive: true,
      createdAt: DateTime(2026, 6, 30),
    ),
    scope: scope,
    config: config,
    isGstEnabled: config.showGst,
    showBankDetails: config.showBankDetails,
  );

  await for (final page in Printing.raster(pdf, pages: const [0], dpi: 72)) {
    return page.toPng();
  }
  throw StateError('Unable to rasterize template thumbnail');
}

final Map<String, Future<Uint8List>> _templateThumbnailCache =
    <String, Future<Uint8List>>{};

Future<Uint8List> _getCachedTemplatePreviewPdf({
  required Business business,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
  required bool isGstEnabled,
  required bool showBankDetails,
}) {
  final cacheKey = [
    business.id,
    scope.name,
    config.encode(),
    isGstEnabled,
    showBankDetails,
    business.brandColor,
    business.bankName,
    business.bankAccount,
    business.bankIfsc,
    business.invoiceTemplate,
    business.quoteTemplate,
  ].join('|');

  return _templatePreviewPdfCache.putIfAbsent(
    cacheKey,
    () => _buildTemplatePreviewPdf(
      business: business,
      scope: scope,
      config: config,
      isGstEnabled: isGstEnabled,
      showBankDetails: showBankDetails,
    ),
  );
}

Future<Uint8List> _getCachedTemplateThumbnail({
  required int businessId,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
}) {
  final cacheKey = '$businessId|${scope.name}|${config.encode()}';
  return _templateThumbnailCache.putIfAbsent(
    cacheKey,
    () => _buildTemplateThumbnail(
      businessId: businessId,
      scope: scope,
      config: config,
    ),
  );
}

void _clearTemplatePreviewCaches() {
  _templatePreviewPdfCache.clear();
  _templateThumbnailCache.clear();
}
