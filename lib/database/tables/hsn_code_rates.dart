import 'package:drift/drift.dart';

@DataClassName('HsnCodeRate')
class HsnCodeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text()();
  RealColumn get gstRate => real().nullable()();
  DateTimeColumn get effectiveFrom => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {code, effectiveFrom},
  ];
}
