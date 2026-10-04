
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/quote_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
  group('QuoteService', () {
    late AppDatabase database;
    late ProviderContainer container;

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
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('duplicates quote with a fresh number and draft status', () async {
      final notifier = container.read(quoteProvider);
      final quoteDate = DateTime(2026, 6, 30);
      final quote = QuotesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: quoteDate,
        invoiceType: 'QUOTATION',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        dueDate: drift.Value(DateTime(2026, 7, 7)),
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        status: const drift.Value('SENT'),
        createdAt: quoteDate,
        updatedAt: quoteDate,
      );
      final items = [
        const QuoteItemsCompanion(
          name: drift.Value('Service'),
          hsnSac: drift.Value('9983'),
          unit: drift.Value('NOS'),
          quantity: drift.Value(1),
          rate: drift.Value(100),
          discountPct: drift.Value(0),
          taxableAmount: drift.Value(100),
          gstRate: drift.Value(18),
          cgstRate: drift.Value(9),
          sgstRate: drift.Value(9),
          igstRate: drift.Value(0),
          cgstAmount: drift.Value(9),
          sgstAmount: drift.Value(9),
          igstAmount: drift.Value(0),
          cessAmount: drift.Value(0),
          totalAmount: drift.Value(118),
        ),
      ];

      final sourceId = await notifier.createQuoteWithItems(quote, items);
      final duplicateId = await notifier.duplicateQuote(sourceId);
      final duplicate = await database.quoteDao.getQuoteById(duplicateId);
      final duplicateItems = await database.quoteDao.getItemsForQuote(
        duplicateId,
      );

      expect(duplicate, isNotNull);
      expect(duplicate!.invoiceNumber, startsWith('QT-'));
      expect(duplicate.invoiceNumber, isNot('QT-2627-0001'));
      expect(duplicate.status, 'DRAFT');
      expect(duplicate.totalAmount, 118);
      expect(duplicateItems, hasLength(1));
      expect(duplicateItems.single.name, 'Service');
    });

    test('blocks deleting converted quotes', () async {
      final notifier = container.read(quoteProvider);
      final quoteDate = DateTime(2026, 6, 30);
      final quote = QuotesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: quoteDate,
        invoiceType: 'QUOTE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: quoteDate,
        updatedAt: quoteDate,
      );
      final items = [
        const QuoteItemsCompanion(
          name: drift.Value('Service'),
          hsnSac: drift.Value('9983'),
          unit: drift.Value('NOS'),
          quantity: drift.Value(1),
          rate: drift.Value(100),
          discountPct: drift.Value(0),
          taxableAmount: drift.Value(100),
          gstRate: drift.Value(18),
          cgstRate: drift.Value(9),
          sgstRate: drift.Value(9),
          igstRate: drift.Value(0),
          cgstAmount: drift.Value(9),
          sgstAmount: drift.Value(9),
          igstAmount: drift.Value(0),
          cessAmount: drift.Value(0),
          totalAmount: drift.Value(118),
        ),
      ];

      final quoteId = await notifier.createQuoteWithItems(quote, items);
      await notifier.convertToInvoice(quoteId);

      await expectLater(
        notifier.deleteQuote(quoteId),
        throwsA(isA<Exception>()),
      );
    });

    test('records an audit event when a quote is edited', () async {
      final notifier = container.read(quoteProvider);
      final quoteDate = DateTime(2026, 6, 30);
      final quote = QuotesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: quoteDate,
        invoiceType: 'QUOTE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        dueDate: drift.Value(DateTime(2026, 7, 7)),
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: quoteDate,
        updatedAt: quoteDate,
      );
      final items = [
        const QuoteItemsCompanion(
          name: drift.Value('Service'),
          hsnSac: drift.Value('9983'),
          unit: drift.Value('NOS'),
          quantity: drift.Value(1),
          rate: drift.Value(100),
          discountPct: drift.Value(0),
          taxableAmount: drift.Value(100),
          gstRate: drift.Value(18),
          cgstRate: drift.Value(9),
          sgstRate: drift.Value(9),
          igstRate: drift.Value(0),
          cgstAmount: drift.Value(9),
          sgstAmount: drift.Value(9),
          igstAmount: drift.Value(0),
          cessAmount: drift.Value(0),
          totalAmount: drift.Value(118),
        ),
      ];

      final quoteId = await notifier.createQuoteWithItems(quote, items);
      final storedQuote = await database.quoteDao.getQuoteById(quoteId);
      final updatedItems = [
        const QuoteItemsCompanion(
          name: drift.Value('Service'),
          hsnSac: drift.Value('9983'),
          unit: drift.Value('NOS'),
          quantity: drift.Value(2),
          rate: drift.Value(100),
          discountPct: drift.Value(0),
          taxableAmount: drift.Value(200),
          gstRate: drift.Value(18),
          cgstRate: drift.Value(9),
          sgstRate: drift.Value(9),
          igstRate: drift.Value(0),
          cgstAmount: drift.Value(18),
          sgstAmount: drift.Value(18),
          igstAmount: drift.Value(0),
          cessAmount: drift.Value(0),
          totalAmount: drift.Value(236),
        ),
      ];

      await notifier.updateQuoteWithItems(
        storedQuote!,
        QuotesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: quoteDate,
          invoiceType: 'QUOTE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 200,
          discountAmount: const drift.Value(0),
          taxableAmount: 200,
          totalAmount: 236,
          dueDate: drift.Value(DateTime(2026, 7, 10)),
          cgstAmount: const drift.Value(18),
          sgstAmount: const drift.Value(18),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          amountInWords: const drift.Value(
            'Two Hundred Thirty Six Rupees Only',
          ),
          notes: const drift.Value<String?>(null),
          terms: const drift.Value<String?>(null),
          isIgst: const drift.Value(false),
          createdAt: quoteDate,
          updatedAt: DateTime(2026, 7, 1),
        ),
        updatedItems,
      );

      final events = await database.customerActivityDao.getEventsForCustomer(1);
      final auditEvent = events.firstWhere(
        (event) => event.eventType == 'QUOTE_EDIT',
      );

      expect(auditEvent.note, contains('Quote edited'));
      expect(auditEvent.entityType, 'QUOTE');
    });
  });
}
