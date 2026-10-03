import 'package:drift/drift.dart';
import 'businesses.dart';
import 'customers.dart';

@TableIndex(name: 'idx_invoices_business_id', columns: {#businessId})
@TableIndex(name: 'idx_invoices_customer_id', columns: {#customerId})
@TableIndex(name: 'idx_invoices_invoice_date', columns: {#invoiceDate})
@TableIndex(name: 'idx_invoices_status', columns: {#status})
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
  /// Adjustment applied to the grand total to reach a whole-rupee payable
  /// amount (the classic Indian invoice "round off" line). Stored separately
  /// so the printed total is a clean figure and the difference is auditable.
  RealColumn get roundOffAmount => real().withDefault(const Constant(0.0))();
  RealColumn get amountPaid => real().withDefault(const Constant(0.0))();
  TextColumn get amountInWords => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get terms => text().nullable()();
  TextColumn get status => text().withDefault(const Constant('DRAFT'))();
  BoolColumn get isIgst => boolean().withDefault(const Constant(false))();
  IntColumn get templateId => integer().nullable()();

  /// The invoice a credit/debit note adjusts. Null for plain invoices.
  IntColumn get referenceInvoiceId => integer().nullable()();

  /// Reverse-charge supplies must be declared on the invoice.
  BoolColumn get reverseCharge =>
      boolean().withDefault(const Constant(false))();

  /// Optional ship-to (delivery) party when it differs from the customer.
  TextColumn get shipToName => text().nullable()();
  TextColumn get shipToAddress => text().nullable()();
  TextColumn get shipToCity => text().nullable()();

  /// Export/SEZ supplies declared under a Letter of Undertaking (no IGST).
  BoolColumn get exportWithLut =>
      boolean().withDefault(const Constant(false))();

  /// Optional TDS/TCS adjustment. TDS is deducted by the buyer; TCS is
  /// collected on the invoice value. Both are computed on the taxable amount.
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
