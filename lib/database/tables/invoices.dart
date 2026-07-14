import 'package:drift/drift.dart';
import 'businesses.dart';
import 'customers.dart';

@DataClassName('Invoice')
class Invoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get invoiceNumber => text()();
  TextColumn get currencyCode =>
      text().withDefault(const Constant('INR'))();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  TextColumn get invoiceType =>
      text()(); // TAX_INVOICE, BILL_OF_SUPPLY, CREDIT_NOTE, DEBIT_NOTE
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
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  TextColumn get amountInWords => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get terms => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  BoolColumn get isIgst => boolean().withDefault(const Constant(false))();
  IntColumn get templateId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {businessId, invoiceNumber},
  ];
}
