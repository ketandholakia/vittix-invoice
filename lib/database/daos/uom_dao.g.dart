// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'uom_dao.dart';

// ignore_for_file: type=lint
mixin _$UomDaoMixin on DatabaseAccessor<AppDatabase> {
  $UomsTable get uoms => attachedDatabase.uoms;
  UomDaoManager get managers => UomDaoManager(this);
}

class UomDaoManager {
  final _$UomDaoMixin _db;
  UomDaoManager(this._db);
  $$UomsTableTableManager get uoms =>
      $$UomsTableTableManager(_db.attachedDatabase, _db.uoms);
}
