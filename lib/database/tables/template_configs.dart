import 'package:drift/drift.dart';
import 'businesses.dart';

enum TemplateScope { invoice, quote }

@DataClassName('TemplateConfig')
class TemplateConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  IntColumn get scope => intEnum<TemplateScope>()();
  TextColumn get name => text()();
  TextColumn get configJson => text()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}
