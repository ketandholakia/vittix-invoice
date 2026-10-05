
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/gstr1_export.dart';
import 'package:vittix_invoice/core/utils/gstr1_validation.dart';
import 'package:vittix_invoice/database/app_database.dart';

void main() {
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
    test('bills of supply never appear in any GSTR-1 section', () async {
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

      // A bill of supply from a composition dealer can carry a GSTIN and a
      // taxable amount - it still must not reach B2B, B2CS or the HSN table.
      final bosId = await database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: registeredId,
              invoiceNumber: 'BOS-2627-0001',
              invoiceDate: DateTime(2026, 6, 30),
              invoiceType: 'BILL_OF_SUPPLY',
              supplyType: 'B2C',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 100,
              status: const drift.Value('SENT'),
              createdAt: DateTime(2026, 6, 30),
              updatedAt: DateTime(2026, 6, 30),
            ),
          );
      await database.into(database.invoiceItems).insert(
            InvoiceItemsCompanion.insert(
              invoiceId: bosId,
              name: 'Goods',
              hsnSac: '8479',
              unit: 'PCS',
              quantity: 1,
              rate: 100,
              taxableAmount: 100,
              gstRate: 0,
              totalAmount: 100,
            ),
          );

      final rows = buildGstr1Rows(
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      final flat = rows.map((row) => row.join('|')).join('\n');

      expect(flat, isNot(contains('BOS-2627-0001')));
      expect(flat, isNot(contains('8479')));
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
}
