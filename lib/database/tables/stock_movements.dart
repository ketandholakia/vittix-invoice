import 'package:drift/drift.dart';
import 'products.dart';

/// Append-only ledger of every stock change for a product.
///
/// `products.stockQuantity` is the cached balance of this ledger, so it can
/// always be rebuilt and every change is auditable. Movements are never
/// clamped, so over-selling is visible as a negative balance instead of being
/// silently swallowed.
@TableIndex(name: 'idx_stock_movements_product_id', columns: {#productId})
@DataClassName('StockMovement')
class StockMovements extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId =>
      integer().references(Products, #id, onDelete: KeyAction.cascade)();

  /// Signed change: negative for sales, positive for reversals and increases.
  RealColumn get quantityDelta => real()();

  /// OPENING, ADJUSTMENT, INVOICE, INVOICE_REVERSAL.
  TextColumn get reason => text()();
  TextColumn get documentType => text().nullable()();
  IntColumn get documentId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime()();
}
