import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/products.dart';

part 'product_dao.g.dart';

@DriftAccessor(tables: [Products])
class ProductDao extends DatabaseAccessor<AppDatabase> with _$ProductDaoMixin {
  ProductDao(super.db);

  Future<List<Product>> getProductsForBusiness(int businessId) =>
      (select(products)..where((t) => t.businessId.equals(businessId))).get();

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

  Future<void> adjustStockQuantity(int productId, double delta) async {
    final product = await getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    await updateProduct(product.copyWith(stockQuantity: product.stockQuantity + delta));
  }
}
