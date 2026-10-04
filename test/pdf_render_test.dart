import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/models/invoice_template_config.dart';
import 'package:vittix_invoice/services/pdf_service.dart';

/// Render-to-bytes smoke tests for every PDF template family and feature
/// block. These prove the layout code does not throw and produces a real
/// document for each shipped combination; pixel-level checking stays out of
/// scope on purpose (brittle).
void main() {
  // Font assets load through rootBundle, which needs the test binding.
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase database;
  late Business business;
  late Customer customer;
  late Invoice invoice;
  late Quote quote;

  setUpAll(() async {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    await database.into(database.businesses).insert(
          BusinessesCompanion.insert(
            name: 'Vittix Traders',
            gstin: '27AAPFU0939F1ZV',
            address: '12 Market Road',
            city: 'Mumbai',
            stateCode: 27,
            createdAt: DateTime(2026, 6, 1),
            upiId: const drift.Value('vittix@upi')),
        );
    await database.into(database.customers).insert(
          CustomersCompanion.insert(
            businessId: 1,
            name: 'Mehta & Sons',
            gstin: const drift.Value('24AAPFU0939F1ZV'),
            stateCode: const drift.Value(24),
            createdAt: DateTime(2026, 6, 1),
          ),
        );
    final invoiceId = await database.into(database.invoices).insert(
          InvoicesCompanion.insert(
            businessId: 1,
            customerId: 1,
            invoiceNumber: 'INV-2627-0001',
            invoiceDate: DateTime(2026, 6, 15),
            invoiceType: 'TAX_INVOICE',
            supplyType: 'B2B',
            placeOfSupply: 27,
            subtotal: 100,
            taxableAmount: 100,
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            totalAmount: 118,
            status: const drift.Value('SENT'),
            createdAt: DateTime(2026, 6, 15),
            updatedAt: DateTime(2026, 6, 15),
          ),
        );
    await database.into(database.invoiceItems).insert(
          InvoiceItemsCompanion.insert(
            invoiceId: invoiceId,
            name: 'Consulting',
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
    final quoteId = await database.into(database.quotes).insert(
          QuotesCompanion.insert(
            businessId: 1,
            customerId: 1,
            invoiceNumber: 'QT-2627-0001',
            invoiceDate: DateTime(2026, 6, 15),
            invoiceType: 'QUOTE',
            supplyType: 'B2B',
            placeOfSupply: 27,
            subtotal: 100,
            taxableAmount: 100,
            cgstAmount: const drift.Value(9),
            sgstAmount: const drift.Value(9),
            totalAmount: 118,
            status: const drift.Value('SENT'),
            createdAt: DateTime(2026, 6, 15),
            updatedAt: DateTime(2026, 6, 15),
          ),
        );
    await database.into(database.quoteItems).insert(
          QuoteItemsCompanion.insert(
            quoteId: quoteId,
            name: 'Consulting',
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

    business = await database.select(database.businesses).getSingle();
    customer = await database.select(database.customers).getSingle();
    invoice = await database.select(database.invoices).getSingle();
    quote = await database.select(database.quotes).getSingle();
  });

  tearDownAll(() => database.close());

  Future<List<InvoiceItem>> items() =>
      database.select(database.invoiceItems).get();
  Future<List<QuoteItem>> quoteItemsList() =>
      database.select(database.quoteItems).get();

  void expectPdf(List<int> bytes) {
    expect(bytes, isNotEmpty);
    expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    expect(bytes.length, greaterThan(2000));
  }

  test('renders the CLASSIC invoice family', () async {
    final bytes = await PdfService.generateInvoice(
      business: business,
      customer: customer,
      invoice: invoice,
      items: await items(),
      isGstEnabled: true,
      showBankDetails: true,
    );
    expectPdf(bytes);
  });

  test('renders the MODERN and ELEGANT invoice families', () async {
    for (final family in ['MODERN', 'ELEGANT']) {
      final bytes = await PdfService.generateInvoice(
        business: business,
        customer: customer,
        invoice: invoice,
        items: await items(),
        isGstEnabled: true,
        templateConfig: InvoiceTemplateConfig.defaults(
          id: 't',
          name: family,
          layoutFamily: family,
        ),
      );
      expectPdf(bytes);
    }
  });

  test('renders watermark, UPI QR, and HSN summary feature blocks', () async {
    final bytes = await PdfService.generateInvoice(
      business: business,
      customer: customer,
      invoice: invoice,
      items: await items(),
      isGstEnabled: true,
      templateConfig: InvoiceTemplateConfig.defaults(id: 't', name: 'T')
          .copyWith(watermarkText: 'PAID', showQrCode: true, showHsn: true),
    );
    expectPdf(bytes);
  });

  test('renders a thermal-sized bill and a quote PDF', () async {
    final thermal = await PdfService.generateInvoice(
      business: business,
      customer: customer,
      invoice: invoice,
      items: await items(),
      isGstEnabled: true,
      templateConfig: InvoiceTemplateConfig.defaults(id: 't', name: 'T')
          .copyWith(paperSize: 'thermal'),
    );
    expectPdf(thermal);

    final quoteBytes = await PdfService.generateQuotePdf(
      business: business,
      customer: customer,
      quote: quote,
      items: await quoteItemsList(),
      isGstEnabled: true,
    );
    expectPdf(quoteBytes);
  });
}
