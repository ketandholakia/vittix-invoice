import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/utils/gst_calculator.dart';
import 'package:vittix_invoice/core/utils/gstin_validator.dart';
import 'package:vittix_invoice/core/utils/invoice_number.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/quote_provider.dart';
import 'package:vittix_invoice/providers/reminder_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';
import 'package:vittix_invoice/providers/uom_provider.dart';

void main() {
  group('InvoiceNumberGenerator', () {
    test('uses financial year sequence format', () {
      final generated = InvoiceNumberGenerator.generate(
        'INV',
        0,
        DateTime(2026, 6, 30),
      );

      expect(generated, 'INV-2627-0001');
      expect(InvoiceNumberGenerator.extractSequence(generated), 1);
    });
  });

  group('GstCalculator', () {
    test('splits intra-state GST equally', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: false,
      );

      expect(breakdown.cgst, 90);
      expect(breakdown.sgst, 90);
      expect(breakdown.igst, 0);
      expect(breakdown.total, 1180);
    });

    test('applies IGST for inter-state invoices', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: true,
      );

      expect(breakdown.cgst, 0);
      expect(breakdown.sgst, 0);
      expect(breakdown.igst, 180);
      expect(breakdown.total, 1180);
    });
  });

  group('GstinValidator', () {
    test('accepts a valid GSTIN checksum', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZV'), isTrue);
      expect(GstinValidator.extractStateCode('27AAPFU0939F1ZV'), 27);
    });

    test('rejects an invalid GSTIN checksum', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZA'), isFalse);
    });
  });

  group('ReminderSettings', () {
    test('uses notification defaults and persists cadence choices', () async {
      SharedPreferences.setMockInitialValues({});
      final sharedPreferences = await SharedPreferences.getInstance();
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
      );

      addTearDown(container.dispose);

      expect(container.read(reminderNotificationsEnabledProvider), isTrue);
      expect(
        container.read(reminderNotificationOffsetsProvider),
        equals([-7, -3, -1, 0, 1, 3]),
      );

      container
          .read(reminderNotificationsEnabledProvider.notifier)
          .setEnabled(false);
      container.read(reminderNotificationOffsetsProvider.notifier).setOffsets([
        -3,
        0,
        2,
      ]);

      expect(
        sharedPreferences.getBool('reminder_notifications_enabled'),
        isFalse,
      );
      expect(
        sharedPreferences.getStringList('reminder_notification_offsets'),
        equals(['-3', '0', '2']),
      );
    });
  });

  group('UomDao', () {
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
      );

      await container.read(uomSeedProvider.future);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('seeds the default unit of measure catalog', () async {
      final units = await container.read(uomListProvider.future);

      expect(
        units.map((unit) => unit.code).toList(),
        equals(['PCS', 'KG', 'GRM', 'MTR', 'CM', 'LTR', 'ML', 'BOX', 'NOS']),
      );
      expect(units.first.name, 'Pieces');
      expect(units[2].name, 'Grams');
      expect(units.last.name, 'Nos');
    });

    test('converts quantities within the same UOM family', () async {
      final uoms = await container.read(uomCatalogProvider.future);

      expect(
        container.read(uomDaoProvider).convertQuantity(
          quantity: 2500,
          fromCode: 'GRM',
          toCode: 'KG',
          uomCatalog: uoms,
        ),
        2.5,
      );
      expect(
        container.read(uomDaoProvider).convertQuantity(
          quantity: 3,
          fromCode: 'BOX',
          toCode: 'PCS',
          uomCatalog: uoms,
        ),
        30,
      );
    });
  });

  group('HsnDao', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());

      await database
          .into(database.hsnCodes)
          .insert(
            HsnCodesCompanion.insert(
              code: '8517',
              description: 'Telephones and mobile phones',
            ),
          );

      await database.batch((batch) {
        batch.insertAll(
          database.hsnCodeRates,
          [
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(18.0),
              effectiveFrom: DateTime(2017, 7, 1),
            ),
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(12.0),
              effectiveFrom: DateTime(2026, 1, 1),
            ),
          ],
        );
      });
    });

    tearDown(() async {
      await database.close();
    });

    test('returns the latest applicable GST rate for the requested date', () async {
      final historical = await database.hsnDao.searchHsnCodes(
        '8517',
        asOf: DateTime(2025, 6, 30),
      );
      final current = await database.hsnDao.searchHsnCodes(
        '8517',
        asOf: DateTime(2026, 6, 30),
      );

      expect(historical.single.gstRate, 18.0);
      expect(current.single.gstRate, 12.0);
    });

    test('stores and lists rate versions in descending effective date order', () async {
      await database.hsnDao.addHsnCodeRate(
        code: '8517',
        gstRate: 5.0,
        effectiveFrom: DateTime(2026, 4, 1),
      );

      final versions = await database.hsnDao.listHsnCodeRates('8517');

      expect(versions.first.gstRate, 5.0);
      expect(versions.first.effectiveFrom, DateTime(2026, 4, 1));
      expect(versions.length, 3);
    });
  });

  group('DatabaseBackupService', () {
    test('exports and restores a full database snapshot', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());

      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Backup Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Backup Customer',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.products).insert(
            ProductsCompanion.insert(
              businessId: 1,
              name: 'Backup Product',
              hsnSac: '8517',
              unit: 'PCS',
              salePrice: 100,
              gstRate: 18,
              stockQuantity: const drift.Value(5),
              isService: const drift.Value(false),
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.uoms).insert(
            UomsCompanion.insert(code: 'PCS', name: 'Pieces').copyWith(
              sortOrder: const drift.Value(0),
            ),
          );

      await source.into(source.hsnCodes).insert(
            HsnCodesCompanion.insert(
              code: '8517',
              description: 'Telephones and mobile phones',
            ),
          );

      await source.into(source.hsnCodeRates).insert(
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(18.0),
              effectiveFrom: DateTime(2017, 7, 1),
            ),
          );

      final backupJson = await DatabaseBackupService.buildBackupJson(source);
      await source.close();

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        backupJson,
      );

      final restoredBusinesses = await target.select(target.businesses).get();
      final restoredCustomers = await target.select(target.customers).get();
      final restoredProducts = await target.select(target.products).get();
      final restoredHsnRates = await target.select(target.hsnCodeRates).get();

      expect(restoredActiveId, 1);
      expect(restoredBusinesses, hasLength(1));
      expect(restoredCustomers, hasLength(1));
      expect(restoredProducts, hasLength(1));
      expect(restoredHsnRates, hasLength(1));
      expect(restoredProducts.first.name, 'Backup Product');
    });
  });

  group('InvoiceNotifier', () {
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

    test(
      'assigns sequential invoice numbers per business and financial year',
      () async {
        final notifier = container.read(invoiceProvider);
        final invoiceDate = DateTime(2026, 6, 30);
        final baseInvoice = InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: invoiceDate,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
          createdAt: invoiceDate,
          updatedAt: invoiceDate,
        );
        final items = [
          InvoiceItemsCompanion(
            name: const drift.Value('Service'),
            hsnSac: const drift.Value('9983'),
            unit: const drift.Value('NOS'),
            quantity: const drift.Value(1),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(100),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(118),
          ),
        ];

        final firstInvoiceId = await notifier.createInvoiceWithItems(
          baseInvoice,
          items,
        );
        final secondInvoiceId = await notifier.createInvoiceWithItems(
          baseInvoice,
          items,
        );

        final firstInvoice = await database.invoiceDao.getInvoiceById(
          firstInvoiceId,
        );
        final secondInvoice = await database.invoiceDao.getInvoiceById(
          secondInvoiceId,
        );

        expect(firstInvoice?.invoiceNumber, 'INV-2627-0001');
        expect(secondInvoice?.invoiceNumber, 'INV-2627-0002');
      },
    );

    test('rolls back invoice insert when an item insert fails', () async {
      final notifier = container.read(invoiceProvider);
      final invoiceDate = DateTime(2026, 6, 30);
      final invoice = InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: invoiceDate,
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: invoiceDate,
        updatedAt: invoiceDate,
      );
      final invalidItems = [
        InvoiceItemsCompanion(
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      await expectLater(
        notifier.createInvoiceWithItems(invoice, invalidItems),
        throwsA(isA<Exception>()),
      );

      final invoices = await database.invoiceDao.getInvoicesForBusiness(1);
      expect(invoices, isEmpty);
    });

    test(
      'duplicates invoice with a fresh number and reset payment state',
      () async {
        final notifier = container.read(invoiceProvider);
        final invoiceDate = DateTime(2026, 6, 30);
        final invoice = InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: invoiceDate,
          invoiceType: 'TAX_INVOICE',
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
          createdAt: invoiceDate,
          updatedAt: invoiceDate,
        );
        final items = [
          InvoiceItemsCompanion(
            name: const drift.Value('Service'),
            hsnSac: const drift.Value('9983'),
            unit: const drift.Value('NOS'),
            quantity: const drift.Value(1),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(100),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(118),
          ),
        ];

        final sourceId = await notifier.createInvoiceWithItems(invoice, items);
        await notifier.recordPayment(sourceId, 50);

        final duplicateId = await notifier.duplicateInvoice(sourceId);
        final duplicate = await database.invoiceDao.getInvoiceById(duplicateId);
        final duplicateItems = await database.invoiceDao.getItemsForInvoice(
          duplicateId,
        );

        expect(duplicate, isNotNull);
        expect(duplicate!.invoiceNumber, startsWith('INV-'));
        expect(duplicate.invoiceNumber, isNot('INV-2627-0001'));
        expect(duplicate.amountPaid, 0);
        expect(duplicate.status, 'DRAFT');
        expect(duplicate.totalAmount, 118);
        expect(duplicateItems, hasLength(1));
        expect(duplicateItems.single.name, 'Service');
      },
    );

    test(
      'adjusts linked product stock when invoices are created, updated, and deleted',
      () async {
        final notifier = container.read(invoiceProvider);
        final invoiceDate = DateTime(2026, 6, 30);
        final productId = await database.into(database.products).insert(
          ProductsCompanion.insert(
            businessId: 1,
            name: 'Tracked Item',
            hsnSac: '1234',
            unit: 'PCS',
            salePrice: 100,
            gstRate: 18,
            stockQuantity: const drift.Value(10),
            createdAt: invoiceDate,
          ),
        );

        final invoice = InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: invoiceDate,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 200,
          discountAmount: const drift.Value(0),
          taxableAmount: 200,
          totalAmount: 236,
          dueDate: drift.Value(DateTime(2026, 7, 7)),
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
          createdAt: invoiceDate,
          updatedAt: invoiceDate,
        );
        final initialItems = [
          InvoiceItemsCompanion(
            productId: drift.Value(productId),
            name: const drift.Value('Tracked Item'),
            hsnSac: const drift.Value('1234'),
            unit: const drift.Value('PCS'),
            quantity: const drift.Value(2),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(200),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(18),
            sgstAmount: const drift.Value(18),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(236),
          ),
        ];

        final invoiceId = await notifier.createInvoiceWithItems(
          invoice,
          initialItems,
        );
        var product = await database.productDao.getProductById(productId);
        expect(product?.stockQuantity, 8);

        final storedInvoice = await database.invoiceDao.getInvoiceById(
          invoiceId,
        );
        final updatedItems = [
          InvoiceItemsCompanion(
            productId: drift.Value(productId),
            name: const drift.Value('Tracked Item'),
            hsnSac: const drift.Value('1234'),
            unit: const drift.Value('PCS'),
            quantity: const drift.Value(5),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(500),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(45),
            sgstAmount: const drift.Value(45),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(590),
          ),
        ];

        await notifier.updateInvoiceWithItems(
          storedInvoice!,
          InvoicesCompanion.insert(
            businessId: 1,
            customerId: 1,
            invoiceNumber: 'PENDING',
            invoiceDate: invoiceDate,
            invoiceType: 'TAX_INVOICE',
            supplyType: 'B2B',
            placeOfSupply: 27,
            subtotal: 500,
            discountAmount: const drift.Value(0),
            taxableAmount: 500,
            totalAmount: 590,
            dueDate: drift.Value(DateTime(2026, 7, 10)),
            cgstAmount: const drift.Value(45),
            sgstAmount: const drift.Value(45),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            amountInWords: const drift.Value(
              'Five Hundred Ninety Rupees Only',
            ),
            notes: const drift.Value<String?>(null),
            terms: const drift.Value<String?>(null),
            isIgst: const drift.Value(false),
            createdAt: invoiceDate,
            updatedAt: DateTime(2026, 7, 1),
          ),
          updatedItems,
        );
        product = await database.productDao.getProductById(productId);
        expect(product?.stockQuantity, 5);

        await notifier.deleteInvoice(invoiceId);
        product = await database.productDao.getProductById(productId);
        expect(product?.stockQuantity, 10);
      },
    );

    test('blocks deleting invoices with recorded payments', () async {
      final notifier = container.read(invoiceProvider);
      final invoiceDate = DateTime(2026, 6, 30);
      final invoice = InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: invoiceDate,
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: invoiceDate,
        updatedAt: invoiceDate,
      );
      final items = [
        InvoiceItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
      await notifier.recordPayment(invoiceId, 50);

      await expectLater(
        notifier.deleteInvoice(invoiceId),
        throwsA(isA<Exception>()),
      );
    });

    test(
      'recalculates invoice status when editing and voiding payments',
      () async {
        final notifier = container.read(invoiceProvider);
        final invoiceDate = DateTime(2026, 6, 30);
        final invoice = InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: invoiceDate,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
          createdAt: invoiceDate,
          updatedAt: invoiceDate,
        );
        final items = [
          InvoiceItemsCompanion(
            name: const drift.Value('Service'),
            hsnSac: const drift.Value('9983'),
            unit: const drift.Value('NOS'),
            quantity: const drift.Value(1),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(100),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(118),
          ),
        ];

        final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
        await notifier.recordPayment(invoiceId, 50);

        final firstPayment = (await database.invoiceDao.getPaymentsForInvoice(
          invoiceId,
        )).single;

        await notifier.updatePayment(
          invoiceId: invoiceId,
          paymentId: firstPayment.id,
          amount: 118,
          paidAt: firstPayment.paidAt,
        );

        var storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
        expect(storedInvoice?.amountPaid, 118);
        expect(storedInvoice?.status, 'PAID');

        await notifier.voidPayment(invoiceId: invoiceId, paymentId: firstPayment.id);

        storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
        expect(storedInvoice?.amountPaid, 0);
        expect(storedInvoice?.status, 'SENT');

        final voidedPayment = (await database.invoiceDao.getPaymentsForInvoice(
          invoiceId,
        )).single;
        expect(voidedPayment.kind, 'VOID');
      },
    );

    test('records refunds as negative payment impact', () async {
      final notifier = container.read(invoiceProvider);
      final invoiceDate = DateTime(2026, 6, 30);
      final invoice = InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: invoiceDate,
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: invoiceDate,
        updatedAt: invoiceDate,
      );
      final items = [
        InvoiceItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
      await notifier.recordPayment(invoiceId, 118);
      await notifier.recordRefund(invoiceId: invoiceId, refundAmount: 18);

      final storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final payments = await database.invoiceDao.getPaymentsForInvoice(
        invoiceId,
      );

      expect(storedInvoice?.amountPaid, 100);
      expect(storedInvoice?.status, 'PARTIALLY_PAID');
      expect(payments, hasLength(2));
      expect(payments.last.kind, 'REFUND');
    });

    test('allows overpayment and keeps balance due at zero', () async {
      final notifier = container.read(invoiceProvider);
      final invoiceDate = DateTime(2026, 6, 30);
      final invoice = InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: invoiceDate,
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: invoiceDate,
        updatedAt: invoiceDate,
      );
      final items = [
        InvoiceItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
      await notifier.recordPayment(invoiceId, 150);

      final storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final payments = await database.invoiceDao.getPaymentsForInvoice(
        invoiceId,
      );

      expect(storedInvoice?.amountPaid, 150);
      expect(storedInvoice?.status, 'PAID');
      expect(payments.single.amount, 150);
    });

    test('records an audit event when an invoice is edited', () async {
      final notifier = container.read(invoiceProvider);
      final invoiceDate = DateTime(2026, 6, 30);
      final invoice = InvoicesCompanion.insert(
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'PENDING',
        invoiceDate: invoiceDate,
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: 100,
        taxableAmount: 100,
        totalAmount: 118,
        dueDate: drift.Value(DateTime(2026, 7, 7)),
        cgstAmount: const drift.Value(9),
        sgstAmount: const drift.Value(9),
        amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
        createdAt: invoiceDate,
        updatedAt: invoiceDate,
      );
      final items = [
        InvoiceItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
      final storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final updatedItems = [
        InvoiceItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(2),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(200),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(18),
          sgstAmount: const drift.Value(18),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(236),
        ),
      ];

      await notifier.updateInvoiceWithItems(
        storedInvoice!,
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: invoiceDate,
          invoiceType: 'TAX_INVOICE',
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
          createdAt: invoiceDate,
          updatedAt: DateTime(2026, 7, 1),
        ),
        updatedItems,
      );

      final events = await database.customerActivityDao.getEventsForCustomer(1);
      final auditEvent = events.firstWhere(
        (event) => event.eventType == 'INVOICE_EDIT',
      );

      expect(auditEvent.note, contains('Invoice edited'));
      expect(auditEvent.entityType, 'INVOICE');
    });

    test(
      'queues unpaid invoices due within seven days for reminders',
      () async {
        final notifier = container.read(invoiceProvider);
        final now = DateTime.now();
        final invoice = InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: now,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          dueDate: drift.Value(now.add(const Duration(days: 3))),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
          status: const drift.Value('SENT'),
          createdAt: now,
          updatedAt: now,
        );
        final items = [
          InvoiceItemsCompanion(
            name: const drift.Value('Service'),
            hsnSac: const drift.Value('9983'),
            unit: const drift.Value('NOS'),
            quantity: const drift.Value(1),
            rate: const drift.Value(100),
            discountPct: const drift.Value(0),
            taxableAmount: const drift.Value(100),
            gstRate: const drift.Value(18),
            cgstRate: const drift.Value(9),
            sgstRate: const drift.Value(9),
            igstRate: const drift.Value(0),
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            igstAmount: const drift.Value(0),
            cessAmount: const drift.Value(0),
            totalAmount: const drift.Value(118),
          ),
        ];

        final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
        final reminders = await container.read(reminderCenterProvider.future);

        expect(reminders.invoiceReminders, hasLength(1));
        expect(reminders.invoiceReminders.single.invoice.id, invoiceId);
        expect(reminders.invoiceReminders.single.daysUntilDue, 3);
        expect(reminders.invoiceReminders.single.balanceDue, 118);
      },
    );
  });

  group('QuoteNotifier', () {
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
        QuoteItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
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
        QuoteItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
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
        QuoteItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(1),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(100),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(118),
        ),
      ];

      final quoteId = await notifier.createQuoteWithItems(quote, items);
      final storedQuote = await database.quoteDao.getQuoteById(quoteId);
      final updatedItems = [
        QuoteItemsCompanion(
          name: const drift.Value('Service'),
          hsnSac: const drift.Value('9983'),
          unit: const drift.Value('NOS'),
          quantity: const drift.Value(2),
          rate: const drift.Value(100),
          discountPct: const drift.Value(0),
          taxableAmount: const drift.Value(200),
          gstRate: const drift.Value(18),
          cgstRate: const drift.Value(9),
          sgstRate: const drift.Value(9),
          igstRate: const drift.Value(0),
          cgstAmount: const drift.Value(18),
          sgstAmount: const drift.Value(18),
          igstAmount: const drift.Value(0),
          cessAmount: const drift.Value(0),
          totalAmount: const drift.Value(236),
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
