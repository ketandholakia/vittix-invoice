// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_dao.dart';

// ignore_for_file: type=lint
mixin _$QuoteDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CustomersTable get customers => attachedDatabase.customers;
  $QuotesTable get quotes => attachedDatabase.quotes;
  $ProductsTable get products => attachedDatabase.products;
  $QuoteItemsTable get quoteItems => attachedDatabase.quoteItems;
  QuoteDaoManager get managers => QuoteDaoManager(this);
}

class QuoteDaoManager {
  final _$QuoteDaoMixin _db;
  QuoteDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db.attachedDatabase, _db.quotes);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$QuoteItemsTableTableManager get quoteItems =>
      $$QuoteItemsTableTableManager(_db.attachedDatabase, _db.quoteItems);
}
