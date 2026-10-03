import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/quote_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

/// Differential coverage for the shared document core (P6): invoice and
/// quote paths must behave identically except for stock effects, and
/// quote-to-invoice conversion must route through the same core.
void main() {
  group('DocumentServiceBase (invoice/quote differential)', () {
    late AppDatabase database;
    late ProviderContainer container;
    late int productId;

    setUp(() async {
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final sharedPreferences = await SharedPreferences.getInstance();
      database = AppDatabase.forTesting(NativeDatabase.memory());

      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      await database
          .into(database.businesses)
          .insert(
            BusinessesCompanion.insert(
              name: 'Test Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database
          .into(database.customers)
          .insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Test Customer',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      productId = await database.into(database.products).insert(
        ProductsCompanion.insert(
          businessId: 1,
          name: 'Tracked Item',
          hsnSac: '1234',
          unit: 'PCS',
          salePrice: 100,
          gstRate: 18,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      // Stock lives in the movement ledger: seed the opening balance as a
      // movement so the cached quantity matches the ledger sum.
      await database.productDao.recordStockMovement(
        productId: productId,
        quantityDelta: 10,
        reason: 'OPENING',
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    InvoicesCompanion invoiceCompanion({DateTime? dueDate, double quantityTotal = 200}) {
      return InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: DateTime(2026, 6, 30),
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: quantityTotal,
        taxableAmount: quantityTotal,
        totalAmount: quantityTotal + (quantityTotal * 18 / 100),
        dueDate: drift.Value(dueDate ?? DateTime(2026, 7, 7)),
        discountAmount: const drift.Value(0),
        cgstAmount: drift.Value(quantityTotal * 9 / 100),
        sgstAmount: drift.Value(quantityTotal * 9 / 100),
        igstAmount: const drift.Value(0),
        cessAmount: const drift.Value(0),
        amountInWords: const drift.Value('Amount In Words'),
        notes: const drift.Value<String?>(null),
        terms: const drift.Value<String?>(null),
        isIgst: const drift.Value(false),
        createdAt: DateTime(2026, 6, 30),
        updatedAt: DateTime(2026, 6, 30),
      );
    }

    QuotesCompanion quoteCompanion({DateTime? dueDate, double quantityTotal = 200}) {
      return QuotesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: DateTime(2026, 6, 30),
        invoiceType: 'QUOTE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: quantityTotal,
        taxableAmount: quantityTotal,
        totalAmount: quantityTotal + (quantityTotal * 18 / 100),
        dueDate: drift.Value(dueDate ?? DateTime(2026, 7, 7)),
        discountAmount: const drift.Value(0),
        cgstAmount: drift.Value(quantityTotal * 9 / 100),
        sgstAmount: drift.Value(quantityTotal * 9 / 100),
        igstAmount: const drift.Value(0),
        cessAmount: const drift.Value(0),
        amountInWords: const drift.Value('Amount In Words'),
        notes: const drift.Value<String?>(null),
        terms: const drift.Value<String?>(null),
        isIgst: const drift.Value(false),
        createdAt: DateTime(2026, 6, 30),
        updatedAt: DateTime(2026, 6, 30),
      );
    }

    List<InvoiceItemsCompanion> invoiceItems({double quantity = 2}) => [
      InvoiceItemsCompanion(
        productId: drift.Value(productId),
        name: const drift.Value('Tracked Item'),
        hsnSac: const drift.Value('1234'),
        unit: const drift.Value('PCS'),
        quantity: drift.Value(quantity),
        rate: const drift.Value(100),
        discountPct: const drift.Value(0),
        taxableAmount: drift.Value(100 * quantity),
        gstRate: const drift.Value(18),
        cgstRate: const drift.Value(9),
        sgstRate: const drift.Value(9),
        igstRate: const drift.Value(0),
        cgstAmount: drift.Value(9 * quantity),
        sgstAmount: drift.Value(9 * quantity),
        igstAmount: const drift.Value(0),
        cessAmount: const drift.Value(0),
        totalAmount: drift.Value(118 * quantity),
      ),
    ];

    List<QuoteItemsCompanion> quoteItems({double quantity = 2}) => [
      QuoteItemsCompanion(
        productId: drift.Value(productId),
        name: const drift.Value('Tracked Item'),
        hsnSac: const drift.Value('1234'),
        unit: const drift.Value('PCS'),
        quantity: drift.Value(quantity),
        rate: const drift.Value(100),
        discountPct: const drift.Value(0),
        taxableAmount: drift.Value(100 * quantity),
        gstRate: const drift.Value(18),
        cgstRate: const drift.Value(9),
        sgstRate: const drift.Value(9),
        igstRate: const drift.Value(0),
        cgstAmount: drift.Value(9 * quantity),
        sgstAmount: drift.Value(9 * quantity),
        igstAmount: const drift.Value(0),
        cessAmount: const drift.Value(0),
        totalAmount: drift.Value(118 * quantity),
      ),
    ];

    test('quote creation leaves stock untouched while invoice creation deducts it', () async {
      final quoteId = await container.read(quoteProvider).createQuoteWithItems(
        quoteCompanion(),
        quoteItems(),
      );
      final quote = await database.quoteDao.getQuoteById(quoteId);

      expect(quote?.status, 'DRAFT');
      expect(quote?.totalAmount, 236);
      expect(
        (await database.productDao.getProductById(productId))?.stockQuantity,
        10,
      );

      final invoiceId = await container.read(invoiceProvider).createInvoiceWithItems(
        invoiceCompanion(),
        invoiceItems(),
      );
      final invoice = await database.invoiceDao.getInvoiceById(invoiceId);

      expect(invoice?.totalAmount, 236);
      expect(invoice?.invoiceNumber, startsWith('INV-'));
      expect(
        (await database.productDao.getProductById(productId))?.stockQuantity,
        8,
      );

      final storedInvoiceItems = await database.invoiceDao.getItemsForInvoice(invoiceId);
      final storedQuoteItems = await database.quoteDao.getItemsForQuote(quoteId);
      expect(storedInvoiceItems.single.name, storedQuoteItems.single.name);
      expect(storedInvoiceItems.single.quantity, storedQuoteItems.single.quantity);
      expect(storedInvoiceItems.single.totalAmount, storedQuoteItems.single.totalAmount);
      expect(storedInvoiceItems.single.sortOrder, storedQuoteItems.single.sortOrder);
    });

    test('duplicating either document produces a fresh-numbered DRAFT copy', () async {
      final invoiceId = await container.read(invoiceProvider).createInvoiceWithItems(
        invoiceCompanion(),
        invoiceItems(),
      );
      final quoteId = await container.read(quoteProvider).createQuoteWithItems(
        quoteCompanion(),
        quoteItems(),
      );

      final duplicatedInvoiceId = await container
          .read(invoiceProvider)
          .duplicateInvoice(invoiceId);
      final duplicatedQuoteId = await container
          .read(quoteProvider)
          .duplicateQuote(quoteId);

      final duplicatedInvoice = await database.invoiceDao.getInvoiceById(
        duplicatedInvoiceId,
      );
      final duplicatedQuote = await database.quoteDao.getQuoteById(
        duplicatedQuoteId,
      );

      expect(duplicatedInvoice?.status, 'DRAFT');
      expect(duplicatedQuote?.status, 'DRAFT');
      expect(duplicatedInvoice?.invoiceNumber, isNot(duplicatedQuote?.invoiceNumber));
      expect(duplicatedInvoice?.invoiceNumber, startsWith('INV-'));
      expect(duplicatedQuote?.invoiceNumber, startsWith('QT-'));
      expect(duplicatedInvoice?.totalAmount, duplicatedQuote?.totalAmount);
      expect(duplicatedInvoice?.dueDate, duplicatedQuote?.dueDate);

      // Duplicating an invoice deducts stock again, mirroring a second sale.
      expect(
        (await database.productDao.getProductById(productId))?.stockQuantity,
        6,
      );
    });

    test('convertToInvoice routes through the shared invoice core and deducts stock', () async {
      final quoteService = container.read(quoteProvider);
      final quoteId = await quoteService.createQuoteWithItems(
        quoteCompanion(),
        quoteItems(),
      );

      final invoiceId = await quoteService.convertToInvoice(quoteId);

      final invoice = await database.invoiceDao.getInvoiceById(invoiceId);
      expect(invoice, isNotNull);
      expect(invoice!.invoiceNumber, startsWith('INV-'));
      expect(invoice.totalAmount, 236);
      expect(invoice.subtotal, 200);

      final storedItems = await database.invoiceDao.getItemsForInvoice(invoiceId);
      expect(storedItems, hasLength(1));
      expect(storedItems.single.productId, productId);
      expect(storedItems.single.name, 'Tracked Item');
      expect(storedItems.single.quantity, 2);

      final quote = await database.quoteDao.getQuoteById(quoteId);
      expect(quote?.status, 'CONVERTED');

      expect(
        (await database.productDao.getProductById(productId))?.stockQuantity,
        8,
      );
    });

    test('edit audit summaries carry the document-specific labels', () async {
      final invoiceId = await container.read(invoiceProvider).createInvoiceWithItems(
        invoiceCompanion(),
        invoiceItems(),
      );
      final quoteId = await container.read(quoteProvider).createQuoteWithItems(
        quoteCompanion(),
        quoteItems(),
      );

      final storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final storedQuote = await database.quoteDao.getQuoteById(quoteId);

      await container.read(invoiceProvider).updateInvoiceWithItems(
        storedInvoice!,
        invoiceCompanion(dueDate: DateTime(2026, 7, 10)),
        invoiceItems(),
      );
      await container.read(quoteProvider).updateQuoteWithItems(
        storedQuote!,
        quoteCompanion(dueDate: DateTime(2026, 7, 10)),
        quoteItems(),
      );

      final events = await database.customerActivityDao.getEventsForCustomer(1);
      final invoiceEdit = events.firstWhere(
        (event) => event.eventType == 'INVOICE_EDIT',
      );
      final quoteEdit = events.firstWhere(
        (event) => event.eventType == 'QUOTE_EDIT',
      );

      expect(invoiceEdit.note, contains('Invoice edited:'));
      expect(invoiceEdit.note, contains('due date Jul 7, 2026 -> Jul 10, 2026'));
      expect(invoiceEdit.entityType, 'INVOICE');

      expect(quoteEdit.note, contains('Quote edited:'));
      expect(quoteEdit.note, contains('valid until Jul 7, 2026 -> Jul 10, 2026'));
      expect(quoteEdit.entityType, 'QUOTE');
    });
  });
}
