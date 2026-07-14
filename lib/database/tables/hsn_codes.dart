import 'package:drift/drift.dart';

@DataClassName('HsnCode')
class HsnCodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text().unique()();
  TextColumn get description => text()();
  RealColumn get gstRate => real().nullable()();
  TextColumn get type => text().withDefault(const Constant('HSN'))();
}
