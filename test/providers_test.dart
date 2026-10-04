
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/business_provider.dart';
import 'package:vittix_invoice/providers/customer_detail_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
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
