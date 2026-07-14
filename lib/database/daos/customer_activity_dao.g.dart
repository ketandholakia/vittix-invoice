// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'customer_activity_dao.dart';

// ignore_for_file: type=lint
mixin _$CustomerActivityDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $CustomersTable get customers => attachedDatabase.customers;
  $CustomerActivityEventsTable get customerActivityEvents =>
      attachedDatabase.customerActivityEvents;
  CustomerActivityDaoManager get managers => CustomerActivityDaoManager(this);
}

class CustomerActivityDaoManager {
  final _$CustomerActivityDaoMixin _db;
  CustomerActivityDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db.attachedDatabase, _db.customers);
  $$CustomerActivityEventsTableTableManager get customerActivityEvents =>
      $$CustomerActivityEventsTableTableManager(
        _db.attachedDatabase,
        _db.customerActivityEvents,
      );
}
