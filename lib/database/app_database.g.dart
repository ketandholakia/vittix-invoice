// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BusinessesTable extends Businesses
    with TableInfo<$BusinessesTable, Business> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BusinessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<BusinessType, int> businessType =
      GeneratedColumn<int>(
        'business_type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<BusinessType>($BusinessesTable.$converterbusinessType);
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<int> stateCode = GeneratedColumn<int>(
    'state_code',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankNameMeta = const VerificationMeta(
    'bankName',
  );
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
    'bank_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankAccountMeta = const VerificationMeta(
    'bankAccount',
  );
  @override
  late final GeneratedColumn<String> bankAccount = GeneratedColumn<String>(
    'bank_account',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bankIfscMeta = const VerificationMeta(
    'bankIfsc',
  );
  @override
  late final GeneratedColumn<String> bankIfsc = GeneratedColumn<String>(
    'bank_ifsc',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
    'upi_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _invoiceTemplateMeta = const VerificationMeta(
    'invoiceTemplate',
  );
  @override
  late final GeneratedColumn<String> invoiceTemplate = GeneratedColumn<String>(
    'invoice_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CLASSIC'),
  );
  static const VerificationMeta _quoteTemplateMeta = const VerificationMeta(
    'quoteTemplate',
  );
  @override
  late final GeneratedColumn<String> quoteTemplate = GeneratedColumn<String>(
    'quote_template',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('CLASSIC'),
  );
  static const VerificationMeta _invoiceSeriesFormatMeta =
      const VerificationMeta('invoiceSeriesFormat');
  @override
  late final GeneratedColumn<String> invoiceSeriesFormat =
      GeneratedColumn<String>(
        'invoice_series_format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('INV-{FY}-{SEQ4}'),
      );
  static const VerificationMeta _quoteSeriesFormatMeta = const VerificationMeta(
    'quoteSeriesFormat',
  );
  @override
  late final GeneratedColumn<String> quoteSeriesFormat =
      GeneratedColumn<String>(
        'quote_series_format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('QT-{FY}-{SEQ4}'),
      );
  static const VerificationMeta _creditNoteSeriesFormatMeta =
      const VerificationMeta('creditNoteSeriesFormat');
  @override
  late final GeneratedColumn<String> creditNoteSeriesFormat =
      GeneratedColumn<String>(
        'credit_note_series_format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('CN-{FY}-{SEQ4}'),
      );
  static const VerificationMeta _debitNoteSeriesFormatMeta =
      const VerificationMeta('debitNoteSeriesFormat');
  @override
  late final GeneratedColumn<String> debitNoteSeriesFormat =
      GeneratedColumn<String>(
        'debit_note_series_format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('DN-{FY}-{SEQ4}'),
      );
  static const VerificationMeta _billOfSupplySeriesFormatMeta =
      const VerificationMeta('billOfSupplySeriesFormat');
  @override
  late final GeneratedColumn<String> billOfSupplySeriesFormat =
      GeneratedColumn<String>(
        'bill_of_supply_series_format',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('BOS-{FY}-{SEQ4}'),
      );
  static const VerificationMeta _defaultInvoiceTemplateIdMeta =
      const VerificationMeta('defaultInvoiceTemplateId');
  @override
  late final GeneratedColumn<int> defaultInvoiceTemplateId =
      GeneratedColumn<int>(
        'default_invoice_template_id',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _defaultQuoteTemplateIdMeta =
      const VerificationMeta('defaultQuoteTemplateId');
  @override
  late final GeneratedColumn<int> defaultQuoteTemplateId = GeneratedColumn<int>(
    'default_quote_template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _brandColorMeta = const VerificationMeta(
    'brandColor',
  );
  @override
  late final GeneratedColumn<int> brandColor = GeneratedColumn<int>(
    'brand_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    gstin,
    pan,
    businessType,
    address,
    city,
    stateCode,
    pincode,
    phone,
    email,
    logoPath,
    bankName,
    bankAccount,
    bankIfsc,
    upiId,
    currencyCode,
    invoiceTemplate,
    quoteTemplate,
    invoiceSeriesFormat,
    quoteSeriesFormat,
    creditNoteSeriesFormat,
    debitNoteSeriesFormat,
    billOfSupplySeriesFormat,
    defaultInvoiceTemplateId,
    defaultQuoteTemplateId,
    brandColor,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'businesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<Business> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    } else if (isInserting) {
      context.missing(_gstinMeta);
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    } else if (isInserting) {
      context.missing(_cityMeta);
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_stateCodeMeta);
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('bank_name')) {
      context.handle(
        _bankNameMeta,
        bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta),
      );
    }
    if (data.containsKey('bank_account')) {
      context.handle(
        _bankAccountMeta,
        bankAccount.isAcceptableOrUnknown(
          data['bank_account']!,
          _bankAccountMeta,
        ),
      );
    }
    if (data.containsKey('bank_ifsc')) {
      context.handle(
        _bankIfscMeta,
        bankIfsc.isAcceptableOrUnknown(data['bank_ifsc']!, _bankIfscMeta),
      );
    }
    if (data.containsKey('upi_id')) {
      context.handle(
        _upiIdMeta,
        upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta),
      );
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('invoice_template')) {
      context.handle(
        _invoiceTemplateMeta,
        invoiceTemplate.isAcceptableOrUnknown(
          data['invoice_template']!,
          _invoiceTemplateMeta,
        ),
      );
    }
    if (data.containsKey('quote_template')) {
      context.handle(
        _quoteTemplateMeta,
        quoteTemplate.isAcceptableOrUnknown(
          data['quote_template']!,
          _quoteTemplateMeta,
        ),
      );
    }
    if (data.containsKey('invoice_series_format')) {
      context.handle(
        _invoiceSeriesFormatMeta,
        invoiceSeriesFormat.isAcceptableOrUnknown(
          data['invoice_series_format']!,
          _invoiceSeriesFormatMeta,
        ),
      );
    }
    if (data.containsKey('quote_series_format')) {
      context.handle(
        _quoteSeriesFormatMeta,
        quoteSeriesFormat.isAcceptableOrUnknown(
          data['quote_series_format']!,
          _quoteSeriesFormatMeta,
        ),
      );
    }
    if (data.containsKey('credit_note_series_format')) {
      context.handle(
        _creditNoteSeriesFormatMeta,
        creditNoteSeriesFormat.isAcceptableOrUnknown(
          data['credit_note_series_format']!,
          _creditNoteSeriesFormatMeta,
        ),
      );
    }
    if (data.containsKey('debit_note_series_format')) {
      context.handle(
        _debitNoteSeriesFormatMeta,
        debitNoteSeriesFormat.isAcceptableOrUnknown(
          data['debit_note_series_format']!,
          _debitNoteSeriesFormatMeta,
        ),
      );
    }
    if (data.containsKey('bill_of_supply_series_format')) {
      context.handle(
        _billOfSupplySeriesFormatMeta,
        billOfSupplySeriesFormat.isAcceptableOrUnknown(
          data['bill_of_supply_series_format']!,
          _billOfSupplySeriesFormatMeta,
        ),
      );
    }
    if (data.containsKey('default_invoice_template_id')) {
      context.handle(
        _defaultInvoiceTemplateIdMeta,
        defaultInvoiceTemplateId.isAcceptableOrUnknown(
          data['default_invoice_template_id']!,
          _defaultInvoiceTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('default_quote_template_id')) {
      context.handle(
        _defaultQuoteTemplateIdMeta,
        defaultQuoteTemplateId.isAcceptableOrUnknown(
          data['default_quote_template_id']!,
          _defaultQuoteTemplateIdMeta,
        ),
      );
    }
    if (data.containsKey('brand_color')) {
      context.handle(
        _brandColorMeta,
        brandColor.isAcceptableOrUnknown(data['brand_color']!, _brandColorMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Business map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Business(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      )!,
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      businessType: $BusinessesTable.$converterbusinessType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}business_type'],
        )!,
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      )!,
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_code'],
      )!,
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      bankName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_name'],
      ),
      bankAccount: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_account'],
      ),
      bankIfsc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bank_ifsc'],
      ),
      upiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}upi_id'],
      ),
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      invoiceTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_template'],
      )!,
      quoteTemplate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_template'],
      )!,
      invoiceSeriesFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_series_format'],
      )!,
      quoteSeriesFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}quote_series_format'],
      )!,
      creditNoteSeriesFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}credit_note_series_format'],
      )!,
      debitNoteSeriesFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}debit_note_series_format'],
      )!,
      billOfSupplySeriesFormat: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bill_of_supply_series_format'],
      )!,
      defaultInvoiceTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_invoice_template_id'],
      ),
      defaultQuoteTemplateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_quote_template_id'],
      ),
      brandColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}brand_color'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BusinessesTable createAlias(String alias) {
    return $BusinessesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<BusinessType, int, int> $converterbusinessType =
      const EnumIndexConverter<BusinessType>(BusinessType.values);
}

class Business extends DataClass implements Insertable<Business> {
  final int id;
  final String name;
  final String gstin;
  final String? pan;
  final BusinessType businessType;
  final String address;
  final String city;
  final int stateCode;
  final String? pincode;
  final String? phone;
  final String? email;
  final String? logoPath;
  final String? bankName;
  final String? bankAccount;
  final String? bankIfsc;
  final String? upiId;
  final String currencyCode;
  final String invoiceTemplate;
  final String quoteTemplate;
  final String invoiceSeriesFormat;
  final String quoteSeriesFormat;
  final String creditNoteSeriesFormat;
  final String debitNoteSeriesFormat;

  /// Bills of Supply (composition / unregistered / exempt supplies) get their
  /// own series so tax invoices and BOS documents never share numbering.
  final String billOfSupplySeriesFormat;
  final int? defaultInvoiceTemplateId;
  final int? defaultQuoteTemplateId;
  final int? brandColor;
  final bool isActive;
  final DateTime createdAt;
  const Business({
    required this.id,
    required this.name,
    required this.gstin,
    this.pan,
    required this.businessType,
    required this.address,
    required this.city,
    required this.stateCode,
    this.pincode,
    this.phone,
    this.email,
    this.logoPath,
    this.bankName,
    this.bankAccount,
    this.bankIfsc,
    this.upiId,
    required this.currencyCode,
    required this.invoiceTemplate,
    required this.quoteTemplate,
    required this.invoiceSeriesFormat,
    required this.quoteSeriesFormat,
    required this.creditNoteSeriesFormat,
    required this.debitNoteSeriesFormat,
    required this.billOfSupplySeriesFormat,
    this.defaultInvoiceTemplateId,
    this.defaultQuoteTemplateId,
    this.brandColor,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['gstin'] = Variable<String>(gstin);
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    {
      map['business_type'] = Variable<int>(
        $BusinessesTable.$converterbusinessType.toSql(businessType),
      );
    }
    map['address'] = Variable<String>(address);
    map['city'] = Variable<String>(city);
    map['state_code'] = Variable<int>(stateCode);
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    if (!nullToAbsent || bankName != null) {
      map['bank_name'] = Variable<String>(bankName);
    }
    if (!nullToAbsent || bankAccount != null) {
      map['bank_account'] = Variable<String>(bankAccount);
    }
    if (!nullToAbsent || bankIfsc != null) {
      map['bank_ifsc'] = Variable<String>(bankIfsc);
    }
    if (!nullToAbsent || upiId != null) {
      map['upi_id'] = Variable<String>(upiId);
    }
    map['currency_code'] = Variable<String>(currencyCode);
    map['invoice_template'] = Variable<String>(invoiceTemplate);
    map['quote_template'] = Variable<String>(quoteTemplate);
    map['invoice_series_format'] = Variable<String>(invoiceSeriesFormat);
    map['quote_series_format'] = Variable<String>(quoteSeriesFormat);
    map['credit_note_series_format'] = Variable<String>(creditNoteSeriesFormat);
    map['debit_note_series_format'] = Variable<String>(debitNoteSeriesFormat);
    map['bill_of_supply_series_format'] = Variable<String>(
      billOfSupplySeriesFormat,
    );
    if (!nullToAbsent || defaultInvoiceTemplateId != null) {
      map['default_invoice_template_id'] = Variable<int>(
        defaultInvoiceTemplateId,
      );
    }
    if (!nullToAbsent || defaultQuoteTemplateId != null) {
      map['default_quote_template_id'] = Variable<int>(defaultQuoteTemplateId);
    }
    if (!nullToAbsent || brandColor != null) {
      map['brand_color'] = Variable<int>(brandColor);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BusinessesCompanion toCompanion(bool nullToAbsent) {
    return BusinessesCompanion(
      id: Value(id),
      name: Value(name),
      gstin: Value(gstin),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      businessType: Value(businessType),
      address: Value(address),
      city: Value(city),
      stateCode: Value(stateCode),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      bankName: bankName == null && nullToAbsent
          ? const Value.absent()
          : Value(bankName),
      bankAccount: bankAccount == null && nullToAbsent
          ? const Value.absent()
          : Value(bankAccount),
      bankIfsc: bankIfsc == null && nullToAbsent
          ? const Value.absent()
          : Value(bankIfsc),
      upiId: upiId == null && nullToAbsent
          ? const Value.absent()
          : Value(upiId),
      currencyCode: Value(currencyCode),
      invoiceTemplate: Value(invoiceTemplate),
      quoteTemplate: Value(quoteTemplate),
      invoiceSeriesFormat: Value(invoiceSeriesFormat),
      quoteSeriesFormat: Value(quoteSeriesFormat),
      creditNoteSeriesFormat: Value(creditNoteSeriesFormat),
      debitNoteSeriesFormat: Value(debitNoteSeriesFormat),
      billOfSupplySeriesFormat: Value(billOfSupplySeriesFormat),
      defaultInvoiceTemplateId: defaultInvoiceTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultInvoiceTemplateId),
      defaultQuoteTemplateId: defaultQuoteTemplateId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultQuoteTemplateId),
      brandColor: brandColor == null && nullToAbsent
          ? const Value.absent()
          : Value(brandColor),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Business.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Business(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      gstin: serializer.fromJson<String>(json['gstin']),
      pan: serializer.fromJson<String?>(json['pan']),
      businessType: $BusinessesTable.$converterbusinessType.fromJson(
        serializer.fromJson<int>(json['businessType']),
      ),
      address: serializer.fromJson<String>(json['address']),
      city: serializer.fromJson<String>(json['city']),
      stateCode: serializer.fromJson<int>(json['stateCode']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      bankName: serializer.fromJson<String?>(json['bankName']),
      bankAccount: serializer.fromJson<String?>(json['bankAccount']),
      bankIfsc: serializer.fromJson<String?>(json['bankIfsc']),
      upiId: serializer.fromJson<String?>(json['upiId']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      invoiceTemplate: serializer.fromJson<String>(json['invoiceTemplate']),
      quoteTemplate: serializer.fromJson<String>(json['quoteTemplate']),
      invoiceSeriesFormat: serializer.fromJson<String>(
        json['invoiceSeriesFormat'],
      ),
      quoteSeriesFormat: serializer.fromJson<String>(json['quoteSeriesFormat']),
      creditNoteSeriesFormat: serializer.fromJson<String>(
        json['creditNoteSeriesFormat'],
      ),
      debitNoteSeriesFormat: serializer.fromJson<String>(
        json['debitNoteSeriesFormat'],
      ),
      billOfSupplySeriesFormat: serializer.fromJson<String>(
        json['billOfSupplySeriesFormat'],
      ),
      defaultInvoiceTemplateId: serializer.fromJson<int?>(
        json['defaultInvoiceTemplateId'],
      ),
      defaultQuoteTemplateId: serializer.fromJson<int?>(
        json['defaultQuoteTemplateId'],
      ),
      brandColor: serializer.fromJson<int?>(json['brandColor']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'gstin': serializer.toJson<String>(gstin),
      'pan': serializer.toJson<String?>(pan),
      'businessType': serializer.toJson<int>(
        $BusinessesTable.$converterbusinessType.toJson(businessType),
      ),
      'address': serializer.toJson<String>(address),
      'city': serializer.toJson<String>(city),
      'stateCode': serializer.toJson<int>(stateCode),
      'pincode': serializer.toJson<String?>(pincode),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'logoPath': serializer.toJson<String?>(logoPath),
      'bankName': serializer.toJson<String?>(bankName),
      'bankAccount': serializer.toJson<String?>(bankAccount),
      'bankIfsc': serializer.toJson<String?>(bankIfsc),
      'upiId': serializer.toJson<String?>(upiId),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'invoiceTemplate': serializer.toJson<String>(invoiceTemplate),
      'quoteTemplate': serializer.toJson<String>(quoteTemplate),
      'invoiceSeriesFormat': serializer.toJson<String>(invoiceSeriesFormat),
      'quoteSeriesFormat': serializer.toJson<String>(quoteSeriesFormat),
      'creditNoteSeriesFormat': serializer.toJson<String>(
        creditNoteSeriesFormat,
      ),
      'debitNoteSeriesFormat': serializer.toJson<String>(debitNoteSeriesFormat),
      'billOfSupplySeriesFormat': serializer.toJson<String>(
        billOfSupplySeriesFormat,
      ),
      'defaultInvoiceTemplateId': serializer.toJson<int?>(
        defaultInvoiceTemplateId,
      ),
      'defaultQuoteTemplateId': serializer.toJson<int?>(defaultQuoteTemplateId),
      'brandColor': serializer.toJson<int?>(brandColor),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Business copyWith({
    int? id,
    String? name,
    String? gstin,
    Value<String?> pan = const Value.absent(),
    BusinessType? businessType,
    String? address,
    String? city,
    int? stateCode,
    Value<String?> pincode = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> logoPath = const Value.absent(),
    Value<String?> bankName = const Value.absent(),
    Value<String?> bankAccount = const Value.absent(),
    Value<String?> bankIfsc = const Value.absent(),
    Value<String?> upiId = const Value.absent(),
    String? currencyCode,
    String? invoiceTemplate,
    String? quoteTemplate,
    String? invoiceSeriesFormat,
    String? quoteSeriesFormat,
    String? creditNoteSeriesFormat,
    String? debitNoteSeriesFormat,
    String? billOfSupplySeriesFormat,
    Value<int?> defaultInvoiceTemplateId = const Value.absent(),
    Value<int?> defaultQuoteTemplateId = const Value.absent(),
    Value<int?> brandColor = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Business(
    id: id ?? this.id,
    name: name ?? this.name,
    gstin: gstin ?? this.gstin,
    pan: pan.present ? pan.value : this.pan,
    businessType: businessType ?? this.businessType,
    address: address ?? this.address,
    city: city ?? this.city,
    stateCode: stateCode ?? this.stateCode,
    pincode: pincode.present ? pincode.value : this.pincode,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    bankName: bankName.present ? bankName.value : this.bankName,
    bankAccount: bankAccount.present ? bankAccount.value : this.bankAccount,
    bankIfsc: bankIfsc.present ? bankIfsc.value : this.bankIfsc,
    upiId: upiId.present ? upiId.value : this.upiId,
    currencyCode: currencyCode ?? this.currencyCode,
    invoiceTemplate: invoiceTemplate ?? this.invoiceTemplate,
    quoteTemplate: quoteTemplate ?? this.quoteTemplate,
    invoiceSeriesFormat: invoiceSeriesFormat ?? this.invoiceSeriesFormat,
    quoteSeriesFormat: quoteSeriesFormat ?? this.quoteSeriesFormat,
    creditNoteSeriesFormat:
        creditNoteSeriesFormat ?? this.creditNoteSeriesFormat,
    debitNoteSeriesFormat: debitNoteSeriesFormat ?? this.debitNoteSeriesFormat,
    billOfSupplySeriesFormat:
        billOfSupplySeriesFormat ?? this.billOfSupplySeriesFormat,
    defaultInvoiceTemplateId: defaultInvoiceTemplateId.present
        ? defaultInvoiceTemplateId.value
        : this.defaultInvoiceTemplateId,
    defaultQuoteTemplateId: defaultQuoteTemplateId.present
        ? defaultQuoteTemplateId.value
        : this.defaultQuoteTemplateId,
    brandColor: brandColor.present ? brandColor.value : this.brandColor,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Business copyWithCompanion(BusinessesCompanion data) {
    return Business(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      pan: data.pan.present ? data.pan.value : this.pan,
      businessType: data.businessType.present
          ? data.businessType.value
          : this.businessType,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      bankAccount: data.bankAccount.present
          ? data.bankAccount.value
          : this.bankAccount,
      bankIfsc: data.bankIfsc.present ? data.bankIfsc.value : this.bankIfsc,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      invoiceTemplate: data.invoiceTemplate.present
          ? data.invoiceTemplate.value
          : this.invoiceTemplate,
      quoteTemplate: data.quoteTemplate.present
          ? data.quoteTemplate.value
          : this.quoteTemplate,
      invoiceSeriesFormat: data.invoiceSeriesFormat.present
          ? data.invoiceSeriesFormat.value
          : this.invoiceSeriesFormat,
      quoteSeriesFormat: data.quoteSeriesFormat.present
          ? data.quoteSeriesFormat.value
          : this.quoteSeriesFormat,
      creditNoteSeriesFormat: data.creditNoteSeriesFormat.present
          ? data.creditNoteSeriesFormat.value
          : this.creditNoteSeriesFormat,
      debitNoteSeriesFormat: data.debitNoteSeriesFormat.present
          ? data.debitNoteSeriesFormat.value
          : this.debitNoteSeriesFormat,
      billOfSupplySeriesFormat: data.billOfSupplySeriesFormat.present
          ? data.billOfSupplySeriesFormat.value
          : this.billOfSupplySeriesFormat,
      defaultInvoiceTemplateId: data.defaultInvoiceTemplateId.present
          ? data.defaultInvoiceTemplateId.value
          : this.defaultInvoiceTemplateId,
      defaultQuoteTemplateId: data.defaultQuoteTemplateId.present
          ? data.defaultQuoteTemplateId.value
          : this.defaultQuoteTemplateId,
      brandColor: data.brandColor.present
          ? data.brandColor.value
          : this.brandColor,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Business(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('businessType: $businessType, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('bankIfsc: $bankIfsc, ')
          ..write('upiId: $upiId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceTemplate: $invoiceTemplate, ')
          ..write('quoteTemplate: $quoteTemplate, ')
          ..write('invoiceSeriesFormat: $invoiceSeriesFormat, ')
          ..write('quoteSeriesFormat: $quoteSeriesFormat, ')
          ..write('creditNoteSeriesFormat: $creditNoteSeriesFormat, ')
          ..write('debitNoteSeriesFormat: $debitNoteSeriesFormat, ')
          ..write('billOfSupplySeriesFormat: $billOfSupplySeriesFormat, ')
          ..write('defaultInvoiceTemplateId: $defaultInvoiceTemplateId, ')
          ..write('defaultQuoteTemplateId: $defaultQuoteTemplateId, ')
          ..write('brandColor: $brandColor, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    name,
    gstin,
    pan,
    businessType,
    address,
    city,
    stateCode,
    pincode,
    phone,
    email,
    logoPath,
    bankName,
    bankAccount,
    bankIfsc,
    upiId,
    currencyCode,
    invoiceTemplate,
    quoteTemplate,
    invoiceSeriesFormat,
    quoteSeriesFormat,
    creditNoteSeriesFormat,
    debitNoteSeriesFormat,
    billOfSupplySeriesFormat,
    defaultInvoiceTemplateId,
    defaultQuoteTemplateId,
    brandColor,
    isActive,
    createdAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Business &&
          other.id == this.id &&
          other.name == this.name &&
          other.gstin == this.gstin &&
          other.pan == this.pan &&
          other.businessType == this.businessType &&
          other.address == this.address &&
          other.city == this.city &&
          other.stateCode == this.stateCode &&
          other.pincode == this.pincode &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.logoPath == this.logoPath &&
          other.bankName == this.bankName &&
          other.bankAccount == this.bankAccount &&
          other.bankIfsc == this.bankIfsc &&
          other.upiId == this.upiId &&
          other.currencyCode == this.currencyCode &&
          other.invoiceTemplate == this.invoiceTemplate &&
          other.quoteTemplate == this.quoteTemplate &&
          other.invoiceSeriesFormat == this.invoiceSeriesFormat &&
          other.quoteSeriesFormat == this.quoteSeriesFormat &&
          other.creditNoteSeriesFormat == this.creditNoteSeriesFormat &&
          other.debitNoteSeriesFormat == this.debitNoteSeriesFormat &&
          other.billOfSupplySeriesFormat == this.billOfSupplySeriesFormat &&
          other.defaultInvoiceTemplateId == this.defaultInvoiceTemplateId &&
          other.defaultQuoteTemplateId == this.defaultQuoteTemplateId &&
          other.brandColor == this.brandColor &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class BusinessesCompanion extends UpdateCompanion<Business> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> gstin;
  final Value<String?> pan;
  final Value<BusinessType> businessType;
  final Value<String> address;
  final Value<String> city;
  final Value<int> stateCode;
  final Value<String?> pincode;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> logoPath;
  final Value<String?> bankName;
  final Value<String?> bankAccount;
  final Value<String?> bankIfsc;
  final Value<String?> upiId;
  final Value<String> currencyCode;
  final Value<String> invoiceTemplate;
  final Value<String> quoteTemplate;
  final Value<String> invoiceSeriesFormat;
  final Value<String> quoteSeriesFormat;
  final Value<String> creditNoteSeriesFormat;
  final Value<String> debitNoteSeriesFormat;
  final Value<String> billOfSupplySeriesFormat;
  final Value<int?> defaultInvoiceTemplateId;
  final Value<int?> defaultQuoteTemplateId;
  final Value<int?> brandColor;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const BusinessesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.businessType = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.pincode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.bankIfsc = const Value.absent(),
    this.upiId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.invoiceTemplate = const Value.absent(),
    this.quoteTemplate = const Value.absent(),
    this.invoiceSeriesFormat = const Value.absent(),
    this.quoteSeriesFormat = const Value.absent(),
    this.creditNoteSeriesFormat = const Value.absent(),
    this.debitNoteSeriesFormat = const Value.absent(),
    this.billOfSupplySeriesFormat = const Value.absent(),
    this.defaultInvoiceTemplateId = const Value.absent(),
    this.defaultQuoteTemplateId = const Value.absent(),
    this.brandColor = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BusinessesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String gstin,
    this.pan = const Value.absent(),
    this.businessType = const Value.absent(),
    required String address,
    required String city,
    required int stateCode,
    this.pincode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.bankName = const Value.absent(),
    this.bankAccount = const Value.absent(),
    this.bankIfsc = const Value.absent(),
    this.upiId = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.invoiceTemplate = const Value.absent(),
    this.quoteTemplate = const Value.absent(),
    this.invoiceSeriesFormat = const Value.absent(),
    this.quoteSeriesFormat = const Value.absent(),
    this.creditNoteSeriesFormat = const Value.absent(),
    this.debitNoteSeriesFormat = const Value.absent(),
    this.billOfSupplySeriesFormat = const Value.absent(),
    this.defaultInvoiceTemplateId = const Value.absent(),
    this.defaultQuoteTemplateId = const Value.absent(),
    this.brandColor = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : name = Value(name),
       gstin = Value(gstin),
       address = Value(address),
       city = Value(city),
       stateCode = Value(stateCode),
       createdAt = Value(createdAt);
  static Insertable<Business> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? gstin,
    Expression<String>? pan,
    Expression<int>? businessType,
    Expression<String>? address,
    Expression<String>? city,
    Expression<int>? stateCode,
    Expression<String>? pincode,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? logoPath,
    Expression<String>? bankName,
    Expression<String>? bankAccount,
    Expression<String>? bankIfsc,
    Expression<String>? upiId,
    Expression<String>? currencyCode,
    Expression<String>? invoiceTemplate,
    Expression<String>? quoteTemplate,
    Expression<String>? invoiceSeriesFormat,
    Expression<String>? quoteSeriesFormat,
    Expression<String>? creditNoteSeriesFormat,
    Expression<String>? debitNoteSeriesFormat,
    Expression<String>? billOfSupplySeriesFormat,
    Expression<int>? defaultInvoiceTemplateId,
    Expression<int>? defaultQuoteTemplateId,
    Expression<int>? brandColor,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (businessType != null) 'business_type': businessType,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (stateCode != null) 'state_code': stateCode,
      if (pincode != null) 'pincode': pincode,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (logoPath != null) 'logo_path': logoPath,
      if (bankName != null) 'bank_name': bankName,
      if (bankAccount != null) 'bank_account': bankAccount,
      if (bankIfsc != null) 'bank_ifsc': bankIfsc,
      if (upiId != null) 'upi_id': upiId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (invoiceTemplate != null) 'invoice_template': invoiceTemplate,
      if (quoteTemplate != null) 'quote_template': quoteTemplate,
      if (invoiceSeriesFormat != null)
        'invoice_series_format': invoiceSeriesFormat,
      if (quoteSeriesFormat != null) 'quote_series_format': quoteSeriesFormat,
      if (creditNoteSeriesFormat != null)
        'credit_note_series_format': creditNoteSeriesFormat,
      if (debitNoteSeriesFormat != null)
        'debit_note_series_format': debitNoteSeriesFormat,
      if (billOfSupplySeriesFormat != null)
        'bill_of_supply_series_format': billOfSupplySeriesFormat,
      if (defaultInvoiceTemplateId != null)
        'default_invoice_template_id': defaultInvoiceTemplateId,
      if (defaultQuoteTemplateId != null)
        'default_quote_template_id': defaultQuoteTemplateId,
      if (brandColor != null) 'brand_color': brandColor,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BusinessesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? gstin,
    Value<String?>? pan,
    Value<BusinessType>? businessType,
    Value<String>? address,
    Value<String>? city,
    Value<int>? stateCode,
    Value<String?>? pincode,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? logoPath,
    Value<String?>? bankName,
    Value<String?>? bankAccount,
    Value<String?>? bankIfsc,
    Value<String?>? upiId,
    Value<String>? currencyCode,
    Value<String>? invoiceTemplate,
    Value<String>? quoteTemplate,
    Value<String>? invoiceSeriesFormat,
    Value<String>? quoteSeriesFormat,
    Value<String>? creditNoteSeriesFormat,
    Value<String>? debitNoteSeriesFormat,
    Value<String>? billOfSupplySeriesFormat,
    Value<int?>? defaultInvoiceTemplateId,
    Value<int?>? defaultQuoteTemplateId,
    Value<int?>? brandColor,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return BusinessesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      businessType: businessType ?? this.businessType,
      address: address ?? this.address,
      city: city ?? this.city,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      bankName: bankName ?? this.bankName,
      bankAccount: bankAccount ?? this.bankAccount,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      upiId: upiId ?? this.upiId,
      currencyCode: currencyCode ?? this.currencyCode,
      invoiceTemplate: invoiceTemplate ?? this.invoiceTemplate,
      quoteTemplate: quoteTemplate ?? this.quoteTemplate,
      invoiceSeriesFormat: invoiceSeriesFormat ?? this.invoiceSeriesFormat,
      quoteSeriesFormat: quoteSeriesFormat ?? this.quoteSeriesFormat,
      creditNoteSeriesFormat:
          creditNoteSeriesFormat ?? this.creditNoteSeriesFormat,
      debitNoteSeriesFormat:
          debitNoteSeriesFormat ?? this.debitNoteSeriesFormat,
      billOfSupplySeriesFormat:
          billOfSupplySeriesFormat ?? this.billOfSupplySeriesFormat,
      defaultInvoiceTemplateId:
          defaultInvoiceTemplateId ?? this.defaultInvoiceTemplateId,
      defaultQuoteTemplateId:
          defaultQuoteTemplateId ?? this.defaultQuoteTemplateId,
      brandColor: brandColor ?? this.brandColor,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (businessType.present) {
      map['business_type'] = Variable<int>(
        $BusinessesTable.$converterbusinessType.toSql(businessType.value),
      );
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<int>(stateCode.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (bankAccount.present) {
      map['bank_account'] = Variable<String>(bankAccount.value);
    }
    if (bankIfsc.present) {
      map['bank_ifsc'] = Variable<String>(bankIfsc.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (invoiceTemplate.present) {
      map['invoice_template'] = Variable<String>(invoiceTemplate.value);
    }
    if (quoteTemplate.present) {
      map['quote_template'] = Variable<String>(quoteTemplate.value);
    }
    if (invoiceSeriesFormat.present) {
      map['invoice_series_format'] = Variable<String>(
        invoiceSeriesFormat.value,
      );
    }
    if (quoteSeriesFormat.present) {
      map['quote_series_format'] = Variable<String>(quoteSeriesFormat.value);
    }
    if (creditNoteSeriesFormat.present) {
      map['credit_note_series_format'] = Variable<String>(
        creditNoteSeriesFormat.value,
      );
    }
    if (debitNoteSeriesFormat.present) {
      map['debit_note_series_format'] = Variable<String>(
        debitNoteSeriesFormat.value,
      );
    }
    if (billOfSupplySeriesFormat.present) {
      map['bill_of_supply_series_format'] = Variable<String>(
        billOfSupplySeriesFormat.value,
      );
    }
    if (defaultInvoiceTemplateId.present) {
      map['default_invoice_template_id'] = Variable<int>(
        defaultInvoiceTemplateId.value,
      );
    }
    if (defaultQuoteTemplateId.present) {
      map['default_quote_template_id'] = Variable<int>(
        defaultQuoteTemplateId.value,
      );
    }
    if (brandColor.present) {
      map['brand_color'] = Variable<int>(brandColor.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BusinessesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('businessType: $businessType, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('bankName: $bankName, ')
          ..write('bankAccount: $bankAccount, ')
          ..write('bankIfsc: $bankIfsc, ')
          ..write('upiId: $upiId, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceTemplate: $invoiceTemplate, ')
          ..write('quoteTemplate: $quoteTemplate, ')
          ..write('invoiceSeriesFormat: $invoiceSeriesFormat, ')
          ..write('quoteSeriesFormat: $quoteSeriesFormat, ')
          ..write('creditNoteSeriesFormat: $creditNoteSeriesFormat, ')
          ..write('debitNoteSeriesFormat: $debitNoteSeriesFormat, ')
          ..write('billOfSupplySeriesFormat: $billOfSupplySeriesFormat, ')
          ..write('defaultInvoiceTemplateId: $defaultInvoiceTemplateId, ')
          ..write('defaultQuoteTemplateId: $defaultQuoteTemplateId, ')
          ..write('brandColor: $brandColor, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstinMeta = const VerificationMeta('gstin');
  @override
  late final GeneratedColumn<String> gstin = GeneratedColumn<String>(
    'gstin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _panMeta = const VerificationMeta('pan');
  @override
  late final GeneratedColumn<String> pan = GeneratedColumn<String>(
    'pan',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cityMeta = const VerificationMeta('city');
  @override
  late final GeneratedColumn<String> city = GeneratedColumn<String>(
    'city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stateCodeMeta = const VerificationMeta(
    'stateCode',
  );
  @override
  late final GeneratedColumn<int> stateCode = GeneratedColumn<int>(
    'state_code',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pincodeMeta = const VerificationMeta(
    'pincode',
  );
  @override
  late final GeneratedColumn<String> pincode = GeneratedColumn<String>(
    'pincode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    gstin,
    pan,
    address,
    city,
    stateCode,
    pincode,
    phone,
    email,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('gstin')) {
      context.handle(
        _gstinMeta,
        gstin.isAcceptableOrUnknown(data['gstin']!, _gstinMeta),
      );
    }
    if (data.containsKey('pan')) {
      context.handle(
        _panMeta,
        pan.isAcceptableOrUnknown(data['pan']!, _panMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('city')) {
      context.handle(
        _cityMeta,
        city.isAcceptableOrUnknown(data['city']!, _cityMeta),
      );
    }
    if (data.containsKey('state_code')) {
      context.handle(
        _stateCodeMeta,
        stateCode.isAcceptableOrUnknown(data['state_code']!, _stateCodeMeta),
      );
    }
    if (data.containsKey('pincode')) {
      context.handle(
        _pincodeMeta,
        pincode.isAcceptableOrUnknown(data['pincode']!, _pincodeMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      gstin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gstin'],
      ),
      pan: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pan'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      city: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}city'],
      ),
      stateCode: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}state_code'],
      ),
      pincode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}pincode'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final int businessId;
  final String name;
  final String? gstin;
  final String? pan;
  final String? address;
  final String? city;
  final int? stateCode;
  final String? pincode;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.businessId,
    required this.name,
    this.gstin,
    this.pan,
    this.address,
    this.city,
    this.stateCode,
    this.pincode,
    this.phone,
    this.email,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || gstin != null) {
      map['gstin'] = Variable<String>(gstin);
    }
    if (!nullToAbsent || pan != null) {
      map['pan'] = Variable<String>(pan);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || city != null) {
      map['city'] = Variable<String>(city);
    }
    if (!nullToAbsent || stateCode != null) {
      map['state_code'] = Variable<int>(stateCode);
    }
    if (!nullToAbsent || pincode != null) {
      map['pincode'] = Variable<String>(pincode);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      gstin: gstin == null && nullToAbsent
          ? const Value.absent()
          : Value(gstin),
      pan: pan == null && nullToAbsent ? const Value.absent() : Value(pan),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      city: city == null && nullToAbsent ? const Value.absent() : Value(city),
      stateCode: stateCode == null && nullToAbsent
          ? const Value.absent()
          : Value(stateCode),
      pincode: pincode == null && nullToAbsent
          ? const Value.absent()
          : Value(pincode),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      gstin: serializer.fromJson<String?>(json['gstin']),
      pan: serializer.fromJson<String?>(json['pan']),
      address: serializer.fromJson<String?>(json['address']),
      city: serializer.fromJson<String?>(json['city']),
      stateCode: serializer.fromJson<int?>(json['stateCode']),
      pincode: serializer.fromJson<String?>(json['pincode']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'name': serializer.toJson<String>(name),
      'gstin': serializer.toJson<String?>(gstin),
      'pan': serializer.toJson<String?>(pan),
      'address': serializer.toJson<String?>(address),
      'city': serializer.toJson<String?>(city),
      'stateCode': serializer.toJson<int?>(stateCode),
      'pincode': serializer.toJson<String?>(pincode),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    int? id,
    int? businessId,
    String? name,
    Value<String?> gstin = const Value.absent(),
    Value<String?> pan = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> city = const Value.absent(),
    Value<int?> stateCode = const Value.absent(),
    Value<String?> pincode = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    gstin: gstin.present ? gstin.value : this.gstin,
    pan: pan.present ? pan.value : this.pan,
    address: address.present ? address.value : this.address,
    city: city.present ? city.value : this.city,
    stateCode: stateCode.present ? stateCode.value : this.stateCode,
    pincode: pincode.present ? pincode.value : this.pincode,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      gstin: data.gstin.present ? data.gstin.value : this.gstin,
      pan: data.pan.present ? data.pan.value : this.pan,
      address: data.address.present ? data.address.value : this.address,
      city: data.city.present ? data.city.value : this.city,
      stateCode: data.stateCode.present ? data.stateCode.value : this.stateCode,
      pincode: data.pincode.present ? data.pincode.value : this.pincode,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    gstin,
    pan,
    address,
    city,
    stateCode,
    pincode,
    phone,
    email,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.gstin == this.gstin &&
          other.pan == this.pan &&
          other.address == this.address &&
          other.city == this.city &&
          other.stateCode == this.stateCode &&
          other.pincode == this.pincode &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<String> name;
  final Value<String?> gstin;
  final Value<String?> pan;
  final Value<String?> address;
  final Value<String?> city;
  final Value<int?> stateCode;
  final Value<String?> pincode;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.pincode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required String name,
    this.gstin = const Value.absent(),
    this.pan = const Value.absent(),
    this.address = const Value.absent(),
    this.city = const Value.absent(),
    this.stateCode = const Value.absent(),
    this.pincode = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : businessId = Value(businessId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<String>? name,
    Expression<String>? gstin,
    Expression<String>? pan,
    Expression<String>? address,
    Expression<String>? city,
    Expression<int>? stateCode,
    Expression<String>? pincode,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (gstin != null) 'gstin': gstin,
      if (pan != null) 'pan': pan,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (stateCode != null) 'state_code': stateCode,
      if (pincode != null) 'pincode': pincode,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<String>? name,
    Value<String?>? gstin,
    Value<String?>? pan,
    Value<String?>? address,
    Value<String?>? city,
    Value<int?>? stateCode,
    Value<String?>? pincode,
    Value<String?>? phone,
    Value<String?>? email,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      gstin: gstin ?? this.gstin,
      pan: pan ?? this.pan,
      address: address ?? this.address,
      city: city ?? this.city,
      stateCode: stateCode ?? this.stateCode,
      pincode: pincode ?? this.pincode,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (gstin.present) {
      map['gstin'] = Variable<String>(gstin.value);
    }
    if (pan.present) {
      map['pan'] = Variable<String>(pan.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (city.present) {
      map['city'] = Variable<String>(city.value);
    }
    if (stateCode.present) {
      map['state_code'] = Variable<int>(stateCode.value);
    }
    if (pincode.present) {
      map['pincode'] = Variable<String>(pincode.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('gstin: $gstin, ')
          ..write('pan: $pan, ')
          ..write('address: $address, ')
          ..write('city: $city, ')
          ..write('stateCode: $stateCode, ')
          ..write('pincode: $pincode, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hsnSacMeta = const VerificationMeta('hsnSac');
  @override
  late final GeneratedColumn<String> hsnSac = GeneratedColumn<String>(
    'hsn_sac',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _salePriceMeta = const VerificationMeta(
    'salePrice',
  );
  @override
  late final GeneratedColumn<double> salePrice = GeneratedColumn<double>(
    'sale_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchasePriceMeta = const VerificationMeta(
    'purchasePrice',
  );
  @override
  late final GeneratedColumn<double> purchasePrice = GeneratedColumn<double>(
    'purchase_price',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gstRateMeta = const VerificationMeta(
    'gstRate',
  );
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
    'gst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cessRateMeta = const VerificationMeta(
    'cessRate',
  );
  @override
  late final GeneratedColumn<double> cessRate = GeneratedColumn<double>(
    'cess_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _stockQuantityMeta = const VerificationMeta(
    'stockQuantity',
  );
  @override
  late final GeneratedColumn<double> stockQuantity = GeneratedColumn<double>(
    'stock_quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _reorderLevelMeta = const VerificationMeta(
    'reorderLevel',
  );
  @override
  late final GeneratedColumn<double> reorderLevel = GeneratedColumn<double>(
    'reorder_level',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _isServiceMeta = const VerificationMeta(
    'isService',
  );
  @override
  late final GeneratedColumn<bool> isService = GeneratedColumn<bool>(
    'is_service',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_service" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    name,
    description,
    hsnSac,
    unit,
    salePrice,
    purchasePrice,
    gstRate,
    cessRate,
    stockQuantity,
    reorderLevel,
    isService,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(
    Insertable<Product> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('hsn_sac')) {
      context.handle(
        _hsnSacMeta,
        hsnSac.isAcceptableOrUnknown(data['hsn_sac']!, _hsnSacMeta),
      );
    } else if (isInserting) {
      context.missing(_hsnSacMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('sale_price')) {
      context.handle(
        _salePriceMeta,
        salePrice.isAcceptableOrUnknown(data['sale_price']!, _salePriceMeta),
      );
    } else if (isInserting) {
      context.missing(_salePriceMeta);
    }
    if (data.containsKey('purchase_price')) {
      context.handle(
        _purchasePriceMeta,
        purchasePrice.isAcceptableOrUnknown(
          data['purchase_price']!,
          _purchasePriceMeta,
        ),
      );
    }
    if (data.containsKey('gst_rate')) {
      context.handle(
        _gstRateMeta,
        gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta),
      );
    } else if (isInserting) {
      context.missing(_gstRateMeta);
    }
    if (data.containsKey('cess_rate')) {
      context.handle(
        _cessRateMeta,
        cessRate.isAcceptableOrUnknown(data['cess_rate']!, _cessRateMeta),
      );
    }
    if (data.containsKey('stock_quantity')) {
      context.handle(
        _stockQuantityMeta,
        stockQuantity.isAcceptableOrUnknown(
          data['stock_quantity']!,
          _stockQuantityMeta,
        ),
      );
    }
    if (data.containsKey('reorder_level')) {
      context.handle(
        _reorderLevelMeta,
        reorderLevel.isAcceptableOrUnknown(
          data['reorder_level']!,
          _reorderLevelMeta,
        ),
      );
    }
    if (data.containsKey('is_service')) {
      context.handle(
        _isServiceMeta,
        isService.isAcceptableOrUnknown(data['is_service']!, _isServiceMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      hsnSac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_sac'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      salePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sale_price'],
      )!,
      purchasePrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}purchase_price'],
      ),
      gstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate'],
      )!,
      cessRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_rate'],
      )!,
      stockQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}stock_quantity'],
      )!,
      reorderLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reorder_level'],
      )!,
      isService: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_service'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final int businessId;
  final String name;
  final String? description;
  final String hsnSac;
  final String unit;
  final double salePrice;
  final double? purchasePrice;
  final double gstRate;
  final double cessRate;
  final double stockQuantity;

  /// Stock level at or below which the product counts as low stock. Zero means
  /// "no threshold configured" and falls back to out-of-stock detection.
  final double reorderLevel;
  final bool isService;
  final bool isActive;
  final DateTime createdAt;
  const Product({
    required this.id,
    required this.businessId,
    required this.name,
    this.description,
    required this.hsnSac,
    required this.unit,
    required this.salePrice,
    this.purchasePrice,
    required this.gstRate,
    required this.cessRate,
    required this.stockQuantity,
    required this.reorderLevel,
    required this.isService,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['hsn_sac'] = Variable<String>(hsnSac);
    map['unit'] = Variable<String>(unit);
    map['sale_price'] = Variable<double>(salePrice);
    if (!nullToAbsent || purchasePrice != null) {
      map['purchase_price'] = Variable<double>(purchasePrice);
    }
    map['gst_rate'] = Variable<double>(gstRate);
    map['cess_rate'] = Variable<double>(cessRate);
    map['stock_quantity'] = Variable<double>(stockQuantity);
    map['reorder_level'] = Variable<double>(reorderLevel);
    map['is_service'] = Variable<bool>(isService);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      hsnSac: Value(hsnSac),
      unit: Value(unit),
      salePrice: Value(salePrice),
      purchasePrice: purchasePrice == null && nullToAbsent
          ? const Value.absent()
          : Value(purchasePrice),
      gstRate: Value(gstRate),
      cessRate: Value(cessRate),
      stockQuantity: Value(stockQuantity),
      reorderLevel: Value(reorderLevel),
      isService: Value(isService),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Product.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      hsnSac: serializer.fromJson<String>(json['hsnSac']),
      unit: serializer.fromJson<String>(json['unit']),
      salePrice: serializer.fromJson<double>(json['salePrice']),
      purchasePrice: serializer.fromJson<double?>(json['purchasePrice']),
      gstRate: serializer.fromJson<double>(json['gstRate']),
      cessRate: serializer.fromJson<double>(json['cessRate']),
      stockQuantity: serializer.fromJson<double>(json['stockQuantity']),
      reorderLevel: serializer.fromJson<double>(json['reorderLevel']),
      isService: serializer.fromJson<bool>(json['isService']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'hsnSac': serializer.toJson<String>(hsnSac),
      'unit': serializer.toJson<String>(unit),
      'salePrice': serializer.toJson<double>(salePrice),
      'purchasePrice': serializer.toJson<double?>(purchasePrice),
      'gstRate': serializer.toJson<double>(gstRate),
      'cessRate': serializer.toJson<double>(cessRate),
      'stockQuantity': serializer.toJson<double>(stockQuantity),
      'reorderLevel': serializer.toJson<double>(reorderLevel),
      'isService': serializer.toJson<bool>(isService),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Product copyWith({
    int? id,
    int? businessId,
    String? name,
    Value<String?> description = const Value.absent(),
    String? hsnSac,
    String? unit,
    double? salePrice,
    Value<double?> purchasePrice = const Value.absent(),
    double? gstRate,
    double? cessRate,
    double? stockQuantity,
    double? reorderLevel,
    bool? isService,
    bool? isActive,
    DateTime? createdAt,
  }) => Product(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    hsnSac: hsnSac ?? this.hsnSac,
    unit: unit ?? this.unit,
    salePrice: salePrice ?? this.salePrice,
    purchasePrice: purchasePrice.present
        ? purchasePrice.value
        : this.purchasePrice,
    gstRate: gstRate ?? this.gstRate,
    cessRate: cessRate ?? this.cessRate,
    stockQuantity: stockQuantity ?? this.stockQuantity,
    reorderLevel: reorderLevel ?? this.reorderLevel,
    isService: isService ?? this.isService,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      hsnSac: data.hsnSac.present ? data.hsnSac.value : this.hsnSac,
      unit: data.unit.present ? data.unit.value : this.unit,
      salePrice: data.salePrice.present ? data.salePrice.value : this.salePrice,
      purchasePrice: data.purchasePrice.present
          ? data.purchasePrice.value
          : this.purchasePrice,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      cessRate: data.cessRate.present ? data.cessRate.value : this.cessRate,
      stockQuantity: data.stockQuantity.present
          ? data.stockQuantity.value
          : this.stockQuantity,
      reorderLevel: data.reorderLevel.present
          ? data.reorderLevel.value
          : this.reorderLevel,
      isService: data.isService.present ? data.isService.value : this.isService,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('gstRate: $gstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('isService: $isService, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    name,
    description,
    hsnSac,
    unit,
    salePrice,
    purchasePrice,
    gstRate,
    cessRate,
    stockQuantity,
    reorderLevel,
    isService,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.name == this.name &&
          other.description == this.description &&
          other.hsnSac == this.hsnSac &&
          other.unit == this.unit &&
          other.salePrice == this.salePrice &&
          other.purchasePrice == this.purchasePrice &&
          other.gstRate == this.gstRate &&
          other.cessRate == this.cessRate &&
          other.stockQuantity == this.stockQuantity &&
          other.reorderLevel == this.reorderLevel &&
          other.isService == this.isService &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> hsnSac;
  final Value<String> unit;
  final Value<double> salePrice;
  final Value<double?> purchasePrice;
  final Value<double> gstRate;
  final Value<double> cessRate;
  final Value<double> stockQuantity;
  final Value<double> reorderLevel;
  final Value<bool> isService;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.hsnSac = const Value.absent(),
    this.unit = const Value.absent(),
    this.salePrice = const Value.absent(),
    this.purchasePrice = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.cessRate = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.isService = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required String name,
    this.description = const Value.absent(),
    required String hsnSac,
    required String unit,
    required double salePrice,
    this.purchasePrice = const Value.absent(),
    required double gstRate,
    this.cessRate = const Value.absent(),
    this.stockQuantity = const Value.absent(),
    this.reorderLevel = const Value.absent(),
    this.isService = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : businessId = Value(businessId),
       name = Value(name),
       hsnSac = Value(hsnSac),
       unit = Value(unit),
       salePrice = Value(salePrice),
       gstRate = Value(gstRate),
       createdAt = Value(createdAt);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? hsnSac,
    Expression<String>? unit,
    Expression<double>? salePrice,
    Expression<double>? purchasePrice,
    Expression<double>? gstRate,
    Expression<double>? cessRate,
    Expression<double>? stockQuantity,
    Expression<double>? reorderLevel,
    Expression<bool>? isService,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (hsnSac != null) 'hsn_sac': hsnSac,
      if (unit != null) 'unit': unit,
      if (salePrice != null) 'sale_price': salePrice,
      if (purchasePrice != null) 'purchase_price': purchasePrice,
      if (gstRate != null) 'gst_rate': gstRate,
      if (cessRate != null) 'cess_rate': cessRate,
      if (stockQuantity != null) 'stock_quantity': stockQuantity,
      if (reorderLevel != null) 'reorder_level': reorderLevel,
      if (isService != null) 'is_service': isService,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ProductsCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? hsnSac,
    Value<String>? unit,
    Value<double>? salePrice,
    Value<double?>? purchasePrice,
    Value<double>? gstRate,
    Value<double>? cessRate,
    Value<double>? stockQuantity,
    Value<double>? reorderLevel,
    Value<bool>? isService,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return ProductsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      name: name ?? this.name,
      description: description ?? this.description,
      hsnSac: hsnSac ?? this.hsnSac,
      unit: unit ?? this.unit,
      salePrice: salePrice ?? this.salePrice,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      gstRate: gstRate ?? this.gstRate,
      cessRate: cessRate ?? this.cessRate,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      reorderLevel: reorderLevel ?? this.reorderLevel,
      isService: isService ?? this.isService,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (hsnSac.present) {
      map['hsn_sac'] = Variable<String>(hsnSac.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (salePrice.present) {
      map['sale_price'] = Variable<double>(salePrice.value);
    }
    if (purchasePrice.present) {
      map['purchase_price'] = Variable<double>(purchasePrice.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (cessRate.present) {
      map['cess_rate'] = Variable<double>(cessRate.value);
    }
    if (stockQuantity.present) {
      map['stock_quantity'] = Variable<double>(stockQuantity.value);
    }
    if (reorderLevel.present) {
      map['reorder_level'] = Variable<double>(reorderLevel.value);
    }
    if (isService.present) {
      map['is_service'] = Variable<bool>(isService.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('salePrice: $salePrice, ')
          ..write('purchasePrice: $purchasePrice, ')
          ..write('gstRate: $gstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('stockQuantity: $stockQuantity, ')
          ..write('reorderLevel: $reorderLevel, ')
          ..write('isService: $isService, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InvoicesTable extends Invoices with TableInfo<$InvoicesTable, Invoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceTypeMeta = const VerificationMeta(
    'invoiceType',
  );
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
    'invoice_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplyTypeMeta = const VerificationMeta(
    'supplyType',
  );
  @override
  late final GeneratedColumn<String> supplyType = GeneratedColumn<String>(
    'supply_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeOfSupplyMeta = const VerificationMeta(
    'placeOfSupply',
  );
  @override
  late final GeneratedColumn<int> placeOfSupply = GeneratedColumn<int>(
    'place_of_supply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxableAmountMeta = const VerificationMeta(
    'taxableAmount',
  );
  @override
  late final GeneratedColumn<double> taxableAmount = GeneratedColumn<double>(
    'taxable_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cgstAmountMeta = const VerificationMeta(
    'cgstAmount',
  );
  @override
  late final GeneratedColumn<double> cgstAmount = GeneratedColumn<double>(
    'cgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstAmountMeta = const VerificationMeta(
    'sgstAmount',
  );
  @override
  late final GeneratedColumn<double> sgstAmount = GeneratedColumn<double>(
    'sgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstAmountMeta = const VerificationMeta(
    'igstAmount',
  );
  @override
  late final GeneratedColumn<double> igstAmount = GeneratedColumn<double>(
    'igst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessAmountMeta = const VerificationMeta(
    'cessAmount',
  );
  @override
  late final GeneratedColumn<double> cessAmount = GeneratedColumn<double>(
    'cess_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundOffAmountMeta = const VerificationMeta(
    'roundOffAmount',
  );
  @override
  late final GeneratedColumn<double> roundOffAmount = GeneratedColumn<double>(
    'round_off_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountInWordsMeta = const VerificationMeta(
    'amountInWords',
  );
  @override
  late final GeneratedColumn<String> amountInWords = GeneratedColumn<String>(
    'amount_in_words',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termsMeta = const VerificationMeta('terms');
  @override
  late final GeneratedColumn<String> terms = GeneratedColumn<String>(
    'terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DRAFT'),
  );
  static const VerificationMeta _isIgstMeta = const VerificationMeta('isIgst');
  @override
  late final GeneratedColumn<bool> isIgst = GeneratedColumn<bool>(
    'is_igst',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_igst" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceInvoiceIdMeta =
      const VerificationMeta('referenceInvoiceId');
  @override
  late final GeneratedColumn<int> referenceInvoiceId = GeneratedColumn<int>(
    'reference_invoice_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reverseChargeMeta = const VerificationMeta(
    'reverseCharge',
  );
  @override
  late final GeneratedColumn<bool> reverseCharge = GeneratedColumn<bool>(
    'reverse_charge',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reverse_charge" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shipToNameMeta = const VerificationMeta(
    'shipToName',
  );
  @override
  late final GeneratedColumn<String> shipToName = GeneratedColumn<String>(
    'ship_to_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shipToAddressMeta = const VerificationMeta(
    'shipToAddress',
  );
  @override
  late final GeneratedColumn<String> shipToAddress = GeneratedColumn<String>(
    'ship_to_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shipToCityMeta = const VerificationMeta(
    'shipToCity',
  );
  @override
  late final GeneratedColumn<String> shipToCity = GeneratedColumn<String>(
    'ship_to_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exportWithLutMeta = const VerificationMeta(
    'exportWithLut',
  );
  @override
  late final GeneratedColumn<bool> exportWithLut = GeneratedColumn<bool>(
    'export_with_lut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("export_with_lut" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tdsSectionMeta = const VerificationMeta(
    'tdsSection',
  );
  @override
  late final GeneratedColumn<String> tdsSection = GeneratedColumn<String>(
    'tds_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tdsRateMeta = const VerificationMeta(
    'tdsRate',
  );
  @override
  late final GeneratedColumn<double> tdsRate = GeneratedColumn<double>(
    'tds_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tdsAmountMeta = const VerificationMeta(
    'tdsAmount',
  );
  @override
  late final GeneratedColumn<double> tdsAmount = GeneratedColumn<double>(
    'tds_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tcsSectionMeta = const VerificationMeta(
    'tcsSection',
  );
  @override
  late final GeneratedColumn<String> tcsSection = GeneratedColumn<String>(
    'tcs_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tcsRateMeta = const VerificationMeta(
    'tcsRate',
  );
  @override
  late final GeneratedColumn<double> tcsRate = GeneratedColumn<double>(
    'tcs_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tcsAmountMeta = const VerificationMeta(
    'tcsAmount',
  );
  @override
  late final GeneratedColumn<double> tcsAmount = GeneratedColumn<double>(
    'tcs_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    customerId,
    invoiceNumber,
    currencyCode,
    invoiceDate,
    dueDate,
    invoiceType,
    supplyType,
    placeOfSupply,
    subtotal,
    discountAmount,
    taxableAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    roundOffAmount,
    amountPaid,
    amountInWords,
    notes,
    terms,
    status,
    isIgst,
    templateId,
    referenceInvoiceId,
    reverseCharge,
    shipToName,
    shipToAddress,
    shipToCity,
    exportWithLut,
    tdsSection,
    tdsRate,
    tdsAmount,
    tcsSection,
    tcsRate,
    tcsAmount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Invoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
        _invoiceTypeMeta,
        invoiceType.isAcceptableOrUnknown(
          data['invoice_type']!,
          _invoiceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceTypeMeta);
    }
    if (data.containsKey('supply_type')) {
      context.handle(
        _supplyTypeMeta,
        supplyType.isAcceptableOrUnknown(data['supply_type']!, _supplyTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_supplyTypeMeta);
    }
    if (data.containsKey('place_of_supply')) {
      context.handle(
        _placeOfSupplyMeta,
        placeOfSupply.isAcceptableOrUnknown(
          data['place_of_supply']!,
          _placeOfSupplyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeOfSupplyMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('taxable_amount')) {
      context.handle(
        _taxableAmountMeta,
        taxableAmount.isAcceptableOrUnknown(
          data['taxable_amount']!,
          _taxableAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxableAmountMeta);
    }
    if (data.containsKey('cgst_amount')) {
      context.handle(
        _cgstAmountMeta,
        cgstAmount.isAcceptableOrUnknown(data['cgst_amount']!, _cgstAmountMeta),
      );
    }
    if (data.containsKey('sgst_amount')) {
      context.handle(
        _sgstAmountMeta,
        sgstAmount.isAcceptableOrUnknown(data['sgst_amount']!, _sgstAmountMeta),
      );
    }
    if (data.containsKey('igst_amount')) {
      context.handle(
        _igstAmountMeta,
        igstAmount.isAcceptableOrUnknown(data['igst_amount']!, _igstAmountMeta),
      );
    }
    if (data.containsKey('cess_amount')) {
      context.handle(
        _cessAmountMeta,
        cessAmount.isAcceptableOrUnknown(data['cess_amount']!, _cessAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('round_off_amount')) {
      context.handle(
        _roundOffAmountMeta,
        roundOffAmount.isAcceptableOrUnknown(
          data['round_off_amount']!,
          _roundOffAmountMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('amount_in_words')) {
      context.handle(
        _amountInWordsMeta,
        amountInWords.isAcceptableOrUnknown(
          data['amount_in_words']!,
          _amountInWordsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('terms')) {
      context.handle(
        _termsMeta,
        terms.isAcceptableOrUnknown(data['terms']!, _termsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_igst')) {
      context.handle(
        _isIgstMeta,
        isIgst.isAcceptableOrUnknown(data['is_igst']!, _isIgstMeta),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('reference_invoice_id')) {
      context.handle(
        _referenceInvoiceIdMeta,
        referenceInvoiceId.isAcceptableOrUnknown(
          data['reference_invoice_id']!,
          _referenceInvoiceIdMeta,
        ),
      );
    }
    if (data.containsKey('reverse_charge')) {
      context.handle(
        _reverseChargeMeta,
        reverseCharge.isAcceptableOrUnknown(
          data['reverse_charge']!,
          _reverseChargeMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_name')) {
      context.handle(
        _shipToNameMeta,
        shipToName.isAcceptableOrUnknown(
          data['ship_to_name']!,
          _shipToNameMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_address')) {
      context.handle(
        _shipToAddressMeta,
        shipToAddress.isAcceptableOrUnknown(
          data['ship_to_address']!,
          _shipToAddressMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_city')) {
      context.handle(
        _shipToCityMeta,
        shipToCity.isAcceptableOrUnknown(
          data['ship_to_city']!,
          _shipToCityMeta,
        ),
      );
    }
    if (data.containsKey('export_with_lut')) {
      context.handle(
        _exportWithLutMeta,
        exportWithLut.isAcceptableOrUnknown(
          data['export_with_lut']!,
          _exportWithLutMeta,
        ),
      );
    }
    if (data.containsKey('tds_section')) {
      context.handle(
        _tdsSectionMeta,
        tdsSection.isAcceptableOrUnknown(data['tds_section']!, _tdsSectionMeta),
      );
    }
    if (data.containsKey('tds_rate')) {
      context.handle(
        _tdsRateMeta,
        tdsRate.isAcceptableOrUnknown(data['tds_rate']!, _tdsRateMeta),
      );
    }
    if (data.containsKey('tds_amount')) {
      context.handle(
        _tdsAmountMeta,
        tdsAmount.isAcceptableOrUnknown(data['tds_amount']!, _tdsAmountMeta),
      );
    }
    if (data.containsKey('tcs_section')) {
      context.handle(
        _tcsSectionMeta,
        tcsSection.isAcceptableOrUnknown(data['tcs_section']!, _tcsSectionMeta),
      );
    }
    if (data.containsKey('tcs_rate')) {
      context.handle(
        _tcsRateMeta,
        tcsRate.isAcceptableOrUnknown(data['tcs_rate']!, _tcsRateMeta),
      );
    }
    if (data.containsKey('tcs_amount')) {
      context.handle(
        _tcsAmountMeta,
        tcsAmount.isAcceptableOrUnknown(data['tcs_amount']!, _tcsAmountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {businessId, invoiceNumber},
  ];
  @override
  Invoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Invoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      invoiceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_type'],
      )!,
      supplyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_type'],
      )!,
      placeOfSupply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place_of_supply'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      taxableAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_amount'],
      )!,
      cgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_amount'],
      )!,
      sgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_amount'],
      )!,
      igstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_amount'],
      )!,
      cessAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      roundOffAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}round_off_amount'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      amountInWords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_in_words'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      terms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isIgst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_igst'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      ),
      referenceInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reference_invoice_id'],
      ),
      reverseCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reverse_charge'],
      )!,
      shipToName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_name'],
      ),
      shipToAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_address'],
      ),
      shipToCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_city'],
      ),
      exportWithLut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}export_with_lut'],
      )!,
      tdsSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tds_section'],
      ),
      tdsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_rate'],
      )!,
      tdsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_amount'],
      )!,
      tcsSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tcs_section'],
      ),
      tcsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tcs_rate'],
      )!,
      tcsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tcs_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $InvoicesTable createAlias(String alias) {
    return $InvoicesTable(attachedDatabase, alias);
  }
}

class Invoice extends DataClass implements Insertable<Invoice> {
  final int id;
  final int businessId;
  final int customerId;
  final String invoiceNumber;
  final String currencyCode;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final String invoiceType;
  final String supplyType;
  final int placeOfSupply;
  final double subtotal;
  final double discountAmount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;

  /// Adjustment applied to the grand total to reach a whole-rupee payable
  /// amount (the classic Indian invoice "round off" line). Stored separately
  /// so the printed total is a clean figure and the difference is auditable.
  final double roundOffAmount;
  final double amountPaid;
  final String? amountInWords;
  final String? notes;
  final String? terms;
  final String status;
  final bool isIgst;
  final int? templateId;

  /// The invoice a credit/debit note adjusts. Null for plain invoices.
  final int? referenceInvoiceId;

  /// Reverse-charge supplies must be declared on the invoice.
  final bool reverseCharge;

  /// Optional ship-to (delivery) party when it differs from the customer.
  final String? shipToName;
  final String? shipToAddress;
  final String? shipToCity;

  /// Export/SEZ supplies declared under a Letter of Undertaking (no IGST).
  final bool exportWithLut;

  /// Optional TDS/TCS adjustment. TDS is deducted by the buyer; TCS is
  /// collected on the invoice value. Both are computed on the taxable amount.
  final String? tdsSection;
  final double tdsRate;
  final double tdsAmount;
  final String? tcsSection;
  final double tcsRate;
  final double tcsAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Invoice({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.invoiceNumber,
    required this.currencyCode,
    required this.invoiceDate,
    this.dueDate,
    required this.invoiceType,
    required this.supplyType,
    required this.placeOfSupply,
    required this.subtotal,
    required this.discountAmount,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
    required this.roundOffAmount,
    required this.amountPaid,
    this.amountInWords,
    this.notes,
    this.terms,
    required this.status,
    required this.isIgst,
    this.templateId,
    this.referenceInvoiceId,
    required this.reverseCharge,
    this.shipToName,
    this.shipToAddress,
    this.shipToCity,
    required this.exportWithLut,
    this.tdsSection,
    required this.tdsRate,
    required this.tdsAmount,
    this.tcsSection,
    required this.tcsRate,
    required this.tcsAmount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['customer_id'] = Variable<int>(customerId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['currency_code'] = Variable<String>(currencyCode);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['invoice_type'] = Variable<String>(invoiceType);
    map['supply_type'] = Variable<String>(supplyType);
    map['place_of_supply'] = Variable<int>(placeOfSupply);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['taxable_amount'] = Variable<double>(taxableAmount);
    map['cgst_amount'] = Variable<double>(cgstAmount);
    map['sgst_amount'] = Variable<double>(sgstAmount);
    map['igst_amount'] = Variable<double>(igstAmount);
    map['cess_amount'] = Variable<double>(cessAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['round_off_amount'] = Variable<double>(roundOffAmount);
    map['amount_paid'] = Variable<double>(amountPaid);
    if (!nullToAbsent || amountInWords != null) {
      map['amount_in_words'] = Variable<String>(amountInWords);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || terms != null) {
      map['terms'] = Variable<String>(terms);
    }
    map['status'] = Variable<String>(status);
    map['is_igst'] = Variable<bool>(isIgst);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<int>(templateId);
    }
    if (!nullToAbsent || referenceInvoiceId != null) {
      map['reference_invoice_id'] = Variable<int>(referenceInvoiceId);
    }
    map['reverse_charge'] = Variable<bool>(reverseCharge);
    if (!nullToAbsent || shipToName != null) {
      map['ship_to_name'] = Variable<String>(shipToName);
    }
    if (!nullToAbsent || shipToAddress != null) {
      map['ship_to_address'] = Variable<String>(shipToAddress);
    }
    if (!nullToAbsent || shipToCity != null) {
      map['ship_to_city'] = Variable<String>(shipToCity);
    }
    map['export_with_lut'] = Variable<bool>(exportWithLut);
    if (!nullToAbsent || tdsSection != null) {
      map['tds_section'] = Variable<String>(tdsSection);
    }
    map['tds_rate'] = Variable<double>(tdsRate);
    map['tds_amount'] = Variable<double>(tdsAmount);
    if (!nullToAbsent || tcsSection != null) {
      map['tcs_section'] = Variable<String>(tcsSection);
    }
    map['tcs_rate'] = Variable<double>(tcsRate);
    map['tcs_amount'] = Variable<double>(tcsAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  InvoicesCompanion toCompanion(bool nullToAbsent) {
    return InvoicesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      customerId: Value(customerId),
      invoiceNumber: Value(invoiceNumber),
      currencyCode: Value(currencyCode),
      invoiceDate: Value(invoiceDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      invoiceType: Value(invoiceType),
      supplyType: Value(supplyType),
      placeOfSupply: Value(placeOfSupply),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      taxableAmount: Value(taxableAmount),
      cgstAmount: Value(cgstAmount),
      sgstAmount: Value(sgstAmount),
      igstAmount: Value(igstAmount),
      cessAmount: Value(cessAmount),
      totalAmount: Value(totalAmount),
      roundOffAmount: Value(roundOffAmount),
      amountPaid: Value(amountPaid),
      amountInWords: amountInWords == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInWords),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      terms: terms == null && nullToAbsent
          ? const Value.absent()
          : Value(terms),
      status: Value(status),
      isIgst: Value(isIgst),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      referenceInvoiceId: referenceInvoiceId == null && nullToAbsent
          ? const Value.absent()
          : Value(referenceInvoiceId),
      reverseCharge: Value(reverseCharge),
      shipToName: shipToName == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToName),
      shipToAddress: shipToAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToAddress),
      shipToCity: shipToCity == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToCity),
      exportWithLut: Value(exportWithLut),
      tdsSection: tdsSection == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsSection),
      tdsRate: Value(tdsRate),
      tdsAmount: Value(tdsAmount),
      tcsSection: tcsSection == null && nullToAbsent
          ? const Value.absent()
          : Value(tcsSection),
      tcsRate: Value(tcsRate),
      tcsAmount: Value(tcsAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Invoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Invoice(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      supplyType: serializer.fromJson<String>(json['supplyType']),
      placeOfSupply: serializer.fromJson<int>(json['placeOfSupply']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxableAmount: serializer.fromJson<double>(json['taxableAmount']),
      cgstAmount: serializer.fromJson<double>(json['cgstAmount']),
      sgstAmount: serializer.fromJson<double>(json['sgstAmount']),
      igstAmount: serializer.fromJson<double>(json['igstAmount']),
      cessAmount: serializer.fromJson<double>(json['cessAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      roundOffAmount: serializer.fromJson<double>(json['roundOffAmount']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      amountInWords: serializer.fromJson<String?>(json['amountInWords']),
      notes: serializer.fromJson<String?>(json['notes']),
      terms: serializer.fromJson<String?>(json['terms']),
      status: serializer.fromJson<String>(json['status']),
      isIgst: serializer.fromJson<bool>(json['isIgst']),
      templateId: serializer.fromJson<int?>(json['templateId']),
      referenceInvoiceId: serializer.fromJson<int?>(json['referenceInvoiceId']),
      reverseCharge: serializer.fromJson<bool>(json['reverseCharge']),
      shipToName: serializer.fromJson<String?>(json['shipToName']),
      shipToAddress: serializer.fromJson<String?>(json['shipToAddress']),
      shipToCity: serializer.fromJson<String?>(json['shipToCity']),
      exportWithLut: serializer.fromJson<bool>(json['exportWithLut']),
      tdsSection: serializer.fromJson<String?>(json['tdsSection']),
      tdsRate: serializer.fromJson<double>(json['tdsRate']),
      tdsAmount: serializer.fromJson<double>(json['tdsAmount']),
      tcsSection: serializer.fromJson<String?>(json['tcsSection']),
      tcsRate: serializer.fromJson<double>(json['tcsRate']),
      tcsAmount: serializer.fromJson<double>(json['tcsAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'customerId': serializer.toJson<int>(customerId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'supplyType': serializer.toJson<String>(supplyType),
      'placeOfSupply': serializer.toJson<int>(placeOfSupply),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxableAmount': serializer.toJson<double>(taxableAmount),
      'cgstAmount': serializer.toJson<double>(cgstAmount),
      'sgstAmount': serializer.toJson<double>(sgstAmount),
      'igstAmount': serializer.toJson<double>(igstAmount),
      'cessAmount': serializer.toJson<double>(cessAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'roundOffAmount': serializer.toJson<double>(roundOffAmount),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'amountInWords': serializer.toJson<String?>(amountInWords),
      'notes': serializer.toJson<String?>(notes),
      'terms': serializer.toJson<String?>(terms),
      'status': serializer.toJson<String>(status),
      'isIgst': serializer.toJson<bool>(isIgst),
      'templateId': serializer.toJson<int?>(templateId),
      'referenceInvoiceId': serializer.toJson<int?>(referenceInvoiceId),
      'reverseCharge': serializer.toJson<bool>(reverseCharge),
      'shipToName': serializer.toJson<String?>(shipToName),
      'shipToAddress': serializer.toJson<String?>(shipToAddress),
      'shipToCity': serializer.toJson<String?>(shipToCity),
      'exportWithLut': serializer.toJson<bool>(exportWithLut),
      'tdsSection': serializer.toJson<String?>(tdsSection),
      'tdsRate': serializer.toJson<double>(tdsRate),
      'tdsAmount': serializer.toJson<double>(tdsAmount),
      'tcsSection': serializer.toJson<String?>(tcsSection),
      'tcsRate': serializer.toJson<double>(tcsRate),
      'tcsAmount': serializer.toJson<double>(tcsAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Invoice copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? invoiceNumber,
    String? currencyCode,
    DateTime? invoiceDate,
    Value<DateTime?> dueDate = const Value.absent(),
    String? invoiceType,
    String? supplyType,
    int? placeOfSupply,
    double? subtotal,
    double? discountAmount,
    double? taxableAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
    double? totalAmount,
    double? roundOffAmount,
    double? amountPaid,
    Value<String?> amountInWords = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> terms = const Value.absent(),
    String? status,
    bool? isIgst,
    Value<int?> templateId = const Value.absent(),
    Value<int?> referenceInvoiceId = const Value.absent(),
    bool? reverseCharge,
    Value<String?> shipToName = const Value.absent(),
    Value<String?> shipToAddress = const Value.absent(),
    Value<String?> shipToCity = const Value.absent(),
    bool? exportWithLut,
    Value<String?> tdsSection = const Value.absent(),
    double? tdsRate,
    double? tdsAmount,
    Value<String?> tcsSection = const Value.absent(),
    double? tcsRate,
    double? tcsAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Invoice(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    customerId: customerId ?? this.customerId,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    currencyCode: currencyCode ?? this.currencyCode,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    invoiceType: invoiceType ?? this.invoiceType,
    supplyType: supplyType ?? this.supplyType,
    placeOfSupply: placeOfSupply ?? this.placeOfSupply,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    taxableAmount: taxableAmount ?? this.taxableAmount,
    cgstAmount: cgstAmount ?? this.cgstAmount,
    sgstAmount: sgstAmount ?? this.sgstAmount,
    igstAmount: igstAmount ?? this.igstAmount,
    cessAmount: cessAmount ?? this.cessAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    roundOffAmount: roundOffAmount ?? this.roundOffAmount,
    amountPaid: amountPaid ?? this.amountPaid,
    amountInWords: amountInWords.present
        ? amountInWords.value
        : this.amountInWords,
    notes: notes.present ? notes.value : this.notes,
    terms: terms.present ? terms.value : this.terms,
    status: status ?? this.status,
    isIgst: isIgst ?? this.isIgst,
    templateId: templateId.present ? templateId.value : this.templateId,
    referenceInvoiceId: referenceInvoiceId.present
        ? referenceInvoiceId.value
        : this.referenceInvoiceId,
    reverseCharge: reverseCharge ?? this.reverseCharge,
    shipToName: shipToName.present ? shipToName.value : this.shipToName,
    shipToAddress: shipToAddress.present
        ? shipToAddress.value
        : this.shipToAddress,
    shipToCity: shipToCity.present ? shipToCity.value : this.shipToCity,
    exportWithLut: exportWithLut ?? this.exportWithLut,
    tdsSection: tdsSection.present ? tdsSection.value : this.tdsSection,
    tdsRate: tdsRate ?? this.tdsRate,
    tdsAmount: tdsAmount ?? this.tdsAmount,
    tcsSection: tcsSection.present ? tcsSection.value : this.tcsSection,
    tcsRate: tcsRate ?? this.tcsRate,
    tcsAmount: tcsAmount ?? this.tcsAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Invoice copyWithCompanion(InvoicesCompanion data) {
    return Invoice(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      invoiceType: data.invoiceType.present
          ? data.invoiceType.value
          : this.invoiceType,
      supplyType: data.supplyType.present
          ? data.supplyType.value
          : this.supplyType,
      placeOfSupply: data.placeOfSupply.present
          ? data.placeOfSupply.value
          : this.placeOfSupply,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxableAmount: data.taxableAmount.present
          ? data.taxableAmount.value
          : this.taxableAmount,
      cgstAmount: data.cgstAmount.present
          ? data.cgstAmount.value
          : this.cgstAmount,
      sgstAmount: data.sgstAmount.present
          ? data.sgstAmount.value
          : this.sgstAmount,
      igstAmount: data.igstAmount.present
          ? data.igstAmount.value
          : this.igstAmount,
      cessAmount: data.cessAmount.present
          ? data.cessAmount.value
          : this.cessAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      roundOffAmount: data.roundOffAmount.present
          ? data.roundOffAmount.value
          : this.roundOffAmount,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      amountInWords: data.amountInWords.present
          ? data.amountInWords.value
          : this.amountInWords,
      notes: data.notes.present ? data.notes.value : this.notes,
      terms: data.terms.present ? data.terms.value : this.terms,
      status: data.status.present ? data.status.value : this.status,
      isIgst: data.isIgst.present ? data.isIgst.value : this.isIgst,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      referenceInvoiceId: data.referenceInvoiceId.present
          ? data.referenceInvoiceId.value
          : this.referenceInvoiceId,
      reverseCharge: data.reverseCharge.present
          ? data.reverseCharge.value
          : this.reverseCharge,
      shipToName: data.shipToName.present
          ? data.shipToName.value
          : this.shipToName,
      shipToAddress: data.shipToAddress.present
          ? data.shipToAddress.value
          : this.shipToAddress,
      shipToCity: data.shipToCity.present
          ? data.shipToCity.value
          : this.shipToCity,
      exportWithLut: data.exportWithLut.present
          ? data.exportWithLut.value
          : this.exportWithLut,
      tdsSection: data.tdsSection.present
          ? data.tdsSection.value
          : this.tdsSection,
      tdsRate: data.tdsRate.present ? data.tdsRate.value : this.tdsRate,
      tdsAmount: data.tdsAmount.present ? data.tdsAmount.value : this.tdsAmount,
      tcsSection: data.tcsSection.present
          ? data.tcsSection.value
          : this.tcsSection,
      tcsRate: data.tcsRate.present ? data.tcsRate.value : this.tcsRate,
      tcsAmount: data.tcsAmount.present ? data.tcsAmount.value : this.tcsAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Invoice(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('supplyType: $supplyType, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('roundOffAmount: $roundOffAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('notes: $notes, ')
          ..write('terms: $terms, ')
          ..write('status: $status, ')
          ..write('isIgst: $isIgst, ')
          ..write('templateId: $templateId, ')
          ..write('referenceInvoiceId: $referenceInvoiceId, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('shipToName: $shipToName, ')
          ..write('shipToAddress: $shipToAddress, ')
          ..write('shipToCity: $shipToCity, ')
          ..write('exportWithLut: $exportWithLut, ')
          ..write('tdsSection: $tdsSection, ')
          ..write('tdsRate: $tdsRate, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsSection: $tcsSection, ')
          ..write('tcsRate: $tcsRate, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    businessId,
    customerId,
    invoiceNumber,
    currencyCode,
    invoiceDate,
    dueDate,
    invoiceType,
    supplyType,
    placeOfSupply,
    subtotal,
    discountAmount,
    taxableAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    roundOffAmount,
    amountPaid,
    amountInWords,
    notes,
    terms,
    status,
    isIgst,
    templateId,
    referenceInvoiceId,
    reverseCharge,
    shipToName,
    shipToAddress,
    shipToCity,
    exportWithLut,
    tdsSection,
    tdsRate,
    tdsAmount,
    tcsSection,
    tcsRate,
    tcsAmount,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Invoice &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.customerId == this.customerId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.currencyCode == this.currencyCode &&
          other.invoiceDate == this.invoiceDate &&
          other.dueDate == this.dueDate &&
          other.invoiceType == this.invoiceType &&
          other.supplyType == this.supplyType &&
          other.placeOfSupply == this.placeOfSupply &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.taxableAmount == this.taxableAmount &&
          other.cgstAmount == this.cgstAmount &&
          other.sgstAmount == this.sgstAmount &&
          other.igstAmount == this.igstAmount &&
          other.cessAmount == this.cessAmount &&
          other.totalAmount == this.totalAmount &&
          other.roundOffAmount == this.roundOffAmount &&
          other.amountPaid == this.amountPaid &&
          other.amountInWords == this.amountInWords &&
          other.notes == this.notes &&
          other.terms == this.terms &&
          other.status == this.status &&
          other.isIgst == this.isIgst &&
          other.templateId == this.templateId &&
          other.referenceInvoiceId == this.referenceInvoiceId &&
          other.reverseCharge == this.reverseCharge &&
          other.shipToName == this.shipToName &&
          other.shipToAddress == this.shipToAddress &&
          other.shipToCity == this.shipToCity &&
          other.exportWithLut == this.exportWithLut &&
          other.tdsSection == this.tdsSection &&
          other.tdsRate == this.tdsRate &&
          other.tdsAmount == this.tdsAmount &&
          other.tcsSection == this.tcsSection &&
          other.tcsRate == this.tcsRate &&
          other.tcsAmount == this.tcsAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class InvoicesCompanion extends UpdateCompanion<Invoice> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<int> customerId;
  final Value<String> invoiceNumber;
  final Value<String> currencyCode;
  final Value<DateTime> invoiceDate;
  final Value<DateTime?> dueDate;
  final Value<String> invoiceType;
  final Value<String> supplyType;
  final Value<int> placeOfSupply;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> taxableAmount;
  final Value<double> cgstAmount;
  final Value<double> sgstAmount;
  final Value<double> igstAmount;
  final Value<double> cessAmount;
  final Value<double> totalAmount;
  final Value<double> roundOffAmount;
  final Value<double> amountPaid;
  final Value<String?> amountInWords;
  final Value<String?> notes;
  final Value<String?> terms;
  final Value<String> status;
  final Value<bool> isIgst;
  final Value<int?> templateId;
  final Value<int?> referenceInvoiceId;
  final Value<bool> reverseCharge;
  final Value<String?> shipToName;
  final Value<String?> shipToAddress;
  final Value<String?> shipToCity;
  final Value<bool> exportWithLut;
  final Value<String?> tdsSection;
  final Value<double> tdsRate;
  final Value<double> tdsAmount;
  final Value<String?> tcsSection;
  final Value<double> tcsRate;
  final Value<double> tcsAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const InvoicesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.supplyType = const Value.absent(),
    this.placeOfSupply = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.roundOffAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.notes = const Value.absent(),
    this.terms = const Value.absent(),
    this.status = const Value.absent(),
    this.isIgst = const Value.absent(),
    this.templateId = const Value.absent(),
    this.referenceInvoiceId = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    this.shipToName = const Value.absent(),
    this.shipToAddress = const Value.absent(),
    this.shipToCity = const Value.absent(),
    this.exportWithLut = const Value.absent(),
    this.tdsSection = const Value.absent(),
    this.tdsRate = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsSection = const Value.absent(),
    this.tcsRate = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  InvoicesCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required int customerId,
    required String invoiceNumber,
    this.currencyCode = const Value.absent(),
    required DateTime invoiceDate,
    this.dueDate = const Value.absent(),
    required String invoiceType,
    required String supplyType,
    required int placeOfSupply,
    required double subtotal,
    this.discountAmount = const Value.absent(),
    required double taxableAmount,
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    required double totalAmount,
    this.roundOffAmount = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.notes = const Value.absent(),
    this.terms = const Value.absent(),
    this.status = const Value.absent(),
    this.isIgst = const Value.absent(),
    this.templateId = const Value.absent(),
    this.referenceInvoiceId = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    this.shipToName = const Value.absent(),
    this.shipToAddress = const Value.absent(),
    this.shipToCity = const Value.absent(),
    this.exportWithLut = const Value.absent(),
    this.tdsSection = const Value.absent(),
    this.tdsRate = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsSection = const Value.absent(),
    this.tcsRate = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : businessId = Value(businessId),
       customerId = Value(customerId),
       invoiceNumber = Value(invoiceNumber),
       invoiceDate = Value(invoiceDate),
       invoiceType = Value(invoiceType),
       supplyType = Value(supplyType),
       placeOfSupply = Value(placeOfSupply),
       subtotal = Value(subtotal),
       taxableAmount = Value(taxableAmount),
       totalAmount = Value(totalAmount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Invoice> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<int>? customerId,
    Expression<String>? invoiceNumber,
    Expression<String>? currencyCode,
    Expression<DateTime>? invoiceDate,
    Expression<DateTime>? dueDate,
    Expression<String>? invoiceType,
    Expression<String>? supplyType,
    Expression<int>? placeOfSupply,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? taxableAmount,
    Expression<double>? cgstAmount,
    Expression<double>? sgstAmount,
    Expression<double>? igstAmount,
    Expression<double>? cessAmount,
    Expression<double>? totalAmount,
    Expression<double>? roundOffAmount,
    Expression<double>? amountPaid,
    Expression<String>? amountInWords,
    Expression<String>? notes,
    Expression<String>? terms,
    Expression<String>? status,
    Expression<bool>? isIgst,
    Expression<int>? templateId,
    Expression<int>? referenceInvoiceId,
    Expression<bool>? reverseCharge,
    Expression<String>? shipToName,
    Expression<String>? shipToAddress,
    Expression<String>? shipToCity,
    Expression<bool>? exportWithLut,
    Expression<String>? tdsSection,
    Expression<double>? tdsRate,
    Expression<double>? tdsAmount,
    Expression<String>? tcsSection,
    Expression<double>? tcsRate,
    Expression<double>? tcsAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (customerId != null) 'customer_id': customerId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (dueDate != null) 'due_date': dueDate,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (supplyType != null) 'supply_type': supplyType,
      if (placeOfSupply != null) 'place_of_supply': placeOfSupply,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxableAmount != null) 'taxable_amount': taxableAmount,
      if (cgstAmount != null) 'cgst_amount': cgstAmount,
      if (sgstAmount != null) 'sgst_amount': sgstAmount,
      if (igstAmount != null) 'igst_amount': igstAmount,
      if (cessAmount != null) 'cess_amount': cessAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (roundOffAmount != null) 'round_off_amount': roundOffAmount,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (amountInWords != null) 'amount_in_words': amountInWords,
      if (notes != null) 'notes': notes,
      if (terms != null) 'terms': terms,
      if (status != null) 'status': status,
      if (isIgst != null) 'is_igst': isIgst,
      if (templateId != null) 'template_id': templateId,
      if (referenceInvoiceId != null)
        'reference_invoice_id': referenceInvoiceId,
      if (reverseCharge != null) 'reverse_charge': reverseCharge,
      if (shipToName != null) 'ship_to_name': shipToName,
      if (shipToAddress != null) 'ship_to_address': shipToAddress,
      if (shipToCity != null) 'ship_to_city': shipToCity,
      if (exportWithLut != null) 'export_with_lut': exportWithLut,
      if (tdsSection != null) 'tds_section': tdsSection,
      if (tdsRate != null) 'tds_rate': tdsRate,
      if (tdsAmount != null) 'tds_amount': tdsAmount,
      if (tcsSection != null) 'tcs_section': tcsSection,
      if (tcsRate != null) 'tcs_rate': tcsRate,
      if (tcsAmount != null) 'tcs_amount': tcsAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  InvoicesCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<int>? customerId,
    Value<String>? invoiceNumber,
    Value<String>? currencyCode,
    Value<DateTime>? invoiceDate,
    Value<DateTime?>? dueDate,
    Value<String>? invoiceType,
    Value<String>? supplyType,
    Value<int>? placeOfSupply,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<double>? taxableAmount,
    Value<double>? cgstAmount,
    Value<double>? sgstAmount,
    Value<double>? igstAmount,
    Value<double>? cessAmount,
    Value<double>? totalAmount,
    Value<double>? roundOffAmount,
    Value<double>? amountPaid,
    Value<String?>? amountInWords,
    Value<String?>? notes,
    Value<String?>? terms,
    Value<String>? status,
    Value<bool>? isIgst,
    Value<int?>? templateId,
    Value<int?>? referenceInvoiceId,
    Value<bool>? reverseCharge,
    Value<String?>? shipToName,
    Value<String?>? shipToAddress,
    Value<String?>? shipToCity,
    Value<bool>? exportWithLut,
    Value<String?>? tdsSection,
    Value<double>? tdsRate,
    Value<double>? tdsAmount,
    Value<String?>? tcsSection,
    Value<double>? tcsRate,
    Value<double>? tcsAmount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return InvoicesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      currencyCode: currencyCode ?? this.currencyCode,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceType: invoiceType ?? this.invoiceType,
      supplyType: supplyType ?? this.supplyType,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      roundOffAmount: roundOffAmount ?? this.roundOffAmount,
      amountPaid: amountPaid ?? this.amountPaid,
      amountInWords: amountInWords ?? this.amountInWords,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      isIgst: isIgst ?? this.isIgst,
      templateId: templateId ?? this.templateId,
      referenceInvoiceId: referenceInvoiceId ?? this.referenceInvoiceId,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      shipToName: shipToName ?? this.shipToName,
      shipToAddress: shipToAddress ?? this.shipToAddress,
      shipToCity: shipToCity ?? this.shipToCity,
      exportWithLut: exportWithLut ?? this.exportWithLut,
      tdsSection: tdsSection ?? this.tdsSection,
      tdsRate: tdsRate ?? this.tdsRate,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      tcsSection: tcsSection ?? this.tcsSection,
      tcsRate: tcsRate ?? this.tcsRate,
      tcsAmount: tcsAmount ?? this.tcsAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (supplyType.present) {
      map['supply_type'] = Variable<String>(supplyType.value);
    }
    if (placeOfSupply.present) {
      map['place_of_supply'] = Variable<int>(placeOfSupply.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxableAmount.present) {
      map['taxable_amount'] = Variable<double>(taxableAmount.value);
    }
    if (cgstAmount.present) {
      map['cgst_amount'] = Variable<double>(cgstAmount.value);
    }
    if (sgstAmount.present) {
      map['sgst_amount'] = Variable<double>(sgstAmount.value);
    }
    if (igstAmount.present) {
      map['igst_amount'] = Variable<double>(igstAmount.value);
    }
    if (cessAmount.present) {
      map['cess_amount'] = Variable<double>(cessAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (roundOffAmount.present) {
      map['round_off_amount'] = Variable<double>(roundOffAmount.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (amountInWords.present) {
      map['amount_in_words'] = Variable<String>(amountInWords.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(terms.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isIgst.present) {
      map['is_igst'] = Variable<bool>(isIgst.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (referenceInvoiceId.present) {
      map['reference_invoice_id'] = Variable<int>(referenceInvoiceId.value);
    }
    if (reverseCharge.present) {
      map['reverse_charge'] = Variable<bool>(reverseCharge.value);
    }
    if (shipToName.present) {
      map['ship_to_name'] = Variable<String>(shipToName.value);
    }
    if (shipToAddress.present) {
      map['ship_to_address'] = Variable<String>(shipToAddress.value);
    }
    if (shipToCity.present) {
      map['ship_to_city'] = Variable<String>(shipToCity.value);
    }
    if (exportWithLut.present) {
      map['export_with_lut'] = Variable<bool>(exportWithLut.value);
    }
    if (tdsSection.present) {
      map['tds_section'] = Variable<String>(tdsSection.value);
    }
    if (tdsRate.present) {
      map['tds_rate'] = Variable<double>(tdsRate.value);
    }
    if (tdsAmount.present) {
      map['tds_amount'] = Variable<double>(tdsAmount.value);
    }
    if (tcsSection.present) {
      map['tcs_section'] = Variable<String>(tcsSection.value);
    }
    if (tcsRate.present) {
      map['tcs_rate'] = Variable<double>(tcsRate.value);
    }
    if (tcsAmount.present) {
      map['tcs_amount'] = Variable<double>(tcsAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('supplyType: $supplyType, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('roundOffAmount: $roundOffAmount, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('notes: $notes, ')
          ..write('terms: $terms, ')
          ..write('status: $status, ')
          ..write('isIgst: $isIgst, ')
          ..write('templateId: $templateId, ')
          ..write('referenceInvoiceId: $referenceInvoiceId, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('shipToName: $shipToName, ')
          ..write('shipToAddress: $shipToAddress, ')
          ..write('shipToCity: $shipToCity, ')
          ..write('exportWithLut: $exportWithLut, ')
          ..write('tdsSection: $tdsSection, ')
          ..write('tdsRate: $tdsRate, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsSection: $tcsSection, ')
          ..write('tcsRate: $tcsRate, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $InvoiceItemsTable extends InvoiceItems
    with TableInfo<$InvoiceItemsTable, InvoiceItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoiceItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hsnSacMeta = const VerificationMeta('hsnSac');
  @override
  late final GeneratedColumn<String> hsnSac = GeneratedColumn<String>(
    'hsn_sac',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPctMeta = const VerificationMeta(
    'discountPct',
  );
  @override
  late final GeneratedColumn<double> discountPct = GeneratedColumn<double>(
    'discount_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxableAmountMeta = const VerificationMeta(
    'taxableAmount',
  );
  @override
  late final GeneratedColumn<double> taxableAmount = GeneratedColumn<double>(
    'taxable_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstRateMeta = const VerificationMeta(
    'gstRate',
  );
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
    'gst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cgstRateMeta = const VerificationMeta(
    'cgstRate',
  );
  @override
  late final GeneratedColumn<double> cgstRate = GeneratedColumn<double>(
    'cgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstRateMeta = const VerificationMeta(
    'sgstRate',
  );
  @override
  late final GeneratedColumn<double> sgstRate = GeneratedColumn<double>(
    'sgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstRateMeta = const VerificationMeta(
    'igstRate',
  );
  @override
  late final GeneratedColumn<double> igstRate = GeneratedColumn<double>(
    'igst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessRateMeta = const VerificationMeta(
    'cessRate',
  );
  @override
  late final GeneratedColumn<double> cessRate = GeneratedColumn<double>(
    'cess_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cgstAmountMeta = const VerificationMeta(
    'cgstAmount',
  );
  @override
  late final GeneratedColumn<double> cgstAmount = GeneratedColumn<double>(
    'cgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstAmountMeta = const VerificationMeta(
    'sgstAmount',
  );
  @override
  late final GeneratedColumn<double> sgstAmount = GeneratedColumn<double>(
    'sgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstAmountMeta = const VerificationMeta(
    'igstAmount',
  );
  @override
  late final GeneratedColumn<double> igstAmount = GeneratedColumn<double>(
    'igst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessAmountMeta = const VerificationMeta(
    'cessAmount',
  );
  @override
  late final GeneratedColumn<double> cessAmount = GeneratedColumn<double>(
    'cess_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    productId,
    name,
    hsnSac,
    unit,
    quantity,
    rate,
    discountPct,
    taxableAmount,
    gstRate,
    cgstRate,
    sgstRate,
    igstRate,
    cessRate,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoiceItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hsn_sac')) {
      context.handle(
        _hsnSacMeta,
        hsnSac.isAcceptableOrUnknown(data['hsn_sac']!, _hsnSacMeta),
      );
    } else if (isInserting) {
      context.missing(_hsnSacMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('discount_pct')) {
      context.handle(
        _discountPctMeta,
        discountPct.isAcceptableOrUnknown(
          data['discount_pct']!,
          _discountPctMeta,
        ),
      );
    }
    if (data.containsKey('taxable_amount')) {
      context.handle(
        _taxableAmountMeta,
        taxableAmount.isAcceptableOrUnknown(
          data['taxable_amount']!,
          _taxableAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxableAmountMeta);
    }
    if (data.containsKey('gst_rate')) {
      context.handle(
        _gstRateMeta,
        gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta),
      );
    } else if (isInserting) {
      context.missing(_gstRateMeta);
    }
    if (data.containsKey('cgst_rate')) {
      context.handle(
        _cgstRateMeta,
        cgstRate.isAcceptableOrUnknown(data['cgst_rate']!, _cgstRateMeta),
      );
    }
    if (data.containsKey('sgst_rate')) {
      context.handle(
        _sgstRateMeta,
        sgstRate.isAcceptableOrUnknown(data['sgst_rate']!, _sgstRateMeta),
      );
    }
    if (data.containsKey('igst_rate')) {
      context.handle(
        _igstRateMeta,
        igstRate.isAcceptableOrUnknown(data['igst_rate']!, _igstRateMeta),
      );
    }
    if (data.containsKey('cess_rate')) {
      context.handle(
        _cessRateMeta,
        cessRate.isAcceptableOrUnknown(data['cess_rate']!, _cessRateMeta),
      );
    }
    if (data.containsKey('cgst_amount')) {
      context.handle(
        _cgstAmountMeta,
        cgstAmount.isAcceptableOrUnknown(data['cgst_amount']!, _cgstAmountMeta),
      );
    }
    if (data.containsKey('sgst_amount')) {
      context.handle(
        _sgstAmountMeta,
        sgstAmount.isAcceptableOrUnknown(data['sgst_amount']!, _sgstAmountMeta),
      );
    }
    if (data.containsKey('igst_amount')) {
      context.handle(
        _igstAmountMeta,
        igstAmount.isAcceptableOrUnknown(data['igst_amount']!, _igstAmountMeta),
      );
    }
    if (data.containsKey('cess_amount')) {
      context.handle(
        _cessAmountMeta,
        cessAmount.isAcceptableOrUnknown(data['cess_amount']!, _cessAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoiceItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoiceItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hsnSac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_sac'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      discountPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_pct'],
      )!,
      taxableAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_amount'],
      )!,
      gstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate'],
      )!,
      cgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_rate'],
      )!,
      sgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_rate'],
      )!,
      igstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_rate'],
      )!,
      cessRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_rate'],
      )!,
      cgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_amount'],
      )!,
      sgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_amount'],
      )!,
      igstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_amount'],
      )!,
      cessAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $InvoiceItemsTable createAlias(String alias) {
    return $InvoiceItemsTable(attachedDatabase, alias);
  }
}

class InvoiceItem extends DataClass implements Insertable<InvoiceItem> {
  final int id;
  final int invoiceId;
  final int? productId;
  final String name;
  final String hsnSac;
  final String unit;
  final double quantity;
  final double rate;
  final double discountPct;
  final double taxableAmount;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;
  final int sortOrder;
  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    this.productId,
    required this.name,
    required this.hsnSac,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.discountPct,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['name'] = Variable<String>(name);
    map['hsn_sac'] = Variable<String>(hsnSac);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    map['rate'] = Variable<double>(rate);
    map['discount_pct'] = Variable<double>(discountPct);
    map['taxable_amount'] = Variable<double>(taxableAmount);
    map['gst_rate'] = Variable<double>(gstRate);
    map['cgst_rate'] = Variable<double>(cgstRate);
    map['sgst_rate'] = Variable<double>(sgstRate);
    map['igst_rate'] = Variable<double>(igstRate);
    map['cess_rate'] = Variable<double>(cessRate);
    map['cgst_amount'] = Variable<double>(cgstAmount);
    map['sgst_amount'] = Variable<double>(sgstAmount);
    map['igst_amount'] = Variable<double>(igstAmount);
    map['cess_amount'] = Variable<double>(cessAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  InvoiceItemsCompanion toCompanion(bool nullToAbsent) {
    return InvoiceItemsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      name: Value(name),
      hsnSac: Value(hsnSac),
      unit: Value(unit),
      quantity: Value(quantity),
      rate: Value(rate),
      discountPct: Value(discountPct),
      taxableAmount: Value(taxableAmount),
      gstRate: Value(gstRate),
      cgstRate: Value(cgstRate),
      sgstRate: Value(sgstRate),
      igstRate: Value(igstRate),
      cessRate: Value(cessRate),
      cgstAmount: Value(cgstAmount),
      sgstAmount: Value(sgstAmount),
      igstAmount: Value(igstAmount),
      cessAmount: Value(cessAmount),
      totalAmount: Value(totalAmount),
      sortOrder: Value(sortOrder),
    );
  }

  factory InvoiceItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoiceItem(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      productId: serializer.fromJson<int?>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      hsnSac: serializer.fromJson<String>(json['hsnSac']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      rate: serializer.fromJson<double>(json['rate']),
      discountPct: serializer.fromJson<double>(json['discountPct']),
      taxableAmount: serializer.fromJson<double>(json['taxableAmount']),
      gstRate: serializer.fromJson<double>(json['gstRate']),
      cgstRate: serializer.fromJson<double>(json['cgstRate']),
      sgstRate: serializer.fromJson<double>(json['sgstRate']),
      igstRate: serializer.fromJson<double>(json['igstRate']),
      cessRate: serializer.fromJson<double>(json['cessRate']),
      cgstAmount: serializer.fromJson<double>(json['cgstAmount']),
      sgstAmount: serializer.fromJson<double>(json['sgstAmount']),
      igstAmount: serializer.fromJson<double>(json['igstAmount']),
      cessAmount: serializer.fromJson<double>(json['cessAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'productId': serializer.toJson<int?>(productId),
      'name': serializer.toJson<String>(name),
      'hsnSac': serializer.toJson<String>(hsnSac),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'rate': serializer.toJson<double>(rate),
      'discountPct': serializer.toJson<double>(discountPct),
      'taxableAmount': serializer.toJson<double>(taxableAmount),
      'gstRate': serializer.toJson<double>(gstRate),
      'cgstRate': serializer.toJson<double>(cgstRate),
      'sgstRate': serializer.toJson<double>(sgstRate),
      'igstRate': serializer.toJson<double>(igstRate),
      'cessRate': serializer.toJson<double>(cessRate),
      'cgstAmount': serializer.toJson<double>(cgstAmount),
      'sgstAmount': serializer.toJson<double>(sgstAmount),
      'igstAmount': serializer.toJson<double>(igstAmount),
      'cessAmount': serializer.toJson<double>(cessAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  InvoiceItem copyWith({
    int? id,
    int? invoiceId,
    Value<int?> productId = const Value.absent(),
    String? name,
    String? hsnSac,
    String? unit,
    double? quantity,
    double? rate,
    double? discountPct,
    double? taxableAmount,
    double? gstRate,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
    double? totalAmount,
    int? sortOrder,
  }) => InvoiceItem(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    productId: productId.present ? productId.value : this.productId,
    name: name ?? this.name,
    hsnSac: hsnSac ?? this.hsnSac,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    rate: rate ?? this.rate,
    discountPct: discountPct ?? this.discountPct,
    taxableAmount: taxableAmount ?? this.taxableAmount,
    gstRate: gstRate ?? this.gstRate,
    cgstRate: cgstRate ?? this.cgstRate,
    sgstRate: sgstRate ?? this.sgstRate,
    igstRate: igstRate ?? this.igstRate,
    cessRate: cessRate ?? this.cessRate,
    cgstAmount: cgstAmount ?? this.cgstAmount,
    sgstAmount: sgstAmount ?? this.sgstAmount,
    igstAmount: igstAmount ?? this.igstAmount,
    cessAmount: cessAmount ?? this.cessAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  InvoiceItem copyWithCompanion(InvoiceItemsCompanion data) {
    return InvoiceItem(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      hsnSac: data.hsnSac.present ? data.hsnSac.value : this.hsnSac,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      rate: data.rate.present ? data.rate.value : this.rate,
      discountPct: data.discountPct.present
          ? data.discountPct.value
          : this.discountPct,
      taxableAmount: data.taxableAmount.present
          ? data.taxableAmount.value
          : this.taxableAmount,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      cgstRate: data.cgstRate.present ? data.cgstRate.value : this.cgstRate,
      sgstRate: data.sgstRate.present ? data.sgstRate.value : this.sgstRate,
      igstRate: data.igstRate.present ? data.igstRate.value : this.igstRate,
      cessRate: data.cessRate.present ? data.cessRate.value : this.cessRate,
      cgstAmount: data.cgstAmount.present
          ? data.cgstAmount.value
          : this.cgstAmount,
      sgstAmount: data.sgstAmount.present
          ? data.sgstAmount.value
          : this.sgstAmount,
      igstAmount: data.igstAmount.present
          ? data.igstAmount.value
          : this.igstAmount,
      cessAmount: data.cessAmount.present
          ? data.cessAmount.value
          : this.cessAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItem(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('discountPct: $discountPct, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstRate: $gstRate, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('igstRate: $igstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    invoiceId,
    productId,
    name,
    hsnSac,
    unit,
    quantity,
    rate,
    discountPct,
    taxableAmount,
    gstRate,
    cgstRate,
    sgstRate,
    igstRate,
    cessRate,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    sortOrder,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoiceItem &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.hsnSac == this.hsnSac &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.rate == this.rate &&
          other.discountPct == this.discountPct &&
          other.taxableAmount == this.taxableAmount &&
          other.gstRate == this.gstRate &&
          other.cgstRate == this.cgstRate &&
          other.sgstRate == this.sgstRate &&
          other.igstRate == this.igstRate &&
          other.cessRate == this.cessRate &&
          other.cgstAmount == this.cgstAmount &&
          other.sgstAmount == this.sgstAmount &&
          other.igstAmount == this.igstAmount &&
          other.cessAmount == this.cessAmount &&
          other.totalAmount == this.totalAmount &&
          other.sortOrder == this.sortOrder);
}

class InvoiceItemsCompanion extends UpdateCompanion<InvoiceItem> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<int?> productId;
  final Value<String> name;
  final Value<String> hsnSac;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<double> rate;
  final Value<double> discountPct;
  final Value<double> taxableAmount;
  final Value<double> gstRate;
  final Value<double> cgstRate;
  final Value<double> sgstRate;
  final Value<double> igstRate;
  final Value<double> cessRate;
  final Value<double> cgstAmount;
  final Value<double> sgstAmount;
  final Value<double> igstAmount;
  final Value<double> cessAmount;
  final Value<double> totalAmount;
  final Value<int> sortOrder;
  const InvoiceItemsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.hsnSac = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rate = const Value.absent(),
    this.discountPct = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.cgstRate = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.cessRate = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  InvoiceItemsCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    this.productId = const Value.absent(),
    required String name,
    required String hsnSac,
    required String unit,
    required double quantity,
    required double rate,
    this.discountPct = const Value.absent(),
    required double taxableAmount,
    required double gstRate,
    this.cgstRate = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.cessRate = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    required double totalAmount,
    this.sortOrder = const Value.absent(),
  }) : invoiceId = Value(invoiceId),
       name = Value(name),
       hsnSac = Value(hsnSac),
       unit = Value(unit),
       quantity = Value(quantity),
       rate = Value(rate),
       taxableAmount = Value(taxableAmount),
       gstRate = Value(gstRate),
       totalAmount = Value(totalAmount);
  static Insertable<InvoiceItem> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<int>? productId,
    Expression<String>? name,
    Expression<String>? hsnSac,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<double>? rate,
    Expression<double>? discountPct,
    Expression<double>? taxableAmount,
    Expression<double>? gstRate,
    Expression<double>? cgstRate,
    Expression<double>? sgstRate,
    Expression<double>? igstRate,
    Expression<double>? cessRate,
    Expression<double>? cgstAmount,
    Expression<double>? sgstAmount,
    Expression<double>? igstAmount,
    Expression<double>? cessAmount,
    Expression<double>? totalAmount,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (hsnSac != null) 'hsn_sac': hsnSac,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (rate != null) 'rate': rate,
      if (discountPct != null) 'discount_pct': discountPct,
      if (taxableAmount != null) 'taxable_amount': taxableAmount,
      if (gstRate != null) 'gst_rate': gstRate,
      if (cgstRate != null) 'cgst_rate': cgstRate,
      if (sgstRate != null) 'sgst_rate': sgstRate,
      if (igstRate != null) 'igst_rate': igstRate,
      if (cessRate != null) 'cess_rate': cessRate,
      if (cgstAmount != null) 'cgst_amount': cgstAmount,
      if (sgstAmount != null) 'sgst_amount': sgstAmount,
      if (igstAmount != null) 'igst_amount': igstAmount,
      if (cessAmount != null) 'cess_amount': cessAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  InvoiceItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? invoiceId,
    Value<int?>? productId,
    Value<String>? name,
    Value<String>? hsnSac,
    Value<String>? unit,
    Value<double>? quantity,
    Value<double>? rate,
    Value<double>? discountPct,
    Value<double>? taxableAmount,
    Value<double>? gstRate,
    Value<double>? cgstRate,
    Value<double>? sgstRate,
    Value<double>? igstRate,
    Value<double>? cessRate,
    Value<double>? cgstAmount,
    Value<double>? sgstAmount,
    Value<double>? igstAmount,
    Value<double>? cessAmount,
    Value<double>? totalAmount,
    Value<int>? sortOrder,
  }) {
    return InvoiceItemsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      hsnSac: hsnSac ?? this.hsnSac,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      discountPct: discountPct ?? this.discountPct,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      gstRate: gstRate ?? this.gstRate,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hsnSac.present) {
      map['hsn_sac'] = Variable<String>(hsnSac.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (discountPct.present) {
      map['discount_pct'] = Variable<double>(discountPct.value);
    }
    if (taxableAmount.present) {
      map['taxable_amount'] = Variable<double>(taxableAmount.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (cgstRate.present) {
      map['cgst_rate'] = Variable<double>(cgstRate.value);
    }
    if (sgstRate.present) {
      map['sgst_rate'] = Variable<double>(sgstRate.value);
    }
    if (igstRate.present) {
      map['igst_rate'] = Variable<double>(igstRate.value);
    }
    if (cessRate.present) {
      map['cess_rate'] = Variable<double>(cessRate.value);
    }
    if (cgstAmount.present) {
      map['cgst_amount'] = Variable<double>(cgstAmount.value);
    }
    if (sgstAmount.present) {
      map['sgst_amount'] = Variable<double>(sgstAmount.value);
    }
    if (igstAmount.present) {
      map['igst_amount'] = Variable<double>(igstAmount.value);
    }
    if (cessAmount.present) {
      map['cess_amount'] = Variable<double>(cessAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoiceItemsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('discountPct: $discountPct, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstRate: $gstRate, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('igstRate: $igstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $InvoicePaymentsTable extends InvoicePayments
    with TableInfo<$InvoicePaymentsTable, InvoicePayment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvoicePaymentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _invoiceIdMeta = const VerificationMeta(
    'invoiceId',
  );
  @override
  late final GeneratedColumn<int> invoiceId = GeneratedColumn<int>(
    'invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('PAYMENT'),
  );
  static const VerificationMeta _paidAtMeta = const VerificationMeta('paidAt');
  @override
  late final GeneratedColumn<DateTime> paidAt = GeneratedColumn<DateTime>(
    'paid_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _referenceMeta = const VerificationMeta(
    'reference',
  );
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
    'reference',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    invoiceId,
    amount,
    kind,
    paidAt,
    mode,
    reference,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'invoice_payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InvoicePayment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('invoice_id')) {
      context.handle(
        _invoiceIdMeta,
        invoiceId.isAcceptableOrUnknown(data['invoice_id']!, _invoiceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_invoiceIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('paid_at')) {
      context.handle(
        _paidAtMeta,
        paidAt.isAcceptableOrUnknown(data['paid_at']!, _paidAtMeta),
      );
    } else if (isInserting) {
      context.missing(_paidAtMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    }
    if (data.containsKey('reference')) {
      context.handle(
        _referenceMeta,
        reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvoicePayment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvoicePayment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      invoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invoice_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      paidAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paid_at'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      ),
      reference: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reference'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InvoicePaymentsTable createAlias(String alias) {
    return $InvoicePaymentsTable(attachedDatabase, alias);
  }
}

class InvoicePayment extends DataClass implements Insertable<InvoicePayment> {
  final int id;
  final int invoiceId;
  final double amount;
  final String kind;
  final DateTime paidAt;

  /// How the money moved (CASH, UPI, BANK, CARD, OTHER). Optional so existing
  /// and manually entered payments stay valid.
  final String? mode;

  /// UPI/bank reference or transaction id the payment can be traced by.
  final String? reference;
  final String? note;
  final DateTime createdAt;
  const InvoicePayment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.kind,
    required this.paidAt,
    this.mode,
    this.reference,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['invoice_id'] = Variable<int>(invoiceId);
    map['amount'] = Variable<double>(amount);
    map['kind'] = Variable<String>(kind);
    map['paid_at'] = Variable<DateTime>(paidAt);
    if (!nullToAbsent || mode != null) {
      map['mode'] = Variable<String>(mode);
    }
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InvoicePaymentsCompanion toCompanion(bool nullToAbsent) {
    return InvoicePaymentsCompanion(
      id: Value(id),
      invoiceId: Value(invoiceId),
      amount: Value(amount),
      kind: Value(kind),
      paidAt: Value(paidAt),
      mode: mode == null && nullToAbsent ? const Value.absent() : Value(mode),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory InvoicePayment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvoicePayment(
      id: serializer.fromJson<int>(json['id']),
      invoiceId: serializer.fromJson<int>(json['invoiceId']),
      amount: serializer.fromJson<double>(json['amount']),
      kind: serializer.fromJson<String>(json['kind']),
      paidAt: serializer.fromJson<DateTime>(json['paidAt']),
      mode: serializer.fromJson<String?>(json['mode']),
      reference: serializer.fromJson<String?>(json['reference']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'invoiceId': serializer.toJson<int>(invoiceId),
      'amount': serializer.toJson<double>(amount),
      'kind': serializer.toJson<String>(kind),
      'paidAt': serializer.toJson<DateTime>(paidAt),
      'mode': serializer.toJson<String?>(mode),
      'reference': serializer.toJson<String?>(reference),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InvoicePayment copyWith({
    int? id,
    int? invoiceId,
    double? amount,
    String? kind,
    DateTime? paidAt,
    Value<String?> mode = const Value.absent(),
    Value<String?> reference = const Value.absent(),
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => InvoicePayment(
    id: id ?? this.id,
    invoiceId: invoiceId ?? this.invoiceId,
    amount: amount ?? this.amount,
    kind: kind ?? this.kind,
    paidAt: paidAt ?? this.paidAt,
    mode: mode.present ? mode.value : this.mode,
    reference: reference.present ? reference.value : this.reference,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  InvoicePayment copyWithCompanion(InvoicePaymentsCompanion data) {
    return InvoicePayment(
      id: data.id.present ? data.id.value : this.id,
      invoiceId: data.invoiceId.present ? data.invoiceId.value : this.invoiceId,
      amount: data.amount.present ? data.amount.value : this.amount,
      kind: data.kind.present ? data.kind.value : this.kind,
      paidAt: data.paidAt.present ? data.paidAt.value : this.paidAt,
      mode: data.mode.present ? data.mode.value : this.mode,
      reference: data.reference.present ? data.reference.value : this.reference,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePayment(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('paidAt: $paidAt, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    invoiceId,
    amount,
    kind,
    paidAt,
    mode,
    reference,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvoicePayment &&
          other.id == this.id &&
          other.invoiceId == this.invoiceId &&
          other.amount == this.amount &&
          other.kind == this.kind &&
          other.paidAt == this.paidAt &&
          other.mode == this.mode &&
          other.reference == this.reference &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class InvoicePaymentsCompanion extends UpdateCompanion<InvoicePayment> {
  final Value<int> id;
  final Value<int> invoiceId;
  final Value<double> amount;
  final Value<String> kind;
  final Value<DateTime> paidAt;
  final Value<String?> mode;
  final Value<String?> reference;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const InvoicePaymentsCompanion({
    this.id = const Value.absent(),
    this.invoiceId = const Value.absent(),
    this.amount = const Value.absent(),
    this.kind = const Value.absent(),
    this.paidAt = const Value.absent(),
    this.mode = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InvoicePaymentsCompanion.insert({
    this.id = const Value.absent(),
    required int invoiceId,
    required double amount,
    this.kind = const Value.absent(),
    required DateTime paidAt,
    this.mode = const Value.absent(),
    this.reference = const Value.absent(),
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : invoiceId = Value(invoiceId),
       amount = Value(amount),
       paidAt = Value(paidAt),
       createdAt = Value(createdAt);
  static Insertable<InvoicePayment> custom({
    Expression<int>? id,
    Expression<int>? invoiceId,
    Expression<double>? amount,
    Expression<String>? kind,
    Expression<DateTime>? paidAt,
    Expression<String>? mode,
    Expression<String>? reference,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (invoiceId != null) 'invoice_id': invoiceId,
      if (amount != null) 'amount': amount,
      if (kind != null) 'kind': kind,
      if (paidAt != null) 'paid_at': paidAt,
      if (mode != null) 'mode': mode,
      if (reference != null) 'reference': reference,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InvoicePaymentsCompanion copyWith({
    Value<int>? id,
    Value<int>? invoiceId,
    Value<double>? amount,
    Value<String>? kind,
    Value<DateTime>? paidAt,
    Value<String?>? mode,
    Value<String?>? reference,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return InvoicePaymentsCompanion(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      amount: amount ?? this.amount,
      kind: kind ?? this.kind,
      paidAt: paidAt ?? this.paidAt,
      mode: mode ?? this.mode,
      reference: reference ?? this.reference,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (invoiceId.present) {
      map['invoice_id'] = Variable<int>(invoiceId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (paidAt.present) {
      map['paid_at'] = Variable<DateTime>(paidAt.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvoicePaymentsCompanion(')
          ..write('id: $id, ')
          ..write('invoiceId: $invoiceId, ')
          ..write('amount: $amount, ')
          ..write('kind: $kind, ')
          ..write('paidAt: $paidAt, ')
          ..write('mode: $mode, ')
          ..write('reference: $reference, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomerActivityEventsTable extends CustomerActivityEvents
    with TableInfo<$CustomerActivityEventsTable, CustomerActivityEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerActivityEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    customerId,
    eventType,
    entityType,
    entityId,
    title,
    note,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_activity_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerActivityEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerActivityEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerActivityEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      ),
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomerActivityEventsTable createAlias(String alias) {
    return $CustomerActivityEventsTable(attachedDatabase, alias);
  }
}

class CustomerActivityEvent extends DataClass
    implements Insertable<CustomerActivityEvent> {
  final int id;
  final int businessId;
  final int customerId;
  final String eventType;
  final String? entityType;
  final int? entityId;
  final String title;
  final String? note;
  final DateTime createdAt;
  const CustomerActivityEvent({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.eventType,
    this.entityType,
    this.entityId,
    required this.title,
    this.note,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['customer_id'] = Variable<int>(customerId);
    map['event_type'] = Variable<String>(eventType);
    if (!nullToAbsent || entityType != null) {
      map['entity_type'] = Variable<String>(entityType);
    }
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomerActivityEventsCompanion toCompanion(bool nullToAbsent) {
    return CustomerActivityEventsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      customerId: Value(customerId),
      eventType: Value(eventType),
      entityType: entityType == null && nullToAbsent
          ? const Value.absent()
          : Value(entityType),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      title: Value(title),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerActivityEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerActivityEvent(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      entityType: serializer.fromJson<String?>(json['entityType']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      title: serializer.fromJson<String>(json['title']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'customerId': serializer.toJson<int>(customerId),
      'eventType': serializer.toJson<String>(eventType),
      'entityType': serializer.toJson<String?>(entityType),
      'entityId': serializer.toJson<int?>(entityId),
      'title': serializer.toJson<String>(title),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomerActivityEvent copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? eventType,
    Value<String?> entityType = const Value.absent(),
    Value<int?> entityId = const Value.absent(),
    String? title,
    Value<String?> note = const Value.absent(),
    DateTime? createdAt,
  }) => CustomerActivityEvent(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    customerId: customerId ?? this.customerId,
    eventType: eventType ?? this.eventType,
    entityType: entityType.present ? entityType.value : this.entityType,
    entityId: entityId.present ? entityId.value : this.entityId,
    title: title ?? this.title,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerActivityEvent copyWithCompanion(
    CustomerActivityEventsCompanion data,
  ) {
    return CustomerActivityEvent(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerActivityEvent(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    customerId,
    eventType,
    entityType,
    entityId,
    title,
    note,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerActivityEvent &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.customerId == this.customerId &&
          other.eventType == this.eventType &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.title == this.title &&
          other.note == this.note &&
          other.createdAt == this.createdAt);
}

class CustomerActivityEventsCompanion
    extends UpdateCompanion<CustomerActivityEvent> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<int> customerId;
  final Value<String> eventType;
  final Value<String?> entityType;
  final Value<int?> entityId;
  final Value<String> title;
  final Value<String?> note;
  final Value<DateTime> createdAt;
  const CustomerActivityEventsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomerActivityEventsCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required int customerId,
    required String eventType,
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    required String title,
    this.note = const Value.absent(),
    required DateTime createdAt,
  }) : businessId = Value(businessId),
       customerId = Value(customerId),
       eventType = Value(eventType),
       title = Value(title),
       createdAt = Value(createdAt);
  static Insertable<CustomerActivityEvent> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<int>? customerId,
    Expression<String>? eventType,
    Expression<String>? entityType,
    Expression<int>? entityId,
    Expression<String>? title,
    Expression<String>? note,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (customerId != null) 'customer_id': customerId,
      if (eventType != null) 'event_type': eventType,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomerActivityEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<int>? customerId,
    Value<String>? eventType,
    Value<String?>? entityType,
    Value<int?>? entityId,
    Value<String>? title,
    Value<String?>? note,
    Value<DateTime>? createdAt,
  }) {
    return CustomerActivityEventsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      eventType: eventType ?? this.eventType,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      title: title ?? this.title,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerActivityEventsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, Quote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id)',
    ),
  );
  static const VerificationMeta _invoiceNumberMeta = const VerificationMeta(
    'invoiceNumber',
  );
  @override
  late final GeneratedColumn<String> invoiceNumber = GeneratedColumn<String>(
    'invoice_number',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('INR'),
  );
  static const VerificationMeta _invoiceDateMeta = const VerificationMeta(
    'invoiceDate',
  );
  @override
  late final GeneratedColumn<DateTime> invoiceDate = GeneratedColumn<DateTime>(
    'invoice_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _invoiceTypeMeta = const VerificationMeta(
    'invoiceType',
  );
  @override
  late final GeneratedColumn<String> invoiceType = GeneratedColumn<String>(
    'invoice_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplyTypeMeta = const VerificationMeta(
    'supplyType',
  );
  @override
  late final GeneratedColumn<String> supplyType = GeneratedColumn<String>(
    'supply_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _placeOfSupplyMeta = const VerificationMeta(
    'placeOfSupply',
  );
  @override
  late final GeneratedColumn<int> placeOfSupply = GeneratedColumn<int>(
    'place_of_supply',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountAmountMeta = const VerificationMeta(
    'discountAmount',
  );
  @override
  late final GeneratedColumn<double> discountAmount = GeneratedColumn<double>(
    'discount_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxableAmountMeta = const VerificationMeta(
    'taxableAmount',
  );
  @override
  late final GeneratedColumn<double> taxableAmount = GeneratedColumn<double>(
    'taxable_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cgstAmountMeta = const VerificationMeta(
    'cgstAmount',
  );
  @override
  late final GeneratedColumn<double> cgstAmount = GeneratedColumn<double>(
    'cgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstAmountMeta = const VerificationMeta(
    'sgstAmount',
  );
  @override
  late final GeneratedColumn<double> sgstAmount = GeneratedColumn<double>(
    'sgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstAmountMeta = const VerificationMeta(
    'igstAmount',
  );
  @override
  late final GeneratedColumn<double> igstAmount = GeneratedColumn<double>(
    'igst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessAmountMeta = const VerificationMeta(
    'cessAmount',
  );
  @override
  late final GeneratedColumn<double> cessAmount = GeneratedColumn<double>(
    'cess_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roundOffAmountMeta = const VerificationMeta(
    'roundOffAmount',
  );
  @override
  late final GeneratedColumn<double> roundOffAmount = GeneratedColumn<double>(
    'round_off_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _amountInWordsMeta = const VerificationMeta(
    'amountInWords',
  );
  @override
  late final GeneratedColumn<String> amountInWords = GeneratedColumn<String>(
    'amount_in_words',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _termsMeta = const VerificationMeta('terms');
  @override
  late final GeneratedColumn<String> terms = GeneratedColumn<String>(
    'terms',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('DRAFT'),
  );
  static const VerificationMeta _isIgstMeta = const VerificationMeta('isIgst');
  @override
  late final GeneratedColumn<bool> isIgst = GeneratedColumn<bool>(
    'is_igst',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_igst" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reverseChargeMeta = const VerificationMeta(
    'reverseCharge',
  );
  @override
  late final GeneratedColumn<bool> reverseCharge = GeneratedColumn<bool>(
    'reverse_charge',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("reverse_charge" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _shipToNameMeta = const VerificationMeta(
    'shipToName',
  );
  @override
  late final GeneratedColumn<String> shipToName = GeneratedColumn<String>(
    'ship_to_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shipToAddressMeta = const VerificationMeta(
    'shipToAddress',
  );
  @override
  late final GeneratedColumn<String> shipToAddress = GeneratedColumn<String>(
    'ship_to_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shipToCityMeta = const VerificationMeta(
    'shipToCity',
  );
  @override
  late final GeneratedColumn<String> shipToCity = GeneratedColumn<String>(
    'ship_to_city',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _exportWithLutMeta = const VerificationMeta(
    'exportWithLut',
  );
  @override
  late final GeneratedColumn<bool> exportWithLut = GeneratedColumn<bool>(
    'export_with_lut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("export_with_lut" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _tdsSectionMeta = const VerificationMeta(
    'tdsSection',
  );
  @override
  late final GeneratedColumn<String> tdsSection = GeneratedColumn<String>(
    'tds_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tdsRateMeta = const VerificationMeta(
    'tdsRate',
  );
  @override
  late final GeneratedColumn<double> tdsRate = GeneratedColumn<double>(
    'tds_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tdsAmountMeta = const VerificationMeta(
    'tdsAmount',
  );
  @override
  late final GeneratedColumn<double> tdsAmount = GeneratedColumn<double>(
    'tds_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tcsSectionMeta = const VerificationMeta(
    'tcsSection',
  );
  @override
  late final GeneratedColumn<String> tcsSection = GeneratedColumn<String>(
    'tcs_section',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tcsRateMeta = const VerificationMeta(
    'tcsRate',
  );
  @override
  late final GeneratedColumn<double> tcsRate = GeneratedColumn<double>(
    'tcs_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _tcsAmountMeta = const VerificationMeta(
    'tcsAmount',
  );
  @override
  late final GeneratedColumn<double> tcsAmount = GeneratedColumn<double>(
    'tcs_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    customerId,
    invoiceNumber,
    currencyCode,
    invoiceDate,
    dueDate,
    invoiceType,
    supplyType,
    placeOfSupply,
    subtotal,
    discountAmount,
    taxableAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    roundOffAmount,
    amountInWords,
    notes,
    terms,
    status,
    isIgst,
    templateId,
    reverseCharge,
    shipToName,
    shipToAddress,
    shipToCity,
    exportWithLut,
    tdsSection,
    tdsRate,
    tdsAmount,
    tcsSection,
    tcsRate,
    tcsAmount,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Quote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('invoice_number')) {
      context.handle(
        _invoiceNumberMeta,
        invoiceNumber.isAcceptableOrUnknown(
          data['invoice_number']!,
          _invoiceNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceNumberMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    }
    if (data.containsKey('invoice_date')) {
      context.handle(
        _invoiceDateMeta,
        invoiceDate.isAcceptableOrUnknown(
          data['invoice_date']!,
          _invoiceDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('invoice_type')) {
      context.handle(
        _invoiceTypeMeta,
        invoiceType.isAcceptableOrUnknown(
          data['invoice_type']!,
          _invoiceTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_invoiceTypeMeta);
    }
    if (data.containsKey('supply_type')) {
      context.handle(
        _supplyTypeMeta,
        supplyType.isAcceptableOrUnknown(data['supply_type']!, _supplyTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_supplyTypeMeta);
    }
    if (data.containsKey('place_of_supply')) {
      context.handle(
        _placeOfSupplyMeta,
        placeOfSupply.isAcceptableOrUnknown(
          data['place_of_supply']!,
          _placeOfSupplyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_placeOfSupplyMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('discount_amount')) {
      context.handle(
        _discountAmountMeta,
        discountAmount.isAcceptableOrUnknown(
          data['discount_amount']!,
          _discountAmountMeta,
        ),
      );
    }
    if (data.containsKey('taxable_amount')) {
      context.handle(
        _taxableAmountMeta,
        taxableAmount.isAcceptableOrUnknown(
          data['taxable_amount']!,
          _taxableAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxableAmountMeta);
    }
    if (data.containsKey('cgst_amount')) {
      context.handle(
        _cgstAmountMeta,
        cgstAmount.isAcceptableOrUnknown(data['cgst_amount']!, _cgstAmountMeta),
      );
    }
    if (data.containsKey('sgst_amount')) {
      context.handle(
        _sgstAmountMeta,
        sgstAmount.isAcceptableOrUnknown(data['sgst_amount']!, _sgstAmountMeta),
      );
    }
    if (data.containsKey('igst_amount')) {
      context.handle(
        _igstAmountMeta,
        igstAmount.isAcceptableOrUnknown(data['igst_amount']!, _igstAmountMeta),
      );
    }
    if (data.containsKey('cess_amount')) {
      context.handle(
        _cessAmountMeta,
        cessAmount.isAcceptableOrUnknown(data['cess_amount']!, _cessAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('round_off_amount')) {
      context.handle(
        _roundOffAmountMeta,
        roundOffAmount.isAcceptableOrUnknown(
          data['round_off_amount']!,
          _roundOffAmountMeta,
        ),
      );
    }
    if (data.containsKey('amount_in_words')) {
      context.handle(
        _amountInWordsMeta,
        amountInWords.isAcceptableOrUnknown(
          data['amount_in_words']!,
          _amountInWordsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('terms')) {
      context.handle(
        _termsMeta,
        terms.isAcceptableOrUnknown(data['terms']!, _termsMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('is_igst')) {
      context.handle(
        _isIgstMeta,
        isIgst.isAcceptableOrUnknown(data['is_igst']!, _isIgstMeta),
      );
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('reverse_charge')) {
      context.handle(
        _reverseChargeMeta,
        reverseCharge.isAcceptableOrUnknown(
          data['reverse_charge']!,
          _reverseChargeMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_name')) {
      context.handle(
        _shipToNameMeta,
        shipToName.isAcceptableOrUnknown(
          data['ship_to_name']!,
          _shipToNameMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_address')) {
      context.handle(
        _shipToAddressMeta,
        shipToAddress.isAcceptableOrUnknown(
          data['ship_to_address']!,
          _shipToAddressMeta,
        ),
      );
    }
    if (data.containsKey('ship_to_city')) {
      context.handle(
        _shipToCityMeta,
        shipToCity.isAcceptableOrUnknown(
          data['ship_to_city']!,
          _shipToCityMeta,
        ),
      );
    }
    if (data.containsKey('export_with_lut')) {
      context.handle(
        _exportWithLutMeta,
        exportWithLut.isAcceptableOrUnknown(
          data['export_with_lut']!,
          _exportWithLutMeta,
        ),
      );
    }
    if (data.containsKey('tds_section')) {
      context.handle(
        _tdsSectionMeta,
        tdsSection.isAcceptableOrUnknown(data['tds_section']!, _tdsSectionMeta),
      );
    }
    if (data.containsKey('tds_rate')) {
      context.handle(
        _tdsRateMeta,
        tdsRate.isAcceptableOrUnknown(data['tds_rate']!, _tdsRateMeta),
      );
    }
    if (data.containsKey('tds_amount')) {
      context.handle(
        _tdsAmountMeta,
        tdsAmount.isAcceptableOrUnknown(data['tds_amount']!, _tdsAmountMeta),
      );
    }
    if (data.containsKey('tcs_section')) {
      context.handle(
        _tcsSectionMeta,
        tcsSection.isAcceptableOrUnknown(data['tcs_section']!, _tcsSectionMeta),
      );
    }
    if (data.containsKey('tcs_rate')) {
      context.handle(
        _tcsRateMeta,
        tcsRate.isAcceptableOrUnknown(data['tcs_rate']!, _tcsRateMeta),
      );
    }
    if (data.containsKey('tcs_amount')) {
      context.handle(
        _tcsAmountMeta,
        tcsAmount.isAcceptableOrUnknown(data['tcs_amount']!, _tcsAmountMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {businessId, invoiceNumber},
  ];
  @override
  Quote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Quote(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      invoiceNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_number'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      invoiceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}invoice_date'],
      )!,
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      invoiceType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}invoice_type'],
      )!,
      supplyType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_type'],
      )!,
      placeOfSupply: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}place_of_supply'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      discountAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_amount'],
      )!,
      taxableAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_amount'],
      )!,
      cgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_amount'],
      )!,
      sgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_amount'],
      )!,
      igstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_amount'],
      )!,
      cessAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      roundOffAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}round_off_amount'],
      )!,
      amountInWords: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}amount_in_words'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      terms: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}terms'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      isIgst: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_igst'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      ),
      reverseCharge: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}reverse_charge'],
      )!,
      shipToName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_name'],
      ),
      shipToAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_address'],
      ),
      shipToCity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ship_to_city'],
      ),
      exportWithLut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}export_with_lut'],
      )!,
      tdsSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tds_section'],
      ),
      tdsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_rate'],
      )!,
      tdsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tds_amount'],
      )!,
      tcsSection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tcs_section'],
      ),
      tcsRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tcs_rate'],
      )!,
      tcsAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tcs_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class Quote extends DataClass implements Insertable<Quote> {
  final int id;
  final int businessId;
  final int customerId;
  final String invoiceNumber;
  final String currencyCode;
  final DateTime invoiceDate;
  final DateTime? dueDate;
  final String invoiceType;
  final String supplyType;
  final int placeOfSupply;
  final double subtotal;
  final double discountAmount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;

  /// Whole-rupee round-off adjustment (see `Invoices.roundOffAmount`).
  final double roundOffAmount;
  final String? amountInWords;
  final String? notes;
  final String? terms;
  final String status;
  final bool isIgst;
  final int? templateId;

  /// Reverse-charge declaration and optional ship-to party (see `Invoices`).
  final bool reverseCharge;
  final String? shipToName;
  final String? shipToAddress;
  final String? shipToCity;

  /// Export/SEZ supplies declared under a Letter of Undertaking (see `Invoices`).
  final bool exportWithLut;

  /// Optional TDS/TCS adjustment (see `Invoices`).
  final String? tdsSection;
  final double tdsRate;
  final double tdsAmount;
  final String? tcsSection;
  final double tcsRate;
  final double tcsAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Quote({
    required this.id,
    required this.businessId,
    required this.customerId,
    required this.invoiceNumber,
    required this.currencyCode,
    required this.invoiceDate,
    this.dueDate,
    required this.invoiceType,
    required this.supplyType,
    required this.placeOfSupply,
    required this.subtotal,
    required this.discountAmount,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
    required this.roundOffAmount,
    this.amountInWords,
    this.notes,
    this.terms,
    required this.status,
    required this.isIgst,
    this.templateId,
    required this.reverseCharge,
    this.shipToName,
    this.shipToAddress,
    this.shipToCity,
    required this.exportWithLut,
    this.tdsSection,
    required this.tdsRate,
    required this.tdsAmount,
    this.tcsSection,
    required this.tcsRate,
    required this.tcsAmount,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['customer_id'] = Variable<int>(customerId);
    map['invoice_number'] = Variable<String>(invoiceNumber);
    map['currency_code'] = Variable<String>(currencyCode);
    map['invoice_date'] = Variable<DateTime>(invoiceDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['invoice_type'] = Variable<String>(invoiceType);
    map['supply_type'] = Variable<String>(supplyType);
    map['place_of_supply'] = Variable<int>(placeOfSupply);
    map['subtotal'] = Variable<double>(subtotal);
    map['discount_amount'] = Variable<double>(discountAmount);
    map['taxable_amount'] = Variable<double>(taxableAmount);
    map['cgst_amount'] = Variable<double>(cgstAmount);
    map['sgst_amount'] = Variable<double>(sgstAmount);
    map['igst_amount'] = Variable<double>(igstAmount);
    map['cess_amount'] = Variable<double>(cessAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['round_off_amount'] = Variable<double>(roundOffAmount);
    if (!nullToAbsent || amountInWords != null) {
      map['amount_in_words'] = Variable<String>(amountInWords);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || terms != null) {
      map['terms'] = Variable<String>(terms);
    }
    map['status'] = Variable<String>(status);
    map['is_igst'] = Variable<bool>(isIgst);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<int>(templateId);
    }
    map['reverse_charge'] = Variable<bool>(reverseCharge);
    if (!nullToAbsent || shipToName != null) {
      map['ship_to_name'] = Variable<String>(shipToName);
    }
    if (!nullToAbsent || shipToAddress != null) {
      map['ship_to_address'] = Variable<String>(shipToAddress);
    }
    if (!nullToAbsent || shipToCity != null) {
      map['ship_to_city'] = Variable<String>(shipToCity);
    }
    map['export_with_lut'] = Variable<bool>(exportWithLut);
    if (!nullToAbsent || tdsSection != null) {
      map['tds_section'] = Variable<String>(tdsSection);
    }
    map['tds_rate'] = Variable<double>(tdsRate);
    map['tds_amount'] = Variable<double>(tdsAmount);
    if (!nullToAbsent || tcsSection != null) {
      map['tcs_section'] = Variable<String>(tcsSection);
    }
    map['tcs_rate'] = Variable<double>(tcsRate);
    map['tcs_amount'] = Variable<double>(tcsAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      customerId: Value(customerId),
      invoiceNumber: Value(invoiceNumber),
      currencyCode: Value(currencyCode),
      invoiceDate: Value(invoiceDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      invoiceType: Value(invoiceType),
      supplyType: Value(supplyType),
      placeOfSupply: Value(placeOfSupply),
      subtotal: Value(subtotal),
      discountAmount: Value(discountAmount),
      taxableAmount: Value(taxableAmount),
      cgstAmount: Value(cgstAmount),
      sgstAmount: Value(sgstAmount),
      igstAmount: Value(igstAmount),
      cessAmount: Value(cessAmount),
      totalAmount: Value(totalAmount),
      roundOffAmount: Value(roundOffAmount),
      amountInWords: amountInWords == null && nullToAbsent
          ? const Value.absent()
          : Value(amountInWords),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      terms: terms == null && nullToAbsent
          ? const Value.absent()
          : Value(terms),
      status: Value(status),
      isIgst: Value(isIgst),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      reverseCharge: Value(reverseCharge),
      shipToName: shipToName == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToName),
      shipToAddress: shipToAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToAddress),
      shipToCity: shipToCity == null && nullToAbsent
          ? const Value.absent()
          : Value(shipToCity),
      exportWithLut: Value(exportWithLut),
      tdsSection: tdsSection == null && nullToAbsent
          ? const Value.absent()
          : Value(tdsSection),
      tdsRate: Value(tdsRate),
      tdsAmount: Value(tdsAmount),
      tcsSection: tcsSection == null && nullToAbsent
          ? const Value.absent()
          : Value(tcsSection),
      tcsRate: Value(tcsRate),
      tcsAmount: Value(tcsAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Quote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Quote(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      invoiceNumber: serializer.fromJson<String>(json['invoiceNumber']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      invoiceDate: serializer.fromJson<DateTime>(json['invoiceDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      invoiceType: serializer.fromJson<String>(json['invoiceType']),
      supplyType: serializer.fromJson<String>(json['supplyType']),
      placeOfSupply: serializer.fromJson<int>(json['placeOfSupply']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      discountAmount: serializer.fromJson<double>(json['discountAmount']),
      taxableAmount: serializer.fromJson<double>(json['taxableAmount']),
      cgstAmount: serializer.fromJson<double>(json['cgstAmount']),
      sgstAmount: serializer.fromJson<double>(json['sgstAmount']),
      igstAmount: serializer.fromJson<double>(json['igstAmount']),
      cessAmount: serializer.fromJson<double>(json['cessAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      roundOffAmount: serializer.fromJson<double>(json['roundOffAmount']),
      amountInWords: serializer.fromJson<String?>(json['amountInWords']),
      notes: serializer.fromJson<String?>(json['notes']),
      terms: serializer.fromJson<String?>(json['terms']),
      status: serializer.fromJson<String>(json['status']),
      isIgst: serializer.fromJson<bool>(json['isIgst']),
      templateId: serializer.fromJson<int?>(json['templateId']),
      reverseCharge: serializer.fromJson<bool>(json['reverseCharge']),
      shipToName: serializer.fromJson<String?>(json['shipToName']),
      shipToAddress: serializer.fromJson<String?>(json['shipToAddress']),
      shipToCity: serializer.fromJson<String?>(json['shipToCity']),
      exportWithLut: serializer.fromJson<bool>(json['exportWithLut']),
      tdsSection: serializer.fromJson<String?>(json['tdsSection']),
      tdsRate: serializer.fromJson<double>(json['tdsRate']),
      tdsAmount: serializer.fromJson<double>(json['tdsAmount']),
      tcsSection: serializer.fromJson<String?>(json['tcsSection']),
      tcsRate: serializer.fromJson<double>(json['tcsRate']),
      tcsAmount: serializer.fromJson<double>(json['tcsAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'customerId': serializer.toJson<int>(customerId),
      'invoiceNumber': serializer.toJson<String>(invoiceNumber),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'invoiceDate': serializer.toJson<DateTime>(invoiceDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'invoiceType': serializer.toJson<String>(invoiceType),
      'supplyType': serializer.toJson<String>(supplyType),
      'placeOfSupply': serializer.toJson<int>(placeOfSupply),
      'subtotal': serializer.toJson<double>(subtotal),
      'discountAmount': serializer.toJson<double>(discountAmount),
      'taxableAmount': serializer.toJson<double>(taxableAmount),
      'cgstAmount': serializer.toJson<double>(cgstAmount),
      'sgstAmount': serializer.toJson<double>(sgstAmount),
      'igstAmount': serializer.toJson<double>(igstAmount),
      'cessAmount': serializer.toJson<double>(cessAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'roundOffAmount': serializer.toJson<double>(roundOffAmount),
      'amountInWords': serializer.toJson<String?>(amountInWords),
      'notes': serializer.toJson<String?>(notes),
      'terms': serializer.toJson<String?>(terms),
      'status': serializer.toJson<String>(status),
      'isIgst': serializer.toJson<bool>(isIgst),
      'templateId': serializer.toJson<int?>(templateId),
      'reverseCharge': serializer.toJson<bool>(reverseCharge),
      'shipToName': serializer.toJson<String?>(shipToName),
      'shipToAddress': serializer.toJson<String?>(shipToAddress),
      'shipToCity': serializer.toJson<String?>(shipToCity),
      'exportWithLut': serializer.toJson<bool>(exportWithLut),
      'tdsSection': serializer.toJson<String?>(tdsSection),
      'tdsRate': serializer.toJson<double>(tdsRate),
      'tdsAmount': serializer.toJson<double>(tdsAmount),
      'tcsSection': serializer.toJson<String?>(tcsSection),
      'tcsRate': serializer.toJson<double>(tcsRate),
      'tcsAmount': serializer.toJson<double>(tcsAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Quote copyWith({
    int? id,
    int? businessId,
    int? customerId,
    String? invoiceNumber,
    String? currencyCode,
    DateTime? invoiceDate,
    Value<DateTime?> dueDate = const Value.absent(),
    String? invoiceType,
    String? supplyType,
    int? placeOfSupply,
    double? subtotal,
    double? discountAmount,
    double? taxableAmount,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
    double? totalAmount,
    double? roundOffAmount,
    Value<String?> amountInWords = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<String?> terms = const Value.absent(),
    String? status,
    bool? isIgst,
    Value<int?> templateId = const Value.absent(),
    bool? reverseCharge,
    Value<String?> shipToName = const Value.absent(),
    Value<String?> shipToAddress = const Value.absent(),
    Value<String?> shipToCity = const Value.absent(),
    bool? exportWithLut,
    Value<String?> tdsSection = const Value.absent(),
    double? tdsRate,
    double? tdsAmount,
    Value<String?> tcsSection = const Value.absent(),
    double? tcsRate,
    double? tcsAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Quote(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    customerId: customerId ?? this.customerId,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    currencyCode: currencyCode ?? this.currencyCode,
    invoiceDate: invoiceDate ?? this.invoiceDate,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    invoiceType: invoiceType ?? this.invoiceType,
    supplyType: supplyType ?? this.supplyType,
    placeOfSupply: placeOfSupply ?? this.placeOfSupply,
    subtotal: subtotal ?? this.subtotal,
    discountAmount: discountAmount ?? this.discountAmount,
    taxableAmount: taxableAmount ?? this.taxableAmount,
    cgstAmount: cgstAmount ?? this.cgstAmount,
    sgstAmount: sgstAmount ?? this.sgstAmount,
    igstAmount: igstAmount ?? this.igstAmount,
    cessAmount: cessAmount ?? this.cessAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    roundOffAmount: roundOffAmount ?? this.roundOffAmount,
    amountInWords: amountInWords.present
        ? amountInWords.value
        : this.amountInWords,
    notes: notes.present ? notes.value : this.notes,
    terms: terms.present ? terms.value : this.terms,
    status: status ?? this.status,
    isIgst: isIgst ?? this.isIgst,
    templateId: templateId.present ? templateId.value : this.templateId,
    reverseCharge: reverseCharge ?? this.reverseCharge,
    shipToName: shipToName.present ? shipToName.value : this.shipToName,
    shipToAddress: shipToAddress.present
        ? shipToAddress.value
        : this.shipToAddress,
    shipToCity: shipToCity.present ? shipToCity.value : this.shipToCity,
    exportWithLut: exportWithLut ?? this.exportWithLut,
    tdsSection: tdsSection.present ? tdsSection.value : this.tdsSection,
    tdsRate: tdsRate ?? this.tdsRate,
    tdsAmount: tdsAmount ?? this.tdsAmount,
    tcsSection: tcsSection.present ? tcsSection.value : this.tcsSection,
    tcsRate: tcsRate ?? this.tcsRate,
    tcsAmount: tcsAmount ?? this.tcsAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Quote copyWithCompanion(QuotesCompanion data) {
    return Quote(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      invoiceNumber: data.invoiceNumber.present
          ? data.invoiceNumber.value
          : this.invoiceNumber,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      invoiceDate: data.invoiceDate.present
          ? data.invoiceDate.value
          : this.invoiceDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      invoiceType: data.invoiceType.present
          ? data.invoiceType.value
          : this.invoiceType,
      supplyType: data.supplyType.present
          ? data.supplyType.value
          : this.supplyType,
      placeOfSupply: data.placeOfSupply.present
          ? data.placeOfSupply.value
          : this.placeOfSupply,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      discountAmount: data.discountAmount.present
          ? data.discountAmount.value
          : this.discountAmount,
      taxableAmount: data.taxableAmount.present
          ? data.taxableAmount.value
          : this.taxableAmount,
      cgstAmount: data.cgstAmount.present
          ? data.cgstAmount.value
          : this.cgstAmount,
      sgstAmount: data.sgstAmount.present
          ? data.sgstAmount.value
          : this.sgstAmount,
      igstAmount: data.igstAmount.present
          ? data.igstAmount.value
          : this.igstAmount,
      cessAmount: data.cessAmount.present
          ? data.cessAmount.value
          : this.cessAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      roundOffAmount: data.roundOffAmount.present
          ? data.roundOffAmount.value
          : this.roundOffAmount,
      amountInWords: data.amountInWords.present
          ? data.amountInWords.value
          : this.amountInWords,
      notes: data.notes.present ? data.notes.value : this.notes,
      terms: data.terms.present ? data.terms.value : this.terms,
      status: data.status.present ? data.status.value : this.status,
      isIgst: data.isIgst.present ? data.isIgst.value : this.isIgst,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      reverseCharge: data.reverseCharge.present
          ? data.reverseCharge.value
          : this.reverseCharge,
      shipToName: data.shipToName.present
          ? data.shipToName.value
          : this.shipToName,
      shipToAddress: data.shipToAddress.present
          ? data.shipToAddress.value
          : this.shipToAddress,
      shipToCity: data.shipToCity.present
          ? data.shipToCity.value
          : this.shipToCity,
      exportWithLut: data.exportWithLut.present
          ? data.exportWithLut.value
          : this.exportWithLut,
      tdsSection: data.tdsSection.present
          ? data.tdsSection.value
          : this.tdsSection,
      tdsRate: data.tdsRate.present ? data.tdsRate.value : this.tdsRate,
      tdsAmount: data.tdsAmount.present ? data.tdsAmount.value : this.tdsAmount,
      tcsSection: data.tcsSection.present
          ? data.tcsSection.value
          : this.tcsSection,
      tcsRate: data.tcsRate.present ? data.tcsRate.value : this.tcsRate,
      tcsAmount: data.tcsAmount.present ? data.tcsAmount.value : this.tcsAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Quote(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('supplyType: $supplyType, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('roundOffAmount: $roundOffAmount, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('notes: $notes, ')
          ..write('terms: $terms, ')
          ..write('status: $status, ')
          ..write('isIgst: $isIgst, ')
          ..write('templateId: $templateId, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('shipToName: $shipToName, ')
          ..write('shipToAddress: $shipToAddress, ')
          ..write('shipToCity: $shipToCity, ')
          ..write('exportWithLut: $exportWithLut, ')
          ..write('tdsSection: $tdsSection, ')
          ..write('tdsRate: $tdsRate, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsSection: $tcsSection, ')
          ..write('tcsRate: $tcsRate, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    businessId,
    customerId,
    invoiceNumber,
    currencyCode,
    invoiceDate,
    dueDate,
    invoiceType,
    supplyType,
    placeOfSupply,
    subtotal,
    discountAmount,
    taxableAmount,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    roundOffAmount,
    amountInWords,
    notes,
    terms,
    status,
    isIgst,
    templateId,
    reverseCharge,
    shipToName,
    shipToAddress,
    shipToCity,
    exportWithLut,
    tdsSection,
    tdsRate,
    tdsAmount,
    tcsSection,
    tcsRate,
    tcsAmount,
    createdAt,
    updatedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.customerId == this.customerId &&
          other.invoiceNumber == this.invoiceNumber &&
          other.currencyCode == this.currencyCode &&
          other.invoiceDate == this.invoiceDate &&
          other.dueDate == this.dueDate &&
          other.invoiceType == this.invoiceType &&
          other.supplyType == this.supplyType &&
          other.placeOfSupply == this.placeOfSupply &&
          other.subtotal == this.subtotal &&
          other.discountAmount == this.discountAmount &&
          other.taxableAmount == this.taxableAmount &&
          other.cgstAmount == this.cgstAmount &&
          other.sgstAmount == this.sgstAmount &&
          other.igstAmount == this.igstAmount &&
          other.cessAmount == this.cessAmount &&
          other.totalAmount == this.totalAmount &&
          other.roundOffAmount == this.roundOffAmount &&
          other.amountInWords == this.amountInWords &&
          other.notes == this.notes &&
          other.terms == this.terms &&
          other.status == this.status &&
          other.isIgst == this.isIgst &&
          other.templateId == this.templateId &&
          other.reverseCharge == this.reverseCharge &&
          other.shipToName == this.shipToName &&
          other.shipToAddress == this.shipToAddress &&
          other.shipToCity == this.shipToCity &&
          other.exportWithLut == this.exportWithLut &&
          other.tdsSection == this.tdsSection &&
          other.tdsRate == this.tdsRate &&
          other.tdsAmount == this.tdsAmount &&
          other.tcsSection == this.tcsSection &&
          other.tcsRate == this.tcsRate &&
          other.tcsAmount == this.tcsAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class QuotesCompanion extends UpdateCompanion<Quote> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<int> customerId;
  final Value<String> invoiceNumber;
  final Value<String> currencyCode;
  final Value<DateTime> invoiceDate;
  final Value<DateTime?> dueDate;
  final Value<String> invoiceType;
  final Value<String> supplyType;
  final Value<int> placeOfSupply;
  final Value<double> subtotal;
  final Value<double> discountAmount;
  final Value<double> taxableAmount;
  final Value<double> cgstAmount;
  final Value<double> sgstAmount;
  final Value<double> igstAmount;
  final Value<double> cessAmount;
  final Value<double> totalAmount;
  final Value<double> roundOffAmount;
  final Value<String?> amountInWords;
  final Value<String?> notes;
  final Value<String?> terms;
  final Value<String> status;
  final Value<bool> isIgst;
  final Value<int?> templateId;
  final Value<bool> reverseCharge;
  final Value<String?> shipToName;
  final Value<String?> shipToAddress;
  final Value<String?> shipToCity;
  final Value<bool> exportWithLut;
  final Value<String?> tdsSection;
  final Value<double> tdsRate;
  final Value<double> tdsAmount;
  final Value<String?> tcsSection;
  final Value<double> tcsRate;
  final Value<double> tcsAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.invoiceNumber = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.invoiceDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.invoiceType = const Value.absent(),
    this.supplyType = const Value.absent(),
    this.placeOfSupply = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.discountAmount = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.roundOffAmount = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.notes = const Value.absent(),
    this.terms = const Value.absent(),
    this.status = const Value.absent(),
    this.isIgst = const Value.absent(),
    this.templateId = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    this.shipToName = const Value.absent(),
    this.shipToAddress = const Value.absent(),
    this.shipToCity = const Value.absent(),
    this.exportWithLut = const Value.absent(),
    this.tdsSection = const Value.absent(),
    this.tdsRate = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsSection = const Value.absent(),
    this.tcsRate = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required int customerId,
    required String invoiceNumber,
    this.currencyCode = const Value.absent(),
    required DateTime invoiceDate,
    this.dueDate = const Value.absent(),
    required String invoiceType,
    required String supplyType,
    required int placeOfSupply,
    required double subtotal,
    this.discountAmount = const Value.absent(),
    required double taxableAmount,
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    required double totalAmount,
    this.roundOffAmount = const Value.absent(),
    this.amountInWords = const Value.absent(),
    this.notes = const Value.absent(),
    this.terms = const Value.absent(),
    this.status = const Value.absent(),
    this.isIgst = const Value.absent(),
    this.templateId = const Value.absent(),
    this.reverseCharge = const Value.absent(),
    this.shipToName = const Value.absent(),
    this.shipToAddress = const Value.absent(),
    this.shipToCity = const Value.absent(),
    this.exportWithLut = const Value.absent(),
    this.tdsSection = const Value.absent(),
    this.tdsRate = const Value.absent(),
    this.tdsAmount = const Value.absent(),
    this.tcsSection = const Value.absent(),
    this.tcsRate = const Value.absent(),
    this.tcsAmount = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : businessId = Value(businessId),
       customerId = Value(customerId),
       invoiceNumber = Value(invoiceNumber),
       invoiceDate = Value(invoiceDate),
       invoiceType = Value(invoiceType),
       supplyType = Value(supplyType),
       placeOfSupply = Value(placeOfSupply),
       subtotal = Value(subtotal),
       taxableAmount = Value(taxableAmount),
       totalAmount = Value(totalAmount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Quote> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<int>? customerId,
    Expression<String>? invoiceNumber,
    Expression<String>? currencyCode,
    Expression<DateTime>? invoiceDate,
    Expression<DateTime>? dueDate,
    Expression<String>? invoiceType,
    Expression<String>? supplyType,
    Expression<int>? placeOfSupply,
    Expression<double>? subtotal,
    Expression<double>? discountAmount,
    Expression<double>? taxableAmount,
    Expression<double>? cgstAmount,
    Expression<double>? sgstAmount,
    Expression<double>? igstAmount,
    Expression<double>? cessAmount,
    Expression<double>? totalAmount,
    Expression<double>? roundOffAmount,
    Expression<String>? amountInWords,
    Expression<String>? notes,
    Expression<String>? terms,
    Expression<String>? status,
    Expression<bool>? isIgst,
    Expression<int>? templateId,
    Expression<bool>? reverseCharge,
    Expression<String>? shipToName,
    Expression<String>? shipToAddress,
    Expression<String>? shipToCity,
    Expression<bool>? exportWithLut,
    Expression<String>? tdsSection,
    Expression<double>? tdsRate,
    Expression<double>? tdsAmount,
    Expression<String>? tcsSection,
    Expression<double>? tcsRate,
    Expression<double>? tcsAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (customerId != null) 'customer_id': customerId,
      if (invoiceNumber != null) 'invoice_number': invoiceNumber,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (invoiceDate != null) 'invoice_date': invoiceDate,
      if (dueDate != null) 'due_date': dueDate,
      if (invoiceType != null) 'invoice_type': invoiceType,
      if (supplyType != null) 'supply_type': supplyType,
      if (placeOfSupply != null) 'place_of_supply': placeOfSupply,
      if (subtotal != null) 'subtotal': subtotal,
      if (discountAmount != null) 'discount_amount': discountAmount,
      if (taxableAmount != null) 'taxable_amount': taxableAmount,
      if (cgstAmount != null) 'cgst_amount': cgstAmount,
      if (sgstAmount != null) 'sgst_amount': sgstAmount,
      if (igstAmount != null) 'igst_amount': igstAmount,
      if (cessAmount != null) 'cess_amount': cessAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (roundOffAmount != null) 'round_off_amount': roundOffAmount,
      if (amountInWords != null) 'amount_in_words': amountInWords,
      if (notes != null) 'notes': notes,
      if (terms != null) 'terms': terms,
      if (status != null) 'status': status,
      if (isIgst != null) 'is_igst': isIgst,
      if (templateId != null) 'template_id': templateId,
      if (reverseCharge != null) 'reverse_charge': reverseCharge,
      if (shipToName != null) 'ship_to_name': shipToName,
      if (shipToAddress != null) 'ship_to_address': shipToAddress,
      if (shipToCity != null) 'ship_to_city': shipToCity,
      if (exportWithLut != null) 'export_with_lut': exportWithLut,
      if (tdsSection != null) 'tds_section': tdsSection,
      if (tdsRate != null) 'tds_rate': tdsRate,
      if (tdsAmount != null) 'tds_amount': tdsAmount,
      if (tcsSection != null) 'tcs_section': tcsSection,
      if (tcsRate != null) 'tcs_rate': tcsRate,
      if (tcsAmount != null) 'tcs_amount': tcsAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QuotesCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<int>? customerId,
    Value<String>? invoiceNumber,
    Value<String>? currencyCode,
    Value<DateTime>? invoiceDate,
    Value<DateTime?>? dueDate,
    Value<String>? invoiceType,
    Value<String>? supplyType,
    Value<int>? placeOfSupply,
    Value<double>? subtotal,
    Value<double>? discountAmount,
    Value<double>? taxableAmount,
    Value<double>? cgstAmount,
    Value<double>? sgstAmount,
    Value<double>? igstAmount,
    Value<double>? cessAmount,
    Value<double>? totalAmount,
    Value<double>? roundOffAmount,
    Value<String?>? amountInWords,
    Value<String?>? notes,
    Value<String?>? terms,
    Value<String>? status,
    Value<bool>? isIgst,
    Value<int?>? templateId,
    Value<bool>? reverseCharge,
    Value<String?>? shipToName,
    Value<String?>? shipToAddress,
    Value<String?>? shipToCity,
    Value<bool>? exportWithLut,
    Value<String?>? tdsSection,
    Value<double>? tdsRate,
    Value<double>? tdsAmount,
    Value<String?>? tcsSection,
    Value<double>? tcsRate,
    Value<double>? tcsAmount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      customerId: customerId ?? this.customerId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      currencyCode: currencyCode ?? this.currencyCode,
      invoiceDate: invoiceDate ?? this.invoiceDate,
      dueDate: dueDate ?? this.dueDate,
      invoiceType: invoiceType ?? this.invoiceType,
      supplyType: supplyType ?? this.supplyType,
      placeOfSupply: placeOfSupply ?? this.placeOfSupply,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      roundOffAmount: roundOffAmount ?? this.roundOffAmount,
      amountInWords: amountInWords ?? this.amountInWords,
      notes: notes ?? this.notes,
      terms: terms ?? this.terms,
      status: status ?? this.status,
      isIgst: isIgst ?? this.isIgst,
      templateId: templateId ?? this.templateId,
      reverseCharge: reverseCharge ?? this.reverseCharge,
      shipToName: shipToName ?? this.shipToName,
      shipToAddress: shipToAddress ?? this.shipToAddress,
      shipToCity: shipToCity ?? this.shipToCity,
      exportWithLut: exportWithLut ?? this.exportWithLut,
      tdsSection: tdsSection ?? this.tdsSection,
      tdsRate: tdsRate ?? this.tdsRate,
      tdsAmount: tdsAmount ?? this.tdsAmount,
      tcsSection: tcsSection ?? this.tcsSection,
      tcsRate: tcsRate ?? this.tcsRate,
      tcsAmount: tcsAmount ?? this.tcsAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (invoiceNumber.present) {
      map['invoice_number'] = Variable<String>(invoiceNumber.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (invoiceDate.present) {
      map['invoice_date'] = Variable<DateTime>(invoiceDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (invoiceType.present) {
      map['invoice_type'] = Variable<String>(invoiceType.value);
    }
    if (supplyType.present) {
      map['supply_type'] = Variable<String>(supplyType.value);
    }
    if (placeOfSupply.present) {
      map['place_of_supply'] = Variable<int>(placeOfSupply.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (discountAmount.present) {
      map['discount_amount'] = Variable<double>(discountAmount.value);
    }
    if (taxableAmount.present) {
      map['taxable_amount'] = Variable<double>(taxableAmount.value);
    }
    if (cgstAmount.present) {
      map['cgst_amount'] = Variable<double>(cgstAmount.value);
    }
    if (sgstAmount.present) {
      map['sgst_amount'] = Variable<double>(sgstAmount.value);
    }
    if (igstAmount.present) {
      map['igst_amount'] = Variable<double>(igstAmount.value);
    }
    if (cessAmount.present) {
      map['cess_amount'] = Variable<double>(cessAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (roundOffAmount.present) {
      map['round_off_amount'] = Variable<double>(roundOffAmount.value);
    }
    if (amountInWords.present) {
      map['amount_in_words'] = Variable<String>(amountInWords.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (terms.present) {
      map['terms'] = Variable<String>(terms.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (isIgst.present) {
      map['is_igst'] = Variable<bool>(isIgst.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (reverseCharge.present) {
      map['reverse_charge'] = Variable<bool>(reverseCharge.value);
    }
    if (shipToName.present) {
      map['ship_to_name'] = Variable<String>(shipToName.value);
    }
    if (shipToAddress.present) {
      map['ship_to_address'] = Variable<String>(shipToAddress.value);
    }
    if (shipToCity.present) {
      map['ship_to_city'] = Variable<String>(shipToCity.value);
    }
    if (exportWithLut.present) {
      map['export_with_lut'] = Variable<bool>(exportWithLut.value);
    }
    if (tdsSection.present) {
      map['tds_section'] = Variable<String>(tdsSection.value);
    }
    if (tdsRate.present) {
      map['tds_rate'] = Variable<double>(tdsRate.value);
    }
    if (tdsAmount.present) {
      map['tds_amount'] = Variable<double>(tdsAmount.value);
    }
    if (tcsSection.present) {
      map['tcs_section'] = Variable<String>(tcsSection.value);
    }
    if (tcsRate.present) {
      map['tcs_rate'] = Variable<double>(tcsRate.value);
    }
    if (tcsAmount.present) {
      map['tcs_amount'] = Variable<double>(tcsAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('customerId: $customerId, ')
          ..write('invoiceNumber: $invoiceNumber, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('invoiceDate: $invoiceDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('invoiceType: $invoiceType, ')
          ..write('supplyType: $supplyType, ')
          ..write('placeOfSupply: $placeOfSupply, ')
          ..write('subtotal: $subtotal, ')
          ..write('discountAmount: $discountAmount, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('roundOffAmount: $roundOffAmount, ')
          ..write('amountInWords: $amountInWords, ')
          ..write('notes: $notes, ')
          ..write('terms: $terms, ')
          ..write('status: $status, ')
          ..write('isIgst: $isIgst, ')
          ..write('templateId: $templateId, ')
          ..write('reverseCharge: $reverseCharge, ')
          ..write('shipToName: $shipToName, ')
          ..write('shipToAddress: $shipToAddress, ')
          ..write('shipToCity: $shipToCity, ')
          ..write('exportWithLut: $exportWithLut, ')
          ..write('tdsSection: $tdsSection, ')
          ..write('tdsRate: $tdsRate, ')
          ..write('tdsAmount: $tdsAmount, ')
          ..write('tcsSection: $tcsSection, ')
          ..write('tcsRate: $tcsRate, ')
          ..write('tcsAmount: $tcsAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QuoteItemsTable extends QuoteItems
    with TableInfo<$QuoteItemsTable, QuoteItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuoteItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _quoteIdMeta = const VerificationMeta(
    'quoteId',
  );
  @override
  late final GeneratedColumn<int> quoteId = GeneratedColumn<int>(
    'quote_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES quotes (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hsnSacMeta = const VerificationMeta('hsnSac');
  @override
  late final GeneratedColumn<String> hsnSac = GeneratedColumn<String>(
    'hsn_sac',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rateMeta = const VerificationMeta('rate');
  @override
  late final GeneratedColumn<double> rate = GeneratedColumn<double>(
    'rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _discountPctMeta = const VerificationMeta(
    'discountPct',
  );
  @override
  late final GeneratedColumn<double> discountPct = GeneratedColumn<double>(
    'discount_pct',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _taxableAmountMeta = const VerificationMeta(
    'taxableAmount',
  );
  @override
  late final GeneratedColumn<double> taxableAmount = GeneratedColumn<double>(
    'taxable_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstRateMeta = const VerificationMeta(
    'gstRate',
  );
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
    'gst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cgstRateMeta = const VerificationMeta(
    'cgstRate',
  );
  @override
  late final GeneratedColumn<double> cgstRate = GeneratedColumn<double>(
    'cgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstRateMeta = const VerificationMeta(
    'sgstRate',
  );
  @override
  late final GeneratedColumn<double> sgstRate = GeneratedColumn<double>(
    'sgst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstRateMeta = const VerificationMeta(
    'igstRate',
  );
  @override
  late final GeneratedColumn<double> igstRate = GeneratedColumn<double>(
    'igst_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessRateMeta = const VerificationMeta(
    'cessRate',
  );
  @override
  late final GeneratedColumn<double> cessRate = GeneratedColumn<double>(
    'cess_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cgstAmountMeta = const VerificationMeta(
    'cgstAmount',
  );
  @override
  late final GeneratedColumn<double> cgstAmount = GeneratedColumn<double>(
    'cgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sgstAmountMeta = const VerificationMeta(
    'sgstAmount',
  );
  @override
  late final GeneratedColumn<double> sgstAmount = GeneratedColumn<double>(
    'sgst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _igstAmountMeta = const VerificationMeta(
    'igstAmount',
  );
  @override
  late final GeneratedColumn<double> igstAmount = GeneratedColumn<double>(
    'igst_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _cessAmountMeta = const VerificationMeta(
    'cessAmount',
  );
  @override
  late final GeneratedColumn<double> cessAmount = GeneratedColumn<double>(
    'cess_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    quoteId,
    productId,
    name,
    hsnSac,
    unit,
    quantity,
    rate,
    discountPct,
    taxableAmount,
    gstRate,
    cgstRate,
    sgstRate,
    igstRate,
    cessRate,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quote_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('quote_id')) {
      context.handle(
        _quoteIdMeta,
        quoteId.isAcceptableOrUnknown(data['quote_id']!, _quoteIdMeta),
      );
    } else if (isInserting) {
      context.missing(_quoteIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('hsn_sac')) {
      context.handle(
        _hsnSacMeta,
        hsnSac.isAcceptableOrUnknown(data['hsn_sac']!, _hsnSacMeta),
      );
    } else if (isInserting) {
      context.missing(_hsnSacMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('rate')) {
      context.handle(
        _rateMeta,
        rate.isAcceptableOrUnknown(data['rate']!, _rateMeta),
      );
    } else if (isInserting) {
      context.missing(_rateMeta);
    }
    if (data.containsKey('discount_pct')) {
      context.handle(
        _discountPctMeta,
        discountPct.isAcceptableOrUnknown(
          data['discount_pct']!,
          _discountPctMeta,
        ),
      );
    }
    if (data.containsKey('taxable_amount')) {
      context.handle(
        _taxableAmountMeta,
        taxableAmount.isAcceptableOrUnknown(
          data['taxable_amount']!,
          _taxableAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_taxableAmountMeta);
    }
    if (data.containsKey('gst_rate')) {
      context.handle(
        _gstRateMeta,
        gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta),
      );
    } else if (isInserting) {
      context.missing(_gstRateMeta);
    }
    if (data.containsKey('cgst_rate')) {
      context.handle(
        _cgstRateMeta,
        cgstRate.isAcceptableOrUnknown(data['cgst_rate']!, _cgstRateMeta),
      );
    }
    if (data.containsKey('sgst_rate')) {
      context.handle(
        _sgstRateMeta,
        sgstRate.isAcceptableOrUnknown(data['sgst_rate']!, _sgstRateMeta),
      );
    }
    if (data.containsKey('igst_rate')) {
      context.handle(
        _igstRateMeta,
        igstRate.isAcceptableOrUnknown(data['igst_rate']!, _igstRateMeta),
      );
    }
    if (data.containsKey('cess_rate')) {
      context.handle(
        _cessRateMeta,
        cessRate.isAcceptableOrUnknown(data['cess_rate']!, _cessRateMeta),
      );
    }
    if (data.containsKey('cgst_amount')) {
      context.handle(
        _cgstAmountMeta,
        cgstAmount.isAcceptableOrUnknown(data['cgst_amount']!, _cgstAmountMeta),
      );
    }
    if (data.containsKey('sgst_amount')) {
      context.handle(
        _sgstAmountMeta,
        sgstAmount.isAcceptableOrUnknown(data['sgst_amount']!, _sgstAmountMeta),
      );
    }
    if (data.containsKey('igst_amount')) {
      context.handle(
        _igstAmountMeta,
        igstAmount.isAcceptableOrUnknown(data['igst_amount']!, _igstAmountMeta),
      );
    }
    if (data.containsKey('cess_amount')) {
      context.handle(
        _cessAmountMeta,
        cessAmount.isAcceptableOrUnknown(data['cess_amount']!, _cessAmountMeta),
      );
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      quoteId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quote_id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      hsnSac: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}hsn_sac'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      rate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rate'],
      )!,
      discountPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}discount_pct'],
      )!,
      taxableAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}taxable_amount'],
      )!,
      gstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate'],
      )!,
      cgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_rate'],
      )!,
      sgstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_rate'],
      )!,
      igstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_rate'],
      )!,
      cessRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_rate'],
      )!,
      cgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cgst_amount'],
      )!,
      sgstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sgst_amount'],
      )!,
      igstAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}igst_amount'],
      )!,
      cessAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cess_amount'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $QuoteItemsTable createAlias(String alias) {
    return $QuoteItemsTable(attachedDatabase, alias);
  }
}

class QuoteItem extends DataClass implements Insertable<QuoteItem> {
  final int id;
  final int quoteId;
  final int? productId;
  final String name;
  final String hsnSac;
  final String unit;
  final double quantity;
  final double rate;
  final double discountPct;
  final double taxableAmount;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;
  final int sortOrder;
  const QuoteItem({
    required this.id,
    required this.quoteId,
    this.productId,
    required this.name,
    required this.hsnSac,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.discountPct,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['quote_id'] = Variable<int>(quoteId);
    if (!nullToAbsent || productId != null) {
      map['product_id'] = Variable<int>(productId);
    }
    map['name'] = Variable<String>(name);
    map['hsn_sac'] = Variable<String>(hsnSac);
    map['unit'] = Variable<String>(unit);
    map['quantity'] = Variable<double>(quantity);
    map['rate'] = Variable<double>(rate);
    map['discount_pct'] = Variable<double>(discountPct);
    map['taxable_amount'] = Variable<double>(taxableAmount);
    map['gst_rate'] = Variable<double>(gstRate);
    map['cgst_rate'] = Variable<double>(cgstRate);
    map['sgst_rate'] = Variable<double>(sgstRate);
    map['igst_rate'] = Variable<double>(igstRate);
    map['cess_rate'] = Variable<double>(cessRate);
    map['cgst_amount'] = Variable<double>(cgstAmount);
    map['sgst_amount'] = Variable<double>(sgstAmount);
    map['igst_amount'] = Variable<double>(igstAmount);
    map['cess_amount'] = Variable<double>(cessAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  QuoteItemsCompanion toCompanion(bool nullToAbsent) {
    return QuoteItemsCompanion(
      id: Value(id),
      quoteId: Value(quoteId),
      productId: productId == null && nullToAbsent
          ? const Value.absent()
          : Value(productId),
      name: Value(name),
      hsnSac: Value(hsnSac),
      unit: Value(unit),
      quantity: Value(quantity),
      rate: Value(rate),
      discountPct: Value(discountPct),
      taxableAmount: Value(taxableAmount),
      gstRate: Value(gstRate),
      cgstRate: Value(cgstRate),
      sgstRate: Value(sgstRate),
      igstRate: Value(igstRate),
      cessRate: Value(cessRate),
      cgstAmount: Value(cgstAmount),
      sgstAmount: Value(sgstAmount),
      igstAmount: Value(igstAmount),
      cessAmount: Value(cessAmount),
      totalAmount: Value(totalAmount),
      sortOrder: Value(sortOrder),
    );
  }

  factory QuoteItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteItem(
      id: serializer.fromJson<int>(json['id']),
      quoteId: serializer.fromJson<int>(json['quoteId']),
      productId: serializer.fromJson<int?>(json['productId']),
      name: serializer.fromJson<String>(json['name']),
      hsnSac: serializer.fromJson<String>(json['hsnSac']),
      unit: serializer.fromJson<String>(json['unit']),
      quantity: serializer.fromJson<double>(json['quantity']),
      rate: serializer.fromJson<double>(json['rate']),
      discountPct: serializer.fromJson<double>(json['discountPct']),
      taxableAmount: serializer.fromJson<double>(json['taxableAmount']),
      gstRate: serializer.fromJson<double>(json['gstRate']),
      cgstRate: serializer.fromJson<double>(json['cgstRate']),
      sgstRate: serializer.fromJson<double>(json['sgstRate']),
      igstRate: serializer.fromJson<double>(json['igstRate']),
      cessRate: serializer.fromJson<double>(json['cessRate']),
      cgstAmount: serializer.fromJson<double>(json['cgstAmount']),
      sgstAmount: serializer.fromJson<double>(json['sgstAmount']),
      igstAmount: serializer.fromJson<double>(json['igstAmount']),
      cessAmount: serializer.fromJson<double>(json['cessAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'quoteId': serializer.toJson<int>(quoteId),
      'productId': serializer.toJson<int?>(productId),
      'name': serializer.toJson<String>(name),
      'hsnSac': serializer.toJson<String>(hsnSac),
      'unit': serializer.toJson<String>(unit),
      'quantity': serializer.toJson<double>(quantity),
      'rate': serializer.toJson<double>(rate),
      'discountPct': serializer.toJson<double>(discountPct),
      'taxableAmount': serializer.toJson<double>(taxableAmount),
      'gstRate': serializer.toJson<double>(gstRate),
      'cgstRate': serializer.toJson<double>(cgstRate),
      'sgstRate': serializer.toJson<double>(sgstRate),
      'igstRate': serializer.toJson<double>(igstRate),
      'cessRate': serializer.toJson<double>(cessRate),
      'cgstAmount': serializer.toJson<double>(cgstAmount),
      'sgstAmount': serializer.toJson<double>(sgstAmount),
      'igstAmount': serializer.toJson<double>(igstAmount),
      'cessAmount': serializer.toJson<double>(cessAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  QuoteItem copyWith({
    int? id,
    int? quoteId,
    Value<int?> productId = const Value.absent(),
    String? name,
    String? hsnSac,
    String? unit,
    double? quantity,
    double? rate,
    double? discountPct,
    double? taxableAmount,
    double? gstRate,
    double? cgstRate,
    double? sgstRate,
    double? igstRate,
    double? cessRate,
    double? cgstAmount,
    double? sgstAmount,
    double? igstAmount,
    double? cessAmount,
    double? totalAmount,
    int? sortOrder,
  }) => QuoteItem(
    id: id ?? this.id,
    quoteId: quoteId ?? this.quoteId,
    productId: productId.present ? productId.value : this.productId,
    name: name ?? this.name,
    hsnSac: hsnSac ?? this.hsnSac,
    unit: unit ?? this.unit,
    quantity: quantity ?? this.quantity,
    rate: rate ?? this.rate,
    discountPct: discountPct ?? this.discountPct,
    taxableAmount: taxableAmount ?? this.taxableAmount,
    gstRate: gstRate ?? this.gstRate,
    cgstRate: cgstRate ?? this.cgstRate,
    sgstRate: sgstRate ?? this.sgstRate,
    igstRate: igstRate ?? this.igstRate,
    cessRate: cessRate ?? this.cessRate,
    cgstAmount: cgstAmount ?? this.cgstAmount,
    sgstAmount: sgstAmount ?? this.sgstAmount,
    igstAmount: igstAmount ?? this.igstAmount,
    cessAmount: cessAmount ?? this.cessAmount,
    totalAmount: totalAmount ?? this.totalAmount,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  QuoteItem copyWithCompanion(QuoteItemsCompanion data) {
    return QuoteItem(
      id: data.id.present ? data.id.value : this.id,
      quoteId: data.quoteId.present ? data.quoteId.value : this.quoteId,
      productId: data.productId.present ? data.productId.value : this.productId,
      name: data.name.present ? data.name.value : this.name,
      hsnSac: data.hsnSac.present ? data.hsnSac.value : this.hsnSac,
      unit: data.unit.present ? data.unit.value : this.unit,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      rate: data.rate.present ? data.rate.value : this.rate,
      discountPct: data.discountPct.present
          ? data.discountPct.value
          : this.discountPct,
      taxableAmount: data.taxableAmount.present
          ? data.taxableAmount.value
          : this.taxableAmount,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      cgstRate: data.cgstRate.present ? data.cgstRate.value : this.cgstRate,
      sgstRate: data.sgstRate.present ? data.sgstRate.value : this.sgstRate,
      igstRate: data.igstRate.present ? data.igstRate.value : this.igstRate,
      cessRate: data.cessRate.present ? data.cessRate.value : this.cessRate,
      cgstAmount: data.cgstAmount.present
          ? data.cgstAmount.value
          : this.cgstAmount,
      sgstAmount: data.sgstAmount.present
          ? data.sgstAmount.value
          : this.sgstAmount,
      igstAmount: data.igstAmount.present
          ? data.igstAmount.value
          : this.igstAmount,
      cessAmount: data.cessAmount.present
          ? data.cessAmount.value
          : this.cessAmount,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItem(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('discountPct: $discountPct, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstRate: $gstRate, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('igstRate: $igstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    quoteId,
    productId,
    name,
    hsnSac,
    unit,
    quantity,
    rate,
    discountPct,
    taxableAmount,
    gstRate,
    cgstRate,
    sgstRate,
    igstRate,
    cessRate,
    cgstAmount,
    sgstAmount,
    igstAmount,
    cessAmount,
    totalAmount,
    sortOrder,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteItem &&
          other.id == this.id &&
          other.quoteId == this.quoteId &&
          other.productId == this.productId &&
          other.name == this.name &&
          other.hsnSac == this.hsnSac &&
          other.unit == this.unit &&
          other.quantity == this.quantity &&
          other.rate == this.rate &&
          other.discountPct == this.discountPct &&
          other.taxableAmount == this.taxableAmount &&
          other.gstRate == this.gstRate &&
          other.cgstRate == this.cgstRate &&
          other.sgstRate == this.sgstRate &&
          other.igstRate == this.igstRate &&
          other.cessRate == this.cessRate &&
          other.cgstAmount == this.cgstAmount &&
          other.sgstAmount == this.sgstAmount &&
          other.igstAmount == this.igstAmount &&
          other.cessAmount == this.cessAmount &&
          other.totalAmount == this.totalAmount &&
          other.sortOrder == this.sortOrder);
}

class QuoteItemsCompanion extends UpdateCompanion<QuoteItem> {
  final Value<int> id;
  final Value<int> quoteId;
  final Value<int?> productId;
  final Value<String> name;
  final Value<String> hsnSac;
  final Value<String> unit;
  final Value<double> quantity;
  final Value<double> rate;
  final Value<double> discountPct;
  final Value<double> taxableAmount;
  final Value<double> gstRate;
  final Value<double> cgstRate;
  final Value<double> sgstRate;
  final Value<double> igstRate;
  final Value<double> cessRate;
  final Value<double> cgstAmount;
  final Value<double> sgstAmount;
  final Value<double> igstAmount;
  final Value<double> cessAmount;
  final Value<double> totalAmount;
  final Value<int> sortOrder;
  const QuoteItemsCompanion({
    this.id = const Value.absent(),
    this.quoteId = const Value.absent(),
    this.productId = const Value.absent(),
    this.name = const Value.absent(),
    this.hsnSac = const Value.absent(),
    this.unit = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rate = const Value.absent(),
    this.discountPct = const Value.absent(),
    this.taxableAmount = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.cgstRate = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.cessRate = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  QuoteItemsCompanion.insert({
    this.id = const Value.absent(),
    required int quoteId,
    this.productId = const Value.absent(),
    required String name,
    required String hsnSac,
    required String unit,
    required double quantity,
    required double rate,
    this.discountPct = const Value.absent(),
    required double taxableAmount,
    required double gstRate,
    this.cgstRate = const Value.absent(),
    this.sgstRate = const Value.absent(),
    this.igstRate = const Value.absent(),
    this.cessRate = const Value.absent(),
    this.cgstAmount = const Value.absent(),
    this.sgstAmount = const Value.absent(),
    this.igstAmount = const Value.absent(),
    this.cessAmount = const Value.absent(),
    required double totalAmount,
    this.sortOrder = const Value.absent(),
  }) : quoteId = Value(quoteId),
       name = Value(name),
       hsnSac = Value(hsnSac),
       unit = Value(unit),
       quantity = Value(quantity),
       rate = Value(rate),
       taxableAmount = Value(taxableAmount),
       gstRate = Value(gstRate),
       totalAmount = Value(totalAmount);
  static Insertable<QuoteItem> custom({
    Expression<int>? id,
    Expression<int>? quoteId,
    Expression<int>? productId,
    Expression<String>? name,
    Expression<String>? hsnSac,
    Expression<String>? unit,
    Expression<double>? quantity,
    Expression<double>? rate,
    Expression<double>? discountPct,
    Expression<double>? taxableAmount,
    Expression<double>? gstRate,
    Expression<double>? cgstRate,
    Expression<double>? sgstRate,
    Expression<double>? igstRate,
    Expression<double>? cessRate,
    Expression<double>? cgstAmount,
    Expression<double>? sgstAmount,
    Expression<double>? igstAmount,
    Expression<double>? cessAmount,
    Expression<double>? totalAmount,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (quoteId != null) 'quote_id': quoteId,
      if (productId != null) 'product_id': productId,
      if (name != null) 'name': name,
      if (hsnSac != null) 'hsn_sac': hsnSac,
      if (unit != null) 'unit': unit,
      if (quantity != null) 'quantity': quantity,
      if (rate != null) 'rate': rate,
      if (discountPct != null) 'discount_pct': discountPct,
      if (taxableAmount != null) 'taxable_amount': taxableAmount,
      if (gstRate != null) 'gst_rate': gstRate,
      if (cgstRate != null) 'cgst_rate': cgstRate,
      if (sgstRate != null) 'sgst_rate': sgstRate,
      if (igstRate != null) 'igst_rate': igstRate,
      if (cessRate != null) 'cess_rate': cessRate,
      if (cgstAmount != null) 'cgst_amount': cgstAmount,
      if (sgstAmount != null) 'sgst_amount': sgstAmount,
      if (igstAmount != null) 'igst_amount': igstAmount,
      if (cessAmount != null) 'cess_amount': cessAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  QuoteItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? quoteId,
    Value<int?>? productId,
    Value<String>? name,
    Value<String>? hsnSac,
    Value<String>? unit,
    Value<double>? quantity,
    Value<double>? rate,
    Value<double>? discountPct,
    Value<double>? taxableAmount,
    Value<double>? gstRate,
    Value<double>? cgstRate,
    Value<double>? sgstRate,
    Value<double>? igstRate,
    Value<double>? cessRate,
    Value<double>? cgstAmount,
    Value<double>? sgstAmount,
    Value<double>? igstAmount,
    Value<double>? cessAmount,
    Value<double>? totalAmount,
    Value<int>? sortOrder,
  }) {
    return QuoteItemsCompanion(
      id: id ?? this.id,
      quoteId: quoteId ?? this.quoteId,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      hsnSac: hsnSac ?? this.hsnSac,
      unit: unit ?? this.unit,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      discountPct: discountPct ?? this.discountPct,
      taxableAmount: taxableAmount ?? this.taxableAmount,
      gstRate: gstRate ?? this.gstRate,
      cgstRate: cgstRate ?? this.cgstRate,
      sgstRate: sgstRate ?? this.sgstRate,
      igstRate: igstRate ?? this.igstRate,
      cessRate: cessRate ?? this.cessRate,
      cgstAmount: cgstAmount ?? this.cgstAmount,
      sgstAmount: sgstAmount ?? this.sgstAmount,
      igstAmount: igstAmount ?? this.igstAmount,
      cessAmount: cessAmount ?? this.cessAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (quoteId.present) {
      map['quote_id'] = Variable<int>(quoteId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (hsnSac.present) {
      map['hsn_sac'] = Variable<String>(hsnSac.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (rate.present) {
      map['rate'] = Variable<double>(rate.value);
    }
    if (discountPct.present) {
      map['discount_pct'] = Variable<double>(discountPct.value);
    }
    if (taxableAmount.present) {
      map['taxable_amount'] = Variable<double>(taxableAmount.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (cgstRate.present) {
      map['cgst_rate'] = Variable<double>(cgstRate.value);
    }
    if (sgstRate.present) {
      map['sgst_rate'] = Variable<double>(sgstRate.value);
    }
    if (igstRate.present) {
      map['igst_rate'] = Variable<double>(igstRate.value);
    }
    if (cessRate.present) {
      map['cess_rate'] = Variable<double>(cessRate.value);
    }
    if (cgstAmount.present) {
      map['cgst_amount'] = Variable<double>(cgstAmount.value);
    }
    if (sgstAmount.present) {
      map['sgst_amount'] = Variable<double>(sgstAmount.value);
    }
    if (igstAmount.present) {
      map['igst_amount'] = Variable<double>(igstAmount.value);
    }
    if (cessAmount.present) {
      map['cess_amount'] = Variable<double>(cessAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuoteItemsCompanion(')
          ..write('id: $id, ')
          ..write('quoteId: $quoteId, ')
          ..write('productId: $productId, ')
          ..write('name: $name, ')
          ..write('hsnSac: $hsnSac, ')
          ..write('unit: $unit, ')
          ..write('quantity: $quantity, ')
          ..write('rate: $rate, ')
          ..write('discountPct: $discountPct, ')
          ..write('taxableAmount: $taxableAmount, ')
          ..write('gstRate: $gstRate, ')
          ..write('cgstRate: $cgstRate, ')
          ..write('sgstRate: $sgstRate, ')
          ..write('igstRate: $igstRate, ')
          ..write('cessRate: $cessRate, ')
          ..write('cgstAmount: $cgstAmount, ')
          ..write('sgstAmount: $sgstAmount, ')
          ..write('igstAmount: $igstAmount, ')
          ..write('cessAmount: $cessAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $HsnCodesTable extends HsnCodes with TableInfo<$HsnCodesTable, HsnCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HsnCodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstRateMeta = const VerificationMeta(
    'gstRate',
  );
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
    'gst_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('HSN'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, code, description, gstRate, type];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hsn_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<HsnCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('gst_rate')) {
      context.handle(
        _gstRateMeta,
        gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta),
      );
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HsnCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HsnCode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      gstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate'],
      ),
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
    );
  }

  @override
  $HsnCodesTable createAlias(String alias) {
    return $HsnCodesTable(attachedDatabase, alias);
  }
}

class HsnCode extends DataClass implements Insertable<HsnCode> {
  final int id;
  final String code;
  final String description;
  final double? gstRate;
  final String type;
  const HsnCode({
    required this.id,
    required this.code,
    required this.description,
    this.gstRate,
    required this.type,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || gstRate != null) {
      map['gst_rate'] = Variable<double>(gstRate);
    }
    map['type'] = Variable<String>(type);
    return map;
  }

  HsnCodesCompanion toCompanion(bool nullToAbsent) {
    return HsnCodesCompanion(
      id: Value(id),
      code: Value(code),
      description: Value(description),
      gstRate: gstRate == null && nullToAbsent
          ? const Value.absent()
          : Value(gstRate),
      type: Value(type),
    );
  }

  factory HsnCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HsnCode(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      description: serializer.fromJson<String>(json['description']),
      gstRate: serializer.fromJson<double?>(json['gstRate']),
      type: serializer.fromJson<String>(json['type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'description': serializer.toJson<String>(description),
      'gstRate': serializer.toJson<double?>(gstRate),
      'type': serializer.toJson<String>(type),
    };
  }

  HsnCode copyWith({
    int? id,
    String? code,
    String? description,
    Value<double?> gstRate = const Value.absent(),
    String? type,
  }) => HsnCode(
    id: id ?? this.id,
    code: code ?? this.code,
    description: description ?? this.description,
    gstRate: gstRate.present ? gstRate.value : this.gstRate,
    type: type ?? this.type,
  );
  HsnCode copyWithCompanion(HsnCodesCompanion data) {
    return HsnCode(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      description: data.description.present
          ? data.description.value
          : this.description,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      type: data.type.present ? data.type.value : this.type,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HsnCode(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('gstRate: $gstRate, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, code, description, gstRate, type);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HsnCode &&
          other.id == this.id &&
          other.code == this.code &&
          other.description == this.description &&
          other.gstRate == this.gstRate &&
          other.type == this.type);
}

class HsnCodesCompanion extends UpdateCompanion<HsnCode> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> description;
  final Value<double?> gstRate;
  final Value<String> type;
  const HsnCodesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.description = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.type = const Value.absent(),
  });
  HsnCodesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String description,
    this.gstRate = const Value.absent(),
    this.type = const Value.absent(),
  }) : code = Value(code),
       description = Value(description);
  static Insertable<HsnCode> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? description,
    Expression<double>? gstRate,
    Expression<String>? type,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (description != null) 'description': description,
      if (gstRate != null) 'gst_rate': gstRate,
      if (type != null) 'type': type,
    });
  }

  HsnCodesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? description,
    Value<double?>? gstRate,
    Value<String>? type,
  }) {
    return HsnCodesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      description: description ?? this.description,
      gstRate: gstRate ?? this.gstRate,
      type: type ?? this.type,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HsnCodesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('description: $description, ')
          ..write('gstRate: $gstRate, ')
          ..write('type: $type')
          ..write(')'))
        .toString();
  }
}

class $HsnCodeRatesTable extends HsnCodeRates
    with TableInfo<$HsnCodeRatesTable, HsnCodeRate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HsnCodeRatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gstRateMeta = const VerificationMeta(
    'gstRate',
  );
  @override
  late final GeneratedColumn<double> gstRate = GeneratedColumn<double>(
    'gst_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _effectiveFromMeta = const VerificationMeta(
    'effectiveFrom',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveFrom =
      GeneratedColumn<DateTime>(
        'effective_from',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _minUnitPriceMeta = const VerificationMeta(
    'minUnitPrice',
  );
  @override
  late final GeneratedColumn<double> minUnitPrice = GeneratedColumn<double>(
    'min_unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _maxUnitPriceMeta = const VerificationMeta(
    'maxUnitPrice',
  );
  @override
  late final GeneratedColumn<double> maxUnitPrice = GeneratedColumn<double>(
    'max_unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(unboundedUnitPrice),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    gstRate,
    effectiveFrom,
    minUnitPrice,
    maxUnitPrice,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'hsn_code_rates';
  @override
  VerificationContext validateIntegrity(
    Insertable<HsnCodeRate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('gst_rate')) {
      context.handle(
        _gstRateMeta,
        gstRate.isAcceptableOrUnknown(data['gst_rate']!, _gstRateMeta),
      );
    }
    if (data.containsKey('effective_from')) {
      context.handle(
        _effectiveFromMeta,
        effectiveFrom.isAcceptableOrUnknown(
          data['effective_from']!,
          _effectiveFromMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveFromMeta);
    }
    if (data.containsKey('min_unit_price')) {
      context.handle(
        _minUnitPriceMeta,
        minUnitPrice.isAcceptableOrUnknown(
          data['min_unit_price']!,
          _minUnitPriceMeta,
        ),
      );
    }
    if (data.containsKey('max_unit_price')) {
      context.handle(
        _maxUnitPriceMeta,
        maxUnitPrice.isAcceptableOrUnknown(
          data['max_unit_price']!,
          _maxUnitPriceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {code, effectiveFrom, minUnitPrice, maxUnitPrice},
  ];
  @override
  HsnCodeRate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HsnCodeRate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      gstRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}gst_rate'],
      ),
      effectiveFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_from'],
      )!,
      minUnitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_unit_price'],
      )!,
      maxUnitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}max_unit_price'],
      )!,
    );
  }

  @override
  $HsnCodeRatesTable createAlias(String alias) {
    return $HsnCodeRatesTable(attachedDatabase, alias);
  }
}

class HsnCodeRate extends DataClass implements Insertable<HsnCodeRate> {
  final int id;
  final String code;
  final double? gstRate;
  final DateTime effectiveFrom;

  /// Price band for rate rules that depend on the unit price (for example
  /// readymade garments: 5% up to Rs.2,500 per piece, 18% above).
  ///
  /// Applied as `minUnitPrice < price <= maxUnitPrice`. The defaults
  /// (0 and [unboundedUnitPrice]) mean "every price". Bounds are non-null so
  /// the uniqueness constraint below stays effective — a nullable column would
  /// let SQLite treat each row as distinct and duplicate seed rates on every
  /// launch.
  final double minUnitPrice;
  final double maxUnitPrice;
  const HsnCodeRate({
    required this.id,
    required this.code,
    this.gstRate,
    required this.effectiveFrom,
    required this.minUnitPrice,
    required this.maxUnitPrice,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    if (!nullToAbsent || gstRate != null) {
      map['gst_rate'] = Variable<double>(gstRate);
    }
    map['effective_from'] = Variable<DateTime>(effectiveFrom);
    map['min_unit_price'] = Variable<double>(minUnitPrice);
    map['max_unit_price'] = Variable<double>(maxUnitPrice);
    return map;
  }

  HsnCodeRatesCompanion toCompanion(bool nullToAbsent) {
    return HsnCodeRatesCompanion(
      id: Value(id),
      code: Value(code),
      gstRate: gstRate == null && nullToAbsent
          ? const Value.absent()
          : Value(gstRate),
      effectiveFrom: Value(effectiveFrom),
      minUnitPrice: Value(minUnitPrice),
      maxUnitPrice: Value(maxUnitPrice),
    );
  }

  factory HsnCodeRate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HsnCodeRate(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      gstRate: serializer.fromJson<double?>(json['gstRate']),
      effectiveFrom: serializer.fromJson<DateTime>(json['effectiveFrom']),
      minUnitPrice: serializer.fromJson<double>(json['minUnitPrice']),
      maxUnitPrice: serializer.fromJson<double>(json['maxUnitPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'gstRate': serializer.toJson<double?>(gstRate),
      'effectiveFrom': serializer.toJson<DateTime>(effectiveFrom),
      'minUnitPrice': serializer.toJson<double>(minUnitPrice),
      'maxUnitPrice': serializer.toJson<double>(maxUnitPrice),
    };
  }

  HsnCodeRate copyWith({
    int? id,
    String? code,
    Value<double?> gstRate = const Value.absent(),
    DateTime? effectiveFrom,
    double? minUnitPrice,
    double? maxUnitPrice,
  }) => HsnCodeRate(
    id: id ?? this.id,
    code: code ?? this.code,
    gstRate: gstRate.present ? gstRate.value : this.gstRate,
    effectiveFrom: effectiveFrom ?? this.effectiveFrom,
    minUnitPrice: minUnitPrice ?? this.minUnitPrice,
    maxUnitPrice: maxUnitPrice ?? this.maxUnitPrice,
  );
  HsnCodeRate copyWithCompanion(HsnCodeRatesCompanion data) {
    return HsnCodeRate(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      gstRate: data.gstRate.present ? data.gstRate.value : this.gstRate,
      effectiveFrom: data.effectiveFrom.present
          ? data.effectiveFrom.value
          : this.effectiveFrom,
      minUnitPrice: data.minUnitPrice.present
          ? data.minUnitPrice.value
          : this.minUnitPrice,
      maxUnitPrice: data.maxUnitPrice.present
          ? data.maxUnitPrice.value
          : this.maxUnitPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HsnCodeRate(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('gstRate: $gstRate, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('minUnitPrice: $minUnitPrice, ')
          ..write('maxUnitPrice: $maxUnitPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, code, gstRate, effectiveFrom, minUnitPrice, maxUnitPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HsnCodeRate &&
          other.id == this.id &&
          other.code == this.code &&
          other.gstRate == this.gstRate &&
          other.effectiveFrom == this.effectiveFrom &&
          other.minUnitPrice == this.minUnitPrice &&
          other.maxUnitPrice == this.maxUnitPrice);
}

class HsnCodeRatesCompanion extends UpdateCompanion<HsnCodeRate> {
  final Value<int> id;
  final Value<String> code;
  final Value<double?> gstRate;
  final Value<DateTime> effectiveFrom;
  final Value<double> minUnitPrice;
  final Value<double> maxUnitPrice;
  const HsnCodeRatesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.gstRate = const Value.absent(),
    this.effectiveFrom = const Value.absent(),
    this.minUnitPrice = const Value.absent(),
    this.maxUnitPrice = const Value.absent(),
  });
  HsnCodeRatesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    this.gstRate = const Value.absent(),
    required DateTime effectiveFrom,
    this.minUnitPrice = const Value.absent(),
    this.maxUnitPrice = const Value.absent(),
  }) : code = Value(code),
       effectiveFrom = Value(effectiveFrom);
  static Insertable<HsnCodeRate> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<double>? gstRate,
    Expression<DateTime>? effectiveFrom,
    Expression<double>? minUnitPrice,
    Expression<double>? maxUnitPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (gstRate != null) 'gst_rate': gstRate,
      if (effectiveFrom != null) 'effective_from': effectiveFrom,
      if (minUnitPrice != null) 'min_unit_price': minUnitPrice,
      if (maxUnitPrice != null) 'max_unit_price': maxUnitPrice,
    });
  }

  HsnCodeRatesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<double?>? gstRate,
    Value<DateTime>? effectiveFrom,
    Value<double>? minUnitPrice,
    Value<double>? maxUnitPrice,
  }) {
    return HsnCodeRatesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      gstRate: gstRate ?? this.gstRate,
      effectiveFrom: effectiveFrom ?? this.effectiveFrom,
      minUnitPrice: minUnitPrice ?? this.minUnitPrice,
      maxUnitPrice: maxUnitPrice ?? this.maxUnitPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (gstRate.present) {
      map['gst_rate'] = Variable<double>(gstRate.value);
    }
    if (effectiveFrom.present) {
      map['effective_from'] = Variable<DateTime>(effectiveFrom.value);
    }
    if (minUnitPrice.present) {
      map['min_unit_price'] = Variable<double>(minUnitPrice.value);
    }
    if (maxUnitPrice.present) {
      map['max_unit_price'] = Variable<double>(maxUnitPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HsnCodeRatesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('gstRate: $gstRate, ')
          ..write('effectiveFrom: $effectiveFrom, ')
          ..write('minUnitPrice: $minUnitPrice, ')
          ..write('maxUnitPrice: $maxUnitPrice')
          ..write(')'))
        .toString();
  }
}

class $UomsTable extends Uoms with TableInfo<$UomsTable, Uom> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UomsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _familyMeta = const VerificationMeta('family');
  @override
  late final GeneratedColumn<String> family = GeneratedColumn<String>(
    'family',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('GENERAL'),
  );
  static const VerificationMeta _baseCodeMeta = const VerificationMeta(
    'baseCode',
  );
  @override
  late final GeneratedColumn<String> baseCode = GeneratedColumn<String>(
    'base_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _conversionFactorMeta = const VerificationMeta(
    'conversionFactor',
  );
  @override
  late final GeneratedColumn<double> conversionFactor = GeneratedColumn<double>(
    'conversion_factor',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    name,
    family,
    baseCode,
    conversionFactor,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'uoms';
  @override
  VerificationContext validateIntegrity(
    Insertable<Uom> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('family')) {
      context.handle(
        _familyMeta,
        family.isAcceptableOrUnknown(data['family']!, _familyMeta),
      );
    }
    if (data.containsKey('base_code')) {
      context.handle(
        _baseCodeMeta,
        baseCode.isAcceptableOrUnknown(data['base_code']!, _baseCodeMeta),
      );
    }
    if (data.containsKey('conversion_factor')) {
      context.handle(
        _conversionFactorMeta,
        conversionFactor.isAcceptableOrUnknown(
          data['conversion_factor']!,
          _conversionFactorMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Uom map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Uom(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      family: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}family'],
      )!,
      baseCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_code'],
      ),
      conversionFactor: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}conversion_factor'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $UomsTable createAlias(String alias) {
    return $UomsTable(attachedDatabase, alias);
  }
}

class Uom extends DataClass implements Insertable<Uom> {
  final int id;
  final String code;
  final String name;
  final String family;
  final String? baseCode;
  final double conversionFactor;
  final bool isActive;
  final int sortOrder;
  const Uom({
    required this.id,
    required this.code,
    required this.name,
    required this.family,
    this.baseCode,
    required this.conversionFactor,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['name'] = Variable<String>(name);
    map['family'] = Variable<String>(family);
    if (!nullToAbsent || baseCode != null) {
      map['base_code'] = Variable<String>(baseCode);
    }
    map['conversion_factor'] = Variable<double>(conversionFactor);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  UomsCompanion toCompanion(bool nullToAbsent) {
    return UomsCompanion(
      id: Value(id),
      code: Value(code),
      name: Value(name),
      family: Value(family),
      baseCode: baseCode == null && nullToAbsent
          ? const Value.absent()
          : Value(baseCode),
      conversionFactor: Value(conversionFactor),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory Uom.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Uom(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      name: serializer.fromJson<String>(json['name']),
      family: serializer.fromJson<String>(json['family']),
      baseCode: serializer.fromJson<String?>(json['baseCode']),
      conversionFactor: serializer.fromJson<double>(json['conversionFactor']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'name': serializer.toJson<String>(name),
      'family': serializer.toJson<String>(family),
      'baseCode': serializer.toJson<String?>(baseCode),
      'conversionFactor': serializer.toJson<double>(conversionFactor),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Uom copyWith({
    int? id,
    String? code,
    String? name,
    String? family,
    Value<String?> baseCode = const Value.absent(),
    double? conversionFactor,
    bool? isActive,
    int? sortOrder,
  }) => Uom(
    id: id ?? this.id,
    code: code ?? this.code,
    name: name ?? this.name,
    family: family ?? this.family,
    baseCode: baseCode.present ? baseCode.value : this.baseCode,
    conversionFactor: conversionFactor ?? this.conversionFactor,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Uom copyWithCompanion(UomsCompanion data) {
    return Uom(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      name: data.name.present ? data.name.value : this.name,
      family: data.family.present ? data.family.value : this.family,
      baseCode: data.baseCode.present ? data.baseCode.value : this.baseCode,
      conversionFactor: data.conversionFactor.present
          ? data.conversionFactor.value
          : this.conversionFactor,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Uom(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('family: $family, ')
          ..write('baseCode: $baseCode, ')
          ..write('conversionFactor: $conversionFactor, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    name,
    family,
    baseCode,
    conversionFactor,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Uom &&
          other.id == this.id &&
          other.code == this.code &&
          other.name == this.name &&
          other.family == this.family &&
          other.baseCode == this.baseCode &&
          other.conversionFactor == this.conversionFactor &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class UomsCompanion extends UpdateCompanion<Uom> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> name;
  final Value<String> family;
  final Value<String?> baseCode;
  final Value<double> conversionFactor;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const UomsCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.name = const Value.absent(),
    this.family = const Value.absent(),
    this.baseCode = const Value.absent(),
    this.conversionFactor = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  UomsCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String name,
    this.family = const Value.absent(),
    this.baseCode = const Value.absent(),
    this.conversionFactor = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : code = Value(code),
       name = Value(name);
  static Insertable<Uom> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? name,
    Expression<String>? family,
    Expression<String>? baseCode,
    Expression<double>? conversionFactor,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (name != null) 'name': name,
      if (family != null) 'family': family,
      if (baseCode != null) 'base_code': baseCode,
      if (conversionFactor != null) 'conversion_factor': conversionFactor,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  UomsCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? name,
    Value<String>? family,
    Value<String?>? baseCode,
    Value<double>? conversionFactor,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return UomsCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      family: family ?? this.family,
      baseCode: baseCode ?? this.baseCode,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (family.present) {
      map['family'] = Variable<String>(family.value);
    }
    if (baseCode.present) {
      map['base_code'] = Variable<String>(baseCode.value);
    }
    if (conversionFactor.present) {
      map['conversion_factor'] = Variable<double>(conversionFactor.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UomsCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('name: $name, ')
          ..write('family: $family, ')
          ..write('baseCode: $baseCode, ')
          ..write('conversionFactor: $conversionFactor, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TemplateConfigsTable extends TemplateConfigs
    with TableInfo<$TemplateConfigsTable, TemplateConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<TemplateScope, int> scope =
      GeneratedColumn<int>(
        'scope',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<TemplateScope>($TemplateConfigsTable.$converterscope);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _configJsonMeta = const VerificationMeta(
    'configJson',
  );
  @override
  late final GeneratedColumn<String> configJson = GeneratedColumn<String>(
    'config_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isDefaultMeta = const VerificationMeta(
    'isDefault',
  );
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
    'is_default',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_default" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    scope,
    name,
    configJson,
    isDefault,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('config_json')) {
      context.handle(
        _configJsonMeta,
        configJson.isAcceptableOrUnknown(data['config_json']!, _configJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_configJsonMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(
        _isDefaultMeta,
        isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      scope: $TemplateConfigsTable.$converterscope.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}scope'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      configJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}config_json'],
      )!,
      isDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_default'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TemplateConfigsTable createAlias(String alias) {
    return $TemplateConfigsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<TemplateScope, int, int> $converterscope =
      const EnumIndexConverter<TemplateScope>(TemplateScope.values);
}

class TemplateConfig extends DataClass implements Insertable<TemplateConfig> {
  final int id;
  final int businessId;
  final TemplateScope scope;
  final String name;
  final String configJson;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  const TemplateConfig({
    required this.id,
    required this.businessId,
    required this.scope,
    required this.name,
    required this.configJson,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    {
      map['scope'] = Variable<int>(
        $TemplateConfigsTable.$converterscope.toSql(scope),
      );
    }
    map['name'] = Variable<String>(name);
    map['config_json'] = Variable<String>(configJson);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TemplateConfigsCompanion toCompanion(bool nullToAbsent) {
    return TemplateConfigsCompanion(
      id: Value(id),
      businessId: Value(businessId),
      scope: Value(scope),
      name: Value(name),
      configJson: Value(configJson),
      isDefault: Value(isDefault),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory TemplateConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateConfig(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      scope: $TemplateConfigsTable.$converterscope.fromJson(
        serializer.fromJson<int>(json['scope']),
      ),
      name: serializer.fromJson<String>(json['name']),
      configJson: serializer.fromJson<String>(json['configJson']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'scope': serializer.toJson<int>(
        $TemplateConfigsTable.$converterscope.toJson(scope),
      ),
      'name': serializer.toJson<String>(name),
      'configJson': serializer.toJson<String>(configJson),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TemplateConfig copyWith({
    int? id,
    int? businessId,
    TemplateScope? scope,
    String? name,
    String? configJson,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => TemplateConfig(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    scope: scope ?? this.scope,
    name: name ?? this.name,
    configJson: configJson ?? this.configJson,
    isDefault: isDefault ?? this.isDefault,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TemplateConfig copyWithCompanion(TemplateConfigsCompanion data) {
    return TemplateConfig(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      scope: data.scope.present ? data.scope.value : this.scope,
      name: data.name.present ? data.name.value : this.name,
      configJson: data.configJson.present
          ? data.configJson.value
          : this.configJson,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateConfig(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('scope: $scope, ')
          ..write('name: $name, ')
          ..write('configJson: $configJson, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    scope,
    name,
    configJson,
    isDefault,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateConfig &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.scope == this.scope &&
          other.name == this.name &&
          other.configJson == this.configJson &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TemplateConfigsCompanion extends UpdateCompanion<TemplateConfig> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<TemplateScope> scope;
  final Value<String> name;
  final Value<String> configJson;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const TemplateConfigsCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.scope = const Value.absent(),
    this.name = const Value.absent(),
    this.configJson = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TemplateConfigsCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required TemplateScope scope,
    required String name,
    required String configJson,
    this.isDefault = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : businessId = Value(businessId),
       scope = Value(scope),
       name = Value(name),
       configJson = Value(configJson),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<TemplateConfig> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<int>? scope,
    Expression<String>? name,
    Expression<String>? configJson,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (scope != null) 'scope': scope,
      if (name != null) 'name': name,
      if (configJson != null) 'config_json': configJson,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TemplateConfigsCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<TemplateScope>? scope,
    Value<String>? name,
    Value<String>? configJson,
    Value<bool>? isDefault,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return TemplateConfigsCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      scope: scope ?? this.scope,
      name: name ?? this.name,
      configJson: configJson ?? this.configJson,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (scope.present) {
      map['scope'] = Variable<int>(
        $TemplateConfigsTable.$converterscope.toSql(scope.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (configJson.present) {
      map['config_json'] = Variable<String>(configJson.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateConfigsCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('scope: $scope, ')
          ..write('name: $name, ')
          ..write('configJson: $configJson, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DocumentSequencesTable extends DocumentSequences
    with TableInfo<$DocumentSequencesTable, DocumentSequence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DocumentSequencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _docTypeMeta = const VerificationMeta(
    'docType',
  );
  @override
  late final GeneratedColumn<String> docType = GeneratedColumn<String>(
    'doc_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fiscalYearMeta = const VerificationMeta(
    'fiscalYear',
  );
  @override
  late final GeneratedColumn<String> fiscalYear = GeneratedColumn<String>(
    'fiscal_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _formatMeta = const VerificationMeta('format');
  @override
  late final GeneratedColumn<String> format = GeneratedColumn<String>(
    'format',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sequenceMeta = const VerificationMeta(
    'sequence',
  );
  @override
  late final GeneratedColumn<int> sequence = GeneratedColumn<int>(
    'sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    docType,
    fiscalYear,
    format,
    sequence,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'document_sequences';
  @override
  VerificationContext validateIntegrity(
    Insertable<DocumentSequence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('doc_type')) {
      context.handle(
        _docTypeMeta,
        docType.isAcceptableOrUnknown(data['doc_type']!, _docTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_docTypeMeta);
    }
    if (data.containsKey('fiscal_year')) {
      context.handle(
        _fiscalYearMeta,
        fiscalYear.isAcceptableOrUnknown(data['fiscal_year']!, _fiscalYearMeta),
      );
    } else if (isInserting) {
      context.missing(_fiscalYearMeta);
    }
    if (data.containsKey('format')) {
      context.handle(
        _formatMeta,
        format.isAcceptableOrUnknown(data['format']!, _formatMeta),
      );
    } else if (isInserting) {
      context.missing(_formatMeta);
    }
    if (data.containsKey('sequence')) {
      context.handle(
        _sequenceMeta,
        sequence.isAcceptableOrUnknown(data['sequence']!, _sequenceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {businessId, docType, fiscalYear, format},
  ];
  @override
  DocumentSequence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DocumentSequence(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      docType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}doc_type'],
      )!,
      fiscalYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fiscal_year'],
      )!,
      format: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format'],
      )!,
      sequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sequence'],
      )!,
    );
  }

  @override
  $DocumentSequencesTable createAlias(String alias) {
    return $DocumentSequencesTable(attachedDatabase, alias);
  }
}

class DocumentSequence extends DataClass
    implements Insertable<DocumentSequence> {
  final int id;
  final int businessId;
  final String docType;
  final String fiscalYear;
  final String format;
  final int sequence;
  const DocumentSequence({
    required this.id,
    required this.businessId,
    required this.docType,
    required this.fiscalYear,
    required this.format,
    required this.sequence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['doc_type'] = Variable<String>(docType);
    map['fiscal_year'] = Variable<String>(fiscalYear);
    map['format'] = Variable<String>(format);
    map['sequence'] = Variable<int>(sequence);
    return map;
  }

  DocumentSequencesCompanion toCompanion(bool nullToAbsent) {
    return DocumentSequencesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      docType: Value(docType),
      fiscalYear: Value(fiscalYear),
      format: Value(format),
      sequence: Value(sequence),
    );
  }

  factory DocumentSequence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DocumentSequence(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      docType: serializer.fromJson<String>(json['docType']),
      fiscalYear: serializer.fromJson<String>(json['fiscalYear']),
      format: serializer.fromJson<String>(json['format']),
      sequence: serializer.fromJson<int>(json['sequence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'docType': serializer.toJson<String>(docType),
      'fiscalYear': serializer.toJson<String>(fiscalYear),
      'format': serializer.toJson<String>(format),
      'sequence': serializer.toJson<int>(sequence),
    };
  }

  DocumentSequence copyWith({
    int? id,
    int? businessId,
    String? docType,
    String? fiscalYear,
    String? format,
    int? sequence,
  }) => DocumentSequence(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    docType: docType ?? this.docType,
    fiscalYear: fiscalYear ?? this.fiscalYear,
    format: format ?? this.format,
    sequence: sequence ?? this.sequence,
  );
  DocumentSequence copyWithCompanion(DocumentSequencesCompanion data) {
    return DocumentSequence(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      docType: data.docType.present ? data.docType.value : this.docType,
      fiscalYear: data.fiscalYear.present
          ? data.fiscalYear.value
          : this.fiscalYear,
      format: data.format.present ? data.format.value : this.format,
      sequence: data.sequence.present ? data.sequence.value : this.sequence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSequence(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('docType: $docType, ')
          ..write('fiscalYear: $fiscalYear, ')
          ..write('format: $format, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, businessId, docType, fiscalYear, format, sequence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DocumentSequence &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.docType == this.docType &&
          other.fiscalYear == this.fiscalYear &&
          other.format == this.format &&
          other.sequence == this.sequence);
}

class DocumentSequencesCompanion extends UpdateCompanion<DocumentSequence> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<String> docType;
  final Value<String> fiscalYear;
  final Value<String> format;
  final Value<int> sequence;
  const DocumentSequencesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.docType = const Value.absent(),
    this.fiscalYear = const Value.absent(),
    this.format = const Value.absent(),
    this.sequence = const Value.absent(),
  });
  DocumentSequencesCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required String docType,
    required String fiscalYear,
    required String format,
    this.sequence = const Value.absent(),
  }) : businessId = Value(businessId),
       docType = Value(docType),
       fiscalYear = Value(fiscalYear),
       format = Value(format);
  static Insertable<DocumentSequence> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<String>? docType,
    Expression<String>? fiscalYear,
    Expression<String>? format,
    Expression<int>? sequence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (docType != null) 'doc_type': docType,
      if (fiscalYear != null) 'fiscal_year': fiscalYear,
      if (format != null) 'format': format,
      if (sequence != null) 'sequence': sequence,
    });
  }

  DocumentSequencesCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<String>? docType,
    Value<String>? fiscalYear,
    Value<String>? format,
    Value<int>? sequence,
  }) {
    return DocumentSequencesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      docType: docType ?? this.docType,
      fiscalYear: fiscalYear ?? this.fiscalYear,
      format: format ?? this.format,
      sequence: sequence ?? this.sequence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (docType.present) {
      map['doc_type'] = Variable<String>(docType.value);
    }
    if (fiscalYear.present) {
      map['fiscal_year'] = Variable<String>(fiscalYear.value);
    }
    if (format.present) {
      map['format'] = Variable<String>(format.value);
    }
    if (sequence.present) {
      map['sequence'] = Variable<int>(sequence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DocumentSequencesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('docType: $docType, ')
          ..write('fiscalYear: $fiscalYear, ')
          ..write('format: $format, ')
          ..write('sequence: $sequence')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _productIdMeta = const VerificationMeta(
    'productId',
  );
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
    'product_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES products (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quantityDeltaMeta = const VerificationMeta(
    'quantityDelta',
  );
  @override
  late final GeneratedColumn<double> quantityDelta = GeneratedColumn<double>(
    'quantity_delta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _documentTypeMeta = const VerificationMeta(
    'documentType',
  );
  @override
  late final GeneratedColumn<String> documentType = GeneratedColumn<String>(
    'document_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _documentIdMeta = const VerificationMeta(
    'documentId',
  );
  @override
  late final GeneratedColumn<int> documentId = GeneratedColumn<int>(
    'document_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    productId,
    quantityDelta,
    reason,
    documentType,
    documentId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(
    Insertable<StockMovement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(
        _productIdMeta,
        productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity_delta')) {
      context.handle(
        _quantityDeltaMeta,
        quantityDelta.isAcceptableOrUnknown(
          data['quantity_delta']!,
          _quantityDeltaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_quantityDeltaMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('document_type')) {
      context.handle(
        _documentTypeMeta,
        documentType.isAcceptableOrUnknown(
          data['document_type']!,
          _documentTypeMeta,
        ),
      );
    }
    if (data.containsKey('document_id')) {
      context.handle(
        _documentIdMeta,
        documentId.isAcceptableOrUnknown(data['document_id']!, _documentIdMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      productId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}product_id'],
      )!,
      quantityDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity_delta'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      documentType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}document_type'],
      ),
      documentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}document_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int id;
  final int productId;

  /// Signed change: negative for sales, positive for reversals and increases.
  final double quantityDelta;

  /// OPENING, ADJUSTMENT, INVOICE, INVOICE_REVERSAL.
  final String reason;
  final String? documentType;
  final int? documentId;
  final DateTime createdAt;
  const StockMovement({
    required this.id,
    required this.productId,
    required this.quantityDelta,
    required this.reason,
    this.documentType,
    this.documentId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['quantity_delta'] = Variable<double>(quantityDelta);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || documentType != null) {
      map['document_type'] = Variable<String>(documentType);
    }
    if (!nullToAbsent || documentId != null) {
      map['document_id'] = Variable<int>(documentId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      quantityDelta: Value(quantityDelta),
      reason: Value(reason),
      documentType: documentType == null && nullToAbsent
          ? const Value.absent()
          : Value(documentType),
      documentId: documentId == null && nullToAbsent
          ? const Value.absent()
          : Value(documentId),
      createdAt: Value(createdAt),
    );
  }

  factory StockMovement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      quantityDelta: serializer.fromJson<double>(json['quantityDelta']),
      reason: serializer.fromJson<String>(json['reason']),
      documentType: serializer.fromJson<String?>(json['documentType']),
      documentId: serializer.fromJson<int?>(json['documentId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'quantityDelta': serializer.toJson<double>(quantityDelta),
      'reason': serializer.toJson<String>(reason),
      'documentType': serializer.toJson<String?>(documentType),
      'documentId': serializer.toJson<int?>(documentId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StockMovement copyWith({
    int? id,
    int? productId,
    double? quantityDelta,
    String? reason,
    Value<String?> documentType = const Value.absent(),
    Value<int?> documentId = const Value.absent(),
    DateTime? createdAt,
  }) => StockMovement(
    id: id ?? this.id,
    productId: productId ?? this.productId,
    quantityDelta: quantityDelta ?? this.quantityDelta,
    reason: reason ?? this.reason,
    documentType: documentType.present ? documentType.value : this.documentType,
    documentId: documentId.present ? documentId.value : this.documentId,
    createdAt: createdAt ?? this.createdAt,
  );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantityDelta: data.quantityDelta.present
          ? data.quantityDelta.value
          : this.quantityDelta,
      reason: data.reason.present ? data.reason.value : this.reason,
      documentType: data.documentType.present
          ? data.documentType.value
          : this.documentType,
      documentId: data.documentId.present
          ? data.documentId.value
          : this.documentId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('reason: $reason, ')
          ..write('documentType: $documentType, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    productId,
    quantityDelta,
    reason,
    documentType,
    documentId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.quantityDelta == this.quantityDelta &&
          other.reason == this.reason &&
          other.documentType == this.documentType &&
          other.documentId == this.documentId &&
          other.createdAt == this.createdAt);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<double> quantityDelta;
  final Value<String> reason;
  final Value<String?> documentType;
  final Value<int?> documentId;
  final Value<DateTime> createdAt;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantityDelta = const Value.absent(),
    this.reason = const Value.absent(),
    this.documentType = const Value.absent(),
    this.documentId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required double quantityDelta,
    required String reason,
    this.documentType = const Value.absent(),
    this.documentId = const Value.absent(),
    required DateTime createdAt,
  }) : productId = Value(productId),
       quantityDelta = Value(quantityDelta),
       reason = Value(reason),
       createdAt = Value(createdAt);
  static Insertable<StockMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<double>? quantityDelta,
    Expression<String>? reason,
    Expression<String>? documentType,
    Expression<int>? documentId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (quantityDelta != null) 'quantity_delta': quantityDelta,
      if (reason != null) 'reason': reason,
      if (documentType != null) 'document_type': documentType,
      if (documentId != null) 'document_id': documentId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StockMovementsCompanion copyWith({
    Value<int>? id,
    Value<int>? productId,
    Value<double>? quantityDelta,
    Value<String>? reason,
    Value<String?>? documentType,
    Value<int?>? documentId,
    Value<DateTime>? createdAt,
  }) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      quantityDelta: quantityDelta ?? this.quantityDelta,
      reason: reason ?? this.reason,
      documentType: documentType ?? this.documentType,
      documentId: documentId ?? this.documentId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantityDelta.present) {
      map['quantity_delta'] = Variable<double>(quantityDelta.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (documentType.present) {
      map['document_type'] = Variable<String>(documentType.value);
    }
    if (documentId.present) {
      map['document_id'] = Variable<int>(documentId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('quantityDelta: $quantityDelta, ')
          ..write('reason: $reason, ')
          ..write('documentType: $documentType, ')
          ..write('documentId: $documentId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RecurringInvoicesTable extends RecurringInvoices
    with TableInfo<$RecurringInvoicesTable, RecurringInvoice> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringInvoicesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _businessIdMeta = const VerificationMeta(
    'businessId',
  );
  @override
  late final GeneratedColumn<int> businessId = GeneratedColumn<int>(
    'business_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES businesses (id)',
    ),
  );
  static const VerificationMeta _sourceInvoiceIdMeta = const VerificationMeta(
    'sourceInvoiceId',
  );
  @override
  late final GeneratedColumn<int> sourceInvoiceId = GeneratedColumn<int>(
    'source_invoice_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES invoices (id)',
    ),
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('MONTHLY'),
  );
  static const VerificationMeta _nextRunDateMeta = const VerificationMeta(
    'nextRunDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextRunDate = GeneratedColumn<DateTime>(
    'next_run_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    businessId,
    sourceInvoiceId,
    frequency,
    nextRunDate,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_invoices';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringInvoice> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('business_id')) {
      context.handle(
        _businessIdMeta,
        businessId.isAcceptableOrUnknown(data['business_id']!, _businessIdMeta),
      );
    } else if (isInserting) {
      context.missing(_businessIdMeta);
    }
    if (data.containsKey('source_invoice_id')) {
      context.handle(
        _sourceInvoiceIdMeta,
        sourceInvoiceId.isAcceptableOrUnknown(
          data['source_invoice_id']!,
          _sourceInvoiceIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceInvoiceIdMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('next_run_date')) {
      context.handle(
        _nextRunDateMeta,
        nextRunDate.isAcceptableOrUnknown(
          data['next_run_date']!,
          _nextRunDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextRunDateMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringInvoice map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringInvoice(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      businessId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_id'],
      )!,
      sourceInvoiceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}source_invoice_id'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      nextRunDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_run_date'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RecurringInvoicesTable createAlias(String alias) {
    return $RecurringInvoicesTable(attachedDatabase, alias);
  }
}

class RecurringInvoice extends DataClass
    implements Insertable<RecurringInvoice> {
  final int id;
  final int businessId;
  final int sourceInvoiceId;

  /// WEEKLY, MONTHLY, QUARTERLY or YEARLY.
  final String frequency;

  /// The next date a draft should be generated for.
  final DateTime nextRunDate;
  final bool isActive;
  final DateTime createdAt;
  const RecurringInvoice({
    required this.id,
    required this.businessId,
    required this.sourceInvoiceId,
    required this.frequency,
    required this.nextRunDate,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['business_id'] = Variable<int>(businessId);
    map['source_invoice_id'] = Variable<int>(sourceInvoiceId);
    map['frequency'] = Variable<String>(frequency);
    map['next_run_date'] = Variable<DateTime>(nextRunDate);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringInvoicesCompanion toCompanion(bool nullToAbsent) {
    return RecurringInvoicesCompanion(
      id: Value(id),
      businessId: Value(businessId),
      sourceInvoiceId: Value(sourceInvoiceId),
      frequency: Value(frequency),
      nextRunDate: Value(nextRunDate),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringInvoice.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringInvoice(
      id: serializer.fromJson<int>(json['id']),
      businessId: serializer.fromJson<int>(json['businessId']),
      sourceInvoiceId: serializer.fromJson<int>(json['sourceInvoiceId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextRunDate: serializer.fromJson<DateTime>(json['nextRunDate']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'businessId': serializer.toJson<int>(businessId),
      'sourceInvoiceId': serializer.toJson<int>(sourceInvoiceId),
      'frequency': serializer.toJson<String>(frequency),
      'nextRunDate': serializer.toJson<DateTime>(nextRunDate),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringInvoice copyWith({
    int? id,
    int? businessId,
    int? sourceInvoiceId,
    String? frequency,
    DateTime? nextRunDate,
    bool? isActive,
    DateTime? createdAt,
  }) => RecurringInvoice(
    id: id ?? this.id,
    businessId: businessId ?? this.businessId,
    sourceInvoiceId: sourceInvoiceId ?? this.sourceInvoiceId,
    frequency: frequency ?? this.frequency,
    nextRunDate: nextRunDate ?? this.nextRunDate,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  RecurringInvoice copyWithCompanion(RecurringInvoicesCompanion data) {
    return RecurringInvoice(
      id: data.id.present ? data.id.value : this.id,
      businessId: data.businessId.present
          ? data.businessId.value
          : this.businessId,
      sourceInvoiceId: data.sourceInvoiceId.present
          ? data.sourceInvoiceId.value
          : this.sourceInvoiceId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextRunDate: data.nextRunDate.present
          ? data.nextRunDate.value
          : this.nextRunDate,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringInvoice(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('sourceInvoiceId: $sourceInvoiceId, ')
          ..write('frequency: $frequency, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    businessId,
    sourceInvoiceId,
    frequency,
    nextRunDate,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringInvoice &&
          other.id == this.id &&
          other.businessId == this.businessId &&
          other.sourceInvoiceId == this.sourceInvoiceId &&
          other.frequency == this.frequency &&
          other.nextRunDate == this.nextRunDate &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class RecurringInvoicesCompanion extends UpdateCompanion<RecurringInvoice> {
  final Value<int> id;
  final Value<int> businessId;
  final Value<int> sourceInvoiceId;
  final Value<String> frequency;
  final Value<DateTime> nextRunDate;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const RecurringInvoicesCompanion({
    this.id = const Value.absent(),
    this.businessId = const Value.absent(),
    this.sourceInvoiceId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextRunDate = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RecurringInvoicesCompanion.insert({
    this.id = const Value.absent(),
    required int businessId,
    required int sourceInvoiceId,
    this.frequency = const Value.absent(),
    required DateTime nextRunDate,
    this.isActive = const Value.absent(),
    required DateTime createdAt,
  }) : businessId = Value(businessId),
       sourceInvoiceId = Value(sourceInvoiceId),
       nextRunDate = Value(nextRunDate),
       createdAt = Value(createdAt);
  static Insertable<RecurringInvoice> custom({
    Expression<int>? id,
    Expression<int>? businessId,
    Expression<int>? sourceInvoiceId,
    Expression<String>? frequency,
    Expression<DateTime>? nextRunDate,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (businessId != null) 'business_id': businessId,
      if (sourceInvoiceId != null) 'source_invoice_id': sourceInvoiceId,
      if (frequency != null) 'frequency': frequency,
      if (nextRunDate != null) 'next_run_date': nextRunDate,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RecurringInvoicesCompanion copyWith({
    Value<int>? id,
    Value<int>? businessId,
    Value<int>? sourceInvoiceId,
    Value<String>? frequency,
    Value<DateTime>? nextRunDate,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
  }) {
    return RecurringInvoicesCompanion(
      id: id ?? this.id,
      businessId: businessId ?? this.businessId,
      sourceInvoiceId: sourceInvoiceId ?? this.sourceInvoiceId,
      frequency: frequency ?? this.frequency,
      nextRunDate: nextRunDate ?? this.nextRunDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (businessId.present) {
      map['business_id'] = Variable<int>(businessId.value);
    }
    if (sourceInvoiceId.present) {
      map['source_invoice_id'] = Variable<int>(sourceInvoiceId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextRunDate.present) {
      map['next_run_date'] = Variable<DateTime>(nextRunDate.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringInvoicesCompanion(')
          ..write('id: $id, ')
          ..write('businessId: $businessId, ')
          ..write('sourceInvoiceId: $sourceInvoiceId, ')
          ..write('frequency: $frequency, ')
          ..write('nextRunDate: $nextRunDate, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BusinessesTable businesses = $BusinessesTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $InvoicesTable invoices = $InvoicesTable(this);
  late final $InvoiceItemsTable invoiceItems = $InvoiceItemsTable(this);
  late final $InvoicePaymentsTable invoicePayments = $InvoicePaymentsTable(
    this,
  );
  late final $CustomerActivityEventsTable customerActivityEvents =
      $CustomerActivityEventsTable(this);
  late final $QuotesTable quotes = $QuotesTable(this);
  late final $QuoteItemsTable quoteItems = $QuoteItemsTable(this);
  late final $HsnCodesTable hsnCodes = $HsnCodesTable(this);
  late final $HsnCodeRatesTable hsnCodeRates = $HsnCodeRatesTable(this);
  late final $UomsTable uoms = $UomsTable(this);
  late final $TemplateConfigsTable templateConfigs = $TemplateConfigsTable(
    this,
  );
  late final $DocumentSequencesTable documentSequences =
      $DocumentSequencesTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $RecurringInvoicesTable recurringInvoices =
      $RecurringInvoicesTable(this);
  late final Index idxCustomersBusinessId = Index(
    'idx_customers_business_id',
    'CREATE INDEX idx_customers_business_id ON customers (business_id)',
  );
  late final Index idxProductsBusinessId = Index(
    'idx_products_business_id',
    'CREATE INDEX idx_products_business_id ON products (business_id)',
  );
  late final Index idxInvoicesBusinessId = Index(
    'idx_invoices_business_id',
    'CREATE INDEX idx_invoices_business_id ON invoices (business_id)',
  );
  late final Index idxInvoicesCustomerId = Index(
    'idx_invoices_customer_id',
    'CREATE INDEX idx_invoices_customer_id ON invoices (customer_id)',
  );
  late final Index idxInvoicesInvoiceDate = Index(
    'idx_invoices_invoice_date',
    'CREATE INDEX idx_invoices_invoice_date ON invoices (invoice_date)',
  );
  late final Index idxInvoicesStatus = Index(
    'idx_invoices_status',
    'CREATE INDEX idx_invoices_status ON invoices (status)',
  );
  late final Index idxInvoiceItemsInvoiceId = Index(
    'idx_invoice_items_invoice_id',
    'CREATE INDEX idx_invoice_items_invoice_id ON invoice_items (invoice_id)',
  );
  late final Index idxInvoiceItemsProductId = Index(
    'idx_invoice_items_product_id',
    'CREATE INDEX idx_invoice_items_product_id ON invoice_items (product_id)',
  );
  late final Index idxInvoicePaymentsInvoiceId = Index(
    'idx_invoice_payments_invoice_id',
    'CREATE INDEX idx_invoice_payments_invoice_id ON invoice_payments (invoice_id)',
  );
  late final Index idxCustomerActivityBusinessId = Index(
    'idx_customer_activity_business_id',
    'CREATE INDEX idx_customer_activity_business_id ON customer_activity_events (business_id)',
  );
  late final Index idxCustomerActivityCustomerId = Index(
    'idx_customer_activity_customer_id',
    'CREATE INDEX idx_customer_activity_customer_id ON customer_activity_events (customer_id)',
  );
  late final Index idxQuotesBusinessId = Index(
    'idx_quotes_business_id',
    'CREATE INDEX idx_quotes_business_id ON quotes (business_id)',
  );
  late final Index idxQuotesCustomerId = Index(
    'idx_quotes_customer_id',
    'CREATE INDEX idx_quotes_customer_id ON quotes (customer_id)',
  );
  late final Index idxQuoteItemsQuoteId = Index(
    'idx_quote_items_quote_id',
    'CREATE INDEX idx_quote_items_quote_id ON quote_items (quote_id)',
  );
  late final Index idxQuoteItemsProductId = Index(
    'idx_quote_items_product_id',
    'CREATE INDEX idx_quote_items_product_id ON quote_items (product_id)',
  );
  late final Index idxTemplateConfigsBusinessId = Index(
    'idx_template_configs_business_id',
    'CREATE INDEX idx_template_configs_business_id ON template_configs (business_id)',
  );
  late final Index idxStockMovementsProductId = Index(
    'idx_stock_movements_product_id',
    'CREATE INDEX idx_stock_movements_product_id ON stock_movements (product_id)',
  );
  late final Index idxRecurringInvoicesSource = Index(
    'idx_recurring_invoices_source',
    'CREATE INDEX idx_recurring_invoices_source ON recurring_invoices (source_invoice_id)',
  );
  late final BusinessDao businessDao = BusinessDao(this as AppDatabase);
  late final CustomerDao customerDao = CustomerDao(this as AppDatabase);
  late final ProductDao productDao = ProductDao(this as AppDatabase);
  late final InvoiceDao invoiceDao = InvoiceDao(this as AppDatabase);
  late final QuoteDao quoteDao = QuoteDao(this as AppDatabase);
  late final CustomerActivityDao customerActivityDao = CustomerActivityDao(
    this as AppDatabase,
  );
  late final HsnDao hsnDao = HsnDao(this as AppDatabase);
  late final UomDao uomDao = UomDao(this as AppDatabase);
  late final TemplateConfigDao templateConfigDao = TemplateConfigDao(
    this as AppDatabase,
  );
  late final RecurringInvoiceDao recurringInvoiceDao = RecurringInvoiceDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    businesses,
    customers,
    products,
    invoices,
    invoiceItems,
    invoicePayments,
    customerActivityEvents,
    quotes,
    quoteItems,
    hsnCodes,
    hsnCodeRates,
    uoms,
    templateConfigs,
    documentSequences,
    stockMovements,
    recurringInvoices,
    idxCustomersBusinessId,
    idxProductsBusinessId,
    idxInvoicesBusinessId,
    idxInvoicesCustomerId,
    idxInvoicesInvoiceDate,
    idxInvoicesStatus,
    idxInvoiceItemsInvoiceId,
    idxInvoiceItemsProductId,
    idxInvoicePaymentsInvoiceId,
    idxCustomerActivityBusinessId,
    idxCustomerActivityCustomerId,
    idxQuotesBusinessId,
    idxQuotesCustomerId,
    idxQuoteItemsQuoteId,
    idxQuoteItemsProductId,
    idxTemplateConfigsBusinessId,
    idxStockMovementsProductId,
    idxRecurringInvoicesSource,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'invoices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'invoices',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('invoice_payments', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'quotes',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('quote_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'products',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('stock_movements', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BusinessesTableCreateCompanionBuilder =
    BusinessesCompanion Function({
      Value<int> id,
      required String name,
      required String gstin,
      Value<String?> pan,
      Value<BusinessType> businessType,
      required String address,
      required String city,
      required int stateCode,
      Value<String?> pincode,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String?> bankName,
      Value<String?> bankAccount,
      Value<String?> bankIfsc,
      Value<String?> upiId,
      Value<String> currencyCode,
      Value<String> invoiceTemplate,
      Value<String> quoteTemplate,
      Value<String> invoiceSeriesFormat,
      Value<String> quoteSeriesFormat,
      Value<String> creditNoteSeriesFormat,
      Value<String> debitNoteSeriesFormat,
      Value<String> billOfSupplySeriesFormat,
      Value<int?> defaultInvoiceTemplateId,
      Value<int?> defaultQuoteTemplateId,
      Value<int?> brandColor,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$BusinessesTableUpdateCompanionBuilder =
    BusinessesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> gstin,
      Value<String?> pan,
      Value<BusinessType> businessType,
      Value<String> address,
      Value<String> city,
      Value<int> stateCode,
      Value<String?> pincode,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String?> bankName,
      Value<String?> bankAccount,
      Value<String?> bankIfsc,
      Value<String?> upiId,
      Value<String> currencyCode,
      Value<String> invoiceTemplate,
      Value<String> quoteTemplate,
      Value<String> invoiceSeriesFormat,
      Value<String> quoteSeriesFormat,
      Value<String> creditNoteSeriesFormat,
      Value<String> debitNoteSeriesFormat,
      Value<String> billOfSupplySeriesFormat,
      Value<int?> defaultInvoiceTemplateId,
      Value<int?> defaultQuoteTemplateId,
      Value<int?> brandColor,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$BusinessesTableReferences
    extends BaseReferences<_$AppDatabase, $BusinessesTable, Business> {
  $$BusinessesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomersTable, List<Customer>>
  _customersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.customers,
    aliasName: 'businesses__id__customers__business_id',
  );

  $$CustomersTableProcessedTableManager get customersRefs {
    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_customersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ProductsTable, List<Product>> _productsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.products,
    aliasName: 'businesses__id__products__business_id',
  );

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'businesses__id__invoices__business_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CustomerActivityEventsTable,
    List<CustomerActivityEvent>
  >
  _customerActivityEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerActivityEvents,
        aliasName: 'businesses__id__customer_activity_events__business_id',
      );

  $$CustomerActivityEventsTableProcessedTableManager
  get customerActivityEventsRefs {
    final manager = $$CustomerActivityEventsTableTableManager(
      $_db,
      $_db.customerActivityEvents,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerActivityEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<Quote>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'businesses__id__quotes__business_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TemplateConfigsTable, List<TemplateConfig>>
  _templateConfigsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.templateConfigs,
    aliasName: 'businesses__id__template_configs__business_id',
  );

  $$TemplateConfigsTableProcessedTableManager get templateConfigsRefs {
    final manager = $$TemplateConfigsTableTableManager(
      $_db,
      $_db.templateConfigs,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateConfigsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DocumentSequencesTable, List<DocumentSequence>>
  _documentSequencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.documentSequences,
        aliasName: 'businesses__id__document_sequences__business_id',
      );

  $$DocumentSequencesTableProcessedTableManager get documentSequencesRefs {
    final manager = $$DocumentSequencesTableTableManager(
      $_db,
      $_db.documentSequences,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _documentSequencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringInvoicesTable, List<RecurringInvoice>>
  _recurringInvoicesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringInvoices,
        aliasName: 'businesses__id__recurring_invoices__business_id',
      );

  $$RecurringInvoicesTableProcessedTableManager get recurringInvoicesRefs {
    final manager = $$RecurringInvoicesTableTableManager(
      $_db,
      $_db.recurringInvoices,
    ).filter((f) => f.businessId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringInvoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BusinessesTableFilterComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<BusinessType, BusinessType, int>
  get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bankIfsc => $composableBuilder(
    column: $table.bankIfsc,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceTemplate => $composableBuilder(
    column: $table.invoiceTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteTemplate => $composableBuilder(
    column: $table.quoteTemplate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceSeriesFormat => $composableBuilder(
    column: $table.invoiceSeriesFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get quoteSeriesFormat => $composableBuilder(
    column: $table.quoteSeriesFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creditNoteSeriesFormat => $composableBuilder(
    column: $table.creditNoteSeriesFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get debitNoteSeriesFormat => $composableBuilder(
    column: $table.debitNoteSeriesFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billOfSupplySeriesFormat => $composableBuilder(
    column: $table.billOfSupplySeriesFormat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultInvoiceTemplateId => $composableBuilder(
    column: $table.defaultInvoiceTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultQuoteTemplateId => $composableBuilder(
    column: $table.defaultQuoteTemplateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> customersRefs(
    Expression<bool> Function($$CustomersTableFilterComposer f) f,
  ) {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> productsRefs(
    Expression<bool> Function($$ProductsTableFilterComposer f) f,
  ) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerActivityEventsRefs(
    Expression<bool> Function($$CustomerActivityEventsTableFilterComposer f) f,
  ) {
    final $$CustomerActivityEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerActivityEvents,
          getReferencedColumn: (t) => t.businessId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerActivityEventsTableFilterComposer(
                $db: $db,
                $table: $db.customerActivityEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> templateConfigsRefs(
    Expression<bool> Function($$TemplateConfigsTableFilterComposer f) f,
  ) {
    final $$TemplateConfigsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateConfigs,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateConfigsTableFilterComposer(
            $db: $db,
            $table: $db.templateConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> documentSequencesRefs(
    Expression<bool> Function($$DocumentSequencesTableFilterComposer f) f,
  ) {
    final $$DocumentSequencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.documentSequences,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DocumentSequencesTableFilterComposer(
            $db: $db,
            $table: $db.documentSequences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringInvoicesRefs(
    Expression<bool> Function($$RecurringInvoicesTableFilterComposer f) f,
  ) {
    final $$RecurringInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringInvoices,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.recurringInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BusinessesTableOrderingComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get businessType => $composableBuilder(
    column: $table.businessType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankName => $composableBuilder(
    column: $table.bankName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bankIfsc => $composableBuilder(
    column: $table.bankIfsc,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get upiId => $composableBuilder(
    column: $table.upiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceTemplate => $composableBuilder(
    column: $table.invoiceTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteTemplate => $composableBuilder(
    column: $table.quoteTemplate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceSeriesFormat => $composableBuilder(
    column: $table.invoiceSeriesFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get quoteSeriesFormat => $composableBuilder(
    column: $table.quoteSeriesFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creditNoteSeriesFormat => $composableBuilder(
    column: $table.creditNoteSeriesFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get debitNoteSeriesFormat => $composableBuilder(
    column: $table.debitNoteSeriesFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billOfSupplySeriesFormat => $composableBuilder(
    column: $table.billOfSupplySeriesFormat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultInvoiceTemplateId => $composableBuilder(
    column: $table.defaultInvoiceTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultQuoteTemplateId => $composableBuilder(
    column: $table.defaultQuoteTemplateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BusinessesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BusinessesTable> {
  $$BusinessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumnWithTypeConverter<BusinessType, int> get businessType =>
      $composableBuilder(
        column: $table.businessType,
        builder: (column) => column,
      );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<int> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get bankAccount => $composableBuilder(
    column: $table.bankAccount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bankIfsc =>
      $composableBuilder(column: $table.bankIfsc, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceTemplate => $composableBuilder(
    column: $table.invoiceTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteTemplate => $composableBuilder(
    column: $table.quoteTemplate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get invoiceSeriesFormat => $composableBuilder(
    column: $table.invoiceSeriesFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get quoteSeriesFormat => $composableBuilder(
    column: $table.quoteSeriesFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get creditNoteSeriesFormat => $composableBuilder(
    column: $table.creditNoteSeriesFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get debitNoteSeriesFormat => $composableBuilder(
    column: $table.debitNoteSeriesFormat,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billOfSupplySeriesFormat => $composableBuilder(
    column: $table.billOfSupplySeriesFormat,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultInvoiceTemplateId => $composableBuilder(
    column: $table.defaultInvoiceTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultQuoteTemplateId => $composableBuilder(
    column: $table.defaultQuoteTemplateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get brandColor => $composableBuilder(
    column: $table.brandColor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> customersRefs<T extends Object>(
    Expression<T> Function($$CustomersTableAnnotationComposer a) f,
  ) {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> productsRefs<T extends Object>(
    Expression<T> Function($$ProductsTableAnnotationComposer a) f,
  ) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerActivityEventsRefs<T extends Object>(
    Expression<T> Function($$CustomerActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$CustomerActivityEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerActivityEvents,
          getReferencedColumn: (t) => t.businessId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerActivityEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerActivityEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> templateConfigsRefs<T extends Object>(
    Expression<T> Function($$TemplateConfigsTableAnnotationComposer a) f,
  ) {
    final $$TemplateConfigsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateConfigs,
      getReferencedColumn: (t) => t.businessId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateConfigsTableAnnotationComposer(
            $db: $db,
            $table: $db.templateConfigs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> documentSequencesRefs<T extends Object>(
    Expression<T> Function($$DocumentSequencesTableAnnotationComposer a) f,
  ) {
    final $$DocumentSequencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.documentSequences,
          getReferencedColumn: (t) => t.businessId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$DocumentSequencesTableAnnotationComposer(
                $db: $db,
                $table: $db.documentSequences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> recurringInvoicesRefs<T extends Object>(
    Expression<T> Function($$RecurringInvoicesTableAnnotationComposer a) f,
  ) {
    final $$RecurringInvoicesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringInvoices,
          getReferencedColumn: (t) => t.businessId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringInvoicesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$BusinessesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BusinessesTable,
          Business,
          $$BusinessesTableFilterComposer,
          $$BusinessesTableOrderingComposer,
          $$BusinessesTableAnnotationComposer,
          $$BusinessesTableCreateCompanionBuilder,
          $$BusinessesTableUpdateCompanionBuilder,
          (Business, $$BusinessesTableReferences),
          Business,
          PrefetchHooks Function({
            bool customersRefs,
            bool productsRefs,
            bool invoicesRefs,
            bool customerActivityEventsRefs,
            bool quotesRefs,
            bool templateConfigsRefs,
            bool documentSequencesRefs,
            bool recurringInvoicesRefs,
          })
        > {
  $$BusinessesTableTableManager(_$AppDatabase db, $BusinessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BusinessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BusinessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BusinessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> gstin = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<BusinessType> businessType = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> city = const Value.absent(),
                Value<int> stateCode = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> bankAccount = const Value.absent(),
                Value<String?> bankIfsc = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> invoiceTemplate = const Value.absent(),
                Value<String> quoteTemplate = const Value.absent(),
                Value<String> invoiceSeriesFormat = const Value.absent(),
                Value<String> quoteSeriesFormat = const Value.absent(),
                Value<String> creditNoteSeriesFormat = const Value.absent(),
                Value<String> debitNoteSeriesFormat = const Value.absent(),
                Value<String> billOfSupplySeriesFormat = const Value.absent(),
                Value<int?> defaultInvoiceTemplateId = const Value.absent(),
                Value<int?> defaultQuoteTemplateId = const Value.absent(),
                Value<int?> brandColor = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => BusinessesCompanion(
                id: id,
                name: name,
                gstin: gstin,
                pan: pan,
                businessType: businessType,
                address: address,
                city: city,
                stateCode: stateCode,
                pincode: pincode,
                phone: phone,
                email: email,
                logoPath: logoPath,
                bankName: bankName,
                bankAccount: bankAccount,
                bankIfsc: bankIfsc,
                upiId: upiId,
                currencyCode: currencyCode,
                invoiceTemplate: invoiceTemplate,
                quoteTemplate: quoteTemplate,
                invoiceSeriesFormat: invoiceSeriesFormat,
                quoteSeriesFormat: quoteSeriesFormat,
                creditNoteSeriesFormat: creditNoteSeriesFormat,
                debitNoteSeriesFormat: debitNoteSeriesFormat,
                billOfSupplySeriesFormat: billOfSupplySeriesFormat,
                defaultInvoiceTemplateId: defaultInvoiceTemplateId,
                defaultQuoteTemplateId: defaultQuoteTemplateId,
                brandColor: brandColor,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String gstin,
                Value<String?> pan = const Value.absent(),
                Value<BusinessType> businessType = const Value.absent(),
                required String address,
                required String city,
                required int stateCode,
                Value<String?> pincode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String?> bankName = const Value.absent(),
                Value<String?> bankAccount = const Value.absent(),
                Value<String?> bankIfsc = const Value.absent(),
                Value<String?> upiId = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> invoiceTemplate = const Value.absent(),
                Value<String> quoteTemplate = const Value.absent(),
                Value<String> invoiceSeriesFormat = const Value.absent(),
                Value<String> quoteSeriesFormat = const Value.absent(),
                Value<String> creditNoteSeriesFormat = const Value.absent(),
                Value<String> debitNoteSeriesFormat = const Value.absent(),
                Value<String> billOfSupplySeriesFormat = const Value.absent(),
                Value<int?> defaultInvoiceTemplateId = const Value.absent(),
                Value<int?> defaultQuoteTemplateId = const Value.absent(),
                Value<int?> brandColor = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => BusinessesCompanion.insert(
                id: id,
                name: name,
                gstin: gstin,
                pan: pan,
                businessType: businessType,
                address: address,
                city: city,
                stateCode: stateCode,
                pincode: pincode,
                phone: phone,
                email: email,
                logoPath: logoPath,
                bankName: bankName,
                bankAccount: bankAccount,
                bankIfsc: bankIfsc,
                upiId: upiId,
                currencyCode: currencyCode,
                invoiceTemplate: invoiceTemplate,
                quoteTemplate: quoteTemplate,
                invoiceSeriesFormat: invoiceSeriesFormat,
                quoteSeriesFormat: quoteSeriesFormat,
                creditNoteSeriesFormat: creditNoteSeriesFormat,
                debitNoteSeriesFormat: debitNoteSeriesFormat,
                billOfSupplySeriesFormat: billOfSupplySeriesFormat,
                defaultInvoiceTemplateId: defaultInvoiceTemplateId,
                defaultQuoteTemplateId: defaultQuoteTemplateId,
                brandColor: brandColor,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BusinessesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customersRefs = false,
                productsRefs = false,
                invoicesRefs = false,
                customerActivityEventsRefs = false,
                quotesRefs = false,
                templateConfigsRefs = false,
                documentSequencesRefs = false,
                recurringInvoicesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (customersRefs) db.customers,
                    if (productsRefs) db.products,
                    if (invoicesRefs) db.invoices,
                    if (customerActivityEventsRefs) db.customerActivityEvents,
                    if (quotesRefs) db.quotes,
                    if (templateConfigsRefs) db.templateConfigs,
                    if (documentSequencesRefs) db.documentSequences,
                    if (recurringInvoicesRefs) db.recurringInvoices,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (customersRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          Customer
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._customersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).customersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (productsRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          Product
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._productsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).productsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (invoicesRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          Invoice
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._invoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerActivityEventsRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          CustomerActivityEvent
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._customerActivityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).customerActivityEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          Quote
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).quotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (templateConfigsRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          TemplateConfig
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._templateConfigsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateConfigsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (documentSequencesRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          DocumentSequence
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._documentSequencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).documentSequencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringInvoicesRefs)
                        await $_getPrefetchedData<
                          Business,
                          $BusinessesTable,
                          RecurringInvoice
                        >(
                          currentTable: table,
                          referencedTable: $$BusinessesTableReferences
                              ._recurringInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BusinessesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.businessId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BusinessesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BusinessesTable,
      Business,
      $$BusinessesTableFilterComposer,
      $$BusinessesTableOrderingComposer,
      $$BusinessesTableAnnotationComposer,
      $$BusinessesTableCreateCompanionBuilder,
      $$BusinessesTableUpdateCompanionBuilder,
      (Business, $$BusinessesTableReferences),
      Business,
      PrefetchHooks Function({
        bool customersRefs,
        bool productsRefs,
        bool invoicesRefs,
        bool customerActivityEventsRefs,
        bool quotesRefs,
        bool templateConfigsRefs,
        bool documentSequencesRefs,
        bool recurringInvoicesRefs,
      })
    >;
typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required int businessId,
      required String name,
      Value<String?> gstin,
      Value<String?> pan,
      Value<String?> address,
      Value<String?> city,
      Value<int?> stateCode,
      Value<String?> pincode,
      Value<String?> phone,
      Value<String?> email,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<String> name,
      Value<String?> gstin,
      Value<String?> pan,
      Value<String?> address,
      Value<String?> city,
      Value<int?> stateCode,
      Value<String?> pincode,
      Value<String?> phone,
      Value<String?> email,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessesTable _businessIdTable(_$AppDatabase db) =>
      db.businesses.createAlias('customers__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoicesTable, List<Invoice>> _invoicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.invoices,
    aliasName: 'customers__id__invoices__customer_id',
  );

  $$InvoicesTableProcessedTableManager get invoicesRefs {
    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $CustomerActivityEventsTable,
    List<CustomerActivityEvent>
  >
  _customerActivityEventsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.customerActivityEvents,
        aliasName: 'customers__id__customer_activity_events__customer_id',
      );

  $$CustomerActivityEventsTableProcessedTableManager
  get customerActivityEventsRefs {
    final manager = $$CustomerActivityEventsTableTableManager(
      $_db,
      $_db.customerActivityEvents,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _customerActivityEventsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<Quote>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'customers__id__quotes__customer_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoicesRefs(
    Expression<bool> Function($$InvoicesTableFilterComposer f) f,
  ) {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> customerActivityEventsRefs(
    Expression<bool> Function($$CustomerActivityEventsTableFilterComposer f) f,
  ) {
    final $$CustomerActivityEventsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerActivityEvents,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerActivityEventsTableFilterComposer(
                $db: $db,
                $table: $db.customerActivityEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gstin => $composableBuilder(
    column: $table.gstin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pan => $composableBuilder(
    column: $table.pan,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get city => $composableBuilder(
    column: $table.city,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stateCode => $composableBuilder(
    column: $table.stateCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pincode => $composableBuilder(
    column: $table.pincode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get gstin =>
      $composableBuilder(column: $table.gstin, builder: (column) => column);

  GeneratedColumn<String> get pan =>
      $composableBuilder(column: $table.pan, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get city =>
      $composableBuilder(column: $table.city, builder: (column) => column);

  GeneratedColumn<int> get stateCode =>
      $composableBuilder(column: $table.stateCode, builder: (column) => column);

  GeneratedColumn<String> get pincode =>
      $composableBuilder(column: $table.pincode, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoicesRefs<T extends Object>(
    Expression<T> Function($$InvoicesTableAnnotationComposer a) f,
  ) {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> customerActivityEventsRefs<T extends Object>(
    Expression<T> Function($$CustomerActivityEventsTableAnnotationComposer a) f,
  ) {
    final $$CustomerActivityEventsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.customerActivityEvents,
          getReferencedColumn: (t) => t.customerId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$CustomerActivityEventsTableAnnotationComposer(
                $db: $db,
                $table: $db.customerActivityEvents,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({
            bool businessId,
            bool invoicesRefs,
            bool customerActivityEventsRefs,
            bool quotesRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> gstin = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<int?> stateCode = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                businessId: businessId,
                name: name,
                gstin: gstin,
                pan: pan,
                address: address,
                city: city,
                stateCode: stateCode,
                pincode: pincode,
                phone: phone,
                email: email,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required String name,
                Value<String?> gstin = const Value.absent(),
                Value<String?> pan = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> city = const Value.absent(),
                Value<int?> stateCode = const Value.absent(),
                Value<String?> pincode = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => CustomersCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                gstin: gstin,
                pan: pan,
                address: address,
                city: city,
                stateCode: stateCode,
                pincode: pincode,
                phone: phone,
                email: email,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                businessId = false,
                invoicesRefs = false,
                customerActivityEventsRefs = false,
                quotesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoicesRefs) db.invoices,
                    if (customerActivityEventsRefs) db.customerActivityEvents,
                    if (quotesRefs) db.quotes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (businessId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.businessId,
                                    referencedTable: $$CustomersTableReferences
                                        ._businessIdTable(db),
                                    referencedColumn: $$CustomersTableReferences
                                        ._businessIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoicesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Invoice
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._invoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (customerActivityEventsRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          CustomerActivityEvent
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._customerActivityEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).customerActivityEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Quote
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).quotesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({
        bool businessId,
        bool invoicesRefs,
        bool customerActivityEventsRefs,
        bool quotesRefs,
      })
    >;
typedef $$ProductsTableCreateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      required int businessId,
      required String name,
      Value<String?> description,
      required String hsnSac,
      required String unit,
      required double salePrice,
      Value<double?> purchasePrice,
      required double gstRate,
      Value<double> cessRate,
      Value<double> stockQuantity,
      Value<double> reorderLevel,
      Value<bool> isService,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$ProductsTableUpdateCompanionBuilder =
    ProductsCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<String> name,
      Value<String?> description,
      Value<String> hsnSac,
      Value<String> unit,
      Value<double> salePrice,
      Value<double?> purchasePrice,
      Value<double> gstRate,
      Value<double> cessRate,
      Value<double> stockQuantity,
      Value<double> reorderLevel,
      Value<bool> isService,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, Product> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessesTable _businessIdTable(_$AppDatabase db) =>
      db.businesses.createAlias('products__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: 'products__id__invoice_items__product_id',
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuoteItemsTable, List<QuoteItem>>
  _quoteItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quoteItems,
    aliasName: 'products__id__quote_items__product_id',
  );

  $$QuoteItemsTableProcessedTableManager get quoteItemsRefs {
    final manager = $$QuoteItemsTableTableManager(
      $_db,
      $_db.quoteItems,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quoteItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StockMovementsTable, List<StockMovement>>
  _stockMovementsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.stockMovements,
    aliasName: 'products__id__stock_movements__product_id',
  );

  $$StockMovementsTableProcessedTableManager get stockMovementsRefs {
    final manager = $$StockMovementsTableTableManager(
      $_db,
      $_db.stockMovements,
    ).filter((f) => f.productId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stockMovementsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isService => $composableBuilder(
    column: $table.isService,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quoteItemsRefs(
    Expression<bool> Function($$QuoteItemsTableFilterComposer f) f,
  ) {
    final $$QuoteItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableFilterComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> stockMovementsRefs(
    Expression<bool> Function($$StockMovementsTableFilterComposer f) f,
  ) {
    final $$StockMovementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableFilterComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get salePrice => $composableBuilder(
    column: $table.salePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isService => $composableBuilder(
    column: $table.isService,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get hsnSac =>
      $composableBuilder(column: $table.hsnSac, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get salePrice =>
      $composableBuilder(column: $table.salePrice, builder: (column) => column);

  GeneratedColumn<double> get purchasePrice => $composableBuilder(
    column: $table.purchasePrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<double> get cessRate =>
      $composableBuilder(column: $table.cessRate, builder: (column) => column);

  GeneratedColumn<double> get stockQuantity => $composableBuilder(
    column: $table.stockQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get reorderLevel => $composableBuilder(
    column: $table.reorderLevel,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isService =>
      $composableBuilder(column: $table.isService, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quoteItemsRefs<T extends Object>(
    Expression<T> Function($$QuoteItemsTableAnnotationComposer a) f,
  ) {
    final $$QuoteItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> stockMovementsRefs<T extends Object>(
    Expression<T> Function($$StockMovementsTableAnnotationComposer a) f,
  ) {
    final $$StockMovementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stockMovements,
      getReferencedColumn: (t) => t.productId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StockMovementsTableAnnotationComposer(
            $db: $db,
            $table: $db.stockMovements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProductsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductsTable,
          Product,
          $$ProductsTableFilterComposer,
          $$ProductsTableOrderingComposer,
          $$ProductsTableAnnotationComposer,
          $$ProductsTableCreateCompanionBuilder,
          $$ProductsTableUpdateCompanionBuilder,
          (Product, $$ProductsTableReferences),
          Product,
          PrefetchHooks Function({
            bool businessId,
            bool invoiceItemsRefs,
            bool quoteItemsRefs,
            bool stockMovementsRefs,
          })
        > {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> hsnSac = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> salePrice = const Value.absent(),
                Value<double?> purchasePrice = const Value.absent(),
                Value<double> gstRate = const Value.absent(),
                Value<double> cessRate = const Value.absent(),
                Value<double> stockQuantity = const Value.absent(),
                Value<double> reorderLevel = const Value.absent(),
                Value<bool> isService = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ProductsCompanion(
                id: id,
                businessId: businessId,
                name: name,
                description: description,
                hsnSac: hsnSac,
                unit: unit,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                gstRate: gstRate,
                cessRate: cessRate,
                stockQuantity: stockQuantity,
                reorderLevel: reorderLevel,
                isService: isService,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required String name,
                Value<String?> description = const Value.absent(),
                required String hsnSac,
                required String unit,
                required double salePrice,
                Value<double?> purchasePrice = const Value.absent(),
                required double gstRate,
                Value<double> cessRate = const Value.absent(),
                Value<double> stockQuantity = const Value.absent(),
                Value<double> reorderLevel = const Value.absent(),
                Value<bool> isService = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => ProductsCompanion.insert(
                id: id,
                businessId: businessId,
                name: name,
                description: description,
                hsnSac: hsnSac,
                unit: unit,
                salePrice: salePrice,
                purchasePrice: purchasePrice,
                gstRate: gstRate,
                cessRate: cessRate,
                stockQuantity: stockQuantity,
                reorderLevel: reorderLevel,
                isService: isService,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProductsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                businessId = false,
                invoiceItemsRefs = false,
                quoteItemsRefs = false,
                stockMovementsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoiceItemsRefs) db.invoiceItems,
                    if (quoteItemsRefs) db.quoteItems,
                    if (stockMovementsRefs) db.stockMovements,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (businessId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.businessId,
                                    referencedTable: $$ProductsTableReferences
                                        ._businessIdTable(db),
                                    referencedColumn: $$ProductsTableReferences
                                        ._businessIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoiceItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          InvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (quoteItemsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          QuoteItem
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._quoteItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).quoteItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (stockMovementsRefs)
                        await $_getPrefetchedData<
                          Product,
                          $ProductsTable,
                          StockMovement
                        >(
                          currentTable: table,
                          referencedTable: $$ProductsTableReferences
                              ._stockMovementsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ProductsTableReferences(
                                db,
                                table,
                                p0,
                              ).stockMovementsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.productId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ProductsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductsTable,
      Product,
      $$ProductsTableFilterComposer,
      $$ProductsTableOrderingComposer,
      $$ProductsTableAnnotationComposer,
      $$ProductsTableCreateCompanionBuilder,
      $$ProductsTableUpdateCompanionBuilder,
      (Product, $$ProductsTableReferences),
      Product,
      PrefetchHooks Function({
        bool businessId,
        bool invoiceItemsRefs,
        bool quoteItemsRefs,
        bool stockMovementsRefs,
      })
    >;
typedef $$InvoicesTableCreateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      required int businessId,
      required int customerId,
      required String invoiceNumber,
      Value<String> currencyCode,
      required DateTime invoiceDate,
      Value<DateTime?> dueDate,
      required String invoiceType,
      required String supplyType,
      required int placeOfSupply,
      required double subtotal,
      Value<double> discountAmount,
      required double taxableAmount,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      required double totalAmount,
      Value<double> roundOffAmount,
      Value<double> amountPaid,
      Value<String?> amountInWords,
      Value<String?> notes,
      Value<String?> terms,
      Value<String> status,
      Value<bool> isIgst,
      Value<int?> templateId,
      Value<int?> referenceInvoiceId,
      Value<bool> reverseCharge,
      Value<String?> shipToName,
      Value<String?> shipToAddress,
      Value<String?> shipToCity,
      Value<bool> exportWithLut,
      Value<String?> tdsSection,
      Value<double> tdsRate,
      Value<double> tdsAmount,
      Value<String?> tcsSection,
      Value<double> tcsRate,
      Value<double> tcsAmount,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$InvoicesTableUpdateCompanionBuilder =
    InvoicesCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<int> customerId,
      Value<String> invoiceNumber,
      Value<String> currencyCode,
      Value<DateTime> invoiceDate,
      Value<DateTime?> dueDate,
      Value<String> invoiceType,
      Value<String> supplyType,
      Value<int> placeOfSupply,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<double> taxableAmount,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      Value<double> totalAmount,
      Value<double> roundOffAmount,
      Value<double> amountPaid,
      Value<String?> amountInWords,
      Value<String?> notes,
      Value<String?> terms,
      Value<String> status,
      Value<bool> isIgst,
      Value<int?> templateId,
      Value<int?> referenceInvoiceId,
      Value<bool> reverseCharge,
      Value<String?> shipToName,
      Value<String?> shipToAddress,
      Value<String?> shipToCity,
      Value<bool> exportWithLut,
      Value<String?> tdsSection,
      Value<double> tdsRate,
      Value<double> tdsAmount,
      Value<String?> tcsSection,
      Value<double> tcsRate,
      Value<double> tcsAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$InvoicesTableReferences
    extends BaseReferences<_$AppDatabase, $InvoicesTable, Invoice> {
  $$InvoicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessesTable _businessIdTable(_$AppDatabase db) =>
      db.businesses.createAlias('invoices__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('invoices__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$InvoiceItemsTable, List<InvoiceItem>>
  _invoiceItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoiceItems,
    aliasName: 'invoices__id__invoice_items__invoice_id',
  );

  $$InvoiceItemsTableProcessedTableManager get invoiceItemsRefs {
    final manager = $$InvoiceItemsTableTableManager(
      $_db,
      $_db.invoiceItems,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_invoiceItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$InvoicePaymentsTable, List<InvoicePayment>>
  _invoicePaymentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.invoicePayments,
    aliasName: 'invoices__id__invoice_payments__invoice_id',
  );

  $$InvoicePaymentsTableProcessedTableManager get invoicePaymentsRefs {
    final manager = $$InvoicePaymentsTableTableManager(
      $_db,
      $_db.invoicePayments,
    ).filter((f) => f.invoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _invoicePaymentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecurringInvoicesTable, List<RecurringInvoice>>
  _recurringInvoicesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringInvoices,
        aliasName: 'invoices__id__recurring_invoices__source_invoice_id',
      );

  $$RecurringInvoicesTableProcessedTableManager get recurringInvoicesRefs {
    final manager = $$RecurringInvoicesTableTableManager(
      $_db,
      $_db.recurringInvoices,
    ).filter((f) => f.sourceInvoiceId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringInvoicesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgst => $composableBuilder(
    column: $table.isIgst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get referenceInvoiceId => $composableBuilder(
    column: $table.referenceInvoiceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsRate => $composableBuilder(
    column: $table.tdsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcsRate => $composableBuilder(
    column: $table.tcsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> invoiceItemsRefs(
    Expression<bool> Function($$InvoiceItemsTableFilterComposer f) f,
  ) {
    final $$InvoiceItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableFilterComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> invoicePaymentsRefs(
    Expression<bool> Function($$InvoicePaymentsTableFilterComposer f) f,
  ) {
    final $$InvoicePaymentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableFilterComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recurringInvoicesRefs(
    Expression<bool> Function($$RecurringInvoicesTableFilterComposer f) f,
  ) {
    final $$RecurringInvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recurringInvoices,
      getReferencedColumn: (t) => t.sourceInvoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecurringInvoicesTableFilterComposer(
            $db: $db,
            $table: $db.recurringInvoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgst => $composableBuilder(
    column: $table.isIgst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get referenceInvoiceId => $composableBuilder(
    column: $table.referenceInvoiceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsRate => $composableBuilder(
    column: $table.tdsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcsRate => $composableBuilder(
    column: $table.tcsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicesTable> {
  $$InvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isIgst =>
      $composableBuilder(column: $table.isIgst, builder: (column) => column);

  GeneratedColumn<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get referenceInvoiceId => $composableBuilder(
    column: $table.referenceInvoiceId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tdsRate =>
      $composableBuilder(column: $table.tdsRate, builder: (column) => column);

  GeneratedColumn<double> get tdsAmount =>
      $composableBuilder(column: $table.tdsAmount, builder: (column) => column);

  GeneratedColumn<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tcsRate =>
      $composableBuilder(column: $table.tcsRate, builder: (column) => column);

  GeneratedColumn<double> get tcsAmount =>
      $composableBuilder(column: $table.tcsAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> invoiceItemsRefs<T extends Object>(
    Expression<T> Function($$InvoiceItemsTableAnnotationComposer a) f,
  ) {
    final $$InvoiceItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoiceItems,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoiceItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoiceItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> invoicePaymentsRefs<T extends Object>(
    Expression<T> Function($$InvoicePaymentsTableAnnotationComposer a) f,
  ) {
    final $$InvoicePaymentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.invoicePayments,
      getReferencedColumn: (t) => t.invoiceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicePaymentsTableAnnotationComposer(
            $db: $db,
            $table: $db.invoicePayments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recurringInvoicesRefs<T extends Object>(
    Expression<T> Function($$RecurringInvoicesTableAnnotationComposer a) f,
  ) {
    final $$RecurringInvoicesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringInvoices,
          getReferencedColumn: (t) => t.sourceInvoiceId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringInvoicesTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringInvoices,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicesTable,
          Invoice,
          $$InvoicesTableFilterComposer,
          $$InvoicesTableOrderingComposer,
          $$InvoicesTableAnnotationComposer,
          $$InvoicesTableCreateCompanionBuilder,
          $$InvoicesTableUpdateCompanionBuilder,
          (Invoice, $$InvoicesTableReferences),
          Invoice,
          PrefetchHooks Function({
            bool businessId,
            bool customerId,
            bool invoiceItemsRefs,
            bool invoicePaymentsRefs,
            bool recurringInvoicesRefs,
          })
        > {
  $$InvoicesTableTableManager(_$AppDatabase db, $InvoicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String> supplyType = const Value.absent(),
                Value<int> placeOfSupply = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> roundOffAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isIgst = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<int?> referenceInvoiceId = const Value.absent(),
                Value<bool> reverseCharge = const Value.absent(),
                Value<String?> shipToName = const Value.absent(),
                Value<String?> shipToAddress = const Value.absent(),
                Value<String?> shipToCity = const Value.absent(),
                Value<bool> exportWithLut = const Value.absent(),
                Value<String?> tdsSection = const Value.absent(),
                Value<double> tdsRate = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<String?> tcsSection = const Value.absent(),
                Value<double> tcsRate = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => InvoicesCompanion(
                id: id,
                businessId: businessId,
                customerId: customerId,
                invoiceNumber: invoiceNumber,
                currencyCode: currencyCode,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                invoiceType: invoiceType,
                supplyType: supplyType,
                placeOfSupply: placeOfSupply,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxableAmount: taxableAmount,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                roundOffAmount: roundOffAmount,
                amountPaid: amountPaid,
                amountInWords: amountInWords,
                notes: notes,
                terms: terms,
                status: status,
                isIgst: isIgst,
                templateId: templateId,
                referenceInvoiceId: referenceInvoiceId,
                reverseCharge: reverseCharge,
                shipToName: shipToName,
                shipToAddress: shipToAddress,
                shipToCity: shipToCity,
                exportWithLut: exportWithLut,
                tdsSection: tdsSection,
                tdsRate: tdsRate,
                tdsAmount: tdsAmount,
                tcsSection: tcsSection,
                tcsRate: tcsRate,
                tcsAmount: tcsAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required int customerId,
                required String invoiceNumber,
                Value<String> currencyCode = const Value.absent(),
                required DateTime invoiceDate,
                Value<DateTime?> dueDate = const Value.absent(),
                required String invoiceType,
                required String supplyType,
                required int placeOfSupply,
                required double subtotal,
                Value<double> discountAmount = const Value.absent(),
                required double taxableAmount,
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                required double totalAmount,
                Value<double> roundOffAmount = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isIgst = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<int?> referenceInvoiceId = const Value.absent(),
                Value<bool> reverseCharge = const Value.absent(),
                Value<String?> shipToName = const Value.absent(),
                Value<String?> shipToAddress = const Value.absent(),
                Value<String?> shipToCity = const Value.absent(),
                Value<bool> exportWithLut = const Value.absent(),
                Value<String?> tdsSection = const Value.absent(),
                Value<double> tdsRate = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<String?> tcsSection = const Value.absent(),
                Value<double> tcsRate = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => InvoicesCompanion.insert(
                id: id,
                businessId: businessId,
                customerId: customerId,
                invoiceNumber: invoiceNumber,
                currencyCode: currencyCode,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                invoiceType: invoiceType,
                supplyType: supplyType,
                placeOfSupply: placeOfSupply,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxableAmount: taxableAmount,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                roundOffAmount: roundOffAmount,
                amountPaid: amountPaid,
                amountInWords: amountInWords,
                notes: notes,
                terms: terms,
                status: status,
                isIgst: isIgst,
                templateId: templateId,
                referenceInvoiceId: referenceInvoiceId,
                reverseCharge: reverseCharge,
                shipToName: shipToName,
                shipToAddress: shipToAddress,
                shipToCity: shipToCity,
                exportWithLut: exportWithLut,
                tdsSection: tdsSection,
                tdsRate: tdsRate,
                tdsAmount: tdsAmount,
                tcsSection: tcsSection,
                tcsRate: tcsRate,
                tcsAmount: tcsAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                businessId = false,
                customerId = false,
                invoiceItemsRefs = false,
                invoicePaymentsRefs = false,
                recurringInvoicesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (invoiceItemsRefs) db.invoiceItems,
                    if (invoicePaymentsRefs) db.invoicePayments,
                    if (recurringInvoicesRefs) db.recurringInvoices,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (businessId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.businessId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._businessIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._businessIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$InvoicesTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$InvoicesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (invoiceItemsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          InvoiceItem
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoiceItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoiceItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (invoicePaymentsRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          InvoicePayment
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._invoicePaymentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).invoicePaymentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.invoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (recurringInvoicesRefs)
                        await $_getPrefetchedData<
                          Invoice,
                          $InvoicesTable,
                          RecurringInvoice
                        >(
                          currentTable: table,
                          referencedTable: $$InvoicesTableReferences
                              ._recurringInvoicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InvoicesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringInvoicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sourceInvoiceId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicesTable,
      Invoice,
      $$InvoicesTableFilterComposer,
      $$InvoicesTableOrderingComposer,
      $$InvoicesTableAnnotationComposer,
      $$InvoicesTableCreateCompanionBuilder,
      $$InvoicesTableUpdateCompanionBuilder,
      (Invoice, $$InvoicesTableReferences),
      Invoice,
      PrefetchHooks Function({
        bool businessId,
        bool customerId,
        bool invoiceItemsRefs,
        bool invoicePaymentsRefs,
        bool recurringInvoicesRefs,
      })
    >;
typedef $$InvoiceItemsTableCreateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<int> id,
      required int invoiceId,
      Value<int?> productId,
      required String name,
      required String hsnSac,
      required String unit,
      required double quantity,
      required double rate,
      Value<double> discountPct,
      required double taxableAmount,
      required double gstRate,
      Value<double> cgstRate,
      Value<double> sgstRate,
      Value<double> igstRate,
      Value<double> cessRate,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      required double totalAmount,
      Value<int> sortOrder,
    });
typedef $$InvoiceItemsTableUpdateCompanionBuilder =
    InvoiceItemsCompanion Function({
      Value<int> id,
      Value<int> invoiceId,
      Value<int?> productId,
      Value<String> name,
      Value<String> hsnSac,
      Value<String> unit,
      Value<double> quantity,
      Value<double> rate,
      Value<double> discountPct,
      Value<double> taxableAmount,
      Value<double> gstRate,
      Value<double> cgstRate,
      Value<double> sgstRate,
      Value<double> igstRate,
      Value<double> cessRate,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      Value<double> totalAmount,
      Value<int> sortOrder,
    });

final class $$InvoiceItemsTableReferences
    extends BaseReferences<_$AppDatabase, $InvoiceItemsTable, InvoiceItem> {
  $$InvoiceItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias('invoice_items__invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('invoice_items__product_id__products__id');

  $$ProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoiceItemsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoiceItemsTable> {
  $$InvoiceItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hsnSac =>
      $composableBuilder(column: $table.hsnSac, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<double> get cgstRate =>
      $composableBuilder(column: $table.cgstRate, builder: (column) => column);

  GeneratedColumn<double> get sgstRate =>
      $composableBuilder(column: $table.sgstRate, builder: (column) => column);

  GeneratedColumn<double> get igstRate =>
      $composableBuilder(column: $table.igstRate, builder: (column) => column);

  GeneratedColumn<double> get cessRate =>
      $composableBuilder(column: $table.cessRate, builder: (column) => column);

  GeneratedColumn<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoiceItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoiceItemsTable,
          InvoiceItem,
          $$InvoiceItemsTableFilterComposer,
          $$InvoiceItemsTableOrderingComposer,
          $$InvoiceItemsTableAnnotationComposer,
          $$InvoiceItemsTableCreateCompanionBuilder,
          $$InvoiceItemsTableUpdateCompanionBuilder,
          (InvoiceItem, $$InvoiceItemsTableReferences),
          InvoiceItem,
          PrefetchHooks Function({bool invoiceId, bool productId})
        > {
  $$InvoiceItemsTableTableManager(_$AppDatabase db, $InvoiceItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoiceItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoiceItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoiceItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> invoiceId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> hsnSac = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double> discountPct = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> gstRate = const Value.absent(),
                Value<double> cgstRate = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<double> cessRate = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => InvoiceItemsCompanion(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                name: name,
                hsnSac: hsnSac,
                unit: unit,
                quantity: quantity,
                rate: rate,
                discountPct: discountPct,
                taxableAmount: taxableAmount,
                gstRate: gstRate,
                cgstRate: cgstRate,
                sgstRate: sgstRate,
                igstRate: igstRate,
                cessRate: cessRate,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int invoiceId,
                Value<int?> productId = const Value.absent(),
                required String name,
                required String hsnSac,
                required String unit,
                required double quantity,
                required double rate,
                Value<double> discountPct = const Value.absent(),
                required double taxableAmount,
                required double gstRate,
                Value<double> cgstRate = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<double> cessRate = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                required double totalAmount,
                Value<int> sortOrder = const Value.absent(),
              }) => InvoiceItemsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                productId: productId,
                name: name,
                hsnSac: hsnSac,
                unit: unit,
                quantity: quantity,
                rate: rate,
                discountPct: discountPct,
                taxableAmount: taxableAmount,
                gstRate: gstRate,
                cgstRate: cgstRate,
                sgstRate: sgstRate,
                igstRate: igstRate,
                cessRate: cessRate,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoiceItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._invoiceIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$InvoiceItemsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$InvoiceItemsTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoiceItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoiceItemsTable,
      InvoiceItem,
      $$InvoiceItemsTableFilterComposer,
      $$InvoiceItemsTableOrderingComposer,
      $$InvoiceItemsTableAnnotationComposer,
      $$InvoiceItemsTableCreateCompanionBuilder,
      $$InvoiceItemsTableUpdateCompanionBuilder,
      (InvoiceItem, $$InvoiceItemsTableReferences),
      InvoiceItem,
      PrefetchHooks Function({bool invoiceId, bool productId})
    >;
typedef $$InvoicePaymentsTableCreateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      Value<int> id,
      required int invoiceId,
      required double amount,
      Value<String> kind,
      required DateTime paidAt,
      Value<String?> mode,
      Value<String?> reference,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$InvoicePaymentsTableUpdateCompanionBuilder =
    InvoicePaymentsCompanion Function({
      Value<int> id,
      Value<int> invoiceId,
      Value<double> amount,
      Value<String> kind,
      Value<DateTime> paidAt,
      Value<String?> mode,
      Value<String?> reference,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$InvoicePaymentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $InvoicePaymentsTable, InvoicePayment> {
  $$InvoicePaymentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $InvoicesTable _invoiceIdTable(_$AppDatabase db) =>
      db.invoices.createAlias('invoice_payments__invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get invoiceId {
    final $_column = $_itemColumn<int>('invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_invoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$InvoicePaymentsTableFilterComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$InvoicesTableFilterComposer get invoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paidAt => $composableBuilder(
    column: $table.paidAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reference => $composableBuilder(
    column: $table.reference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$InvoicesTableOrderingComposer get invoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvoicePaymentsTable> {
  $$InvoicePaymentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<DateTime> get paidAt =>
      $composableBuilder(column: $table.paidAt, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$InvoicesTableAnnotationComposer get invoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.invoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$InvoicePaymentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InvoicePaymentsTable,
          InvoicePayment,
          $$InvoicePaymentsTableFilterComposer,
          $$InvoicePaymentsTableOrderingComposer,
          $$InvoicePaymentsTableAnnotationComposer,
          $$InvoicePaymentsTableCreateCompanionBuilder,
          $$InvoicePaymentsTableUpdateCompanionBuilder,
          (InvoicePayment, $$InvoicePaymentsTableReferences),
          InvoicePayment,
          PrefetchHooks Function({bool invoiceId})
        > {
  $$InvoicePaymentsTableTableManager(
    _$AppDatabase db,
    $InvoicePaymentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvoicePaymentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvoicePaymentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvoicePaymentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> invoiceId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<DateTime> paidAt = const Value.absent(),
                Value<String?> mode = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InvoicePaymentsCompanion(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                kind: kind,
                paidAt: paidAt,
                mode: mode,
                reference: reference,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int invoiceId,
                required double amount,
                Value<String> kind = const Value.absent(),
                required DateTime paidAt,
                Value<String?> mode = const Value.absent(),
                Value<String?> reference = const Value.absent(),
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => InvoicePaymentsCompanion.insert(
                id: id,
                invoiceId: invoiceId,
                amount: amount,
                kind: kind,
                paidAt: paidAt,
                mode: mode,
                reference: reference,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InvoicePaymentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({invoiceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (invoiceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.invoiceId,
                                referencedTable:
                                    $$InvoicePaymentsTableReferences
                                        ._invoiceIdTable(db),
                                referencedColumn:
                                    $$InvoicePaymentsTableReferences
                                        ._invoiceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$InvoicePaymentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InvoicePaymentsTable,
      InvoicePayment,
      $$InvoicePaymentsTableFilterComposer,
      $$InvoicePaymentsTableOrderingComposer,
      $$InvoicePaymentsTableAnnotationComposer,
      $$InvoicePaymentsTableCreateCompanionBuilder,
      $$InvoicePaymentsTableUpdateCompanionBuilder,
      (InvoicePayment, $$InvoicePaymentsTableReferences),
      InvoicePayment,
      PrefetchHooks Function({bool invoiceId})
    >;
typedef $$CustomerActivityEventsTableCreateCompanionBuilder =
    CustomerActivityEventsCompanion Function({
      Value<int> id,
      required int businessId,
      required int customerId,
      required String eventType,
      Value<String?> entityType,
      Value<int?> entityId,
      required String title,
      Value<String?> note,
      required DateTime createdAt,
    });
typedef $$CustomerActivityEventsTableUpdateCompanionBuilder =
    CustomerActivityEventsCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<int> customerId,
      Value<String> eventType,
      Value<String?> entityType,
      Value<int?> entityId,
      Value<String> title,
      Value<String?> note,
      Value<DateTime> createdAt,
    });

final class $$CustomerActivityEventsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $CustomerActivityEventsTable,
          CustomerActivityEvent
        > {
  $$CustomerActivityEventsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BusinessesTable _businessIdTable(_$AppDatabase db) => db.businesses
      .createAlias('customer_activity_events__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) => db.customers
      .createAlias('customer_activity_events__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CustomerActivityEventsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerActivityEventsTable> {
  $$CustomerActivityEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerActivityEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerActivityEventsTable> {
  $$CustomerActivityEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerActivityEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerActivityEventsTable> {
  $$CustomerActivityEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CustomerActivityEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerActivityEventsTable,
          CustomerActivityEvent,
          $$CustomerActivityEventsTableFilterComposer,
          $$CustomerActivityEventsTableOrderingComposer,
          $$CustomerActivityEventsTableAnnotationComposer,
          $$CustomerActivityEventsTableCreateCompanionBuilder,
          $$CustomerActivityEventsTableUpdateCompanionBuilder,
          (CustomerActivityEvent, $$CustomerActivityEventsTableReferences),
          CustomerActivityEvent,
          PrefetchHooks Function({bool businessId, bool customerId})
        > {
  $$CustomerActivityEventsTableTableManager(
    _$AppDatabase db,
    $CustomerActivityEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerActivityEventsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerActivityEventsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerActivityEventsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String?> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomerActivityEventsCompanion(
                id: id,
                businessId: businessId,
                customerId: customerId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                title: title,
                note: note,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required int customerId,
                required String eventType,
                Value<String?> entityType = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                required String title,
                Value<String?> note = const Value.absent(),
                required DateTime createdAt,
              }) => CustomerActivityEventsCompanion.insert(
                id: id,
                businessId: businessId,
                customerId: customerId,
                eventType: eventType,
                entityType: entityType,
                entityId: entityId,
                title: title,
                note: note,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomerActivityEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false, customerId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (businessId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.businessId,
                                referencedTable:
                                    $$CustomerActivityEventsTableReferences
                                        ._businessIdTable(db),
                                referencedColumn:
                                    $$CustomerActivityEventsTableReferences
                                        ._businessIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (customerId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.customerId,
                                referencedTable:
                                    $$CustomerActivityEventsTableReferences
                                        ._customerIdTable(db),
                                referencedColumn:
                                    $$CustomerActivityEventsTableReferences
                                        ._customerIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CustomerActivityEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerActivityEventsTable,
      CustomerActivityEvent,
      $$CustomerActivityEventsTableFilterComposer,
      $$CustomerActivityEventsTableOrderingComposer,
      $$CustomerActivityEventsTableAnnotationComposer,
      $$CustomerActivityEventsTableCreateCompanionBuilder,
      $$CustomerActivityEventsTableUpdateCompanionBuilder,
      (CustomerActivityEvent, $$CustomerActivityEventsTableReferences),
      CustomerActivityEvent,
      PrefetchHooks Function({bool businessId, bool customerId})
    >;
typedef $$QuotesTableCreateCompanionBuilder =
    QuotesCompanion Function({
      Value<int> id,
      required int businessId,
      required int customerId,
      required String invoiceNumber,
      Value<String> currencyCode,
      required DateTime invoiceDate,
      Value<DateTime?> dueDate,
      required String invoiceType,
      required String supplyType,
      required int placeOfSupply,
      required double subtotal,
      Value<double> discountAmount,
      required double taxableAmount,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      required double totalAmount,
      Value<double> roundOffAmount,
      Value<String?> amountInWords,
      Value<String?> notes,
      Value<String?> terms,
      Value<String> status,
      Value<bool> isIgst,
      Value<int?> templateId,
      Value<bool> reverseCharge,
      Value<String?> shipToName,
      Value<String?> shipToAddress,
      Value<String?> shipToCity,
      Value<bool> exportWithLut,
      Value<String?> tdsSection,
      Value<double> tdsRate,
      Value<double> tdsAmount,
      Value<String?> tcsSection,
      Value<double> tcsRate,
      Value<double> tcsAmount,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$QuotesTableUpdateCompanionBuilder =
    QuotesCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<int> customerId,
      Value<String> invoiceNumber,
      Value<String> currencyCode,
      Value<DateTime> invoiceDate,
      Value<DateTime?> dueDate,
      Value<String> invoiceType,
      Value<String> supplyType,
      Value<int> placeOfSupply,
      Value<double> subtotal,
      Value<double> discountAmount,
      Value<double> taxableAmount,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      Value<double> totalAmount,
      Value<double> roundOffAmount,
      Value<String?> amountInWords,
      Value<String?> notes,
      Value<String?> terms,
      Value<String> status,
      Value<bool> isIgst,
      Value<int?> templateId,
      Value<bool> reverseCharge,
      Value<String?> shipToName,
      Value<String?> shipToAddress,
      Value<String?> shipToCity,
      Value<bool> exportWithLut,
      Value<String?> tdsSection,
      Value<double> tdsRate,
      Value<double> tdsAmount,
      Value<String?> tcsSection,
      Value<double> tcsRate,
      Value<double> tcsAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, Quote> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BusinessesTable _businessIdTable(_$AppDatabase db) =>
      db.businesses.createAlias('quotes__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias('quotes__customer_id__customers__id');

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QuoteItemsTable, List<QuoteItem>>
  _quoteItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.quoteItems,
    aliasName: 'quotes__id__quote_items__quote_id',
  );

  $$QuoteItemsTableProcessedTableManager get quoteItemsRefs {
    final manager = $$QuoteItemsTableTableManager(
      $_db,
      $_db.quoteItems,
    ).filter((f) => f.quoteId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_quoteItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgst => $composableBuilder(
    column: $table.isIgst,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsRate => $composableBuilder(
    column: $table.tdsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcsRate => $composableBuilder(
    column: $table.tcsRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> quoteItemsRefs(
    Expression<bool> Function($$QuoteItemsTableFilterComposer f) f,
  ) {
    final $$QuoteItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.quoteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableFilterComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get terms => $composableBuilder(
    column: $table.terms,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgst => $composableBuilder(
    column: $table.isIgst,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsRate => $composableBuilder(
    column: $table.tdsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tdsAmount => $composableBuilder(
    column: $table.tdsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcsRate => $composableBuilder(
    column: $table.tcsRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tcsAmount => $composableBuilder(
    column: $table.tcsAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get invoiceNumber => $composableBuilder(
    column: $table.invoiceNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get invoiceDate => $composableBuilder(
    column: $table.invoiceDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<String> get invoiceType => $composableBuilder(
    column: $table.invoiceType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplyType => $composableBuilder(
    column: $table.supplyType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get placeOfSupply => $composableBuilder(
    column: $table.placeOfSupply,
    builder: (column) => column,
  );

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get discountAmount => $composableBuilder(
    column: $table.discountAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get roundOffAmount => $composableBuilder(
    column: $table.roundOffAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get amountInWords => $composableBuilder(
    column: $table.amountInWords,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get terms =>
      $composableBuilder(column: $table.terms, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<bool> get isIgst =>
      $composableBuilder(column: $table.isIgst, builder: (column) => column);

  GeneratedColumn<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get reverseCharge => $composableBuilder(
    column: $table.reverseCharge,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToName => $composableBuilder(
    column: $table.shipToName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToAddress => $composableBuilder(
    column: $table.shipToAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shipToCity => $composableBuilder(
    column: $table.shipToCity,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get exportWithLut => $composableBuilder(
    column: $table.exportWithLut,
    builder: (column) => column,
  );

  GeneratedColumn<String> get tdsSection => $composableBuilder(
    column: $table.tdsSection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tdsRate =>
      $composableBuilder(column: $table.tdsRate, builder: (column) => column);

  GeneratedColumn<double> get tdsAmount =>
      $composableBuilder(column: $table.tdsAmount, builder: (column) => column);

  GeneratedColumn<String> get tcsSection => $composableBuilder(
    column: $table.tcsSection,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tcsRate =>
      $composableBuilder(column: $table.tcsRate, builder: (column) => column);

  GeneratedColumn<double> get tcsAmount =>
      $composableBuilder(column: $table.tcsAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> quoteItemsRefs<T extends Object>(
    Expression<T> Function($$QuoteItemsTableAnnotationComposer a) f,
  ) {
    final $$QuoteItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quoteItems,
      getReferencedColumn: (t) => t.quoteId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuoteItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.quoteItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          Quote,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (Quote, $$QuotesTableReferences),
          Quote,
          PrefetchHooks Function({
            bool businessId,
            bool customerId,
            bool quoteItemsRefs,
          })
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<String> invoiceNumber = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<DateTime> invoiceDate = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<String> invoiceType = const Value.absent(),
                Value<String> supplyType = const Value.absent(),
                Value<int> placeOfSupply = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> discountAmount = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<double> roundOffAmount = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isIgst = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<bool> reverseCharge = const Value.absent(),
                Value<String?> shipToName = const Value.absent(),
                Value<String?> shipToAddress = const Value.absent(),
                Value<String?> shipToCity = const Value.absent(),
                Value<bool> exportWithLut = const Value.absent(),
                Value<String?> tdsSection = const Value.absent(),
                Value<double> tdsRate = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<String?> tcsSection = const Value.absent(),
                Value<double> tcsRate = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                businessId: businessId,
                customerId: customerId,
                invoiceNumber: invoiceNumber,
                currencyCode: currencyCode,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                invoiceType: invoiceType,
                supplyType: supplyType,
                placeOfSupply: placeOfSupply,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxableAmount: taxableAmount,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                roundOffAmount: roundOffAmount,
                amountInWords: amountInWords,
                notes: notes,
                terms: terms,
                status: status,
                isIgst: isIgst,
                templateId: templateId,
                reverseCharge: reverseCharge,
                shipToName: shipToName,
                shipToAddress: shipToAddress,
                shipToCity: shipToCity,
                exportWithLut: exportWithLut,
                tdsSection: tdsSection,
                tdsRate: tdsRate,
                tdsAmount: tdsAmount,
                tcsSection: tcsSection,
                tcsRate: tcsRate,
                tcsAmount: tcsAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required int customerId,
                required String invoiceNumber,
                Value<String> currencyCode = const Value.absent(),
                required DateTime invoiceDate,
                Value<DateTime?> dueDate = const Value.absent(),
                required String invoiceType,
                required String supplyType,
                required int placeOfSupply,
                required double subtotal,
                Value<double> discountAmount = const Value.absent(),
                required double taxableAmount,
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                required double totalAmount,
                Value<double> roundOffAmount = const Value.absent(),
                Value<String?> amountInWords = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> terms = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<bool> isIgst = const Value.absent(),
                Value<int?> templateId = const Value.absent(),
                Value<bool> reverseCharge = const Value.absent(),
                Value<String?> shipToName = const Value.absent(),
                Value<String?> shipToAddress = const Value.absent(),
                Value<String?> shipToCity = const Value.absent(),
                Value<bool> exportWithLut = const Value.absent(),
                Value<String?> tdsSection = const Value.absent(),
                Value<double> tdsRate = const Value.absent(),
                Value<double> tdsAmount = const Value.absent(),
                Value<String?> tcsSection = const Value.absent(),
                Value<double> tcsRate = const Value.absent(),
                Value<double> tcsAmount = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => QuotesCompanion.insert(
                id: id,
                businessId: businessId,
                customerId: customerId,
                invoiceNumber: invoiceNumber,
                currencyCode: currencyCode,
                invoiceDate: invoiceDate,
                dueDate: dueDate,
                invoiceType: invoiceType,
                supplyType: supplyType,
                placeOfSupply: placeOfSupply,
                subtotal: subtotal,
                discountAmount: discountAmount,
                taxableAmount: taxableAmount,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                roundOffAmount: roundOffAmount,
                amountInWords: amountInWords,
                notes: notes,
                terms: terms,
                status: status,
                isIgst: isIgst,
                templateId: templateId,
                reverseCharge: reverseCharge,
                shipToName: shipToName,
                shipToAddress: shipToAddress,
                shipToCity: shipToCity,
                exportWithLut: exportWithLut,
                tdsSection: tdsSection,
                tdsRate: tdsRate,
                tdsAmount: tdsAmount,
                tcsSection: tcsSection,
                tcsRate: tcsRate,
                tcsAmount: tcsAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$QuotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                businessId = false,
                customerId = false,
                quoteItemsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (quoteItemsRefs) db.quoteItems],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (businessId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.businessId,
                                    referencedTable: $$QuotesTableReferences
                                        ._businessIdTable(db),
                                    referencedColumn: $$QuotesTableReferences
                                        ._businessIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$QuotesTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$QuotesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (quoteItemsRefs)
                        await $_getPrefetchedData<
                          Quote,
                          $QuotesTable,
                          QuoteItem
                        >(
                          currentTable: table,
                          referencedTable: $$QuotesTableReferences
                              ._quoteItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$QuotesTableReferences(
                                db,
                                table,
                                p0,
                              ).quoteItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.quoteId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      Quote,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (Quote, $$QuotesTableReferences),
      Quote,
      PrefetchHooks Function({
        bool businessId,
        bool customerId,
        bool quoteItemsRefs,
      })
    >;
typedef $$QuoteItemsTableCreateCompanionBuilder =
    QuoteItemsCompanion Function({
      Value<int> id,
      required int quoteId,
      Value<int?> productId,
      required String name,
      required String hsnSac,
      required String unit,
      required double quantity,
      required double rate,
      Value<double> discountPct,
      required double taxableAmount,
      required double gstRate,
      Value<double> cgstRate,
      Value<double> sgstRate,
      Value<double> igstRate,
      Value<double> cessRate,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      required double totalAmount,
      Value<int> sortOrder,
    });
typedef $$QuoteItemsTableUpdateCompanionBuilder =
    QuoteItemsCompanion Function({
      Value<int> id,
      Value<int> quoteId,
      Value<int?> productId,
      Value<String> name,
      Value<String> hsnSac,
      Value<String> unit,
      Value<double> quantity,
      Value<double> rate,
      Value<double> discountPct,
      Value<double> taxableAmount,
      Value<double> gstRate,
      Value<double> cgstRate,
      Value<double> sgstRate,
      Value<double> igstRate,
      Value<double> cessRate,
      Value<double> cgstAmount,
      Value<double> sgstAmount,
      Value<double> igstAmount,
      Value<double> cessAmount,
      Value<double> totalAmount,
      Value<int> sortOrder,
    });

final class $$QuoteItemsTableReferences
    extends BaseReferences<_$AppDatabase, $QuoteItemsTable, QuoteItem> {
  $$QuoteItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $QuotesTable _quoteIdTable(_$AppDatabase db) =>
      db.quotes.createAlias('quote_items__quote_id__quotes__id');

  $$QuotesTableProcessedTableManager get quoteId {
    final $_column = $_itemColumn<int>('quote_id')!;

    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_quoteIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('quote_items__product_id__products__id');

  $$ProductsTableProcessedTableManager? get productId {
    final $_column = $_itemColumn<int>('product_id');
    if ($_column == null) return null;
    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuoteItemsTableFilterComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$QuotesTableFilterComposer get quoteId {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get hsnSac => $composableBuilder(
    column: $table.hsnSac,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rate => $composableBuilder(
    column: $table.rate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstRate => $composableBuilder(
    column: $table.cgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstRate => $composableBuilder(
    column: $table.sgstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstRate => $composableBuilder(
    column: $table.igstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessRate => $composableBuilder(
    column: $table.cessRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$QuotesTableOrderingComposer get quoteId {
    final $$QuotesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableOrderingComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuoteItemsTable> {
  $$QuoteItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get hsnSac =>
      $composableBuilder(column: $table.hsnSac, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get rate =>
      $composableBuilder(column: $table.rate, builder: (column) => column);

  GeneratedColumn<double> get discountPct => $composableBuilder(
    column: $table.discountPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get taxableAmount => $composableBuilder(
    column: $table.taxableAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<double> get cgstRate =>
      $composableBuilder(column: $table.cgstRate, builder: (column) => column);

  GeneratedColumn<double> get sgstRate =>
      $composableBuilder(column: $table.sgstRate, builder: (column) => column);

  GeneratedColumn<double> get igstRate =>
      $composableBuilder(column: $table.igstRate, builder: (column) => column);

  GeneratedColumn<double> get cessRate =>
      $composableBuilder(column: $table.cessRate, builder: (column) => column);

  GeneratedColumn<double> get cgstAmount => $composableBuilder(
    column: $table.cgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get sgstAmount => $composableBuilder(
    column: $table.sgstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get igstAmount => $composableBuilder(
    column: $table.igstAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cessAmount => $composableBuilder(
    column: $table.cessAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$QuotesTableAnnotationComposer get quoteId {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.quoteId,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuoteItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuoteItemsTable,
          QuoteItem,
          $$QuoteItemsTableFilterComposer,
          $$QuoteItemsTableOrderingComposer,
          $$QuoteItemsTableAnnotationComposer,
          $$QuoteItemsTableCreateCompanionBuilder,
          $$QuoteItemsTableUpdateCompanionBuilder,
          (QuoteItem, $$QuoteItemsTableReferences),
          QuoteItem,
          PrefetchHooks Function({bool quoteId, bool productId})
        > {
  $$QuoteItemsTableTableManager(_$AppDatabase db, $QuoteItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuoteItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuoteItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuoteItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> quoteId = const Value.absent(),
                Value<int?> productId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> hsnSac = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<double> rate = const Value.absent(),
                Value<double> discountPct = const Value.absent(),
                Value<double> taxableAmount = const Value.absent(),
                Value<double> gstRate = const Value.absent(),
                Value<double> cgstRate = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<double> cessRate = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => QuoteItemsCompanion(
                id: id,
                quoteId: quoteId,
                productId: productId,
                name: name,
                hsnSac: hsnSac,
                unit: unit,
                quantity: quantity,
                rate: rate,
                discountPct: discountPct,
                taxableAmount: taxableAmount,
                gstRate: gstRate,
                cgstRate: cgstRate,
                sgstRate: sgstRate,
                igstRate: igstRate,
                cessRate: cessRate,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int quoteId,
                Value<int?> productId = const Value.absent(),
                required String name,
                required String hsnSac,
                required String unit,
                required double quantity,
                required double rate,
                Value<double> discountPct = const Value.absent(),
                required double taxableAmount,
                required double gstRate,
                Value<double> cgstRate = const Value.absent(),
                Value<double> sgstRate = const Value.absent(),
                Value<double> igstRate = const Value.absent(),
                Value<double> cessRate = const Value.absent(),
                Value<double> cgstAmount = const Value.absent(),
                Value<double> sgstAmount = const Value.absent(),
                Value<double> igstAmount = const Value.absent(),
                Value<double> cessAmount = const Value.absent(),
                required double totalAmount,
                Value<int> sortOrder = const Value.absent(),
              }) => QuoteItemsCompanion.insert(
                id: id,
                quoteId: quoteId,
                productId: productId,
                name: name,
                hsnSac: hsnSac,
                unit: unit,
                quantity: quantity,
                rate: rate,
                discountPct: discountPct,
                taxableAmount: taxableAmount,
                gstRate: gstRate,
                cgstRate: cgstRate,
                sgstRate: sgstRate,
                igstRate: igstRate,
                cessRate: cessRate,
                cgstAmount: cgstAmount,
                sgstAmount: sgstAmount,
                igstAmount: igstAmount,
                cessAmount: cessAmount,
                totalAmount: totalAmount,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QuoteItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({quoteId = false, productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (quoteId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.quoteId,
                                referencedTable: $$QuoteItemsTableReferences
                                    ._quoteIdTable(db),
                                referencedColumn: $$QuoteItemsTableReferences
                                    ._quoteIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$QuoteItemsTableReferences
                                    ._productIdTable(db),
                                referencedColumn: $$QuoteItemsTableReferences
                                    ._productIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuoteItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuoteItemsTable,
      QuoteItem,
      $$QuoteItemsTableFilterComposer,
      $$QuoteItemsTableOrderingComposer,
      $$QuoteItemsTableAnnotationComposer,
      $$QuoteItemsTableCreateCompanionBuilder,
      $$QuoteItemsTableUpdateCompanionBuilder,
      (QuoteItem, $$QuoteItemsTableReferences),
      QuoteItem,
      PrefetchHooks Function({bool quoteId, bool productId})
    >;
typedef $$HsnCodesTableCreateCompanionBuilder =
    HsnCodesCompanion Function({
      Value<int> id,
      required String code,
      required String description,
      Value<double?> gstRate,
      Value<String> type,
    });
typedef $$HsnCodesTableUpdateCompanionBuilder =
    HsnCodesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> description,
      Value<double?> gstRate,
      Value<String> type,
    });

class $$HsnCodesTableFilterComposer
    extends Composer<_$AppDatabase, $HsnCodesTable> {
  $$HsnCodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HsnCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $HsnCodesTable> {
  $$HsnCodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HsnCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HsnCodesTable> {
  $$HsnCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);
}

class $$HsnCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HsnCodesTable,
          HsnCode,
          $$HsnCodesTableFilterComposer,
          $$HsnCodesTableOrderingComposer,
          $$HsnCodesTableAnnotationComposer,
          $$HsnCodesTableCreateCompanionBuilder,
          $$HsnCodesTableUpdateCompanionBuilder,
          (HsnCode, BaseReferences<_$AppDatabase, $HsnCodesTable, HsnCode>),
          HsnCode,
          PrefetchHooks Function()
        > {
  $$HsnCodesTableTableManager(_$AppDatabase db, $HsnCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HsnCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HsnCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HsnCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double?> gstRate = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => HsnCodesCompanion(
                id: id,
                code: code,
                description: description,
                gstRate: gstRate,
                type: type,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String description,
                Value<double?> gstRate = const Value.absent(),
                Value<String> type = const Value.absent(),
              }) => HsnCodesCompanion.insert(
                id: id,
                code: code,
                description: description,
                gstRate: gstRate,
                type: type,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HsnCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HsnCodesTable,
      HsnCode,
      $$HsnCodesTableFilterComposer,
      $$HsnCodesTableOrderingComposer,
      $$HsnCodesTableAnnotationComposer,
      $$HsnCodesTableCreateCompanionBuilder,
      $$HsnCodesTableUpdateCompanionBuilder,
      (HsnCode, BaseReferences<_$AppDatabase, $HsnCodesTable, HsnCode>),
      HsnCode,
      PrefetchHooks Function()
    >;
typedef $$HsnCodeRatesTableCreateCompanionBuilder =
    HsnCodeRatesCompanion Function({
      Value<int> id,
      required String code,
      Value<double?> gstRate,
      required DateTime effectiveFrom,
      Value<double> minUnitPrice,
      Value<double> maxUnitPrice,
    });
typedef $$HsnCodeRatesTableUpdateCompanionBuilder =
    HsnCodeRatesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<double?> gstRate,
      Value<DateTime> effectiveFrom,
      Value<double> minUnitPrice,
      Value<double> maxUnitPrice,
    });

class $$HsnCodeRatesTableFilterComposer
    extends Composer<_$AppDatabase, $HsnCodeRatesTable> {
  $$HsnCodeRatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minUnitPrice => $composableBuilder(
    column: $table.minUnitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxUnitPrice => $composableBuilder(
    column: $table.maxUnitPrice,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HsnCodeRatesTableOrderingComposer
    extends Composer<_$AppDatabase, $HsnCodeRatesTable> {
  $$HsnCodeRatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get gstRate => $composableBuilder(
    column: $table.gstRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minUnitPrice => $composableBuilder(
    column: $table.minUnitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxUnitPrice => $composableBuilder(
    column: $table.maxUnitPrice,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HsnCodeRatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $HsnCodeRatesTable> {
  $$HsnCodeRatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<double> get gstRate =>
      $composableBuilder(column: $table.gstRate, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveFrom => $composableBuilder(
    column: $table.effectiveFrom,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minUnitPrice => $composableBuilder(
    column: $table.minUnitPrice,
    builder: (column) => column,
  );

  GeneratedColumn<double> get maxUnitPrice => $composableBuilder(
    column: $table.maxUnitPrice,
    builder: (column) => column,
  );
}

class $$HsnCodeRatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HsnCodeRatesTable,
          HsnCodeRate,
          $$HsnCodeRatesTableFilterComposer,
          $$HsnCodeRatesTableOrderingComposer,
          $$HsnCodeRatesTableAnnotationComposer,
          $$HsnCodeRatesTableCreateCompanionBuilder,
          $$HsnCodeRatesTableUpdateCompanionBuilder,
          (
            HsnCodeRate,
            BaseReferences<_$AppDatabase, $HsnCodeRatesTable, HsnCodeRate>,
          ),
          HsnCodeRate,
          PrefetchHooks Function()
        > {
  $$HsnCodeRatesTableTableManager(_$AppDatabase db, $HsnCodeRatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HsnCodeRatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HsnCodeRatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HsnCodeRatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<double?> gstRate = const Value.absent(),
                Value<DateTime> effectiveFrom = const Value.absent(),
                Value<double> minUnitPrice = const Value.absent(),
                Value<double> maxUnitPrice = const Value.absent(),
              }) => HsnCodeRatesCompanion(
                id: id,
                code: code,
                gstRate: gstRate,
                effectiveFrom: effectiveFrom,
                minUnitPrice: minUnitPrice,
                maxUnitPrice: maxUnitPrice,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                Value<double?> gstRate = const Value.absent(),
                required DateTime effectiveFrom,
                Value<double> minUnitPrice = const Value.absent(),
                Value<double> maxUnitPrice = const Value.absent(),
              }) => HsnCodeRatesCompanion.insert(
                id: id,
                code: code,
                gstRate: gstRate,
                effectiveFrom: effectiveFrom,
                minUnitPrice: minUnitPrice,
                maxUnitPrice: maxUnitPrice,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HsnCodeRatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HsnCodeRatesTable,
      HsnCodeRate,
      $$HsnCodeRatesTableFilterComposer,
      $$HsnCodeRatesTableOrderingComposer,
      $$HsnCodeRatesTableAnnotationComposer,
      $$HsnCodeRatesTableCreateCompanionBuilder,
      $$HsnCodeRatesTableUpdateCompanionBuilder,
      (
        HsnCodeRate,
        BaseReferences<_$AppDatabase, $HsnCodeRatesTable, HsnCodeRate>,
      ),
      HsnCodeRate,
      PrefetchHooks Function()
    >;
typedef $$UomsTableCreateCompanionBuilder =
    UomsCompanion Function({
      Value<int> id,
      required String code,
      required String name,
      Value<String> family,
      Value<String?> baseCode,
      Value<double> conversionFactor,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$UomsTableUpdateCompanionBuilder =
    UomsCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> name,
      Value<String> family,
      Value<String?> baseCode,
      Value<double> conversionFactor,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

class $$UomsTableFilterComposer extends Composer<_$AppDatabase, $UomsTable> {
  $$UomsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseCode => $composableBuilder(
    column: $table.baseCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UomsTableOrderingComposer extends Composer<_$AppDatabase, $UomsTable> {
  $$UomsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get family => $composableBuilder(
    column: $table.family,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseCode => $composableBuilder(
    column: $table.baseCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UomsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UomsTable> {
  $$UomsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get family =>
      $composableBuilder(column: $table.family, builder: (column) => column);

  GeneratedColumn<String> get baseCode =>
      $composableBuilder(column: $table.baseCode, builder: (column) => column);

  GeneratedColumn<double> get conversionFactor => $composableBuilder(
    column: $table.conversionFactor,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);
}

class $$UomsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UomsTable,
          Uom,
          $$UomsTableFilterComposer,
          $$UomsTableOrderingComposer,
          $$UomsTableAnnotationComposer,
          $$UomsTableCreateCompanionBuilder,
          $$UomsTableUpdateCompanionBuilder,
          (Uom, BaseReferences<_$AppDatabase, $UomsTable, Uom>),
          Uom,
          PrefetchHooks Function()
        > {
  $$UomsTableTableManager(_$AppDatabase db, $UomsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UomsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UomsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UomsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> family = const Value.absent(),
                Value<String?> baseCode = const Value.absent(),
                Value<double> conversionFactor = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => UomsCompanion(
                id: id,
                code: code,
                name: name,
                family: family,
                baseCode: baseCode,
                conversionFactor: conversionFactor,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String name,
                Value<String> family = const Value.absent(),
                Value<String?> baseCode = const Value.absent(),
                Value<double> conversionFactor = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => UomsCompanion.insert(
                id: id,
                code: code,
                name: name,
                family: family,
                baseCode: baseCode,
                conversionFactor: conversionFactor,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UomsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UomsTable,
      Uom,
      $$UomsTableFilterComposer,
      $$UomsTableOrderingComposer,
      $$UomsTableAnnotationComposer,
      $$UomsTableCreateCompanionBuilder,
      $$UomsTableUpdateCompanionBuilder,
      (Uom, BaseReferences<_$AppDatabase, $UomsTable, Uom>),
      Uom,
      PrefetchHooks Function()
    >;
typedef $$TemplateConfigsTableCreateCompanionBuilder =
    TemplateConfigsCompanion Function({
      Value<int> id,
      required int businessId,
      required TemplateScope scope,
      required String name,
      required String configJson,
      Value<bool> isDefault,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$TemplateConfigsTableUpdateCompanionBuilder =
    TemplateConfigsCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<TemplateScope> scope,
      Value<String> name,
      Value<String> configJson,
      Value<bool> isDefault,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$TemplateConfigsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TemplateConfigsTable, TemplateConfig> {
  $$TemplateConfigsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BusinessesTable _businessIdTable(_$AppDatabase db) => db.businesses
      .createAlias('template_configs__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateConfigsTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateConfigsTable> {
  $$TemplateConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TemplateScope, TemplateScope, int> get scope =>
      $composableBuilder(
        column: $table.scope,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateConfigsTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateConfigsTable> {
  $$TemplateConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDefault => $composableBuilder(
    column: $table.isDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateConfigsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateConfigsTable> {
  $$TemplateConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<TemplateScope, int> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get configJson => $composableBuilder(
    column: $table.configJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateConfigsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateConfigsTable,
          TemplateConfig,
          $$TemplateConfigsTableFilterComposer,
          $$TemplateConfigsTableOrderingComposer,
          $$TemplateConfigsTableAnnotationComposer,
          $$TemplateConfigsTableCreateCompanionBuilder,
          $$TemplateConfigsTableUpdateCompanionBuilder,
          (TemplateConfig, $$TemplateConfigsTableReferences),
          TemplateConfig,
          PrefetchHooks Function({bool businessId})
        > {
  $$TemplateConfigsTableTableManager(
    _$AppDatabase db,
    $TemplateConfigsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<TemplateScope> scope = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> configJson = const Value.absent(),
                Value<bool> isDefault = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TemplateConfigsCompanion(
                id: id,
                businessId: businessId,
                scope: scope,
                name: name,
                configJson: configJson,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required TemplateScope scope,
                required String name,
                required String configJson,
                Value<bool> isDefault = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => TemplateConfigsCompanion.insert(
                id: id,
                businessId: businessId,
                scope: scope,
                name: name,
                configJson: configJson,
                isDefault: isDefault,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateConfigsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (businessId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.businessId,
                                referencedTable:
                                    $$TemplateConfigsTableReferences
                                        ._businessIdTable(db),
                                referencedColumn:
                                    $$TemplateConfigsTableReferences
                                        ._businessIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TemplateConfigsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateConfigsTable,
      TemplateConfig,
      $$TemplateConfigsTableFilterComposer,
      $$TemplateConfigsTableOrderingComposer,
      $$TemplateConfigsTableAnnotationComposer,
      $$TemplateConfigsTableCreateCompanionBuilder,
      $$TemplateConfigsTableUpdateCompanionBuilder,
      (TemplateConfig, $$TemplateConfigsTableReferences),
      TemplateConfig,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$DocumentSequencesTableCreateCompanionBuilder =
    DocumentSequencesCompanion Function({
      Value<int> id,
      required int businessId,
      required String docType,
      required String fiscalYear,
      required String format,
      Value<int> sequence,
    });
typedef $$DocumentSequencesTableUpdateCompanionBuilder =
    DocumentSequencesCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<String> docType,
      Value<String> fiscalYear,
      Value<String> format,
      Value<int> sequence,
    });

final class $$DocumentSequencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DocumentSequencesTable,
          DocumentSequence
        > {
  $$DocumentSequencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BusinessesTable _businessIdTable(_$AppDatabase db) => db.businesses
      .createAlias('document_sequences__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DocumentSequencesTableFilterComposer
    extends Composer<_$AppDatabase, $DocumentSequencesTable> {
  $$DocumentSequencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentSequencesTableOrderingComposer
    extends Composer<_$AppDatabase, $DocumentSequencesTable> {
  $$DocumentSequencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get docType => $composableBuilder(
    column: $table.docType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get format => $composableBuilder(
    column: $table.format,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sequence => $composableBuilder(
    column: $table.sequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentSequencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DocumentSequencesTable> {
  $$DocumentSequencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get docType =>
      $composableBuilder(column: $table.docType, builder: (column) => column);

  GeneratedColumn<String> get fiscalYear => $composableBuilder(
    column: $table.fiscalYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get format =>
      $composableBuilder(column: $table.format, builder: (column) => column);

  GeneratedColumn<int> get sequence =>
      $composableBuilder(column: $table.sequence, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DocumentSequencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DocumentSequencesTable,
          DocumentSequence,
          $$DocumentSequencesTableFilterComposer,
          $$DocumentSequencesTableOrderingComposer,
          $$DocumentSequencesTableAnnotationComposer,
          $$DocumentSequencesTableCreateCompanionBuilder,
          $$DocumentSequencesTableUpdateCompanionBuilder,
          (DocumentSequence, $$DocumentSequencesTableReferences),
          DocumentSequence,
          PrefetchHooks Function({bool businessId})
        > {
  $$DocumentSequencesTableTableManager(
    _$AppDatabase db,
    $DocumentSequencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DocumentSequencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DocumentSequencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DocumentSequencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<String> docType = const Value.absent(),
                Value<String> fiscalYear = const Value.absent(),
                Value<String> format = const Value.absent(),
                Value<int> sequence = const Value.absent(),
              }) => DocumentSequencesCompanion(
                id: id,
                businessId: businessId,
                docType: docType,
                fiscalYear: fiscalYear,
                format: format,
                sequence: sequence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required String docType,
                required String fiscalYear,
                required String format,
                Value<int> sequence = const Value.absent(),
              }) => DocumentSequencesCompanion.insert(
                id: id,
                businessId: businessId,
                docType: docType,
                fiscalYear: fiscalYear,
                format: format,
                sequence: sequence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DocumentSequencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({businessId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (businessId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.businessId,
                                referencedTable:
                                    $$DocumentSequencesTableReferences
                                        ._businessIdTable(db),
                                referencedColumn:
                                    $$DocumentSequencesTableReferences
                                        ._businessIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DocumentSequencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DocumentSequencesTable,
      DocumentSequence,
      $$DocumentSequencesTableFilterComposer,
      $$DocumentSequencesTableOrderingComposer,
      $$DocumentSequencesTableAnnotationComposer,
      $$DocumentSequencesTableCreateCompanionBuilder,
      $$DocumentSequencesTableUpdateCompanionBuilder,
      (DocumentSequence, $$DocumentSequencesTableReferences),
      DocumentSequence,
      PrefetchHooks Function({bool businessId})
    >;
typedef $$StockMovementsTableCreateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      required int productId,
      required double quantityDelta,
      required String reason,
      Value<String?> documentType,
      Value<int?> documentId,
      required DateTime createdAt,
    });
typedef $$StockMovementsTableUpdateCompanionBuilder =
    StockMovementsCompanion Function({
      Value<int> id,
      Value<int> productId,
      Value<double> quantityDelta,
      Value<String> reason,
      Value<String?> documentType,
      Value<int?> documentId,
      Value<DateTime> createdAt,
    });

final class $$StockMovementsTableReferences
    extends BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement> {
  $$StockMovementsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ProductsTable _productIdTable(_$AppDatabase db) =>
      db.products.createAlias('stock_movements__product_id__products__id');

  $$ProductsTableProcessedTableManager get productId {
    final $_column = $_itemColumn<int>('product_id')!;

    final manager = $$ProductsTableTableManager(
      $_db,
      $_db.products,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_productIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProductsTableFilterComposer get productId {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableFilterComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProductsTableOrderingComposer get productId {
    final $$ProductsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableOrderingComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantityDelta => $composableBuilder(
    column: $table.quantityDelta,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get documentType => $composableBuilder(
    column: $table.documentType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get documentId => $composableBuilder(
    column: $table.documentId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProductsTableAnnotationComposer get productId {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.productId,
      referencedTable: $db.products,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProductsTableAnnotationComposer(
            $db: $db,
            $table: $db.products,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StockMovementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StockMovementsTable,
          StockMovement,
          $$StockMovementsTableFilterComposer,
          $$StockMovementsTableOrderingComposer,
          $$StockMovementsTableAnnotationComposer,
          $$StockMovementsTableCreateCompanionBuilder,
          $$StockMovementsTableUpdateCompanionBuilder,
          (StockMovement, $$StockMovementsTableReferences),
          StockMovement,
          PrefetchHooks Function({bool productId})
        > {
  $$StockMovementsTableTableManager(
    _$AppDatabase db,
    $StockMovementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> productId = const Value.absent(),
                Value<double> quantityDelta = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> documentType = const Value.absent(),
                Value<int?> documentId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StockMovementsCompanion(
                id: id,
                productId: productId,
                quantityDelta: quantityDelta,
                reason: reason,
                documentType: documentType,
                documentId: documentId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int productId,
                required double quantityDelta,
                required String reason,
                Value<String?> documentType = const Value.absent(),
                Value<int?> documentId = const Value.absent(),
                required DateTime createdAt,
              }) => StockMovementsCompanion.insert(
                id: id,
                productId: productId,
                quantityDelta: quantityDelta,
                reason: reason,
                documentType: documentType,
                documentId: documentId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StockMovementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({productId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (productId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.productId,
                                referencedTable: $$StockMovementsTableReferences
                                    ._productIdTable(db),
                                referencedColumn:
                                    $$StockMovementsTableReferences
                                        ._productIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StockMovementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StockMovementsTable,
      StockMovement,
      $$StockMovementsTableFilterComposer,
      $$StockMovementsTableOrderingComposer,
      $$StockMovementsTableAnnotationComposer,
      $$StockMovementsTableCreateCompanionBuilder,
      $$StockMovementsTableUpdateCompanionBuilder,
      (StockMovement, $$StockMovementsTableReferences),
      StockMovement,
      PrefetchHooks Function({bool productId})
    >;
typedef $$RecurringInvoicesTableCreateCompanionBuilder =
    RecurringInvoicesCompanion Function({
      Value<int> id,
      required int businessId,
      required int sourceInvoiceId,
      Value<String> frequency,
      required DateTime nextRunDate,
      Value<bool> isActive,
      required DateTime createdAt,
    });
typedef $$RecurringInvoicesTableUpdateCompanionBuilder =
    RecurringInvoicesCompanion Function({
      Value<int> id,
      Value<int> businessId,
      Value<int> sourceInvoiceId,
      Value<String> frequency,
      Value<DateTime> nextRunDate,
      Value<bool> isActive,
      Value<DateTime> createdAt,
    });

final class $$RecurringInvoicesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringInvoicesTable,
          RecurringInvoice
        > {
  $$RecurringInvoicesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $BusinessesTable _businessIdTable(_$AppDatabase db) => db.businesses
      .createAlias('recurring_invoices__business_id__businesses__id');

  $$BusinessesTableProcessedTableManager get businessId {
    final $_column = $_itemColumn<int>('business_id')!;

    final manager = $$BusinessesTableTableManager(
      $_db,
      $_db.businesses,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_businessIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InvoicesTable _sourceInvoiceIdTable(_$AppDatabase db) => db.invoices
      .createAlias('recurring_invoices__source_invoice_id__invoices__id');

  $$InvoicesTableProcessedTableManager get sourceInvoiceId {
    final $_column = $_itemColumn<int>('source_invoice_id')!;

    final manager = $$InvoicesTableTableManager(
      $_db,
      $_db.invoices,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sourceInvoiceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecurringInvoicesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringInvoicesTable> {
  $$RecurringInvoicesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BusinessesTableFilterComposer get businessId {
    final $$BusinessesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableFilterComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoicesTableFilterComposer get sourceInvoiceId {
    final $$InvoicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceInvoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableFilterComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringInvoicesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringInvoicesTable> {
  $$RecurringInvoicesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BusinessesTableOrderingComposer get businessId {
    final $$BusinessesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableOrderingComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoicesTableOrderingComposer get sourceInvoiceId {
    final $$InvoicesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceInvoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableOrderingComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringInvoicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringInvoicesTable> {
  $$RecurringInvoicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunDate => $composableBuilder(
    column: $table.nextRunDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$BusinessesTableAnnotationComposer get businessId {
    final $$BusinessesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.businessId,
      referencedTable: $db.businesses,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BusinessesTableAnnotationComposer(
            $db: $db,
            $table: $db.businesses,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InvoicesTableAnnotationComposer get sourceInvoiceId {
    final $$InvoicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sourceInvoiceId,
      referencedTable: $db.invoices,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InvoicesTableAnnotationComposer(
            $db: $db,
            $table: $db.invoices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringInvoicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringInvoicesTable,
          RecurringInvoice,
          $$RecurringInvoicesTableFilterComposer,
          $$RecurringInvoicesTableOrderingComposer,
          $$RecurringInvoicesTableAnnotationComposer,
          $$RecurringInvoicesTableCreateCompanionBuilder,
          $$RecurringInvoicesTableUpdateCompanionBuilder,
          (RecurringInvoice, $$RecurringInvoicesTableReferences),
          RecurringInvoice,
          PrefetchHooks Function({bool businessId, bool sourceInvoiceId})
        > {
  $$RecurringInvoicesTableTableManager(
    _$AppDatabase db,
    $RecurringInvoicesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringInvoicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringInvoicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringInvoicesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> businessId = const Value.absent(),
                Value<int> sourceInvoiceId = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<DateTime> nextRunDate = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RecurringInvoicesCompanion(
                id: id,
                businessId: businessId,
                sourceInvoiceId: sourceInvoiceId,
                frequency: frequency,
                nextRunDate: nextRunDate,
                isActive: isActive,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int businessId,
                required int sourceInvoiceId,
                Value<String> frequency = const Value.absent(),
                required DateTime nextRunDate,
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
              }) => RecurringInvoicesCompanion.insert(
                id: id,
                businessId: businessId,
                sourceInvoiceId: sourceInvoiceId,
                frequency: frequency,
                nextRunDate: nextRunDate,
                isActive: isActive,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringInvoicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({businessId = false, sourceInvoiceId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (businessId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.businessId,
                                    referencedTable:
                                        $$RecurringInvoicesTableReferences
                                            ._businessIdTable(db),
                                    referencedColumn:
                                        $$RecurringInvoicesTableReferences
                                            ._businessIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sourceInvoiceId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sourceInvoiceId,
                                    referencedTable:
                                        $$RecurringInvoicesTableReferences
                                            ._sourceInvoiceIdTable(db),
                                    referencedColumn:
                                        $$RecurringInvoicesTableReferences
                                            ._sourceInvoiceIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringInvoicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringInvoicesTable,
      RecurringInvoice,
      $$RecurringInvoicesTableFilterComposer,
      $$RecurringInvoicesTableOrderingComposer,
      $$RecurringInvoicesTableAnnotationComposer,
      $$RecurringInvoicesTableCreateCompanionBuilder,
      $$RecurringInvoicesTableUpdateCompanionBuilder,
      (RecurringInvoice, $$RecurringInvoicesTableReferences),
      RecurringInvoice,
      PrefetchHooks Function({bool businessId, bool sourceInvoiceId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db, _db.invoices);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db, _db.invoiceItems);
  $$InvoicePaymentsTableTableManager get invoicePayments =>
      $$InvoicePaymentsTableTableManager(_db, _db.invoicePayments);
  $$CustomerActivityEventsTableTableManager get customerActivityEvents =>
      $$CustomerActivityEventsTableTableManager(
        _db,
        _db.customerActivityEvents,
      );
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$QuoteItemsTableTableManager get quoteItems =>
      $$QuoteItemsTableTableManager(_db, _db.quoteItems);
  $$HsnCodesTableTableManager get hsnCodes =>
      $$HsnCodesTableTableManager(_db, _db.hsnCodes);
  $$HsnCodeRatesTableTableManager get hsnCodeRates =>
      $$HsnCodeRatesTableTableManager(_db, _db.hsnCodeRates);
  $$UomsTableTableManager get uoms => $$UomsTableTableManager(_db, _db.uoms);
  $$TemplateConfigsTableTableManager get templateConfigs =>
      $$TemplateConfigsTableTableManager(_db, _db.templateConfigs);
  $$DocumentSequencesTableTableManager get documentSequences =>
      $$DocumentSequencesTableTableManager(_db, _db.documentSequences);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$RecurringInvoicesTableTableManager get recurringInvoices =>
      $$RecurringInvoicesTableTableManager(_db, _db.recurringInvoices);
}
