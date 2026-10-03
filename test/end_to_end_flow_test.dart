import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/invoice_provider.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';
import 'package:vittix_invoice/services/invoice_service.dart';
import 'package:vittix_invoice/services/pdf_service.dart';

/// End-to-end smoke test of the core document pipeline against a real
/// in-memory database: business -> customer -> product -> invoice -> payment
/// -> PDF bytes -> backup -> restore.
///
/// Runs in the regular `flutter test` VM.
void main() {
  // The PDF renderer loads the bundled fonts through the asset bundle, which
  // needs the Flutter test binding to be initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late InvoiceService invoiceService;
  late Business business;

  setUp(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    invoiceService = container.read(invoiceProvider);

    business = await database.into(database.businesses).insertReturning(
      BusinessesCompanion.insert(
        name: 'Integration Business',
        gstin: '27AAPFU0939F1ZV',
        address: 'Address',
        city: 'Mumbai',
        stateCode: 27,
        createdAt: DateTime(2026, 6, 30),
      ),
    );
    addTearDown(database.close);
  });

  test('creates an invoice end to end, renders PDF, and restores backup',
      () async {
    final customer = await database.into(database.customers).insertReturning(
      CustomersCompanion.insert(
        businessId: business.id,
        name: 'Integration Customer',
        createdAt: DateTime(2026, 6, 30),
      ),
    );

    final product = await database.into(database.products).insertReturning(
      ProductsCompanion.insert(
        businessId: business.id,
        name: 'Integration Product',
        hsnSac: '9983',
        unit: 'NOS',
        salePrice: 1000,
        gstRate: 18,
        createdAt: DateTime(2026, 6, 30),
      ),
    );

    final date = DateTime(2026, 6, 30);
    final invoiceCompanion = InvoicesCompanion.insert(
      businessId: business.id,
      customerId: customer.id,
      invoiceNumber: 'PENDING',
      invoiceDate: date,
      invoiceType: 'TAX_INVOICE',
      supplyType: 'B2B',
      placeOfSupply: 27,
      subtotal: 1000,
      taxableAmount: 1000,
      totalAmount: 1180,
      cgstAmount: const drift.Value(90),
      sgstAmount: const drift.Value(90),
      createdAt: date,
      updatedAt: date,
    );

    final items = [
      InvoiceItemsCompanion(
        invoiceId: const drift.Value(0),
        productId: drift.Value(product.id),
        name: const drift.Value('Integration Product'),
        hsnSac: const drift.Value('9983'),
        unit: const drift.Value('NOS'),
        quantity: const drift.Value(1),
        rate: const drift.Value(1000),
        taxableAmount: const drift.Value(1000),
        gstRate: const drift.Value(18),
        cgstRate: const drift.Value(9),
        sgstRate: const drift.Value(9),
        cgstAmount: const drift.Value(90),
        sgstAmount: const drift.Value(90),
        totalAmount: const drift.Value(1180),
        sortOrder: const drift.Value(0),
      ),
    ];

    final invoiceId = await invoiceService.createInvoiceWithItems(
      invoiceCompanion,
      items,
    );

    final invoice = await database.invoiceDao.getInvoiceById(invoiceId);
    expect(invoice, isNotNull);
    expect(invoice!.invoiceNumber, startsWith('INV-'));
    expect(invoice.status, 'DRAFT');

    await invoiceService.recordPayment(invoiceId, 500);

    final paidInvoice = await database.invoiceDao.getInvoiceById(invoiceId);
    expect(paidInvoice!.amountPaid, 500);

    final storedItems = await database.invoiceDao.getItemsForInvoice(invoiceId);
    expect(storedItems, hasLength(1));

    final pdfBytes = await PdfService.generateInvoice(
      business: business,
      customer: customer,
      invoice: paidInvoice,
      items: storedItems,
      isGstEnabled: true,
      showBankDetails: false,
    );
    expect(pdfBytes, isNotEmpty);
    expect(String.fromCharCodes(pdfBytes.take(4)), '%PDF');

    final backupJson = await DatabaseBackupService.buildBackupJson(database);

    final restored = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(restored.close);
    final restoredActiveId =
        await DatabaseBackupService.restoreFromJson(restored, backupJson);

    expect(restoredActiveId, business.id);
    expect(await restored.select(restored.businesses).get(), hasLength(1));
    expect(await restored.select(restored.customers).get(), hasLength(1));
    expect(await restored.select(restored.products).get(), hasLength(1));
    expect(await restored.select(restored.invoices).get(), hasLength(1));
    expect(await restored.select(restored.invoiceItems).get(), hasLength(1));
    expect(await restored.select(restored.invoicePayments).get(), hasLength(1));

    final restoredInvoice = await restored.invoiceDao.getInvoiceById(invoiceId);
    expect(restoredInvoice!.invoiceNumber, invoice.invoiceNumber);
    expect(restoredInvoice.amountPaid, 500);
  });
}