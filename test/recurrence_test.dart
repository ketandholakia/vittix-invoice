
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/utils/due_dates.dart';
import 'package:vittix_invoice/core/utils/recurrence.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';
import 'package:vittix_invoice/services/invoice_service.dart';
import 'package:vittix_invoice/services/recurring_invoice_service.dart';

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

    test('anchored stepping recovers the anchor day after a clamp', () {
      // 31 Jan -> February clamps to the 28th, but March returns to the 31st.
      expect(
        advanceFromAnchor(DateTime(2026, 1, 31), 'MONTHLY', 31),
        DateTime(2026, 2, 28),
      );
      expect(
        advanceFromAnchor(DateTime(2026, 2, 28), 'MONTHLY', 31),
        DateTime(2026, 3, 31),
      );
      // The anchor also keeps an already-clamped schedule from drifting.
      expect(
        advanceFromAnchor(DateTime(2026, 2, 28), 'QUARTERLY', 31),
        DateTime(2026, 5, 31),
      );
      // One yearly step lands in 2027, whose February has 28 days; the
      // leap-year anchor resumes in 2028.
      expect(
        advanceFromAnchor(DateTime(2026, 2, 28), 'YEARLY', 29),
        DateTime(2027, 2, 28),
      );
      expect(
        advanceFromAnchor(DateTime(2027, 2, 28), 'YEARLY', 29),
        DateTime(2028, 2, 29),
      );
      // Weekly schedules ignore the anchor.
      expect(
        advanceFromAnchor(DateTime(2026, 6, 3), 'WEEKLY', 15),
        DateTime(2026, 6, 10),
      );
      // A missing (pre-migration) anchor falls back to the old behavior.
      expect(
        advanceFromAnchor(DateTime(2026, 1, 31), 'MONTHLY', 0),
        DateTime(2026, 2, 28),
      );
    });
  });

  group('DueDateTerm', () {
    test('keeps the payment term of the source document', () {
      expect(
        dueDateForCopy(
          sourceInvoiceDate: DateTime(2026, 1, 10),
          sourceDueDate: DateTime(2026, 1, 25),
          newInvoiceDate: DateTime(2026, 3, 5),
        ),
        DateTime(2026, 3, 20),
      );
      // A month boundary keeps the day count, not the calendar position:
      // Jan 20 -> Feb 5 is 16 days, so Aug 31 + 16 = Sep 16.
      expect(
        dueDateForCopy(
          sourceInvoiceDate: DateTime(2026, 1, 20),
          sourceDueDate: DateTime(2026, 2, 5),
          newInvoiceDate: DateTime(2026, 8, 31),
        ),
        DateTime(2026, 9, 16),
      );
    });

    test('stays null when the source has no due date', () {
      expect(
        dueDateForCopy(
          sourceInvoiceDate: DateTime(2026, 1, 10),
          sourceDueDate: null,
          newInvoiceDate: DateTime(2026, 3, 5),
        ),
        isNull,
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

    test('remembers the anchor day of the first run', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();

      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 1, 31),
      );

      expect(
        (await recurring.listForBusiness(1)).single.anchorDay,
        31,
      );
    });

    test('a clamped month-end run recovers its anchor next month', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 1, 31),
      );

      // Opening the app on Feb 28: the missed January run (dated Jan 31)
      // and February's own run (the anchor 31 clamped to the 28th) both
      // generate.
      expect(await recurring.runDue(now: DateTime(2026, 2, 28)), 2);
      final schedule = (await recurring.listForBusiness(1)).single;
      // Without the anchor this would drift to the 28th forever.
      expect(schedule.nextRunDate, DateTime(2026, 3, 31));
    });

    test('generates one draft per missed period', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 1, 1),
      );

      // Jan-Apr all ran while the app was closed; opening it mid-April
      // generates a dated draft for every missed period.
      expect(await recurring.runDue(now: DateTime(2026, 4, 15)), 4);

      final drafts = await database.select(database.invoices).get();
      final generated = drafts.where((row) => row.status == 'DRAFT').toList()
        ..sort((a, b) => a.invoiceDate.compareTo(b.invoiceDate));
      expect(generated.map((row) => row.invoiceDate), [
        DateTime(2026, 1, 1),
        DateTime(2026, 2, 1),
        DateTime(2026, 3, 1),
        DateTime(2026, 4, 1),
      ]);
      expect(
        (await recurring.listForBusiness(1)).single.nextRunDate,
        DateTime(2026, 5, 1),
      );
    });

    test('catch-up is capped at twelve drafts per schedule and run',
        () async {
      final recurring = container.read(recurringInvoiceProvider);
      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2025, 1, 1),
      );

      // 23 months were missed: the first run stops at the cap, the second
      // catches up the remaining 11, and the schedule is then caught up.
      expect(await recurring.runDue(now: DateTime(2026, 11, 19)), 12);
      expect(await recurring.runDue(now: DateTime(2026, 11, 19)), 11);
      expect(await recurring.runDue(now: DateTime(2026, 11, 19)), 0);

      final schedule = (await recurring.listForBusiness(1)).single;
      expect(schedule.nextRunDate, DateTime(2026, 12, 1));
    });

    test('generated drafts keep the source payment term and rebuild stale '
        'amounts from the source lines', () async {
      final recurring = container.read(recurringInvoiceProvider);
      // Source with a 7-day term and a stale stored split (no tax recorded
      // on the header or the line even though the rate is 18%).
      final date = DateTime(2026, 6, 30);
      final invoiceId = await container.read(invoiceProvider).createInvoiceWithItems(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          dueDate: drift.Value(DateTime(2026, 7, 7)),
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 100,
          status: const drift.Value('SENT'),
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
            cgstRate: drift.Value(0),
            sgstRate: drift.Value(0),
            igstRate: drift.Value(0),
            cgstAmount: drift.Value(0),
            sgstAmount: drift.Value(0),
            igstAmount: drift.Value(0),
            cessAmount: drift.Value(0),
            totalAmount: drift.Value(100),
          ),
        ],
      );
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 7, 31),
      );

      expect(await recurring.runDue(now: DateTime(2026, 7, 31)), 1);

      final draft = (await database.select(database.invoices).get())
          .firstWhere((row) => row.status == 'DRAFT');
      // The draft is dated on the run date and carries the same 7-day term.
      expect(draft.invoiceDate, DateTime(2026, 7, 31));
      expect(draft.dueDate, DateTime(2026, 8, 7));
      // Totals are rebuilt from the lines, not copied from the stale header.
      expect(draft.cgstAmount, 9);
      expect(draft.sgstAmount, 9);
      expect(draft.totalAmount, 118);

      final draftItems = await database.invoiceDao.getItemsForInvoice(draft.id);
      expect(draftItems.single.taxableAmount, 100);
      expect(draftItems.single.cgstAmount, 9);
      expect(draftItems.single.sgstAmount, 9);
      expect(draftItems.single.totalAmount, 118);
      // rate, quantity and discount come from the source line untouched.
      expect(draftItems.single.rate, 100);
      expect(draftItems.single.quantity, 1);
      expect(draftItems.single.discountPct, 0);
    });

    test('an export under LUT regenerates as a zero-rated draft', () async {
      final recurring = container.read(recurringInvoiceProvider);
      final date = DateTime(2026, 6, 30);
      final invoiceId = await container.read(invoiceProvider).createInvoiceWithItems(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'PENDING',
          invoiceDate: date,
          invoiceType: 'TAX_INVOICE',
          supplyType: 'EXPORT',
          placeOfSupply: 96,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          isIgst: const drift.Value(true),
          exportWithLut: const drift.Value(true),
          status: const drift.Value('SENT'),
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
            igstRate: drift.Value(18),
            igstAmount: drift.Value(18),
            cessAmount: drift.Value(0),
            totalAmount: drift.Value(118),
          ),
        ],
      );
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 7, 1),
      );

      expect(await recurring.runDue(now: DateTime(2026, 7, 1)), 1);

      final draft = (await database.select(database.invoices).get())
          .firstWhere((row) => row.status == 'DRAFT');
      expect(draft.exportWithLut, isTrue);
      expect(draft.igstAmount, 0);
      expect(draft.totalAmount, 100);
      final draftItems = await database.invoiceDao.getItemsForInvoice(draft.id);
      expect(draftItems.single.igstAmount, 0);
    });

    test('a failing draft generation leaves the schedule untouched',
        () async {
      var generateCalls = 0;
      final flakyService = _ThrowingInvoiceService(
        container.read(invoiceServiceProvider),
        () => generateCalls++ >= 1, // first call succeeds, second throws
      );
      final recurring = RecurringInvoiceService(
        invoiceDao: container.read(invoiceDaoProvider),
        recurringDao: container.read(recurringInvoiceDaoProvider),
        invoiceService: flakyService,
      );

      final invoiceId = await createIssuedInvoice();
      await recurring.startRecurrence(
        invoiceId: invoiceId,
        frequency: RecurrenceFrequency.monthly,
        firstRunDate: DateTime(2026, 1, 1),
      );

      // Two missed periods; the second generation fails.
      await expectLater(
        recurring.runDue(now: DateTime(2026, 2, 15)),
        throwsA(isA<Exception>()),
      );

      // The first period committed atomically: exactly one draft, and the
      // schedule sits at the second period — no partial second draft.
      final drafts = await database
          .select(database.invoices)
          .get()
          .then((rows) => rows.where((row) => row.status == 'DRAFT').length);
      expect(drafts, 1);
      final schedule = (await recurring.listForBusiness(1)).single;
      expect(schedule.nextRunDate, DateTime(2026, 2, 1));
    });
  });
}

/// Wraps the real invoice service and throws from [createInvoiceWithItems]
/// once [shouldThrow] turns true, to exercise runDue's transaction boundary.
class _ThrowingInvoiceService extends InvoiceService {
  final bool Function() shouldThrow;

  _ThrowingInvoiceService(InvoiceService real, this.shouldThrow)
      : super(
          db: real.db,
          activityDao: real.activityDao,
          invoiceDao: real.invoiceDao,
          businessDao: real.businessDao,
          productDao: real.productDao,
        );

  @override
  Future<int> createInvoiceWithItems(
    InvoicesCompanion invoice,
    List<InvoiceItemsCompanion> items,
  ) {
    if (shouldThrow()) {
      throw Exception('simulated generation failure');
    }
    return super.createInvoiceWithItems(invoice, items);
  }
}
