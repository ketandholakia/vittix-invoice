import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/template_configs.dart';

part 'template_config_dao.g.dart';

@DriftAccessor(tables: [TemplateConfigs])
class TemplateConfigDao extends DatabaseAccessor<AppDatabase>
    with _$TemplateConfigDaoMixin {
  TemplateConfigDao(super.db);

  Future<List<TemplateConfig>> getTemplatesForBusiness(
    int businessId,
    TemplateScope scope,
  ) {
    return (select(templateConfigs)
          ..where((t) => t.businessId.equals(businessId))
          ..where((t) => t.scope.equals(scope.index)))
        .get();
  }

  Future<TemplateConfig?> getDefaultTemplate(
    int businessId,
    TemplateScope scope,
  ) {
    return (select(templateConfigs)
          ..where((t) => t.businessId.equals(businessId))
          ..where((t) => t.scope.equals(scope.index))
          ..where((t) => t.isDefault.equals(true)))
        .getSingleOrNull();
  }

  Future<TemplateConfig?> getTemplateById(int id) {
    return (select(templateConfigs)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  Future<int> insertTemplate(TemplateConfigsCompanion template) =>
      into(templateConfigs).insert(template);

  Future<bool> updateTemplate(TemplateConfig template) =>
      update(templateConfigs).replace(template);

  Future<int> deleteTemplate(int id) =>
      (delete(templateConfigs)..where((t) => t.id.equals(id))).go();

  Future<void> clearDefaultForScope(int businessId, TemplateScope scope) async {
    await (update(templateConfigs)
          ..where((t) => t.businessId.equals(businessId))
          ..where((t) => t.scope.equals(scope.index)))
        .write(const TemplateConfigsCompanion(isDefault: Value(false)));
  }
}
