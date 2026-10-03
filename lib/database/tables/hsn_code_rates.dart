import 'package:drift/drift.dart';

/// Upper sentinel for an unbounded price band. Large enough to exceed any
/// realistic unit price, and finite so it stores and compares reliably.
const double unboundedUnitPrice = 1e12;

@DataClassName('HsnCodeRate')
class HsnCodeRates extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text()();
  RealColumn get gstRate => real().nullable()();
  DateTimeColumn get effectiveFrom => dateTime()();

  /// Price band for rate rules that depend on the unit price (for example
  /// readymade garments: 5% up to Rs.2,500 per piece, 18% above).
  ///
  /// Applied as `minUnitPrice < price <= maxUnitPrice`. The defaults
  /// (0 and [unboundedUnitPrice]) mean "every price". Bounds are non-null so
  /// the uniqueness constraint below stays effective — a nullable column would
  /// let SQLite treat each row as distinct and duplicate seed rates on every
  /// launch.
  RealColumn get minUnitPrice => real().withDefault(const Constant(0))();
  RealColumn get maxUnitPrice =>
      real().withDefault(const Constant(unboundedUnitPrice))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {code, effectiveFrom, minUnitPrice, maxUnitPrice},
  ];
}
