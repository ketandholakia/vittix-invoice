// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hsn_dao.dart';

// ignore_for_file: type=lint
mixin _$HsnDaoMixin on DatabaseAccessor<AppDatabase> {
  $HsnCodesTable get hsnCodes => attachedDatabase.hsnCodes;
  $HsnCodeRatesTable get hsnCodeRates => attachedDatabase.hsnCodeRates;
  HsnDaoManager get managers => HsnDaoManager(this);
}

class HsnDaoManager {
  final _$HsnDaoMixin _db;
  HsnDaoManager(this._db);
  $$HsnCodesTableTableManager get hsnCodes =>
      $$HsnCodesTableTableManager(_db.attachedDatabase, _db.hsnCodes);
  $$HsnCodeRatesTableTableManager get hsnCodeRates =>
      $$HsnCodeRatesTableTableManager(_db.attachedDatabase, _db.hsnCodeRates);
}
