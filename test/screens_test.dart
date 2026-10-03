import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart' as drift;
import 'package:vittix_invoice/app.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/features/dashboard/dashboard_screen.dart';
import 'package:vittix_invoice/features/invoices/create/invoice_form.dart';
import 'package:vittix_invoice/features/invoices/list/invoice_list_screen.dart';
import 'package:vittix_invoice/features/settings/document_numbering_screen.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
  void usePhoneViewport(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(tester.view.reset);
  }

  /// Drift stream queries schedule a zero-duration close timer when the
  /// ProviderScope is disposed; flush the tree so no timer is pending at the
  /// end of the test.
  Future<void> settleDriftStreams(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<AppDatabase> setUpDatabase() async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
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
    return database;
  }

  InvoicesCompanion invoiceCompanion({required String invoiceNumber}) {
    final date = DateTime(2026, 6, 30);
    return InvoicesCompanion.insert(
      businessId: 1,
      customerId: 1,
      invoiceNumber: invoiceNumber,
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
  }

  Widget wrapWithProviders(
    AppDatabase database,
    SharedPreferences prefs,
    Widget child, {
    List<Override> extraOverrides = const [],
  }) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(database),
        sharedPreferencesProvider.overrideWithValue(prefs),
        ...extraOverrides,
      ],
      child: MaterialApp(home: child),
    );
  }

  group('InvoiceFormScreen validation', () {
    testWidgets('requires a customer and items before saving', (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({
        'active_business_id': 1,
        'is_gst_enabled': true,
      });
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);

      await tester.pumpWidget(
        wrapWithProviders(
          database,
          prefs,
          const InvoiceFormScreen(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Invoice'));
      await tester.pump();
      expect(find.text('Select customer and add items'), findsOneWidget);

      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Test Customer').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Invoice'));
      await tester.pump();
      expect(find.text('Select customer and add items'), findsOneWidget);

      await settleDriftStreams(tester);
    });
  });

  group('InvoiceListScreen states', () {
    testWidgets('shows the empty state with a create action', (tester) async {
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);

      await tester.pumpWidget(
        wrapWithProviders(database, prefs, const InvoiceListScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('No invoices yet'), findsOneWidget);
      expect(find.text('New Invoice'), findsNWidgets(2));
      await settleDriftStreams(tester);
    });

    testWidgets('shows the filtered-empty state when nothing matches',
        (tester) async {
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);
      await database.into(database.invoices).insert(
        invoiceCompanion(invoiceNumber: 'INV-2627-0001'),
      );

      await tester.pumpWidget(
        wrapWithProviders(database, prefs, const InvoiceListScreen()),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'zzz-nothing-matches');
      await tester.pumpAndSettle();

      expect(find.text('No matching invoices'), findsOneWidget);
      expect(find.text('INV-2627-0001'), findsNothing);
      await settleDriftStreams(tester);
    });

    testWidgets('shows the error state with a working retry action',
        (tester) async {
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);

      var failFirst = true;

      await tester.pumpWidget(
        wrapWithProviders(
          database,
          prefs,
          const InvoiceListScreen(),
          extraOverrides: [
            invoiceListProvider.overrideWith((ref) {
              if (failFirst) {
                return Stream<List<Invoice>>.error(Exception('database is down'));
              }
              return Stream.value(const <Invoice>[]);
            }),
          ],
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Error loading invoices'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      failFirst = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.text('No invoices yet'), findsOneWidget);
      expect(find.text('Retry'), findsNothing);
      await settleDriftStreams(tester);
    });
  });

  group('Dashboard totals', () {
    testWidgets('excludes draft and cancelled invoices from revenue',
        (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);

      Future<void> insertInvoice(String number, String status) async {
        await database.into(database.invoices).insert(
              invoiceCompanion(
                invoiceNumber: number,
              ).copyWith(status: drift.Value(status)),
            );
      }

      await insertInvoice('INV-2627-0001', 'SENT');
      await insertInvoice('INV-2627-0002', 'DRAFT');
      await insertInvoice('INV-2627-0003', 'CANCELLED');

      await tester.pumpWidget(
        wrapWithProviders(database, prefs, const DashboardScreen()),
      );
      await tester.pumpAndSettle();

      // Only the issued 118 invoice counts; adding the draft and cancelled
      // ones would render 354.
      expect(find.textContaining('354'), findsNothing);
      expect(find.text('Total Revenue'), findsOneWidget);
      await settleDriftStreams(tester);
    });
  });

  group('DocumentNumberingScreen', () {
    testWidgets('exposes and saves the credit and debit note series',
        (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({'active_business_id': 1});
      final prefs = await SharedPreferences.getInstance();
      final database = await setUpDatabase();
      addTearDown(database.close);

      await tester.pumpWidget(
        wrapWithProviders(database, prefs, const DocumentNumberingScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.text('Credit Note Series Format'), findsOneWidget);
      expect(find.text('Debit Note Series Format'), findsOneWidget);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Credit Note Series Format'),
        'CR-{FY}-{SEQ4}',
      );
      await tester.pump();
      await tester.tap(find.text('Save Numbering'));
      await tester.pumpAndSettle();

      final business = await database.select(database.businesses).getSingle();
      expect(business.creditNoteSeriesFormat, 'CR-{FY}-{SEQ4}');
      expect(business.debitNoteSeriesFormat, 'DN-{FY}-{SEQ4}');

      await settleDriftStreams(tester);
    });
  });

  group('Onboarding flow', () {
    testWidgets('creates the first business and lands on the dashboard',
        (tester) async {
      usePhoneViewport(tester);
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            databaseProvider.overrideWithValue(database),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const VittixInvoiceApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Welcome to VittixInvoice'), findsOneWidget);

      await tester.tap(find.text('Add Business'));
      await tester.pumpAndSettle();

      expect(find.text('GSTIN *'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextFormField, 'GSTIN *'), '27AAPFU0939F1ZV');
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Business Name *'),
        'Happy Path Business',
      );
      await tester.enterText(find.widgetWithText(TextFormField, 'Address *'), '1 Main Road');
      await tester.enterText(find.widgetWithText(TextFormField, 'City *'), 'Mumbai');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Save Business'));
      await tester.pumpAndSettle();

      expect(find.text('Happy Path Business'), findsWidgets);
      expect(find.text('Total Revenue'), findsOneWidget);
      expect(
        await database.select(database.businesses).getSingleOrNull(),
        isNotNull,
      );
      final activeId = prefs.getInt('active_business_id');
      expect(activeId, isNotNull);
      await settleDriftStreams(tester);
    });
  });
}