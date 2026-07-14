// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'template_config_dao.dart';

// ignore_for_file: type=lint
mixin _$TemplateConfigDaoMixin on DatabaseAccessor<AppDatabase> {
  $BusinessesTable get businesses => attachedDatabase.businesses;
  $TemplateConfigsTable get templateConfigs => attachedDatabase.templateConfigs;
  TemplateConfigDaoManager get managers => TemplateConfigDaoManager(this);
}

class TemplateConfigDaoManager {
  final _$TemplateConfigDaoMixin _db;
  TemplateConfigDaoManager(this._db);
  $$BusinessesTableTableManager get businesses =>
      $$BusinessesTableTableManager(_db.attachedDatabase, _db.businesses);
  $$TemplateConfigsTableTableManager get templateConfigs =>
      $$TemplateConfigsTableTableManager(
        _db.attachedDatabase,
        _db.templateConfigs,
      );
}
