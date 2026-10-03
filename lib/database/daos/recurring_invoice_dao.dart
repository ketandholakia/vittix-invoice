import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recurring_invoices.dart';

part 'recurring_invoice_dao.g.dart';

@DriftAccessor(tables: [RecurringInvoices])
class RecurringInvoiceDao extends DatabaseAccessor<AppDatabase>
    with _$RecurringInvoiceDaoMixin {
  RecurringInvoiceDao(super.db);

  Future<List<RecurringInvoice>> getForBusiness(int businessId) =>
      (select(recurringInvoices)
            ..where((t) => t.businessId.equals(businessId))
            ..orderBy([(t) => OrderingTerm(expression: t.nextRunDate)]))
          .get();

  Future<RecurringInvoice?> getActiveForSource(int invoiceId) =>
      (select(recurringInvoices)..where(
            (t) =>
                t.sourceInvoiceId.equals(invoiceId) & t.isActive.equals(true),
          ))
          .getSingleOrNull();

  Future<List<RecurringInvoice>> getDue(DateTime today) =>
      (select(recurringInvoices)..where(
            (t) =>
                t.isActive.equals(true) &
                t.nextRunDate.isSmallerOrEqualValue(today),
          ))
          .get();

  Future<int> insertRecurrence(RecurringInvoicesCompanion row) =>
      into(recurringInvoices).insert(row);

  Future<bool> updateRecurrence(RecurringInvoice row) =>
      update(recurringInvoices).replace(row);

  Future<int> deleteRecurrence(int id) =>
      (delete(recurringInvoices)..where((t) => t.id.equals(id))).go();
}
