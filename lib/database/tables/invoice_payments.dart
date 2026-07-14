import 'package:drift/drift.dart';
import 'invoices.dart';

@DataClassName('InvoicePayment')
class InvoicePayments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get invoiceId =>
      integer().references(Invoices, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get kind => text().withDefault(const Constant('PAYMENT'))();
  DateTimeColumn get paidAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
