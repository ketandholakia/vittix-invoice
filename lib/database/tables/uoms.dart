import 'package:drift/drift.dart';

@DataClassName('Uom')
class Uoms extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get name => text()();
  TextColumn get family => text().withDefault(const Constant('GENERAL'))();
  TextColumn get baseCode => text().nullable()();
  RealColumn get conversionFactor => real().withDefault(const Constant(1.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}
