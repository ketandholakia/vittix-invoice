
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/constants/gst_states.dart';
import 'package:vittix_invoice/core/utils/document_totals.dart';
import 'package:vittix_invoice/core/utils/gst_calculator.dart';
import 'package:vittix_invoice/core/utils/gst_supply.dart';
import 'package:vittix_invoice/core/utils/gstin_validator.dart';
import 'package:vittix_invoice/core/utils/invoice_type.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/tables/businesses.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/hsn_provider.dart';

void main() {
  group('GstCalculator', () {
    test('splits intra-state GST equally', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: false,
      );

      expect(breakdown.cgst, 90);
      expect(breakdown.sgst, 90);
      expect(breakdown.igst, 0);
      expect(breakdown.total, 1180);
    });

    test('applies IGST for inter-state invoices', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: true,
      );

      expect(breakdown.cgst, 0);
      expect(breakdown.sgst, 0);
      expect(breakdown.igst, 180);
      expect(breakdown.total, 1180);
    });
  });

  group('LineTaxRecompute', () {
    test('re-splits a line from inter-state to intra-state (customer changed)',
        () {
      final asIgst = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: true,
      );
      expect(asIgst.igstAmount, 180);
      expect(asIgst.igstRate, 18);
      expect(asIgst.cgstAmount, 0);
      expect(asIgst.sgstAmount, 0);

      final asCgstSgst = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 18,
        isInterState: false,
      );
      expect(asCgstSgst.igstAmount, 0);
      expect(asCgstSgst.igstRate, 0);
      expect(asCgstSgst.cgstAmount, 90);
      expect(asCgstSgst.sgstAmount, 90);
      expect(asCgstSgst.cgstRate, 9);
      expect(asCgstSgst.sgstRate, 9);

      // Only the split moves; the tax total and line total are unchanged.
      expect(
        asCgstSgst.cgstAmount + asCgstSgst.sgstAmount,
        asIgst.igstAmount,
      );
      expect(asCgstSgst.totalAmount, asIgst.totalAmount);
    });

    test('re-splits a line from intra-state to inter-state (customer changed)',
        () {
      final split = GstCalculator.splitLine(
        taxableAmount: 1000,
        gstRate: 12,
        isInterState: true,
      );
      expect(split.cgstAmount, 0);
      expect(split.sgstAmount, 0);
      expect(split.cgstRate, 0);
      expect(split.sgstRate, 0);
      expect(split.igstRate, 12);
      expect(split.igstAmount, 120);
    });

    test('keeps a tax-free line at zero components', () {
      final split = GstCalculator.splitLine(
        taxableAmount: 500,
        gstRate: 0,
        isInterState: false,
      );
      expect(split.cgstAmount, 0);
      expect(split.sgstAmount, 0);
      expect(split.igstAmount, 0);
      expect(split.totalAmount, 500);
    });

    test('rounds recomputed components to paise', () {
      final split = GstCalculator.splitLine(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(split.cgstAmount, 3.00);
      expect(split.sgstAmount, 3.00);
      expect(split.totalAmount, 39.33);
    });
  });

  group('GstinValidator', () {
    test('accepts a valid GSTIN checksum', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZV'), isTrue);
      expect(GstinValidator.extractStateCode('27AAPFU0939F1ZV'), 27);
    });

    test('rejects an invalid GSTIN checksum', () {
      expect(GstinValidator.isValid('27AAPFU0939F1ZA'), isFalse);
    });
  });

  group('GstSupplyDerivation', () {
    Customer customer({int? stateCode, String? gstin}) => Customer(
          id: 1,
          businessId: 1,
          name: 'Customer',
          gstin: gstin,
          stateCode: stateCode,
          isActive: true,
          createdAt: DateTime(2026, 6, 30),
        );

    Business business({int stateCode = 27}) => Business(
          id: 1,
          name: 'Business',
          gstin: '27AAPFU0939F1ZV',
          businessType: BusinessType.gstRegistered,
          address: 'Address',
          city: 'Mumbai',
          stateCode: stateCode,
          currencyCode: 'INR',
          invoiceTemplate: 'CLASSIC',
          quoteTemplate: 'CLASSIC',
          invoiceSeriesFormat: 'INV-{FY}-{SEQ4}',
          quoteSeriesFormat: 'QT-{FY}-{SEQ4}',
          creditNoteSeriesFormat: 'CN-{FY}-{SEQ4}',
          debitNoteSeriesFormat: 'DN-{FY}-{SEQ4}',
billOfSupplySeriesFormat: 'BOS-{FY}-{SEQ4}',
          isActive: true,
          createdAt: DateTime(2026, 6, 30),
        );

    test('is B2B for a valid GSTIN and B2C otherwise', () {
      expect(deriveSupplyType(customer(gstin: '27AAPFU0939F1ZV')), 'B2B');
      expect(deriveSupplyType(customer()), 'B2C');
      expect(deriveSupplyType(customer(gstin: '27AAPFU0939F1ZA')), 'B2C');
    });

    test('place of supply prefers customer state, then GSTIN, then business',
        () {
      expect(
        derivePlaceOfSupply(customer(stateCode: 29), business(stateCode: 27)),
        29,
      );
      expect(
        derivePlaceOfSupply(
          customer(gstin: '27AAPFU0939F1ZV'),
          business(stateCode: 27),
        ),
        27,
      );
      expect(derivePlaceOfSupply(customer(), business(stateCode: 27)), 27);
    });

    test('customer state code prefers the explicit value over the GSTIN', () {
      expect(
        customerStateCode(customer(stateCode: 29, gstin: '27AAPFU0939F1ZV')),
        29,
      );
    });
  });

  group('HsnRateRefresh', () {
    test('seeds the post-2025 garment rate while keeping history', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);
      final container = ProviderContainer(
        overrides: [databaseProvider.overrideWithValue(database)],
      );
      addTearDown(container.dispose);

      await container.read(hsnSeedProvider.future);

      final current = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
      );
      final historical = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2020, 1, 1),
      );

      expect(current?.gstRate, 5.0);
      expect(historical?.gstRate, 12.0);

      final lowValue = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
        unitPrice: 1000,
      );
      final highValue = await database.hsnDao.getHsnCodeByCode(
        '6203',
        asOf: DateTime(2026, 6, 30),
        unitPrice: 3000,
      );

      expect(lowValue?.gstRate, 5.0);
      expect(highValue?.gstRate, 18.0);
    });
  });

  group('InvoiceType', () {
    test('tax invoice with GST, bill of supply without', () {
      expect(invoiceTypeForGst(isGstEnabled: true), 'TAX_INVOICE');
      expect(invoiceTypeForGst(isGstEnabled: false), 'BILL_OF_SUPPLY');
    });
  });

  group('DocumentTotals', () {
    test('sums lines, applies the discount and rounds the payable', () {
      final totals = computeDocumentTotals([
        (
          gross: 200.0,
          discount: 20.0,
          taxable: 180.0,
          cgst: 16.2,
          sgst: 16.2,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 200);
      expect(totals.discount, 20);
      expect(totals.taxable, 180);
      expect(totals.cgst, 16.2);
      // 180 + 16.2 + 16.2 = 212.4, rounded to the rupee.
      expect(totals.grandTotal, 212);
      expect(totals.roundOff, closeTo(-0.4, 0.0001));
    });

    test('without a discount the subtotal equals the taxable amount', () {
      final totals = computeDocumentTotals([
        (
          gross: 100.0,
          discount: 0.0,
          taxable: 100.0,
          cgst: 9.0,
          sgst: 9.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 100);
      expect(totals.discount, 0);
      expect(totals.grandTotal, 118);
      expect(totals.roundOff, 0);
    });

    test('adds TCS and deducts TDS from the payable', () {      final totals = computeDocumentTotals([
        (
          gross: 1000.0,
          discount: 0.0,
          taxable: 1000.0,
          cgst: 90.0,
          sgst: 90.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ], tcsAmount: 10, tdsAmount: 50);

      expect(totals.tcsAmount, 10);
      expect(totals.tdsAmount, 50);
      // 1000 + 180 + 10 - 50 = 1140
      expect(totals.grandTotal, 1140);
      expect(totals.roundOff, 0);
    });

    test('skips the round off when it is disabled', () {
      final lines = [
        (
          gross: 100.40,
          discount: 0.0,
          taxable: 100.40,
          cgst: 9.04,
          sgst: 9.04,
          igst: 0.0,
          cess: 0.0,
        ),
      ];

      final rounded = computeDocumentTotals(lines);
      expect(rounded.grandTotal, 118);
      expect(rounded.roundOff, closeTo(-0.48, 0.0001));

      final exact = computeDocumentTotals(lines, applyRoundOff: false);
      expect(exact.grandTotal, 118.48);
      expect(exact.roundOff, 0);
    });

    test('rounds every component to paise', () {
      final totals = computeDocumentTotals([
        (
          gross: 33.33,
          discount: 0.0,
          taxable: 33.33,
          cgst: 3.0,
          sgst: 3.0,
          igst: 0.0,
          cess: 0.0,
        ),
        (
          gross: 0.01,
          discount: 0.0,
          taxable: 0.01,
          cgst: 0.0,
          sgst: 0.0,
          igst: 0.0,
          cess: 0.0,
        ),
      ]);

      expect(totals.subtotal, 33.34);
      expect(totals.taxable, 33.34);
    });
  });

  group('GstStates', () {
    test('labels a state code with its name', () {
      expect(GstStates.labelFor(24), 'Gujarat (24)');
      expect(GstStates.labelFor(27), 'Maharashtra (27)');
      expect(GstStates.labelFor(null), '');
      expect(GstStates.labelFor(999), 'State 999');
    });
  });
}
