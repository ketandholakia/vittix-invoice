import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/pdf.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/tables/businesses.dart';
import 'package:vittix_invoice/models/invoice_template_config.dart';
import 'package:vittix_invoice/services/pdf_layout.dart' as layout;

void main() {
  group('parseColor', () {
    test('parses #RRGGBB into an opaque color', () {
      final color = layout.parseColor('#1E88E5', PdfColors.indigo);
      expect(color.red, 0x1E / 255);
      expect(color.green, 0x88 / 255);
      expect(color.blue, 0xE5 / 255);
      expect(color.alpha, 1);
    });

    test('accepts bare RRGGBB and RRGGBBAA', () {
      final bare = layout.parseColor('FF0000', PdfColors.indigo);
      expect(bare.red, 1);
      expect(bare.alpha, 1);

      final withAlpha = layout.parseColor('#80FF0000', PdfColors.indigo);
      expect(withAlpha.alpha, 0x80 / 255);
      expect(withAlpha.red, 1);
    });

    test('falls back on empty, short, and non-hex input', () {
      const fallback = PdfColors.indigo;
      for (final input in ['', 'xyz', '#12345', '1234567', '#GGHHII']) {
        expect(layout.parseColor(input, fallback), fallback,
            reason: '$input should fall back');
      }
    });
  });

  group('pageFormatFor', () {
    test('maps the three paper sizes and defaults to A4', () {
      expect(layout.pageFormatFor('a4').width, PdfPageFormat.a4.width);
      expect(layout.pageFormatFor('A5').width, PdfPageFormat.a5.width);

      final thermal = layout.pageFormatFor('thermal');
      expect(thermal.width, closeTo(80 * PdfPageFormat.mm, 0.01));
      // A roll with infinite height asserts inside MultiPage, so thermal
      // must stay finite (and tall enough to feel like a receipt).
      expect(thermal.height, lessThan(double.infinity));
      expect(thermal.height, greaterThan(PdfPageFormat.a4.height));

      expect(layout.pageFormatFor('legal').width, PdfPageFormat.a4.width);
      expect(layout.pageFormatFor('').width, PdfPageFormat.a4.width);
    });
  });

  group('brandColorFor', () {
    Business business(int? brandColor) => Business(
      id: 1,
      name: 'B',
      gstin: '27AAPFU0939F1ZV',
      businessType: BusinessType.gstRegistered,
      address: 'a',
      city: 'c',
      stateCode: 27,
      currencyCode: 'INR',
      invoiceTemplate: 'CLASSIC',
      quoteTemplate: 'CLASSIC',
      invoiceSeriesFormat: 'INV-{FY}-{SEQ4}',
      quoteSeriesFormat: 'QT-{FY}-{SEQ4}',
      creditNoteSeriesFormat: 'CN-{FY}-{SEQ4}',
      debitNoteSeriesFormat: 'DN-{FY}-{SEQ4}',
billOfSupplySeriesFormat: 'BOS-{FY}-{SEQ4}',
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      brandColor: brandColor,
    );

    test('template color wins over the business brand color', () {
      final config = InvoiceTemplateConfig.defaults(id: 't', name: 'T')
          .copyWith(primaryColor: '#FF0000');
      expect(
        layout.brandColorFor(business(0xFF00FF00), config).red,
        1,
      );
    });

    test('falls back to the business brand color, then indigo', () {
      // Only an EMPTY template color yields to the business color — the
      // default template ships '#1E88E5', which always wins.
      final noColor = InvoiceTemplateConfig.defaults(id: 't', name: 'T')
          .copyWith(primaryColor: '');

      final fromBusiness =
          layout.brandColorFor(business(0xFF00FF00), noColor);
      expect(fromBusiness.green, 1);

      final indigo = layout.brandColorFor(business(null), noColor);
      expect(indigo, PdfColors.indigo);
    });
  });

  group('density metrics', () {
    test('compact/comfortable/spacious step consistently', () {
      for (final density in ['COMPACT', 'COMFORTABLE', 'SPACIOUS']) {
        expect(
          layout.headerTitleSize(density),
          greaterThan(layout.headerSubtitleSize(density)),
        );
        expect(layout.headerGap(density), inExclusiveRange(0, 20));
      }
      expect(layout.headerTitleSize('COMPACT'), lessThan(layout.headerTitleSize('SPACIOUS')));
      expect(layout.headerGap('UNKNOWN'), layout.headerGap('COMFORTABLE'));
    });
  });

  group('tableBorderFor', () {
    InvoiceTemplateConfig configWith(String style, double thickness) =>
        InvoiceTemplateConfig.defaults(id: 't', name: 'T')
            .copyWith(tableBorderStyle: style, borderThickness: thickness);

    test('FULL draws all sides at the configured thickness', () {
      final border = layout.tableBorderFor(configWith('FULL', 2.5));
      expect(border.top.width, 2.5);
      expect(border.left.width, 2.5);
      expect(border.bottom.width, 2.5);
    });

    test('ROWS_ONLY has no vertical lines', () {
      final border = layout.tableBorderFor(configWith('ROWS_ONLY', 1));
      // Absent sides are BorderSide.none (width 0), not null.
      expect(border.left.width, 0);
      expect(border.right.width, 0);
      expect(border.verticalInside.width, 0);
      expect(border.horizontalInside.width, 1);
      expect(border.bottom.width, 1);
    });

    test('NONE has no lines at all', () {
      final border = layout.tableBorderFor(configWith('NONE', 3));
      expect(border.top.width, 0);
      expect(border.bottom.width, 0);
      // Unknown styles behave as FULL rather than dropping the border.
      expect(layout.tableBorderFor(configWith('DASHED', 1)).top.width, 1);
    });
  });

  group('buildUpiQrPayload', () {
    test('encodes a payable UPI intent URI', () {
      final payload = layout.buildUpiQrPayload(
        businessName: 'Vittix Traders',
        upiId: 'vittix@upi',
        amount: 1234.5,
        invoiceNumber: 'INV-2627-0001',
      );
      expect(payload, startsWith('upi://pay?'));
      expect(payload, contains('pa=vittix%40upi'));
      expect(payload, contains('pn=Vittix%20Traders'));
      expect(payload, contains('tn=Invoice%20INV-2627-0001'));
      expect(payload, contains('am=1234.50'));
      expect(payload, contains('cu=INR'));
    });

    test('degrades to a readable line without a UPI id', () {
      expect(
        layout.buildUpiQrPayload(
          businessName: 'Vittix Traders',
          upiId: '  ',
          amount: 100,
          invoiceNumber: 'INV-1',
        ),
        'Vittix Traders | INV-1 | 100.00',
      );
    });
  });
}
