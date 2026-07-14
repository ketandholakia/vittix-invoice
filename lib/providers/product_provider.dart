import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final productListProvider = FutureProvider<List<Product>>((ref) async {
  final dao = ref.watch(productDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return [];
  return dao.getProductsForBusiness(activeBusinessId);
});

final productProvider = Provider<ProductNotifier>((ref) {
  return ProductNotifier(ref);
});

class ProductNotifier {
  final Ref _ref;

  ProductNotifier(this._ref);

  Future<int> addProduct(ProductsCompanion product) async {
    final dao = _ref.read(productDaoProvider);
    final id = await dao.insertProduct(product);
    _ref.invalidate(productListProvider);
    return id;
  }

  Future<bool> updateProduct(Product product) async {
    final dao = _ref.read(productDaoProvider);
    final success = await dao.updateProduct(product);
    _ref.invalidate(productListProvider);
    return success;
  }

  Future<void> deleteProduct(int id) async {
    final dao = _ref.read(productDaoProvider);
    await dao.deleteProduct(id);
    _ref.invalidate(productListProvider);
  }
}
