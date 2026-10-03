import 'package:drift/drift.dart';
import 'businesses.dart';
import 'customers.dart';

@TableIndex(name: 'idx_quotes_business_id', columns: {#businessId})
@TableIndex(name: 'idx_quotes_customer_id', columns: {#customerId})
@DataClassName('Quote')
class Quotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get invoiceNumber => text()();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('INR'))();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get invoiceType => text()(); // QUOTE
  TextColumn get supplyType => text()(); // B2B, B2C, EXPORT
  IntColumn get placeOfSupply => integer()();
  RealColumn get subtotal => real()();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxableAmount => real()();
  RealColumn get cgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get sgstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get igstAmount => real().withDefault(const Constant(0.0))();
  RealColumn get cessAmount => real().withDefault(const Constant(0.0))();
  RealColumn get totalAmount => real()();
  /// Whole-rupee round-off adjustment (see `Invoices.roundOffAmount`).
  RealColumn get roundOffAmount => real().withDefault(const Constant(0.0))();
  TextColumn get amountInWords => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get terms => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  BoolColumn get isIgst => boolean().withDefault(const Constant(false))();
  IntColumn get templateId => integer().nullable()();

  /// Reverse-charge declaration and optional ship-to party (see `Invoices`).
  BoolColumn get reverseCharge =>
      boolean().withDefault(const Constant(false))();
  TextColumn get shipToName => text().nullable()();
  TextColumn get shipToAddress => text().nullable()();
  TextColumn get shipToCity => text().nullable()();

  /// Export/SEZ supplies declared under a Letter of Undertaking (see `Invoices`).
  BoolColumn get exportWithLut =>
      boolean().withDefault(const Constant(false))();

  /// Optional TDS/TCS adjustment (see `Invoices`).
  TextColumn get tdsSection => text().nullable()();
  RealColumn get tdsRate => real().withDefault(const Constant(0.0))();
  RealColumn get tdsAmount => real().withDefault(const Constant(0.0))();
  TextColumn get tcsSection => text().nullable()();
  RealColumn get tcsRate => real().withDefault(const Constant(0.0))();
  RealColumn get tcsAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {businessId, invoiceNumber},
  ];
}
