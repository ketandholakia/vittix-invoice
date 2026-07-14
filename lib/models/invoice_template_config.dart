import 'dart:convert';

class InvoiceTemplateConfig {
  final String id;
  final String name;
  final String paperSize;
  final String primaryColor;
  final String accentColor;
  final bool showLogo;
  final bool showGst;
  final bool showHsn;
  final bool showBankDetails;
  final bool showSignature;
  final bool showQrCode;
  final List<String> itemColumns;
  final String titleLabel;
  final String invoiceNoLabel;
  final String dateLabel;
  final String billToLabel;
  final String termsText;
  final String layoutFamily;
  final double layoutSpacing;
  final double borderThickness;
  final String headerDensity;
  final String? watermarkText;
  final String? fontFamily;
  // New customisation fields
  final bool showDueDate;
  final bool showPlaceOfSupply;
  final bool showAmountInWords;
  /// 'FULL' | 'ROWS_ONLY' | 'NONE'
  final String tableBorderStyle;
  final String? footerText;

  const InvoiceTemplateConfig({
    required this.id,
    required this.name,
    required this.paperSize,
    required this.primaryColor,
    required this.accentColor,
    required this.showLogo,
    required this.showGst,
    required this.showHsn,
    required this.showBankDetails,
    required this.showSignature,
    required this.showQrCode,
    required this.itemColumns,
    required this.titleLabel,
    required this.invoiceNoLabel,
    required this.dateLabel,
    required this.billToLabel,
    required this.termsText,
    required this.layoutFamily,
    required this.layoutSpacing,
    required this.borderThickness,
    required this.headerDensity,
    this.watermarkText,
    this.fontFamily,
    this.showDueDate = true,
    this.showPlaceOfSupply = true,
    this.showAmountInWords = true,
    this.tableBorderStyle = 'FULL',
    this.footerText,
  });

  factory InvoiceTemplateConfig.defaults({
    required String id,
    required String name,
    String layoutFamily = 'CLASSIC',
  }) {
    return InvoiceTemplateConfig(
      id: id,
      name: name,
      paperSize: 'a4',
      primaryColor: '#1E88E5',
      accentColor: '#E3F2FD',
      showLogo: true,
      showGst: true,
      showHsn: true,
      showBankDetails: true,
      showSignature: true,
      showQrCode: false,
      itemColumns: const ['item', 'hsn', 'qty', 'rate', 'gst', 'amount'],
      titleLabel: 'TAX INVOICE',
      invoiceNoLabel: 'Invoice No',
      dateLabel: 'Date',
      billToLabel: 'Bill To',
      termsText: 'Thank you for your business.',
      layoutFamily: layoutFamily,
      layoutSpacing: 12,
      borderThickness: 1,
      headerDensity: 'COMFORTABLE',
      watermarkText: null,
      fontFamily: null,
      showDueDate: true,
      showPlaceOfSupply: true,
      showAmountInWords: true,
      tableBorderStyle: 'FULL',
      footerText: null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'paperSize': paperSize,
    'primaryColor': primaryColor,
    'accentColor': accentColor,
    'showLogo': showLogo,
    'showGst': showGst,
    'showHsn': showHsn,
    'showBankDetails': showBankDetails,
    'showSignature': showSignature,
    'showQrCode': showQrCode,
    'itemColumns': itemColumns,
    'titleLabel': titleLabel,
    'invoiceNoLabel': invoiceNoLabel,
    'dateLabel': dateLabel,
    'billToLabel': billToLabel,
    'termsText': termsText,
    'layoutFamily': layoutFamily,
    'layoutSpacing': layoutSpacing,
    'borderThickness': borderThickness,
    'headerDensity': headerDensity,
    'watermarkText': watermarkText,
    'fontFamily': fontFamily,
    'showDueDate': showDueDate,
    'showPlaceOfSupply': showPlaceOfSupply,
    'showAmountInWords': showAmountInWords,
    'tableBorderStyle': tableBorderStyle,
    'footerText': footerText,
  };

  factory InvoiceTemplateConfig.fromJson(Map<String, dynamic> json) {
    return InvoiceTemplateConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      paperSize: json['paperSize'] as String? ?? 'a4',
      primaryColor: json['primaryColor'] as String? ?? '#1E88E5',
      accentColor: json['accentColor'] as String? ?? '#E3F2FD',
      showLogo: json['showLogo'] as bool? ?? true,
      showGst: json['showGst'] as bool? ?? true,
      showHsn: json['showHsn'] as bool? ?? true,
      showBankDetails: json['showBankDetails'] as bool? ?? true,
      showSignature: json['showSignature'] as bool? ?? true,
      showQrCode: json['showQrCode'] as bool? ?? false,
      itemColumns: (json['itemColumns'] as List<dynamic>? ?? const [])
          .map((e) => e.toString())
          .toList(),
      titleLabel: json['titleLabel'] as String? ?? 'TAX INVOICE',
      invoiceNoLabel: json['invoiceNoLabel'] as String? ?? 'Invoice No',
      dateLabel: json['dateLabel'] as String? ?? 'Date',
      billToLabel: json['billToLabel'] as String? ?? 'Bill To',
      termsText: json['termsText'] as String? ?? '',
      layoutFamily: json['layoutFamily'] as String? ?? 'CLASSIC',
      layoutSpacing: (json['layoutSpacing'] as num?)?.toDouble() ?? 12,
      borderThickness: (json['borderThickness'] as num?)?.toDouble() ?? 1,
      headerDensity: json['headerDensity'] as String? ?? 'COMFORTABLE',
      watermarkText: json['watermarkText'] as String?,
      fontFamily: json['fontFamily'] as String?,
      showDueDate: json['showDueDate'] as bool? ?? true,
      showPlaceOfSupply: json['showPlaceOfSupply'] as bool? ?? true,
      showAmountInWords: json['showAmountInWords'] as bool? ?? true,
      tableBorderStyle: json['tableBorderStyle'] as String? ?? 'FULL',
      footerText: json['footerText'] as String?,
    );
  }

  InvoiceTemplateConfig copyWith({
    String? id,
    String? name,
    String? paperSize,
    String? primaryColor,
    String? accentColor,
    bool? showLogo,
    bool? showGst,
    bool? showHsn,
    bool? showBankDetails,
    bool? showSignature,
    bool? showQrCode,
    List<String>? itemColumns,
    String? titleLabel,
    String? invoiceNoLabel,
    String? dateLabel,
    String? billToLabel,
    String? termsText,
    String? layoutFamily,
    double? layoutSpacing,
    double? borderThickness,
    String? headerDensity,
    String? watermarkText,
    String? fontFamily,
    bool? showDueDate,
    bool? showPlaceOfSupply,
    bool? showAmountInWords,
    String? tableBorderStyle,
    String? footerText,
  }) {
    return InvoiceTemplateConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      paperSize: paperSize ?? this.paperSize,
      primaryColor: primaryColor ?? this.primaryColor,
      accentColor: accentColor ?? this.accentColor,
      showLogo: showLogo ?? this.showLogo,
      showGst: showGst ?? this.showGst,
      showHsn: showHsn ?? this.showHsn,
      showBankDetails: showBankDetails ?? this.showBankDetails,
      showSignature: showSignature ?? this.showSignature,
      showQrCode: showQrCode ?? this.showQrCode,
      itemColumns: itemColumns ?? this.itemColumns,
      titleLabel: titleLabel ?? this.titleLabel,
      invoiceNoLabel: invoiceNoLabel ?? this.invoiceNoLabel,
      dateLabel: dateLabel ?? this.dateLabel,
      billToLabel: billToLabel ?? this.billToLabel,
      termsText: termsText ?? this.termsText,
      layoutFamily: layoutFamily ?? this.layoutFamily,
      layoutSpacing: layoutSpacing ?? this.layoutSpacing,
      borderThickness: borderThickness ?? this.borderThickness,
      headerDensity: headerDensity ?? this.headerDensity,
      watermarkText: watermarkText ?? this.watermarkText,
      fontFamily: fontFamily ?? this.fontFamily,
      showDueDate: showDueDate ?? this.showDueDate,
      showPlaceOfSupply: showPlaceOfSupply ?? this.showPlaceOfSupply,
      showAmountInWords: showAmountInWords ?? this.showAmountInWords,
      tableBorderStyle: tableBorderStyle ?? this.tableBorderStyle,
      footerText: footerText ?? this.footerText,
    );
  }

  String encode() => jsonEncode(toJson());

  factory InvoiceTemplateConfig.decode(String value) =>
      InvoiceTemplateConfig.fromJson(jsonDecode(value) as Map<String, dynamic>);
}
