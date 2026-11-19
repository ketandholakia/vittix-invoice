
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
        businessStateCode: 27,
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
        businessStateCode: 27,
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
        // B2CS aggregates rate-wise from the line items, so the bulk export
        // must carry one item per document.
        for (var i = 1; i <= 501; i++) {
          batch.insert(
            database.invoiceItems,
            InvoiceItemsCompanion.insert(
              invoiceId: i,
              name: 'Service',
              hsnSac: '9983',
              unit: 'NOS',
              quantity: 1,
              rate: 100,
              taxableAmount: 100,
              gstRate: 18,
              cgstAmount: const drift.Value(9),
              sgstAmount: const drift.Value(9),
              totalAmount: 118,
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
        businessStateCode: 27,
        customers: await database.select(database.customers).get(),
        invoices: inRange,
        items: await database.invoiceDao.getItemsForInvoices(
          inRange.map((invoice) => invoice.id).toList(),
        ),
      );
      final flat = rows.map((row) => row.join('|')).join('\n');
      // B2CS consolidates rows rate-wise from the line items, so
      // completeness is proven by the bucket total: all 501 invoices at 100
      // taxable each.
      expect(flat, contains('27|18|50100.00|4509.00|4509.00'));
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
        businessStateCode: 27,
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      final flat = rows.map((row) => row.join('|')).join('\n');

      expect(flat, isNot(contains('BOS-2627-0001')));
      expect(flat, isNot(contains('8479')));
    });

  });

  group('Gstr1Sections', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      await database.into(database.businesses).insert(
            BusinessesCompanion.insert(
              name: 'B',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );
    });

    Future<int> insertCustomer({String? gstin, String name = 'C'}) =>
        database.into(database.customers).insert(
              CustomersCompanion.insert(
                businessId: 1,
                name: name,
                gstin: drift.Value(gstin),
                createdAt: DateTime(2026, 6, 30),
              ),
            );

    Future<int> insertInvoice({
      required int customerId,
      required String number,
      String type = 'TAX_INVOICE',
      String supplyType = 'B2C',
      int placeOfSupply = 27,
      double taxable = 100,
      double cgst = 0,
      double sgst = 0,
      double igst = 0,
      double total = 100,
      double tdsAmount = 0,
      String status = 'SENT',
      int? referenceInvoiceId,
    }) =>
        database.into(database.invoices).insert(
              InvoicesCompanion.insert(
                businessId: 1,
                customerId: customerId,
                invoiceNumber: number,
                invoiceDate: DateTime(2026, 6, 30),
                invoiceType: type,
                supplyType: supplyType,
                placeOfSupply: placeOfSupply,
                subtotal: taxable,
                taxableAmount: taxable,
                cgstAmount: drift.Value(cgst),
                sgstAmount: drift.Value(sgst),
                igstAmount: drift.Value(igst),
                totalAmount: total,
                tdsAmount: drift.Value(tdsAmount),
                referenceInvoiceId: drift.Value(referenceInvoiceId),
                status: drift.Value(status),
                createdAt: DateTime(2026, 6, 30),
                updatedAt: DateTime(2026, 6, 30),
              ),
            );

    Future<void> insertItem(
      int invoiceId, {
      double taxable = 100,
      double gstRate = 18,
      double cgst = 9,
      double sgst = 0,
      double igst = 0,
    }) =>
        database.into(database.invoiceItems).insert(
              InvoiceItemsCompanion.insert(
                invoiceId: invoiceId,
                name: 'Service',
                hsnSac: '9983',
                unit: 'NOS',
                quantity: 1,
                rate: taxable,
                taxableAmount: taxable,
                gstRate: gstRate,
                cgstAmount: drift.Value(cgst),
                sgstAmount: drift.Value(sgst),
                igstAmount: drift.Value(igst),
                totalAmount: taxable + cgst + sgst + igst,
              ),
            );

    Future<String> export() async {
      final rows = buildGstr1Rows(
        businessStateCode: 27,
        customers: await database.select(database.customers).get(),
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
      );
      return rows.map((row) => row.join('|')).join('\n');
    }

    String section(String flat, String name) => flat
        .split('Section|$name')
        .last
        .split(RegExp(r'Section\|[A-Za-z /]+'))
        .first;

    test('a mixed 5%/18% invoice reports rate-wise buckets in B2CS',
        () async {
      final walkIn = await insertCustomer(name: 'Walk-in');
      final invoice = await insertInvoice(
        customerId: walkIn,
        number: 'INV-2627-0001',
        taxable: 200,
        cgst: 23,
        sgst: 23,
        total: 246,
      );
      await insertItem(invoice, taxable: 100, gstRate: 5, cgst: 2.5, sgst: 2.5);
      await insertItem(invoice, taxable: 100, gstRate: 18, cgst: 9, sgst: 9);

      final flat = await export();
      final b2cs = section(flat, 'B2CS');

      // One bucket per rate, straight from the lines — never a blended rate.
      expect(b2cs, contains('27|5|100.00|2.50|2.50|0.00|0.00'));
      expect(b2cs, contains('27|18|100.00|9.00|9.00|0.00|0.00'));
      expect(b2cs, isNot(contains('11.5')));
    });

    test('credit notes net into B2CS and debit notes add back', () async {
      final walkIn = await insertCustomer(name: 'Walk-in');
      final invoice = await insertInvoice(
        customerId: walkIn,
        number: 'INV-2627-0001',
        cgst: 9,
        sgst: 9,
        total: 118,
      );
      await insertItem(invoice);
      final creditNote = await insertInvoice(
        customerId: walkIn,
        number: 'CN-2627-0001',
        type: 'CREDIT_NOTE',
        referenceInvoiceId: invoice,
        cgst: 9,
        sgst: 9,
        total: 118,
      );
      await insertItem(creditNote);
      final debitNote = await insertInvoice(
        customerId: walkIn,
        number: 'DN-2627-0001',
        type: 'DEBIT_NOTE',
        referenceInvoiceId: invoice,
        taxable: 50,
        cgst: 4.5,
        sgst: 4.5,
        total: 59,
      );
      await insertItem(
        debitNote,
        taxable: 50,
        cgst: 4.5,
        sgst: 4.5,
      );

      final flat = await export();
      final b2cs = section(flat, 'B2CS');

      // 100 - 100 (credit) + 50 (debit) taxable, and likewise the tax.
      expect(b2cs, contains('27|18|50.00|4.50|4.50|0.00|0.00'));
    });

    test('registered-recipient notes go to CDNR, not B2CS', () async {
      final registered = await insertCustomer(
        gstin: '24AAPFU0939F1Z2',
        name: 'Registered',
      );
      final invoice = await insertInvoice(
        customerId: registered,
        number: 'INV-2627-0001',
        supplyType: 'B2B',
        cgst: 9,
        sgst: 9,
        total: 118,
      );
      await insertItem(invoice);
      final creditNote = await insertInvoice(
        customerId: registered,
        number: 'CN-2627-0001',
        type: 'CREDIT_NOTE',
        supplyType: 'B2B',
        referenceInvoiceId: invoice,
        cgst: 9,
        sgst: 9,
        total: 118,
      );
      await insertItem(creditNote);

      final flat = await export();
      final b2cs = section(flat, 'B2CS');

      expect(b2cs, isNot(contains('100.00')));
      expect(flat, contains('CN-2627-0001'));
    });

    test('large inter-state supplies to unregistered recipients go to B2CL, '
        'not B2CS', () async {
      final outOfState = await insertCustomer(name: 'Out-of-state');
      await insertInvoice(
        customerId: outOfState,
        number: 'INV-2627-0001',
        placeOfSupply: 24,
        taxable: 300000,
        igst: 54000,
        total: 354000,
      );
      final small = await insertInvoice(
        customerId: outOfState,
        number: 'INV-2627-0002',
        placeOfSupply: 24,
        taxable: 200000,
        igst: 36000,
        total: 236000,
      );
      await insertItem(small, taxable: 200000, cgst: 0, igst: 36000);

      final flat = await export();
      final b2cl = section(flat, 'B2CL');
      final b2cs = section(flat, 'B2CS');

      expect(b2cl, contains('INV-2627-0001'));
      expect(b2cl, contains('354000.00'));
      expect(b2cl, contains('24'));
      // Below the threshold it stays consolidated, rate-wise.
      expect(b2cs, contains('24|18|200000.00|0.00|0.00|36000.00|0.00'));
      expect(b2cs, isNot(contains('INV-2627-0001')));
    });

    test('notes to unregistered recipients above the threshold go to CDNUR',
        () async {
      final outOfState = await insertCustomer(name: 'Out-of-state');
      final invoice = await insertInvoice(
        customerId: outOfState,
        number: 'INV-2627-0001',
        placeOfSupply: 24,
        taxable: 300000,
        igst: 54000,
        total: 354000,
      );
      await insertItem(invoice, taxable: 300000, cgst: 0, igst: 54000);
      final creditNote = await insertInvoice(
        customerId: outOfState,
        number: 'CN-2627-0001',
        type: 'CREDIT_NOTE',
        placeOfSupply: 24,
        referenceInvoiceId: invoice,
        taxable: 260000,
        igst: 46800,
        total: 306800,
      );
      await insertItem(creditNote, taxable: 260000, cgst: 0, igst: 46800);

      final flat = await export();
      final cdnur = section(flat, 'CDNUR');
      final b2cs = section(flat, 'B2CS');

      expect(cdnur, contains('CN-2627-0001'));
      expect(cdnur, contains('306800.00'));
      // The large note must not leak into the consolidated section.
      expect(b2cs, isNot(contains('260000')));
    });

    test('cancelled invoices appear only in documents issued', () async {
      final walkIn = await insertCustomer(name: 'Walk-in');
      await insertInvoice(
        customerId: walkIn,
        number: 'INV-2627-0001',
        cgst: 9,
        sgst: 9,
        total: 118,
      );
      await insertItem(
        (await database.select(database.invoices).get()).first.id,
      );
      await insertInvoice(
        customerId: walkIn,
        number: 'INV-2627-0002',
        cgst: 9,
        sgst: 9,
        total: 118,
        status: 'CANCELLED',
      );

      final flat = await export();
      final documents = section(flat, 'Documents issued');

      expect(documents, contains('TAX_INVOICE|INV-2627-0001|INV-2627-0002|2|1'));
      final b2cs = section(flat, 'B2CS');
      expect(b2cs, isNot(contains('INV-2627-0002')));
    });

    test('B2B and CDNR report the gross invoice value, not net of TDS',
        () async {
      final registered = await insertCustomer(
        gstin: '24AAPFU0939F1Z2',
        name: 'Registered',
      );
      await insertInvoice(
        customerId: registered,
        number: 'INV-2627-0001',
        supplyType: 'B2B',
        taxable: 1000,
        igst: 180,
        total: 1060,
        tdsAmount: 20,
      );
      final invoiceId =
          (await database.select(database.invoices).get()).single.id;
      await insertItem(invoiceId, taxable: 1000, cgst: 0, igst: 180);

      final flat = await export();
      final b2b = section(flat, 'B2B');

      // Gross = totalAmount (1060, net of TDS) + tdsAmount (20) = 1080.
      expect(b2b, contains('1080.00|1000.00'));
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
