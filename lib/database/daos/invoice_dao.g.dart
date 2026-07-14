// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_dao.dart';

// ignore_for_file: type=lint
mixin _$InvoiceDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CustomersTable get customers => attachedDatabase.customers;
  $InvoicesTable get invoices => attachedDatabase.invoices;
  $ProductsTable get products => attachedDatabase.products;
  $InvoiceItemsTable get invoiceItems => attachedDatabase.invoiceItems;
  $InvoicePaymentsTable get invoicePayments => attachedDatabase.invoicePayments;
  InvoiceDaoManager get managers => InvoiceDaoManager(this);
}

class InvoiceDaoManager {
  final _$InvoiceDaoMixin _db;
  InvoiceDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$InvoicesTableTableManager get invoices =>
      $$InvoicesTableTableManager(_db.attachedDatabase, _db.invoices);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$InvoiceItemsTableTableManager get invoiceItems =>
      $$InvoiceItemsTableTableManager(_db.attachedDatabase, _db.invoiceItems);
  $$InvoicePaymentsTableTableManager get invoicePayments =>
      $$InvoicePaymentsTableTableManager(
        _db.attachedDatabase,
        _db.invoicePayments,
      );
}
