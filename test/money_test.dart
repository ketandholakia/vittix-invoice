
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/amount_in_words.dart';
import 'package:vittix_invoice/core/utils/formatting.dart';
import 'package:vittix_invoice/core/utils/gst_calculator.dart';
import 'package:vittix_invoice/core/utils/invoice_balance.dart';
import 'package:vittix_invoice/core/utils/money.dart';
import 'package:vittix_invoice/database/app_database.dart';

void main() {
  group('DateFormatting', () {
    test('numeric Indian format is dd-MM-yyyy', () {
      expect(formatDateNumeric(DateTime(2026, 7, 5)), '05-07-2026');
      expect(formatDateNumeric(DateTime(2026, 12, 31)), '31-12-2026');
    });
  });

  group('AmountInWords', () {
    test('zero amount', () {
      expect(AmountInWords.convert(0), 'Zero Rupees Only');
    });

    test('amounts below one rupee keep paise', () {
      expect(
        AmountInWords.convert(0.99),
        'Zero Rupees and Ninety Nine Paise Only',
      );
    });

    test('singular rupee', () {
      expect(AmountInWords.convert(1), 'One Rupee Only');
      expect(AmountInWords.convert(1.01), 'One Rupee and One Paise Only');
    });

    test('rounds binary doubles to paise like the form display', () {
      // 1.995*100 lands on 199.5, so both the stored value and the words use
      // the same rounded double: 2.00.
      expect(round2(1.995), 2.0);
      expect(AmountInWords.convert(round2(1.995)), 'Two Rupees Only');
      expect(AmountInWords.convert(round2(1.994)), 'One Rupee and Ninety Nine Paise Only');
      expect(AmountInWords.convert(2.5), 'Two Rupees and Fifty Paise Only');
    });

    test('hundreds, thousands, lakhs and crores', () {
      expect(AmountInWords.convert(100), 'One Hundred Rupees Only');
      expect(
        AmountInWords.convert(10500),
        'Ten Thousand Five Hundred Rupees Only',
      );
      expect(
        AmountInWords.convert(123456),
        'One Lakh Twenty Three Thousand Four Hundred Fifty Six Rupees Only',
      );
      expect(
        AmountInWords.convert(99999999.99),
        'Nine Crore Ninety Nine Lakh Ninety Nine Thousand '
        'Nine Hundred Ninety Nine Rupees and Ninety Nine Paise Only',
      );
    });
  });

  group('MoneyRounding', () {
    test('round2 rounds to paise', () {
      expect(round2(123.3333333), 123.33);
      expect(round2(123.336), 123.34);
      expect(round2(0.004), 0.0);
    });

    test('GstCalculator rounds intra-state components to paise', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(breakdown.cgst, 3.00);
      expect(breakdown.sgst, 3.00);
      expect(breakdown.igst, 0);
      expect(breakdown.total, 39.33);
    });

    test('GstCalculator rounds inter-state IGST and cess to paise', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 100.01,
        gstRate: 12,
        isInterState: true,
        cessRate: 1,
      );
      expect(breakdown.igst, 12.00);
      expect(breakdown.cess, 1.00);
      expect(breakdown.total, 113.01);
    });

    test('total always equals the rounded sum of components', () {
      final breakdown = GstCalculator.calculate(
        taxableAmount: 33.33,
        gstRate: 18,
        isInterState: false,
      );
      expect(
        breakdown.total,
        round2(33.33 + breakdown.cgst + breakdown.sgst + breakdown.cess),
      );
    });
  });

  group('RoundOff', () {
    test('adjusts a total to the nearest whole rupee', () {
      expect(roundOffForTotal(1180.0), 0);
      expect(roundOffForTotal(1180.4), -0.4);
      expect(roundOffForTotal(1180.5), 0.5);
      expect(roundOffForTotal(1180.6), 0.4);
      expect(payableTotal(1180.4), 1180);
      expect(payableTotal(1180.5), 1181);
    });

    test('round off plus the exact total equals the payable amount', () {
      for (final total in [0.0, 99.99, 100.5, 1234.49, 99999.99]) {
        expect(round2(total + roundOffForTotal(total)), payableTotal(total));
      }
    });
  });

  group('InvoiceBalance', () {
    Invoice invoiceWith({
      required double total,
      required double paid,
      String currencyCode = 'INR',
    }) {
      return Invoice(
        id: 1,
        businessId: 1,
        customerId: 1,
        invoiceNumber: 'INV-2627-0001',
        currencyCode: currencyCode,
        invoiceDate: DateTime(2026, 6, 30),
        invoiceType: 'TAX_INVOICE',
        supplyType: 'B2B',
        placeOfSupply: 27,
        subtotal: total,
        discountAmount: 0,
        taxableAmount: total,
        cgstAmount: 0,
        sgstAmount: 0,
        igstAmount: 0,
        cessAmount: 0,
        totalAmount: total,
        roundOffAmount: 0,
        amountPaid: paid,
        status: 'DRAFT',
        isIgst: false,
        reverseCharge: false,
        exportWithLut: false,
        tdsRate: 0,
        tdsAmount: 0,
        tcsRate: 0,
        tcsAmount: 0,
        createdAt: DateTime(2026, 6, 30),
        updatedAt: DateTime(2026, 6, 30),
      );
    }

    test('balance clamps at zero for paid-in-full invoices', () {
      expect(invoiceWith(total: 100, paid: 100).amountPaid, 100);
      expect(invoiceBalanceDue(invoiceWith(total: 100, paid: 100)), 0);
    });

    test('overpayment is reported separately from balance', () {
      final overpaid = invoiceWith(total: 100, paid: 150);
      expect(invoiceBalanceDue(overpaid), 0);
      expect(invoiceOverpaidAmount(overpaid), 50);
    });

    test('partial payments leave the exact balance due', () {
      expect(invoiceBalanceDue(invoiceWith(total: 250.5, paid: 100.25)), 150.25);
    });

    test('balance math is currency-agnostic', () {
      final usd = invoiceWith(total: 500, paid: 200, currencyCode: 'USD');
      expect(usd.currencyCode, 'USD');
      expect(invoiceBalanceDue(usd), 300);
      final eur = invoiceWith(total: 1000, paid: 1200, currencyCode: 'EUR');
      expect(invoiceOverpaidAmount(eur), 200);
    });
  });
}
