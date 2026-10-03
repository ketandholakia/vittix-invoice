import 'package:drift/drift.dart';
import 'businesses.dart';
import 'invoices.dart';

/// A schedule that repeats an existing invoice: on each due date a fresh draft
/// invoice is generated from [sourceInvoiceId].
@TableIndex(name: 'idx_recurring_invoices_source', columns: {#sourceInvoiceId})
@DataClassName('RecurringInvoice')
class RecurringInvoices extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  IntColumn get sourceInvoiceId => integer().references(Invoices, #id)();

  /// WEEKLY, MONTHLY, QUARTERLY or YEARLY.
  TextColumn get frequency => text().withDefault(const Constant('MONTHLY'))();

  /// The next date a draft should be generated for.
  DateTimeColumn get nextRunDate => dateTime()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
