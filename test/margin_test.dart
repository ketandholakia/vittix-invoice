import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/margin_report.dart';
import 'package:vittix_invoice/database/app_database.dart';

void main() {
  late AppDatabase database;

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
            createdAt: DateTime(2026, 6, 1),
          ),
        );
  });

  Future<int> customer({String name = 'Mehta & Sons'}) =>
      database.into(database.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: name,
              createdAt: DateTime(2026, 6, 1),
            ),
          );

  Future<int> product({
    required String name,
    double? purchasePrice,
    bool isService = false,
  }) =>
      database.into(database.products).insert(
            ProductsCompanion.insert(
              businessId: 1,
              name: name,
              hsnSac: '9983',
              unit: 'NOS',
              salePrice: 100,
              gstRate: 18,
              isService: drift.Value(isService),
              purchasePrice: drift.Value(purchasePrice),
              createdAt: DateTime(2026, 6, 1),
            ),
          );

  Future<int> invoice({
    required int customerId,
    required String number,
    String status = 'SENT',
    String type = 'TAX_INVOICE',
    int? referenceInvoiceId,
    DateTime? date,
  }) =>
      database.into(database.invoices).insert(
            InvoicesCompanion.insert(
              businessId: 1,
              customerId: customerId,
              invoiceNumber: number,
              invoiceDate: date ?? DateTime(2026, 6, 15),
              invoiceType: type,
              supplyType: 'B2B',
              placeOfSupply: 27,
              subtotal: 100,
              taxableAmount: 100,
              totalAmount: 118,
              status: drift.Value(status),
              referenceInvoiceId: drift.Value(referenceInvoiceId),
              createdAt: DateTime(2026, 6, 15),
              updatedAt: DateTime(2026, 6, 15),
            ),
          );

  Future<void> item(
    int invoiceId, {
    required int? productId,
    String name = 'Line',
    double quantity = 1,
    double taxable = 100,
  }) =>
      database.into(database.invoiceItems).insert(
            InvoiceItemsCompanion.insert(
              invoiceId: invoiceId,
              productId: drift.Value(productId),
              name: name,
              hsnSac: '9983',
              unit: 'NOS',
              quantity: quantity,
              rate: taxable,
              taxableAmount: taxable,
              gstRate: 18,
              totalAmount: taxable * 1.18,
            ),
          );

  Future<MarginReport> report() async => computeMarginReport(
        invoices: await database.select(database.invoices).get(),
        items: await database.select(database.invoiceItems).get(),
        products: await database.select(database.products).get(),
        customers: await database.select(database.customers).get(),
      );

  test('computes revenue, COGS and margin per invoice, customer and product',
      () async {
    final customerId = await customer();
    final widgetId = await product(name: 'Widget', purchasePrice: 40);
    final invoiceId = await invoice(customerId: customerId, number: 'INV-1');
    await item(invoiceId, productId: widgetId, quantity: 2, taxable: 200);

    final result = await report();

    expect(result.totalRevenue, 200);
    expect(result.totalCogs, 80); // 2 x 40
    expect(result.totalMargin, 120);
    expect(result.marginPercent, closeTo(60, 0.001));

    expect(result.invoiceRows.single.margin, 120);
    expect(result.customerRows.single.invoiceCount, 1);
    expect(result.customerRows.single.margin, 120);
    expect(result.productRows.single.quantity, 2);
    expect(result.productRows.single.margin, 120);
    expect(result.noCostBasisLineCount, 0);
  });

  test('revenue excludes GST', () async {
    final customerId = await customer();
    final invoiceId = await invoice(customerId: customerId, number: 'INV-1');
    await item(invoiceId, productId: null, taxable: 100);
    // The invoice totals carry 18% tax; the taxable amount is the basis.
    await (database.update(database.invoices)
          ..where((t) => t.id.equals(invoiceId)))
        .write(const InvoicesCompanion(cgstAmount: drift.Value(9)));

    final result = await report();
    expect(result.totalRevenue, 100);
  });

  test('lines without a cost basis count revenue and are flagged', () async {
    final customerId = await customer();
    final noPrice = await product(name: 'NoPrice', purchasePrice: null);
    final service = await product(
      name: 'Service',
      purchasePrice: null,
      isService: true,
    );
    final invoiceId = await invoice(customerId: customerId, number: 'INV-1');
    await item(invoiceId, productId: noPrice, taxable: 100);
    await item(invoiceId, productId: service, name: 'Consulting', taxable: 50);

    final result = await report();

    expect(result.totalRevenue, 150);
    expect(result.totalCogs, 0);
    expect(result.totalMargin, 150);
    expect(result.noCostBasisLineCount, 2);
    expect(result.invoiceRows.single.noCostBasisLines, 2);
    expect(result.customerRows.single.noCostBasisLines, 2);
    expect(result.productRows.every((row) => row.noCostBasis), isTrue);
  });

  test('negative margins are preserved', () async {
    final customerId = await customer();
    final expensive = await product(name: 'Loss', purchasePrice: 150);
    final invoiceId = await invoice(customerId: customerId, number: 'INV-1');
    await item(invoiceId, productId: expensive, quantity: 1, taxable: 100);

    final result = await report();
    expect(result.totalMargin, -50);
    expect(result.invoiceRows.single.margin, -50);
    expect(result.marginPercent, closeTo(-50, 0.001));
  });

  test('credit notes reverse revenue and COGS', () async {
    final customerId = await customer();
    final widget = await product(name: 'Widget', purchasePrice: 40);
    final saleId = await invoice(customerId: customerId, number: 'INV-1');
    await item(saleId, productId: widget, quantity: 2, taxable: 200);
    final creditId = await invoice(
      customerId: customerId,
      number: 'CN-1',
      type: 'CREDIT_NOTE',
      referenceInvoiceId: saleId,
    );
    await item(creditId, productId: widget, quantity: 1, taxable: 100);

    final result = await report();

    expect(result.totalRevenue, 100); // 200 - 100
    expect(result.totalCogs, 40); // 80 - 40
    expect(result.totalMargin, 60);
    // The product ledger nets the quantity too: 2 sold, 1 returned.
    expect(result.productRows.single.quantity, 1);
  });

  test('drafts and cancelled documents are excluded', () async {
    final customerId = await customer();
    final widget = await product(name: 'Widget', purchasePrice: 40);
    final draftId = await invoice(
      customerId: customerId,
      number: 'INV-D',
      status: 'DRAFT',
    );
    await item(draftId, productId: widget, taxable: 999);
    final cancelledId = await invoice(
      customerId: customerId,
      number: 'INV-C',
      status: 'CANCELLED',
    );
    await item(cancelledId, productId: widget, taxable: 999);
    final sentId = await invoice(customerId: customerId, number: 'INV-S');
    await item(sentId, productId: widget, taxable: 100);

    final result = await report();
    expect(result.totalRevenue, 100);
    expect(result.invoiceRows.map((row) => row.invoiceNumber), ['INV-S']);
  });

  test('totals reconcile with the invoice taxable amounts to the paise',
      () async {
    final customerId = await customer();
    final widget = await product(name: 'Widget', purchasePrice: 33.33);
    final first = await invoice(customerId: customerId, number: 'INV-1');
    await item(
      first,
      productId: widget,
      quantity: 3,
      taxable: 59.99,
    );
    final second = await invoice(customerId: customerId, number: 'INV-2');
    await item(
      second,
      productId: widget,
      quantity: 1,
      taxable: 0.01,
    );

    final result = await report();

    final expectedRevenue = 59.99 + 0.01;
    expect(result.totalRevenue, expectedRevenue);
    expect(result.totalCogs, 4 * 33.33);
    // Margin is revenue minus COGS, both rounded at every boundary.
    expect(
      result.totalMargin,
      closeTo(expectedRevenue - 4 * 33.33, 0.01),
    );
  });

  test('customers and products aggregate across invoices', () async {
    final a = await customer(name: 'A');
    final b = await customer(name: 'B');
    final widget = await product(name: 'Widget', purchasePrice: 10);
    final first = await invoice(customerId: a, number: 'INV-1');
    await item(first, productId: widget, taxable: 100);
    final second = await invoice(customerId: a, number: 'INV-2');
    await item(second, productId: widget, taxable: 50);
    final third = await invoice(customerId: b, number: 'INV-3');
    await item(third, productId: widget, name: 'Widget', taxable: 70);

    final result = await report();

    expect(result.customerRows, hasLength(2));
    expect(result.customerRows.first.customerName, 'A'); // higher revenue
    expect(result.customerRows.first.invoiceCount, 2);
    expect(result.customerRows.first.revenue, 150);
    // The same product merges across customers.
    expect(result.productRows, hasLength(1));
    expect(result.productRows.single.revenue, 220);
  });
}
