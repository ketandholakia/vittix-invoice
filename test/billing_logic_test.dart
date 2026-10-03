import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/utils/amount_in_words.dart';
import 'package:vittix_invoice/core/constants/gst_states.dart';
import 'package:vittix_invoice/core/utils/document_totals.dart';
import 'package:vittix_invoice/core/utils/formatting.dart';
import 'package:vittix_invoice/core/utils/gst_calculator.dart';
import 'package:vittix_invoice/core/utils/gstr1_export.dart';
import 'package:vittix_invoice/core/utils/gstr1_validation.dart';
import 'package:vittix_invoice/core/utils/gst_supply.dart';
import 'package:vittix_invoice/core/utils/gstin_validator.dart';
import 'package:vittix_invoice/core/utils/invoice_balance.dart';
import 'package:vittix_invoice/core/utils/invoice_number.dart';
import 'package:vittix_invoice/core/utils/invoice_status.dart';
import 'package:vittix_invoice/core/utils/invoice_type.dart';
import 'package:vittix_invoice/core/utils/money.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/document_sequence_allocator.dart';
import 'package:vittix_invoice/database/tables/businesses.dart';
import 'package:vittix_invoice/database/tables/template_configs.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/business_provider.dart';
import 'package:vittix_invoice/providers/customer_detail_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/quote_provider.dart';
import 'package:vittix_invoice/providers/reminder_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';
import 'package:vittix_invoice/core/utils/recurrence.dart';
import 'package:vittix_invoice/core/utils/stock_status.dart';
import 'package:vittix_invoice/services/backup_cipher.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';
import 'package:vittix_invoice/providers/uom_provider.dart';
import 'package:vittix_invoice/providers/hsn_provider.dart';
import 'package:vittix_invoice/features/reports/customer_statement_report.dart';

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

  group('LineTaxRecompute', () {
    test('re-splits a line from inter-state to intra-state (customer changed)',
        () {
      final asIgst = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: true,
      );
      expect(asIgst.igstAmount, 180);
      expect(asIgst.igstRate, 18);
      expect(asIgst.cgstAmount, 0);
      expect(asIgst.sgstAmount, 0);

      final asCgstSgst = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: false,
      );
      expect(asCgstSgst.igstAmount, 0);
      expect(asCgstSgst.igstRate, 0);
      expect(asCgstSgst.cgstAmount, 90);
      expect(asCgstSgst.sgstAmount, 90);
      expect(asCgstSgst.cgstRate, 9);
      expect(asCgstSgst.sgstRate, 9);

      // Only the split moves; the tax total and line total are unchanged.
      expect(
        asCgstSgst.cgstAmount + asCgstSgst.sgstAmount,
        asIgst.igstAmount,
      );
      expect(asCgstSgst.totalAmount, asIgst.totalAmount);
    });

    test('re-splits a line from intra-state to inter-state (customer changed)',
        () {
      final split = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 12,
        isInterState: true,
      );
      expect(split.cgstAmount, 0);
      expect(split.sgstAmount, 0);
      expect(split.cgstRate, 0);
      expect(split.sgstRate, 0);
      expect(split.igstRate, 12);
      expect(split.igstAmount, 120);
    });

    test('keeps a tax-free line at zero components', () {
      final split = GstCalculator.splitLine(
        taxableAmount: 500,
        gstRate: 0,
        isInterState: false,
      );
      expect(split.cgstAmount, 0);
      expect(split.sgstAmount, 0);
      expect(split.igstAmount, 0);
      expect(split.totalAmount, 500);
    });

    test('rounds recomputed components to paise', () {
      final split = GstCalculator.splitLine(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(split.cgstAmount, 3.00);
      expect(split.sgstAmount, 3.00);
      expect(split.totalAmount, 39.33);
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

  group('CustomerStatementReport', () {
    test('builds signed statement rows with running balances', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final invoiceId = await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: 1,
              invoiceNumber: 'INV-2627-0001',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'TAX_INVOICE',
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
              amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 50,
              kind: const drift.Value('PAYMENT'),
              paidAt: DateTime(2026, 7, 1),
              createdAt: DateTime(2026, 7, 1),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 10,
              kind: const drift.Value('REFUND'),
              paidAt: DateTime(2026, 7, 2),
              createdAt: DateTime(2026, 7, 2),
            ),
          );

      await database.into(database.invoicePayments).insert(
            InvoicePaymentsCompanion.insert(
              invoiceId: invoiceId,
              amount: 50,
              kind: const drift.Value('VOID'),
              paidAt: DateTime(2026, 7, 3),
              createdAt: DateTime(2026, 7, 3),
            ),
          );

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(4));
      expect(rows[0].entryType, 'INVOICE');
      expect(rows[0].amount, 118);
      expect(rows[0].runningBalance, 118);
      expect(rows[1].entryType, 'PAYMENT');
      expect(rows[1].amount, -50);
      expect(rows[1].runningBalance, 68);
      expect(rows[2].entryType, 'REFUND');
      expect(rows[2].amount, 10);
      expect(rows[2].runningBalance, 78);
      expect(rows[3].entryType, 'VOID');
      expect(rows[3].amount, 0);
      expect(rows[3].runningBalance, 78);
    });

    test('credit notes appear as negative statement entries', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: 1,
              invoiceNumber: 'INV-2627-0001',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'TAX_INVOICE',
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.invoices).insert(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'CN-2627-0001',
          invoiceDate: DateTime(2026, 7, 5),
          invoiceType: 'CREDIT_NOTE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          referenceInvoiceId: const drift.Value(1),
          status: const drift.Value('SENT'),
          createdAt: DateTime(2026, 7, 5),
          updatedAt: DateTime(2026, 7, 5),
        ),
      );

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(2));
      expect(rows[0].entryType, 'INVOICE');
      expect(rows[0].amount, 118);
      expect(rows[1].entryType, 'CREDIT_NOTE');
      expect(rows[1].amount, -118);
      expect(rows[1].runningBalance, 0);
    });

    test('excludes draft and cancelled invoices', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Acme Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Acme',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      Future<void> insertInvoice(String number, String status) =>
          database.into(database.invoices).insert(
                InvoicesCompanion.insert(
                  businessId: 1,
                  customerId: 1,
                  invoiceNumber: number,
                  invoiceDate: DateTime(2026, 6, 30),
                  invoiceType: 'TAX_INVOICE',
                  supplyType: 'B2B',
                  placeOfSupply: 27,
                  subtotal: 100,
                  taxableAmount: 100,
                  totalAmount: 118,
                  status: drift.Value(status),
                  createdAt: DateTime(2026, 6, 30),
                  updatedAt: DateTime(2026, 6, 30),
                ),
              );

      await insertInvoice('INV-2627-0001', 'SENT');
      await insertInvoice('INV-2627-0002', 'DRAFT');
      await insertInvoice('INV-2627-0003', 'CANCELLED');

      final rows = buildCustomerStatementRows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        payments: await database.select(database.invoicePayments).get(),
      );

      expect(rows, hasLength(1));
      expect(rows.single.documentNumber, 'INV-2627-0001');
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
          const InvoiceItemsCompanion(
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
        const InvoiceItemsCompanion(
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
          const InvoiceItemsCompanion(
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
            createdAt: invoiceDate,
          ),
        );
        await database.productDao.recordStockMovement(
          productId: productId,
          quantityDelta: 10,
          reason: 'OPENING',
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
        const InvoiceItemsCompanion(
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
          const InvoiceItemsCompanion(
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
        const InvoiceItemsCompanion(
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
        const InvoiceItemsCompanion(
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
        const InvoiceItemsCompanion(
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

      final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
      final storedInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final updatedItems = [
        const InvoiceItemsCompanion(
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
          const InvoiceItemsCompanion(
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

        final invoiceId = await notifier.createInvoiceWithItems(invoice, items);
        final reminders = await container.read(reminderCenterProvider.future);

        expect(reminders.invoiceReminders, hasLength(1));
        expect(reminders.invoiceReminders.single.invoice.id, invoiceId);
        expect(reminders.invoiceReminders.single.daysUntilDue, 3);
        expect(reminders.invoiceReminders.single.balanceDue, 118);
      },
    );
  });

  group('GstSupplyDerivation', () {
    Customer customer({int? stateCode, String? gstin}) => Customer(
          id: 1,
          businessId: 1,
          name: 'Customer',
          gstin: gstin,
          stateCode: stateCode,
          isActive: true,
          createdAt: DateTime(2026, 6, 30),
        );

    Business business({int stateCode = 27}) => Business(
          id: 1,
          name: 'Business',
          gstin: '27AAPFU0939F1ZV',
          businessType: BusinessType.gstRegistered,
          address: 'Address',
          city: 'Mumbai',
          stateCode: stateCode,
          currencyCode: 'INR',
          invoiceTemplate: 'CLASSIC',
          quoteTemplate: 'CLASSIC',
          invoiceSeriesFormat: 'INV-{FY}-{SEQ4}',
          quoteSeriesFormat: 'QT-{FY}-{SEQ4}',
          creditNoteSeriesFormat: 'CN-{FY}-{SEQ4}',
          debitNoteSeriesFormat: 'DN-{FY}-{SEQ4}',
          isActive: true,
          createdAt: DateTime(2026, 6, 30),
        );

    test('is B2B for a valid GSTIN and B2C otherwise', () {
      expect(deriveSupplyType(customer(gstin: '27AAPFU0939F1ZV')), 'B2B');
      expect(deriveSupplyType(customer()), 'B2C');
      expect(deriveSupplyType(customer(gstin: '27AAPFU0939F1ZA')), 'B2C');
    });

    test('place of supply prefers customer state, then GSTIN, then business',
        () {
      expect(
        derivePlaceOfSupply(customer(stateCode: 29), business(stateCode: 27)),
        29,
      );
      expect(
        derivePlaceOfSupply(
          customer(gstin: '27AAPFU0939F1ZV'),
          business(stateCode: 27),
        ),
        27,
      );
      expect(derivePlaceOfSupply(customer(), business(stateCode: 27)), 27);
    });

    test('customer state code prefers the explicit value over the GSTIN', () {
      expect(
        customerStateCode(customer(stateCode: 29, gstin: '27AAPFU0939F1ZV')),
        29,
      );
    });
  });

  group('HsnRateRefresh', () {
    test('seeds the post-2025 garment rate while keeping history', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      await container.read(hsnSeedProvider.future);

      final current = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
      );
      final historical = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2020, 1, 1),
      );

      expect(current?.gstRate, 5.0);
      expect(historical?.gstRate, 12.0);

      final lowValue = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
        unitPrice: 1000,
      );
      final highValue = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
        unitPrice: 3000,
      );

      expect(lowValue?.gstRate, 5.0);
      expect(highValue?.gstRate, 18.0);
    });
  });

  group('InvoiceType', () {
    test('tax invoice with GST, bill of supply without', () {
      expect(invoiceTypeForGst(isGstEnabled: true), 'TAX_INVOICE');
      expect(invoiceTypeForGst(isGstEnabled: false), 'BILL_OF_SUPPLY');
    });
  });

  group('DocumentTotals', () {
    test('sums lines, applies the discount and rounds the payable', () {
      final totals = computeDocumentTotals([
        (
          gross: 200.0,
          discount: 20.0,
          taxable: 180.0,
          cgst: 16.2,
          sgst: 16.2,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 200);
      expect(totals.discount, 20);
      expect(totals.taxable, 180);
      expect(totals.cgst, 16.2);
      // 180 + 16.2 + 16.2 = 212.4, rounded to the rupee.
      expect(totals.grandTotal, 212);
      expect(totals.roundOff, closeTo(-0.4, 0.0001));
    });

    test('without a discount the subtotal equals the taxable amount', () {
      final totals = computeDocumentTotals([
        (
          gross: 100.0,
          discount: 0.0,
          taxable: 100.0,
          cgst: 9.0,
          sgst: 9.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 100);
      expect(totals.discount, 0);
      expect(totals.grandTotal, 118);
      expect(totals.roundOff, 0);
    });

    test('adds TCS and deducts TDS from the payable', () {      final totals = computeDocumentTotals([
        (
          gross: 1000.0,
          discount: 0.0,
          taxable: 1000.0,
          cgst: 90.0,
          sgst: 90.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ], tcsAmount: 10, tdsAmount: 50);

      expect(totals.tcsAmount, 10);
      expect(totals.tdsAmount, 50);
      // 1000 + 180 + 10 - 50 = 1140
      expect(totals.grandTotal, 1140);
      expect(totals.roundOff, 0);
    });

    test('skips the round off when it is disabled', () {
      final lines = [
        (
          gross: 100.40,
          discount: 0.0,
          taxable: 100.40,
          cgst: 9.04,
          sgst: 9.04,
          igst: 0.0,
          cess: 0.0,
        ),
      ];

      final rounded = computeDocumentTotals(lines);
      expect(rounded.grandTotal, 118);
      expect(rounded.roundOff, closeTo(-0.48, 0.0001));

      final exact = computeDocumentTotals(lines, applyRoundOff: false);
      expect(exact.grandTotal, 118.48);
      expect(exact.roundOff, 0);
    });

    test('rounds every component to paise', () {
      final totals = computeDocumentTotals([
        (
          gross: 33.33,
          discount: 0.0,
          taxable: 33.33,
          cgst: 3.0,
          sgst: 3.0,
          igst: 0.0,
          cess: 0.0,
        ),
        (
          gross: 0.01,
          discount: 0.0,
          taxable: 0.01,
          cgst: 0.0,
          sgst: 0.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 33.34);
      expect(totals.taxable, 33.34);
    });
  });

  group('RecurrenceMath', () {
    test('clamps month-end dates instead of rolling over', () {
      expect(
        advanceByFrequency(DateTime(2026, 1, 31), 'MONTHLY'),
        DateTime(2026, 2, 28),
      );
      expect(
        advanceByFrequency(DateTime(2026, 1, 15), 'MONTHLY'),
        DateTime(2026, 2, 15),
      );
      expect(
        advanceByFrequency(DateTime(2026, 11, 30), 'QUARTERLY'),
        DateTime(2027, 2, 28),
      );
      expect(
        advanceByFrequency(DateTime(2026, 2, 28), 'YEARLY'),
        DateTime(2027, 2, 28),
      );
      expect(
        advanceByFrequency(DateTime(2026, 6, 3), 'WEEKLY'),
        DateTime(2026, 6, 10),
      );
    });

    test('catches up to the next run on or after today', () {
      expect(
        nextRunOnOrAfter(DateTime(2026, 1, 1), DateTime(2026, 3, 5), 'MONTHLY'),
        DateTime(2026, 4, 1),
      );
      expect(
        nextRunOnOrAfter(DateTime(2026, 3, 1), DateTime(2026, 3, 1), 'MONTHLY'),
        DateTime(2026, 3, 1),
      );
    });
  });

  group('RecurringInvoices', () {
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

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Test Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.customers).insert(
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

    Future<int> createIssuedInvoice({String status = 'SENT'}) {
      final date = DateTime(2026, 6, 30);
      return container.read(invoiceProvider).createInvoiceWithItems(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          status: drift.Value(status),
          amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
          notes: const drift.Value('Thanks'),
          createdAt: date,
          updatedAt: date,
        ),
        [
          const InvoiceItemsCompanion(
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
        ],
      );
    }

    test('generates a draft and advances the schedule', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();

      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 7, 1),
      );

      expect(await recurring.runDue(now: DateTime(2026, 7, 1)), 1);

      final invoices = await database.select(database.invoices).get();
      expect(invoices, hasLength(2));
      final draft = invoices.firstWhere((row) => row.status == 'DRAFT');
      expect(draft.totalAmount, 118);
      expect(draft.customerId, 1);
      expect(draft.notes, 'Thanks');
      final draftItems = await database.invoiceDao.getItemsForInvoice(
        draft.id,
      );
      expect(draftItems, hasLength(1));

      final schedules = await recurring.listForBusiness(1);
      expect(schedules.single.nextRunDate, DateTime(2026, 8, 1));

      // The same date must not generate twice.
      expect(await recurring.runDue(now: DateTime(2026, 7, 1)), 0);
    });

    test('refuses a draft source and a duplicate schedule', () async {
      final recurring = container.read(recurringInvoiceProvider);

      final draftId = await createIssuedInvoice(status: 'DRAFT');
      await expectLater(
        recurring.startRecurrence(
          invoiceId: draftId,
          frequency: RecurrenceFrequency.monthly,
        ),
        throwsA(isA<Exception>()),
      );

      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.weekly,
      );
      await expectLater(
        recurring.startRecurrence(
          invoiceId: invoiceId,
          frequency: RecurrenceFrequency.monthly,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('stopping a schedule leaves generated drafts alone', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 7, 1),
      );

      final schedule = (await recurring.listForBusiness(1)).single;
      await recurring.stopRecurrence(schedule.id);

      expect(await recurring.listForBusiness(1), isEmpty);
      expect(await recurring.runDue(now: DateTime(2026, 9, 1)), 0);
      expect(await database.select(database.invoices).get(), hasLength(1));
    });
  });

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

  group('GstStates', () {
    test('labels a state code with its name', () {
      expect(GstStates.labelFor(24), 'Gujarat (24)');
      expect(GstStates.labelFor(27), 'Maharashtra (27)');
      expect(GstStates.labelFor(null), '');
      expect(GstStates.labelFor(999), 'State 999');
    });
  });

  group('DateFormatting', () {
    test('numeric Indian format is dd-MM-yyyy', () {
      expect(formatDateNumeric(DateTime(2026, 7, 5)), '05-07-2026');
      expect(formatDateNumeric(DateTime(2026, 12, 31)), '31-12-2026');
    });
  });

  group('PdfFonts', () {
    test('bundled PDF fonts are available offline', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final regular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final devanagari = await rootBundle.load(
        'assets/fonts/NotoSansDevanagari-Regular.ttf',
      );
      final gujarati = await rootBundle.load(
        'assets/fonts/NotoSansGujarati-Regular.ttf',
      );

      expect(regular.lengthInBytes, greaterThan(1000));
      expect(bold.lengthInBytes, greaterThan(1000));
      expect(devanagari.lengthInBytes, greaterThan(1000));
      expect(gujarati.lengthInBytes, greaterThan(1000));
    });
  });

  group('InvoiceTotalsScope', () {
    test('excludes draft and cancelled invoices from totals', () {
      expect(isInvoiceCountedInTotals('DRAFT'), isFalse);
      expect(isInvoiceCountedInTotals('CANCELLED'), isFalse);
    });

    test('includes issued invoices', () {
      expect(isInvoiceCountedInTotals('SENT'), isTrue);
      expect(isInvoiceCountedInTotals('PARTIALLY_PAID'), isTrue);
      expect(isInvoiceCountedInTotals('PAID'), isTrue);
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

  group('CreditAndDebitNotes', () {
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

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Test Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.customers).insert(
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

    Future<int> createIssuedInvoice({String status = 'SENT'}) {
      final service = container.read(invoiceProvider);
      final date = DateTime(2026, 6, 30);
      return service.createInvoiceWithItems(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          cgstAmount: const drift.Value(9),
          sgstAmount: const drift.Value(9),
          reverseCharge: const drift.Value(true),
          shipToName: const drift.Value('Warehouse'),
          shipToCity: const drift.Value('Surat'),
          status: drift.Value(status),
          amountInWords: const drift.Value('One Hundred Eighteen Rupees Only'),
          createdAt: date,
          updatedAt: date,
        ),
        [
          const InvoiceItemsCompanion(
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
        ],
      );
    }

    test('credit note copies the invoice under its own number series',
        () async {
      final service = container.read(invoiceProvider);
      final invoiceId = await createIssuedInvoice();

      final noteId = await service.createCreditNote(invoiceId);
      final note = await database.invoiceDao.getInvoiceById(noteId);
      final noteItems = await database.invoiceDao.getItemsForInvoice(noteId);

      expect(note?.invoiceType, 'CREDIT_NOTE');
      expect(note?.referenceInvoiceId, invoiceId);
      expect(note?.invoiceNumber, startsWith('CN-2627-'));
      expect(note?.status, 'DRAFT');
      expect(note?.totalAmount, 118);
      expect(note?.reverseCharge, isTrue);
      expect(note?.shipToName, 'Warehouse');
      expect(note?.shipToCity, 'Surat');
      expect(noteItems, hasLength(1));
    });

    test('debit notes use their own series', () async {
      final service = container.read(invoiceProvider);
      final invoiceId = await createIssuedInvoice();

      final noteId = await service.createDebitNote(invoiceId);
      final note = await database.invoiceDao.getInvoiceById(noteId);

      expect(note?.invoiceType, 'DEBIT_NOTE');
      expect(note?.invoiceNumber, startsWith('DN-2627-'));
      expect(note?.referenceInvoiceId, invoiceId);
    });

    test('a draft or cancelled invoice cannot be adjusted', () async {
      final service = container.read(invoiceProvider);

      final draftId = await createIssuedInvoice(status: 'DRAFT');
      await expectLater(
        service.createCreditNote(draftId),
        throwsA(isA<Exception>()),
      );

      final cancelledId = await createIssuedInvoice();
      await service.updateInvoiceStatus(cancelledId, 'CANCELLED');
      await expectLater(
        service.createCreditNote(cancelledId),
        throwsA(isA<Exception>()),
      );
    });

    test('a note cannot itself be adjusted', () async {
      final service = container.read(invoiceProvider);
      final invoiceId = await createIssuedInvoice();
      final noteId = await service.createCreditNote(invoiceId);

      await expectLater(
        service.createCreditNote(noteId),
        throwsA(isA<Exception>()),
      );
    });

    test('credit notes subtract from the signed total', () async {
      final service = container.read(invoiceProvider);
      final invoiceId = await createIssuedInvoice();
      final noteId = await service.createCreditNote(invoiceId);

      final invoice = await database.invoiceDao.getInvoiceById(invoiceId);
      final note = await database.invoiceDao.getInvoiceById(noteId);

      expect(
        signedInvoiceTotal(invoice!.totalAmount, invoice.invoiceType),
        118,
      );
      expect(signedInvoiceTotal(note!.totalAmount, note.invoiceType), -118);
      expect(isAdjustmentNote(note.invoiceType), isTrue);
    });
  });

  group('InvoiceLifecycleGuards', () {
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

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Test Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.into(database.customers).insert(
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

    final invoiceDate = DateTime(2026, 6, 30);

    InvoicesCompanion companion() => InvoicesCompanion.insert(
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

    List<InvoiceItemsCompanion> lineItems() => [
          const InvoiceItemsCompanion(
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

    test('blocks editing a paid invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.recordPayment(id, 118);

      final stored = await database.invoiceDao.getInvoiceById(id);
      expect(stored?.status, 'PAID');

      await expectLater(
        notifier.updateInvoiceWithItems(stored!, companion(), lineItems()),
        throwsA(isA<Exception>()),
      );
    });

    test('blocks editing a cancelled invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.updateInvoiceStatus(id, 'CANCELLED');

      final stored = await database.invoiceDao.getInvoiceById(id);
      expect(stored?.status, 'CANCELLED');

      await expectLater(
        notifier.updateInvoiceWithItems(stored!, companion(), lineItems()),
        throwsA(isA<Exception>()),
      );
    });

    test('blocks editing an issued (sent) invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.updateInvoiceStatus(id, 'SENT');

      final stored = await database.invoiceDao.getInvoiceById(id);
      expect(stored?.status, 'SENT');

      await expectLater(
        notifier.updateInvoiceWithItems(stored!, companion(), lineItems()),
        throwsA(isA<Exception>()),
      );
    });

    test('blocks deleting an issued (non-draft) invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.updateInvoiceStatus(id, 'SENT');

      await expectLater(notifier.deleteInvoice(id), throwsA(isA<Exception>()));
      expect(await database.invoiceDao.getInvoiceById(id), isNotNull);
    });

    test('still allows deleting a draft invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());

      await notifier.deleteInvoice(id);
      expect(await database.invoiceDao.getInvoiceById(id), isNull);
    });

    test('blocks recording a payment on a cancelled invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.updateInvoiceStatus(id, 'CANCELLED');

      await expectLater(
        notifier.recordPayment(id, 50),
        throwsA(isA<Exception>()),
      );

      final stored = await database.invoiceDao.getInvoiceById(id);
      expect(stored?.status, 'CANCELLED');
      expect(stored?.amountPaid, 0);
    });

    test('blocks reopening a cancelled invoice', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());
      await notifier.updateInvoiceStatus(id, 'CANCELLED');

      await expectLater(
        notifier.updateInvoiceStatus(id, 'SENT'),
        throwsA(isA<Exception>()),
      );

      final stored = await database.invoiceDao.getInvoiceById(id);
      expect(stored?.status, 'CANCELLED');
    });

    test('records a backdated payment with mode and reference', () async {
      final notifier = container.read(invoiceProvider);
      final id = await notifier.createInvoiceWithItems(companion(), lineItems());

      await notifier.recordPayment(
        id,
        50,
        paidAt: DateTime(2026, 7, 1),
        mode: 'UPI',
        reference: 'TXN-123',
      );

      final payment =
          (await database.invoiceDao.getPaymentsForInvoice(id)).single;
      expect(payment.paidAt, DateTime(2026, 7, 1));
      expect(payment.mode, 'UPI');
      expect(payment.reference, 'TXN-123');
      expect(payment.amount, 50);
    });
  });

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

  group('AmountInWords', () {
    test('zero amount', () {
      expect(AmountInWords.convert(0), 'Zero Rupees Only');
    });

    test('amounts below one rupee keep paise', () {
      expect(
        AmountInWords.convert(0.99),
        'Zero Rupees and Ninety Nine Paise Only',
      );
    });

    test('singular rupee', () {
      expect(AmountInWords.convert(1), 'One Rupee Only');
      expect(AmountInWords.convert(1.01), 'One Rupee and One Paise Only');
    });

    test('rounds binary doubles to paise like the form display', () {
      // 1.995*100 lands on 199.5, so both the stored value and the words use
      // the same rounded double: 2.00.
      expect(round2(1.995), 2.0);
      expect(AmountInWords.convert(round2(1.995)), 'Two Rupees Only');
      expect(AmountInWords.convert(round2(1.994)), 'One Rupee and Ninety Nine Paise Only');
      expect(AmountInWords.convert(2.5), 'Two Rupees and Fifty Paise Only');
    });

    test('hundreds, thousands, lakhs and crores', () {
      expect(AmountInWords.convert(100), 'One Hundred Rupees Only');
      expect(
        AmountInWords.convert(10500),
        'Ten Thousand Five Hundred Rupees Only',
      );
      expect(
        AmountInWords.convert(123456),
        'One Lakh Twenty Three Thousand Four Hundred Fifty Six Rupees Only',
      );
      expect(
        AmountInWords.convert(99999999.99),
        'Nine Crore Ninety Nine Lakh Ninety Nine Thousand '
        'Nine Hundred Ninety Nine Rupees and Ninety Nine Paise Only',
      );
    });
  });

  group('MoneyRounding', () {
    test('round2 rounds to paise', () {
      expect(round2(123.3333333), 123.33);
      expect(round2(123.336), 123.34);
      expect(round2(0.004), 0.0);
    });

    test('GstCalculator rounds intra-state components to paise', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(breakdown.cgst, 3.00);
      expect(breakdown.sgst, 3.00);
      expect(breakdown.igst, 0);
      expect(breakdown.total, 39.33);
    });

    test('GstCalculator rounds inter-state IGST and cess to paise', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 100.01,
        gstRate: 12,
        isInterState: true,
        cessRate: 1,
      );
      expect(breakdown.igst, 12.00);
      expect(breakdown.cess, 1.00);
      expect(breakdown.total, 113.01);
    });

    test('total always equals the rounded sum of components', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(
        breakdown.total,
        round2(33.33 + breakdown.cgst + breakdown.sgst + breakdown.cess),
      );
    });
  });

  group('RoundOff', () {
    test('adjusts a total to the nearest whole rupee', () {
      expect(roundOffForTotal(1180.0), 0);
      expect(roundOffForTotal(1180.4), -0.4);
      expect(roundOffForTotal(1180.5), 0.5);
      expect(roundOffForTotal(1180.6), 0.4);
      expect(payableTotal(1180.4), 1180);
      expect(payableTotal(1180.5), 1181);
    });

    test('round off plus the exact total equals the payable amount', () {
      for (final total in [0.0, 99.99, 100.5, 1234.49, 99999.99]) {
        expect(round2(total + roundOffForTotal(total)), payableTotal(total));
      }
    });
  });

  group('DatabaseBackupService regression tests', () {
    test('restores template configs along with the rest of the data', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
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
      await source.into(source.templateConfigs).insert(
        TemplateConfigsCompanion.insert(
          businessId: 1,
          scope: TemplateScope.invoice,
          name: 'My Template',
          configJson: '{"layoutFamily":"MODERN"}',
          createdAt: DateTime(2026, 6, 30),
          updatedAt: DateTime(2026, 6, 30),
        ),
      );
      final backupJson = await DatabaseBackupService.buildBackupJson(source);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId =
          await DatabaseBackupService.restoreFromJson(target, backupJson);

      final templates = await target.select(target.templateConfigs).get();
      expect(restoredActiveId, 1);
      expect(templates, hasLength(1));
      expect(templates.single.name, 'My Template');
      expect(templates.single.configJson, contains('MODERN'));
    });

    test('restores backups created before optional tables existed', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Legacy Backup Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      final decoded =
          jsonDecode(await DatabaseBackupService.buildBackupJson(source))
              as Map<String, dynamic>;
      decoded.remove('templateConfigs');
      decoded.remove('documentSequences');

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId =
          await DatabaseBackupService.restoreFromJson(target, jsonEncode(decoded));

      expect(restoredActiveId, 1);
      expect(await target.select(target.templateConfigs).get(), isEmpty);
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('rejects backups from another schema version without touching data',
        () async {
      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      await target.into(target.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Existing Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final backup = jsonEncode(<String, Object>{'schemaVersion': 1, 'businesses': <Object>[]});
      await expectLater(
        DatabaseBackupService.restoreFromJson(target, backup),
        throwsA(isA<BackupVersionMismatch>()),
      );
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('rejects malformed backups without touching data', () async {
      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      await target.into(target.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Existing Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final backup = jsonEncode(<String, Object>{
        'schemaVersion': target.schemaVersion,
        'businesses': <Object>[],
      });
      await expectLater(
        DatabaseBackupService.restoreFromJson(target, backup),
        throwsA(isA<FormatException>()),
      );
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('writes a restorable pre-restore safety snapshot', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Snapshot Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final directory = await Directory.systemTemp.createTemp('vittix_snapshot');
      addTearDown(() => directory.delete(recursive: true));

      final path = await DatabaseBackupService.createRestoreSafetySnapshot(
        source,
        directory: directory,
      );

      final snapshot = File(path);
      expect(await snapshot.exists(), isTrue);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        await snapshot.readAsString(),
      );

      expect(restoredActiveId, 1);
      expect((await target.select(target.businesses).get()), hasLength(1));
    });
  });

  group('Gstr1Export', () {
    test('emits B2B, B2CS, CDNR and HSN sections', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final registeredId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Registered',
              gstin: const drift.Value('27AAPFU0939F1ZV'),
              stateCode: const drift.Value(27),
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final walkInId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Walk-in',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      Future<int> insertInvoice({
        required int customerId,
        required String number,
        required String type,
        int? referenceInvoiceId,
      }) => database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: customerId,
              invoiceNumber: number,
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: type,
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
              referenceInvoiceId: drift.Value(referenceInvoiceId),
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      final registeredInvoice = await insertInvoice(
        customerId: registeredId,
        number: 'INV-2627-0001',
        type: 'TAX_INVOICE',
      );
      await insertInvoice(
        customerId: walkInId,
        number: 'INV-2627-0002',
        type: 'TAX_INVOICE',
      );
      await insertInvoice(
        customerId: registeredId,
        number: 'CN-2627-0001',
        type: 'CREDIT_NOTE',
        referenceInvoiceId: registeredInvoice,
      );

      await database.into(database.invoiceItems).insert(
            InvoiceItemsCompanion.insert(
              invoiceId: registeredInvoice,
              name: 'Service',
              hsnSac: '9983',
              unit: 'NOS',
              quantity: 1,
              rate: 100,
              taxableAmount: 100,
              gstRate: 18,
              totalAmount: 118,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
            ),
          );

      final rows = buildGstr1Rows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );

      final flat = rows.map((row) => row.join('|')).join('\n');
      expect(flat, contains('Section|B2B'));
      expect(flat, contains('Section|B2CS'));
      expect(flat, contains('Section|CDNR'));
      expect(flat, contains('Section|HSN'));
      expect(flat, contains('INV-2627-0001'));
      expect(flat, contains('CN-2627-0001'));
      expect(flat, contains('9983'));
    });

    test('maps line units to UQC codes in the HSN summary', () {
      expect(uqcForUnit('KG'), 'KGS');
      expect(uqcForUnit('kg'), 'KGS');
      expect(uqcForUnit('GRM'), 'GMS');
      expect(uqcForUnit('CM'), 'CMS');
      expect(uqcForUnit('ML'), 'MLT');
      expect(uqcForUnit('PCS'), 'PCS');
      expect(uqcForUnit('NOS'), 'NOS');
      expect(uqcForUnit('Box'), 'BOX');
      expect(uqcForUnit('Crate'), 'OTH');
      expect(uqcForUnit(''), 'OTH');
    });

    test('routes export supplies to the EXP/SEZ section only', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final importerId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Importer',
              gstin: const drift.Value('27AAPFU0939F1ZV'),
              stateCode: const drift.Value(27),
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final foreignId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Foreign',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      Future<void> insertInvoice({
        required int customerId,
        required String number,
        required String supplyType,
        bool? exportWithLut,
      }) => database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: customerId,
              invoiceNumber: number,
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'TAX_INVOICE',
              supplyType: supplyType,
              placeOfSupply: 96,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 100,
              exportWithLut: drift.Value(exportWithLut ?? false),
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );

      await insertInvoice(
        customerId: foreignId,
        number: 'EXP-0001',
        supplyType: 'EXPORT',
        exportWithLut: true,
      );
      await insertInvoice(
        customerId: importerId,
        number: 'SEZ-0001',
        supplyType: 'SEZ',
        exportWithLut: false,
      );

      final rows = buildGstr1Rows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: const [],
      );
      final flat = rows.map((row) => row.join('|')).join('\n');

      expect(flat, contains('Section|EXP/SEZ'));
      expect(flat, contains('EXP-WOPAY||EXP-0001'));
      expect(flat, contains('SEZ-WPAY|27AAPFU0939F1ZV|SEZ-0001'));

      // Export supplies must not leak into the domestic sections.
      final b2bSection = flat.split('Section|B2CS').first;
      expect(b2bSection, isNot(contains('EXP-0001')));
      expect(b2bSection, isNot(contains('SEZ-0001')));
      final b2csSection = flat.split('Section|B2CS').last.split('Section|EXP/SEZ').first;
      expect(b2csSection, isNot(contains('EXP-0001')));
      expect(b2csSection, isNot(contains('SEZ-0001')));
    });

    test('includes every invoice in range, beyond the 500-row list cap',
        () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      final walkInId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Walk-in',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await database.batch((batch) {
        for (var i = 1; i <= 501; i++) {
          batch.insert(
            database.invoices,
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: walkInId,
              invoiceNumber: 'INV-BULK-${i.toString().padLeft(4, '0')}',
              invoiceDate: DateTime(2026, 6, 1, 12),
              invoiceType: 'TAX_INVOICE',
              supplyType: 'B2C',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );
        }
      });

      final inRange = await database.invoiceDao.getInvoicesForBusinessBetween(
        1,
        DateTime(2026, 6, 1),
        DateTime(2026, 6, 30, 23, 59, 59),
      );
      expect(inRange.length, 501);

      final rows = buildGstr1Rows(
        customers: await database.select(database.customers).get(),
        invoices: inRange,
        items: const [],
      );
      final flat = rows.map((row) => row.join('|')).join('\n');
      // B2CS consolidates rows, so completeness is proven by the bucket
      // total: all 501 invoices at 100 taxable each.
      expect(flat, contains('27|18.0|50100.00|4509.00|4509.00'));
    });
  });

  group('Gstr1Validation', () {
    late AppDatabase database;
    late int customerId;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
      customerId = await database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Registered',
              createdAt: DateTime(2026, 6, 30),
            ),
          );
    });

    Future<int> insertInvoice({
      String gstin = '27AAPFU0939F1ZV',
      String supplyType = 'B2B',
      int placeOfSupply = 27,
      String status = 'SENT',
      String invoiceType = 'TAX_INVOICE',
    }) async {
      final existing = await database.select(database.invoices).get();
      final id = await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: customerId,
              invoiceNumber: 'INV-V-${existing.length + 1}',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: invoiceType,
              supplyType: supplyType,
              placeOfSupply: placeOfSupply,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              status: drift.Value(status),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );
      await (database.update(database.customers)
            ..where((t) => t.id.equals(customerId)))
          .write(CustomersCompanion(gstin: drift.Value(gstin)));
      return id;
    }

    Future<void> insertItem(int invoiceId, {String hsnSac = '9983'}) =>
        database.into(database.invoiceItems).insert(
              InvoiceItemsCompanion.insert(
                invoiceId: invoiceId,
                name: 'Service',
                hsnSac: hsnSac,
                unit: 'NOS',
                quantity: 1,
                rate: 100,
                taxableAmount: 100,
                gstRate: 18,
                totalAmount: 118,
              ),
            );

    test('passes a clean B2B invoice', () async {
      final id = await insertInvoice();
      await insertItem(id);
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues, isEmpty);
    });

    test('flags a customer GSTIN with a broken checksum', () async {
      final id = await insertInvoice(gstin: '27AAPFU0939F1Z0');
      await insertItem(id);
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues, hasLength(1));
      expect(issues.single.field, 'GSTIN');
    });

    test('flags a B2B invoice whose customer has no GSTIN', () async {
      final id = await insertInvoice(gstin: '');
      await insertItem(id);
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues.single.message, contains('no GSTIN'));
    });

    test('flags an impossible place of supply', () async {
      final id = await insertInvoice(placeOfSupply: 99);
      await insertItem(id);
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues.single.field, 'Place of supply');
    });

    test('flags lines with a missing or too-short HSN/SAC', () async {
      final id = await insertInvoice();
      await insertItem(id, hsnSac: '');
      await insertItem(id, hsnSac: '99');
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues.where((issue) => issue.field == 'HSN/SAC'), hasLength(2));
    });

    test('flags a SEZ supply without the SEZ unit GSTIN', () async {
      final id = await insertInvoice(gstin: '', supplyType: 'SEZ');
      await insertItem(id);
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues.single.field, 'GSTIN');
      expect(issues.single.message, contains('SEZ'));
    });

    test('skips bills of supply and non-counted documents', () async {
      final billId = await insertInvoice(invoiceType: 'BILL_OF_SUPPLY');
      await insertItem(billId);
      final draftId = await insertInvoice(status: 'DRAFT');
      await insertItem(draftId, hsnSac: '');
      final issues = validateInvoicesForGstr1(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      expect(issues, isEmpty);
    });
  });


  group('BackupEncryption', () {
    test('round-trips a payload and rejects a wrong passphrase', () {
      const plaintext = '{"hello":"world"}';
      final envelope = BackupCipher.encrypt(plaintext, 'correct horse');

      expect(BackupCipher.isEncrypted(envelope), isTrue);
      expect(BackupCipher.isEncrypted(plaintext), isFalse);
      expect(BackupCipher.decrypt(envelope, 'correct horse'), plaintext);
      expect(
        () => BackupCipher.decrypt(envelope, 'wrong'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a tampered envelope', () {
      final envelope = BackupCipher.encrypt('{"a":1}', 'pw');
      final tampered = envelope.replaceFirst('"payload":"', '"payload":"!!');

      expect(
        () => BackupCipher.decrypt(tampered, 'pw'),
        throwsA(isA<FormatException>()),
      );
    });

    test('an encrypted backup round-trips through the service', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Encrypted',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final encrypted = await DatabaseBackupService.buildBackupJson(
        source,
        passphrase: 'secret',
      );
      expect(BackupCipher.isEncrypted(encrypted), isTrue);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      expect(
        await DatabaseBackupService.restoreFromJson(
          target,
          encrypted,
          passphrase: 'secret',
        ),
        1,
      );

      // A wrong passphrase must leave the target database untouched.
      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await expectLater(
        DatabaseBackupService.restoreFromJson(
          other,
          encrypted,
          passphrase: 'nope',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await other.select(other.businesses).get(), isEmpty);

      // With no passphrase at all the service asks for one rather than
      // guessing, and still leaves the target untouched.
      final missing = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(missing.close);
      await expectLater(
        DatabaseBackupService.restoreFromJson(missing, encrypted),
        throwsA(isA<BackupPassphraseRequired>()),
      );
      expect(await missing.select(missing.businesses).get(), isEmpty);
    });
  });

  group('DocumentSequences', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await database.into(database.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Seq Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      await database.into(database.customers).insert(
        CustomersCompanion.insert(
          businessId: 1,
          name: 'Seq Customer',
          createdAt: DateTime(2026, 6, 30),
        ),
      );
    });

    tearDown(() => database.close());

    InvoicesCompanion invoiceAt(DateTime date) => InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          createdAt: date,
          updatedAt: date,
        );

    QuotesCompanion quoteAt(DateTime date) => QuotesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          invoiceType: 'QUOTE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          createdAt: date,
          updatedAt: date,
        );

    test('allocates sequential numbers from the counter', () async {
      final date = DateTime(2026, 6, 30);
      final numbers = <String>[];
      for (var i = 0; i < 3; i++) {
        final id = await database.transaction(
          () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
            invoice: invoiceAt(date),
            format: 'INV-{FY}-{SEQ4}',
            date: date,
          ),
        );
        numbers.add((await database.invoiceDao.getInvoiceById(id))!.invoiceNumber);
      }
      expect(numbers, ['INV-2627-0001', 'INV-2627-0002', 'INV-2627-0003']);
    });

    test('continues numbering after a legacy number that predates counters',
        () async {
      final date = DateTime(2026, 6, 30);
      await database.into(database.invoices).insert(
        invoiceAt(date).copyWith(
          invoiceNumber: const drift.Value('INV-2627-0001'),
        ),
      );
      final id = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(id))!.invoiceNumber,
        'INV-2627-0002',
      );
    });

    test('keeps separate counters per financial year for backdated documents',
        () async {
      final fy2526 = DateTime(2026, 3, 31);
      final fy2627 = DateTime(2026, 4, 1);
      final oldId = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(fy2526),
          format: 'INV-{FY}-{SEQ4}',
          date: fy2526,
        ),
      );
      final newId = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(fy2627),
          format: 'INV-{FY}-{SEQ4}',
          date: fy2627,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(oldId))!.invoiceNumber,
        'INV-2526-0001',
      );
      expect(
        (await database.invoiceDao.getInvoiceById(newId))!.invoiceNumber,
        'INV-2627-0001',
      );
    });

    test('resumes a previous series when the format is rolled back mid-year',
        () async {
      final date = DateTime(2026, 6, 30);
      await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ5}',
          date: date,
        ),
      );
      final id = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(id))!.invoiceNumber,
        'INV-2627-0002',
      );
    });

    test('does not reuse numbers after deletion', () async {
      final date = DateTime(2026, 6, 30);
      final firstId = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      await database.invoiceDao.deleteInvoice(firstId);
      final id = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(id))!.invoiceNumber,
        'INV-2627-0003',
      );
    });

    test('quotes use their own counter series', () async {
      final date = DateTime(2026, 6, 30);
      final q1 = await database.transaction(
        () => database.quoteDao.insertQuoteWithGeneratedNumber(
          quote: quoteAt(date),
          format: 'QT-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.quoteDao.getQuoteById(q1))!.invoiceNumber,
        'QT-2627-0001',
      );
      final i1 = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(i1))!.invoiceNumber,
        'INV-2627-0001',
      );
    });

    test('computeMaxSequences mirrors the legacy scan per financial year', () {
      final rows = [
        (invoiceNumber: 'INV-2526-0005', invoiceDate: DateTime(2026, 3, 1)),
        (invoiceNumber: 'INV-2627-0003', invoiceDate: DateTime(2026, 6, 1)),
        (invoiceNumber: 'INV-2627-0009', invoiceDate: DateTime(2026, 8, 1)),
        (invoiceNumber: 'OTHER-1', invoiceDate: DateTime(2026, 7, 1)),
      ];
      final maxes = DocumentSequenceBackfill.computeMaxSequences(
        format: 'INV-{FY}-{SEQ4}',
        documents: rows,
      );
      expect(
        maxes[DocumentSequenceBackfill.keyFor('2526', 'INV-{FY}-{SEQ4}')],
        5,
      );
      expect(
        maxes[DocumentSequenceBackfill.keyFor('2627', 'INV-{FY}-{SEQ4}')],
        9,
      );
    });
  });

  group('InvoiceNumberGenerator', () {
    test('financial year rolls over in April', () {
      expect(
        InvoiceNumberGenerator.financialYear(DateTime(2026, 4, 1)),
        '2627',
      );
      expect(
        InvoiceNumberGenerator.financialYear(DateTime(2027, 3, 31)),
        '2627',
      );
      expect(
        InvoiceNumberGenerator.financialYear(DateTime(2026, 3, 31)),
        '2526',
      );
      expect(
        InvoiceNumberGenerator.financialYear(DateTime(2000, 1, 1)),
        '9900',
      );
    });

    test('generates every supported token', () {
      final date = DateTime(2026, 4, 5);
      expect(
        InvoiceNumberGenerator.generateFromFormat('{FY}', 1, date),
        '2627',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{YYYY}', 1, date),
        '2026',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{YY}', 1, date),
        '26',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{MM}', 1, date),
        '04',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{M}', 1, date),
        '4',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{DD}', 1, date),
        '05',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{MON}', 1, date),
        'APR',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{MONTH}', 1, date),
        'APRIL',
      );
    });

    test('pads and renders every sequence token width', () {
      final date = DateTime(2026, 6, 30);
      expect(InvoiceNumberGenerator.generateFromFormat('{SEQ}', 7, date), '7');
      expect(
        InvoiceNumberGenerator.generateFromFormat('{SEQ2}', 7, date),
        '07',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{SEQ3}', 7, date),
        '007',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{SEQ4}', 7, date),
        '0007',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{SEQ5}', 7, date),
        '00007',
      );
      expect(
        InvoiceNumberGenerator.generateFromFormat('{SEQ6}', 7, date),
        '000007',
      );
    });

    test('uses the backdated financial year for March documents', () {
      final marchDate = DateTime(2026, 3, 31);
      expect(
        InvoiceNumberGenerator.generateFromFormat(
          'INV-{FY}-{SEQ4}',
          3,
          marchDate,
        ),
        'INV-2526-0003',
      );
    });

    test('matches and extracts sequences per document date', () {
      final date = DateTime(2026, 6, 30);
      expect(
        InvoiceNumberGenerator.matchesFormat(
          'INV-2627-0009',
          'INV-{FY}-{SEQ4}',
          date,
        ),
        isTrue,
      );
      expect(
        InvoiceNumberGenerator.matchesFormat(
          'INV-2526-0009',
          'INV-{FY}-{SEQ4}',
          date,
        ),
        isFalse,
      );
      expect(
        InvoiceNumberGenerator.extractSequenceFromFormat(
          'INV-2627-0009',
          'INV-{FY}-{SEQ4}',
          date,
        ),
        9,
      );
      expect(
        InvoiceNumberGenerator.extractSequenceFromFormat(
          'INV-2627-0009',
          'QT-{FY}-{SEQ4}',
          date,
        ),
        0,
      );
    });

    test('extracts a bare trailing sequence as a fallback', () {
      expect(InvoiceNumberGenerator.extractSequence('ABC-42'), 42);
      expect(InvoiceNumberGenerator.extractSequence('INV-2627-0009'), 9);
      expect(InvoiceNumberGenerator.extractSequence('NO-NUMBER'), 0);
    });

    test('generate() increments the last number by one', () {
      final date = DateTime(2026, 6, 30);
      expect(
        InvoiceNumberGenerator.generate('INV', 42, date),
        'INV-2627-0043',
      );
    });

    test('normalizeFormat falls back for null or blank formats', () {
      expect(
        InvoiceNumberGenerator.normalizeFormat(
          null,
          fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
        ),
        'INV-{FY}-{SEQ4}',
      );
      expect(
        InvoiceNumberGenerator.normalizeFormat(
          '   ',
          fallback: InvoiceNumberGenerator.defaultQuoteFormat,
        ),
        'QT-{FY}-{SEQ4}',
      );
      expect(
        InvoiceNumberGenerator.normalizeFormat(
          'CUSTOM-{SEQ3}',
          fallback: 'INV-{FY}-{SEQ4}',
        ),
        'CUSTOM-{SEQ3}',
      );
    });
  });

  group('InvoiceBalance', () {
    Invoice invoiceWith({
      required double total,
      required double paid,
      String currencyCode = 'INR',
    }) {
      return Invoice(
        id: 1,
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'INV-2627-0001',
        currencyCode: currencyCode,
        invoiceDate: DateTime(2026, 6, 30),
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: total,
        discountAmount: 0,
        taxableAmount: total,
        cgstAmount: 0,
        sgstAmount: 0,
        igstAmount: 0,
        cessAmount: 0,
        totalAmount: total,
        roundOffAmount: 0,
        amountPaid: paid,
        status: 'DRAFT',
        isIgst: false,
        reverseCharge: false,
        exportWithLut: false,
        tdsRate: 0,
        tdsAmount: 0,
        tcsRate: 0,
        tcsAmount: 0,
        createdAt: DateTime(2026, 6, 30),
        updatedAt: DateTime(2026, 6, 30),
      );
    }

    test('balance clamps at zero for paid-in-full invoices', () {
      expect(invoiceWith(total: 100, paid: 100).amountPaid, 100);
      expect(invoiceBalanceDue(invoiceWith(total: 100, paid: 100)), 0);
    });

    test('overpayment is reported separately from balance', () {
      final overpaid = invoiceWith(total: 100, paid: 150);
      expect(invoiceBalanceDue(overpaid), 0);
      expect(invoiceOverpaidAmount(overpaid), 50);
    });

    test('partial payments leave the exact balance due', () {
      expect(invoiceBalanceDue(invoiceWith(total: 250.5, paid: 100.25)), 150.25);
    });

    test('balance math is currency-agnostic', () {
      final usd = invoiceWith(total: 500, paid: 200, currencyCode: 'USD');
      expect(usd.currencyCode, 'USD');
      expect(invoiceBalanceDue(usd), 300);
      final eur = invoiceWith(total: 1000, paid: 1200, currencyCode: 'EUR');
      expect(invoiceOverpaidAmount(eur), 200);
    });
  });

  group('P5 stream-driven providers', () {
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      database = AppDatabase.forTesting(NativeDatabase.memory());
      await database.into(database.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Stream Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      await database.into(database.customers).insert(
        CustomersCompanion.insert(
          businessId: 1,
          name: 'Original Name',
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(database.close);
    });

    test('customer detail reflects edits without manual invalidation', () async {
      final detail = container.listen(
        customerDetailProvider(1),
        (previous, next) {},
      );
      await container.read(customerDetailProvider(1).future);

      final customer = (await database.select(database.customers).getSingle())
          .copyWith(name: 'Renamed Customer');
      await database.update(database.customers).replace(customer);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(detail.read().value?.name, 'Renamed Customer');
    });

    test('invoice detail stream emits status changes after payment', () async {
      final date = DateTime(2026, 6, 30);
      final invoiceId = await database.into(database.invoices).insert(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'INV-2627-0001',
          invoiceDate: date,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          createdAt: date,
          updatedAt: date,
        ),
      );

      final detail = container.listen(
        invoiceDetailProvider(invoiceId),
        (previous, next) {},
      );
      final payments = container.listen(
        invoicePaymentsProvider(invoiceId),
        (previous, next) {},
      );
      await container.read(invoiceDetailProvider(invoiceId).future);
      expect(detail.read().value?.amountPaid, 0);

      await container.read(invoiceProvider).recordPayment(invoiceId, 118);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(detail.read().value?.amountPaid, 118);
      expect(detail.read().value?.status, 'PAID');
      expect(payments.read().value?.length, 1);
    });

    test('active business provider emits after the business row changes',
        () async {
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
      );
      addTearDown(container.dispose);

      final active = container.listen(
        activeBusinessProvider,
        (previous, next) {},
      );
      await container.read(activeBusinessProvider.future);
      expect(active.read().value?.name, 'Stream Business');

      final business = (await database.select(database.businesses).getSingle())
          .copyWith(name: 'Renamed Business');
      await database.update(database.businesses).replace(business);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(active.read().value?.name, 'Renamed Business');
    });
  });
}
