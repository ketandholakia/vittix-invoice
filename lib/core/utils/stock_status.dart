import '../../database/app_database.dart';

/// Whether [product] is at or below its reorder level.
///
/// A configured reorder level wins; when none is set (0) the product only
/// counts as low once it is out of stock, so the feature works before anyone
/// bothers to configure thresholds. Services never hold stock.
bool isProductLowStock(Product product) {
  if (product.isService) return false;
  return product.reorderLevel > 0
      ? product.stockQuantity <= product.reorderLevel
      : product.stockQuantity <= 0;
}

/// Short label for a low-stock badge, e.g. "Low stock" or "Out of stock".
String? lowStockLabel(Product product) {
  if (!isProductLowStock(product)) return null;
  return product.stockQuantity <= 0 ? 'Out of stock' : 'Low stock';
}
