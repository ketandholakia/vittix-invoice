
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/core/utils/stock_status.dart';

void main() {
  group('LowStock', () {
    Product product({
      double stock = 0,
      double reorder = 0,
      bool isService = false,
    }) => Product(
      id: 1,
      businessId: 1,
      name: 'P',
      hsnSac: '1234',
      unit: 'PCS',
      salePrice: 100,
      gstRate: 18,
      cessRate: 0,
      stockQuantity: stock,
      reorderLevel: reorder,
      isService: isService,
      isActive: true,
      createdAt: DateTime(2026, 6, 30),
    );

    test('uses the reorder level when one is configured', () {
      expect(isProductLowStock(product(stock: 10, reorder: 5)), isFalse);
      expect(isProductLowStock(product(stock: 5, reorder: 5)), isTrue);
      expect(lowStockLabel(product(stock: 5, reorder: 5)), 'Low stock');
      expect(lowStockLabel(product(stock: 0, reorder: 5)), 'Out of stock');
    });

    test('falls back to out-of-stock when no level is set', () {
      expect(isProductLowStock(product(stock: 1, reorder: 0)), isFalse);
      expect(isProductLowStock(product(stock: 0, reorder: 0)), isTrue);
      expect(lowStockLabel(product(stock: 1, reorder: 0)), isNull);
    });

    test('services are never low on stock', () {
      expect(
        isProductLowStock(product(stock: 0, reorder: 5, isService: true)),
        isFalse,
      );
      expect(
        lowStockLabel(product(stock: 0, reorder: 5, isService: true)),
        isNull,
      );
    });
  });

  group('StockLedger', () {
    late AppDatabase database;

    setUp(() => database = AppDatabase.forTesting(NativeDatabase.memory()));
    tearDown(() => database.close());

    Future<int> createProduct({double opening = 0}) async {
      final businessId = await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final productId = await database.into(database.products).insert(
            ProductsCompanion.insert(
              businessId: businessId,
              name: 'P',
              hsnSac: '1234',
              unit: 'PCS',
              salePrice: 100,
              gstRate: 18,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      if (opening != 0) {
        await database.productDao.recordStockMovement(
          productId: productId,
          quantityDelta: opening,
          reason: 'OPENING',
        );
      }
      return productId;
    }

    test('records movements and keeps the cached balance in step', () async {
      final id = await createProduct(opening: 10);

      await database.productDao.recordStockMovement(
        productId: id,
        quantityDelta: -4,
        reason: 'INVOICE',
      );

      expect((await database.productDao.getProductById(id))?.stockQuantity, 6);
      expect(await database.productDao.stockBalance(id), 6);
    });

    test('over-sale stays visible and the reversal restores the balance',
        () async {
      final id = await createProduct(opening: 5);

      await database.productDao.recordStockMovement(
        productId: id,
        quantityDelta: -10,
        reason: 'INVOICE',
      );
      // No clamp: the over-sale is visible as a negative balance.
      expect((await database.productDao.getProductById(id))?.stockQuantity, -5);

      await database.productDao.recordStockMovement(
        productId: id,
        quantityDelta: 10,
        reason: 'INVOICE_REVERSAL',
      );
      expect((await database.productDao.getProductById(id))?.stockQuantity, 5);
      expect(await database.productDao.getStockMovements(id), hasLength(3));
    });
  });
}
