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

  /// Day of month of the schedule's first run. Month-based steps land on
  /// this day (clamped to the month's length) so a 31st-anchored schedule
  /// never drifts after a short month clamps it. 0 marks rows created
  /// before the column existed (v31 and earlier) — they advance from the
  /// current date instead.
  IntColumn get anchorDay => integer().withDefault(const Constant(0))();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
