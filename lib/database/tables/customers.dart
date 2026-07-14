import 'package:drift/drift.dart';
import 'businesses.dart';

@DataClassName('Customer')
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get gstin => text().nullable()();
  TextColumn get pan => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  IntColumn get stateCode => integer().nullable()();
  TextColumn get pincode => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
