import 'package:drift/drift.dart';
import 'businesses.dart';

@TableIndex(name: 'idx_products_business_id', columns: {#businessId})
@DataClassName('Product')
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get hsnSac => text()();
  TextColumn get unit => text()();
  RealColumn get salePrice => real()();
  RealColumn get purchasePrice => real().nullable()();
  RealColumn get gstRate => real()();
  RealColumn get cessRate => real().withDefault(const Constant(0.0))();
  RealColumn get stockQuantity => real().withDefault(const Constant(0.0))();

  /// Stock level at or below which the product counts as low stock. Zero means
  /// "no threshold configured" and falls back to out-of-stock detection.
  RealColumn get reorderLevel => real().withDefault(const Constant(0.0))();
  BoolColumn get isService => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
}
