import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products.dart';
import '../tables/stock_movements.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products, StockMovements])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<Product>> getProductsForBusiness(int businessId) =>
      (select(products)..where((t) => t.businessId.equals(businessId))).get();

  Stream<List<Product>> watchProductsForBusiness(int businessId) =>
      (select(products)..where((t) => t.businessId.equals(businessId))).watch();

  Future<Product?> getProductById(int id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Product>> getProductsByIds(List<int> ids) {
    if (ids.isEmpty) {
      return Future.value(const []);
    }

    return (select(products)..where((t) => t.id.isIn(ids))).get();
  }

  Future<int> insertProduct(ProductsCompanion product) =>
      into(products).insert(product);
  Future<bool> updateProduct(Product product) =>
      update(products).replace(product);
  Future<int> deleteProduct(int id) =>
      (delete(products)..where((t) => t.id.equals(id))).go();

  /// Records a signed stock change and rewrites the product's cached balance
  /// to the ledger sum. Movements are never clamped, so an over-sale shows as a
  /// negative balance rather than being lost.
  Future<void> recordStockMovement({
    required int productId,
    required double quantityDelta,
    required String reason,
    String? documentType,
    int? documentId,
    DateTime? createdAt,
  }) async {
    if (quantityDelta == 0) return;

    await transaction(() async {
      await into(stockMovements).insert(
        StockMovementsCompanion.insert(
          productId: productId,
          quantityDelta: quantityDelta,
          reason: reason,
          documentType: Value(documentType),
          documentId: Value(documentId),
          createdAt: createdAt ?? DateTime.now(),
        ),
      );
      await _recomputeStockBalance(productId);
    });
  }

  /// The ledger sum for [productId] — the authoritative stock level.
  Future<double> stockBalance(int productId) async {
    final total = stockMovements.quantityDelta.sum();
    final query = selectOnly(stockMovements)
      ..addColumns([total])
      ..where(stockMovements.productId.equals(productId));
    final row = await query.getSingle();
    return row.read(total) ?? 0;
  }

  Future<List<StockMovement>> getStockMovements(int productId) =>
      (select(stockMovements)
            ..where((t) => t.productId.equals(productId))
            ..orderBy([
              (t) => OrderingTerm(
                expression: t.createdAt,
                mode: OrderingMode.desc,
              ),
            ]))
          .get();

  Future<void> adjustStockQuantity(int productId, double delta) =>
      recordStockMovement(
        productId: productId,
        quantityDelta: delta,
        reason: 'ADJUSTMENT',
      );

  Future<void> _recomputeStockBalance(int productId) async {
    final balance = await stockBalance(productId);
    final product = await getProductById(productId);
    if (product == null) return;
    await updateProduct(product.copyWith(stockQuantity: balance));
  }
}
