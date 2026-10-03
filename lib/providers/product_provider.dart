import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final productListProvider = StreamProvider.autoDispose<List<Product>>((ref) {
  final dao = ref.watch(productDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return Stream.value(const []);
  return dao.watchProductsForBusiness(activeBusinessId);
});

final productProvider = Provider<ProductNotifier>((ref) {
  return ProductNotifier(ref);
});

class ProductNotifier {
  final Ref _ref;

  ProductNotifier(this._ref);

  Future<int> addProduct(ProductsCompanion product) async {
    final dao = _ref.read(productDaoProvider);
    return dao.insertProduct(product);
  }

  Future<bool> updateProduct(Product product) async {
    final dao = _ref.read(productDaoProvider);
    return dao.updateProduct(product);
  }

  Future<void> deleteProduct(int id) async {
    final dao = _ref.read(productDaoProvider);
    await dao.deleteProduct(id);
  }

  /// Records a signed stock change in the movement ledger.
  Future<void> recordStockMovement({
    required int productId,
    required double quantityDelta,
    required String reason,
  }) async {
    final dao = _ref.read(productDaoProvider);
    await dao.recordStockMovement(
      productId: productId,
      quantityDelta: quantityDelta,
      reason: reason,
    );
  }
}