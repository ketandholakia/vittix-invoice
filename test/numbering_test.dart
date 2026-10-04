
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/invoice_number.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/document_sequence_allocator.dart';

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
}
