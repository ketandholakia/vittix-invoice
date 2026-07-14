import 'package:drift/drift.dart';

enum BusinessType { gstRegistered, unregistered, compositionScheme }

@DataClassName('Business')
class Businesses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get gstin => text()();
  TextColumn get pan => text().nullable()();
  IntColumn get businessType =>
      intEnum<BusinessType>().withDefault(const Constant(0))();
  TextColumn get address => text()();
  TextColumn get city => text()();
  IntColumn get stateCode => integer()();
  TextColumn get pincode => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get logoPath => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get bankAccount => text().nullable()();
  TextColumn get bankIfsc => text().nullable()();
  TextColumn get upiId => text().nullable()();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('INR'))();
  TextColumn get invoiceTemplate =>
      text().withDefault(const Constant('CLASSIC'))();
  TextColumn get quoteTemplate =>
      text().withDefault(const Constant('CLASSIC'))();
  TextColumn get invoiceSeriesFormat =>
      text().withDefault(const Constant('INV-{FY}-{SEQ4}'))();
  TextColumn get quoteSeriesFormat =>
      text().withDefault(const Constant('QT-{FY}-{SEQ4}'))();
  IntColumn get defaultInvoiceTemplateId => integer().nullable()();
  IntColumn get defaultQuoteTemplateId => integer().nullable()();
  IntColumn get brandColor => integer().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}
