// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'business_dao.dart';

// ignore_for_file: type=lint
mixin _$BusinessDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  BusinessDaoManager get managers => BusinessDaoManager(this);
}

class BusinessDaoManager {
  final _$BusinessDaoMixin _db;
  BusinessDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
}
