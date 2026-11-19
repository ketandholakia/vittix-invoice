
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/core/utils/invoice_number.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/document_sequence_allocator.dart';
import 'package:vittix_invoice/providers/business_provider.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

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

    test('resyncs the counter to the number it actually used after a legacy '
        'collision', () async {
      final date = DateTime(2026, 6, 30);
      // Legacy books: a stale 0001 plus the real high-water mark 0007, and
      // no counter row yet.
      await database.into(database.invoices).insert(
        invoiceAt(date).copyWith(
          invoiceNumber: const drift.Value('INV-2627-0001'),
        ),
      );
      await database.into(database.invoices).insert(
        invoiceAt(date).copyWith(
          invoiceNumber: const drift.Value('INV-2627-0007'),
        ),
      );

      final firstId = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(firstId))!.invoiceNumber,
        'INV-2627-0008',
      );

      // The counter must now equal the number just used (8), so the next
      // insert succeeds on its first attempt — exactly one failed insert in
      // total across the run.
      final counterAfterFirst = await database
          .select(database.documentSequences)
          .getSingle();
      expect(counterAfterFirst.sequence, 8);

      final secondId = await database.transaction(
        () => database.invoiceDao.insertInvoiceWithGeneratedNumber(
          invoice: invoiceAt(date),
          format: 'INV-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.invoiceDao.getInvoiceById(secondId))!.invoiceNumber,
        'INV-2627-0009',
      );

      final counterAfterSecond = await database
          .select(database.documentSequences)
          .getSingle();
      expect(counterAfterSecond.sequence, 9);
    });

    test('quote numbering also advances the counter after a resync', () async {
      final date = DateTime(2026, 6, 30);
      await database.into(database.quotes).insert(
        quoteAt(date).copyWith(
          invoiceNumber: const drift.Value('QT-2627-0001'),
        ),
      );
      await database.into(database.quotes).insert(
        quoteAt(date).copyWith(
          invoiceNumber: const drift.Value('QT-2627-0007'),
        ),
      );

      final firstId = await database.transaction(
        () => database.quoteDao.insertQuoteWithGeneratedNumber(
          quote: quoteAt(date),
          format: 'QT-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.quoteDao.getQuoteById(firstId))!.invoiceNumber,
        'QT-2627-0008',
      );
      final secondId = await database.transaction(
        () => database.quoteDao.insertQuoteWithGeneratedNumber(
          quote: quoteAt(date),
          format: 'QT-{FY}-{SEQ4}',
          date: date,
        ),
      );
      expect(
        (await database.quoteDao.getQuoteById(secondId))!.invoiceNumber,
        'QT-2627-0009',
      );

      final counter =
          await database.select(database.documentSequences).getSingle();
      expect(counter.sequence, 9);
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

  group('InvoiceNumberGenerator.validateFormat', () {
    String? error(String format) => InvoiceNumberGenerator.validateFormat(format);

    test('accepts the defaults and compliant custom formats', () {
      expect(error(InvoiceNumberGenerator.defaultInvoiceFormat), isNull);
      expect(error(InvoiceNumberGenerator.defaultQuoteFormat), isNull);
      expect(error(InvoiceNumberGenerator.defaultCreditNoteFormat), isNull);
      expect(error(InvoiceNumberGenerator.defaultBillOfSupplyFormat), isNull);
      expect(error('QT-{FY}-{SEQ5}'), isNull);
      expect(error('INV-{YYYY}-{SEQ6}'), isNull);
      // Blank falls back to the default series, so it is fine.
      expect(error(''), isNull);
      expect(error('   '), isNull);
    });

    test('requires a sequence token', () {
      expect(error('INV-{FY}'), isNotNull);
      expect(error('INV-{FY}-A'), isNotNull);
    });

    test('requires a financial-year anchor so series never repeat', () {
      expect(error('INV-{SEQ4}'), isNotNull);
      expect(error('INV-{MM}-{SEQ4}'), isNotNull);
      expect(error('QT-{MON}-{YY}-{SEQ3}'), isNotNull);
      // {YYYY} is an equally unambiguous anchor.
      expect(error('INV-{YYYY}-{SEQ4}'), isNull);
    });

    test('rejects numbers longer than 16 characters (GST Rule 46)', () {
      expect(error('INV/{YYYY}/{MM}/{SEQ4}'), isNotNull);
      expect(error('SALE-{YYYY}-{MM}-A-{SEQ4}-X'), isNotNull);
      expect(error('QT-{MON}-{FY}-{SEQ3}'), isNotNull);
      // 'INV/2627-123456' is exactly 16 characters, so it fits.
      expect(error('INV/{FY}-{SEQ6}'), isNull);
    });

    test('rejects punctuation outside tokens', () {
      expect(error('INV_{FY}_{SEQ4}'), isNotNull);
      expect(error('INV-{FY}-{SEQ4}!'), isNotNull);
      expect(error('INV {FY} {SEQ4}'), isNotNull);
      // Letters, digits, hyphen and slash are fine.
      expect(error('A9/{FY}-{SEQ4}'), isNull);
    });

    test('rejects unknown tokens as stray characters', () {
      expect(error('INV-{FY}-{SEQ4}-{XYZ}'), isNotNull);
    });
  });

  group('BusinessSeriesFormatValidation (save-time)', () {
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

      // A business saved before the GST numbering rules existed: its format
      // no longer passes validation but must keep working.
      await database.into(database.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Legacy Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ).copyWith(
          invoiceSeriesFormat: const drift.Value('INV/{YYYY}/{MM}/{SEQ4}'),
        ),
      );
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('saving without changing a legacy format is allowed', () async {
      final notifier = container.read(businessProvider);
      final stored = await database.select(database.businesses).getSingle();

      await notifier.updateBusiness(stored.copyWith(name: 'Renamed'));

      final reloaded = await database.select(database.businesses).getSingle();
      expect(reloaded.name, 'Renamed');
      expect(reloaded.invoiceSeriesFormat, 'INV/{YYYY}/{MM}/{SEQ4}');
    });

    test('changing a format to an invalid one is rejected at save time',
        () async {
      final notifier = container.read(businessProvider);
      final stored = await database.select(database.businesses).getSingle();

      await expectLater(
        notifier.updateBusiness(
          stored.copyWith(invoiceSeriesFormat: 'INV-{SEQ4}'),
        ),
        throwsA(isA<Exception>()),
      );
      expect(
        (await database.select(database.businesses).getSingle())
            .invoiceSeriesFormat,
        'INV/{YYYY}/{MM}/{SEQ4}',
      );

      // A compliant change goes through.
      await notifier.updateBusiness(
        stored.copyWith(invoiceSeriesFormat: 'INV-{FY}-{SEQ4}'),
      );
      expect(
        (await database.select(database.businesses).getSingle())
            .invoiceSeriesFormat,
        'INV-{FY}-{SEQ4}',
      );
    });
  });
}
