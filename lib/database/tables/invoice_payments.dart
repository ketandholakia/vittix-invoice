import 'package:drift/drift.dart';
import 'invoices.dart';

@TableIndex(name: 'idx_invoice_payments_invoice_id', columns: {#invoiceId})
@DataClassName('InvoicePayment')
class InvoicePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get kind => text().withDefault(const Constant('PAYMENT'))();
  DateTimeColumn get paidAt => dateTime()();

  /// How the money moved (CASH, UPI, BANK, CARD, OTHER). Optional so existing
  /// and manually entered payments stay valid.
  TextColumn get mode => text().nullable()();

  /// UPI/bank reference or transaction id the payment can be traced by.
  TextColumn get reference => text().nullable()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
