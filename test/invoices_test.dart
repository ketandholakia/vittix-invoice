
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/utils/invoice_status.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/reminder_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
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
}
