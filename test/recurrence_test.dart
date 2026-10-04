
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';
import 'package:vittix_invoice/core/utils/recurrence.dart';

void main() {
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
}
