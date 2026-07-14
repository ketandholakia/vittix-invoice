import 'package:drift/drift.dart';
import 'businesses.dart';
import 'customers.dart';

@DataClassName('CustomerActivityEvent')
class CustomerActivityEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  IntColumn get customerId => integer().references(Customers, #id)();
  TextColumn get eventType => text()();
  TextColumn get entityType => text().nullable()();
  IntColumn get entityId => integer().nullable()();
  TextColumn get title => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
