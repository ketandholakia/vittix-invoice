// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recurring_invoice_dao.dart';

// ignore_for_file: type=lint
mixin _$RecurringInvoiceDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CustomersTable get customers => attachedDatabase.customers;
  $InvoicesTable get invoices => attachedDatabase.invoices;
  $RecurringInvoicesTable get recurringInvoices =>
      attachedDatabase.recurringInvoices;
  RecurringInvoiceDaoManager get managers => RecurringInvoiceDaoManager(this);
}

class RecurringInvoiceDaoManager {
  final _$RecurringInvoiceDaoMixin _db;
  RecurringInvoiceDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db.attachedDatabase, _db.invoices);
  $$RecurringInvoicesTableTableManager get recurringInvoices =>
      $$RecurringInvoicesTableTableManager(
        _db.attachedDatabase,
        _db.recurringInvoices,
      );
}
