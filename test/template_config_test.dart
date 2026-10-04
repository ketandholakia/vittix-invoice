import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/models/invoice_template_config.dart';

void main() {
  group('InvoiceTemplateConfig JSON compatibility', () {
    test('defaults round-trip through encode/decode byte-for-field', () {
      final config = InvoiceTemplateConfig.defaults(
        id: 'tpl-1',
        name: 'Shop Invoice',
        layoutFamily: 'MODERN',
      );
      final decoded = InvoiceTemplateConfig.decode(config.encode());

      expect(decoded.id, config.id);
      expect(decoded.layoutFamily, 'MODERN');
      expect(decoded.itemColumns, config.itemColumns);
      expect(decoded.watermarkText, isNull);
      expect(decoded.footerText, isNull);
      expect(decoded.tableBorderStyle, 'FULL');
      expect(decoded.showDueDate, isTrue);
    });

    test('a customized template round-trips every extended field', () {
      final config = InvoiceTemplateConfig.defaults(id: 't', name: 'T')
          .copyWith(
            paperSize: 'a5',
            primaryColor: '#3730A3',
            watermarkText: 'PAID',
            footerText: 'Thanks!',
            tableBorderStyle: 'ROWS_ONLY',
            borderThickness: 0.5,
            headerDensity: 'SPACIOUS',
            showQrCode: true,
            showAmountInWords: false,
            itemColumns: const ['item', 'qty', 'amount'],
            titleLabel: 'BILL OF SUPPLY',
          );
      final decoded = InvoiceTemplateConfig.decode(config.encode());

      expect(decoded.paperSize, 'a5');
      expect(decoded.watermarkText, 'PAID');
      expect(decoded.footerText, 'Thanks!');
      expect(decoded.tableBorderStyle, 'ROWS_ONLY');
      expect(decoded.borderThickness, 0.5);
      expect(decoded.headerDensity, 'SPACIOUS');
      expect(decoded.showQrCode, isTrue);
      expect(decoded.showAmountInWords, isFalse);
      expect(decoded.itemColumns, ['item', 'qty', 'amount']);
      expect(decoded.titleLabel, 'BILL OF SUPPLY');
    });

    test('legacy JSON missing newer keys fills compatibility defaults', () {
      // Template configs are stored as JSON blobs, so a config saved before a
      // field existed must decode with that field's default instead of
      // crashing or silently nulling non-null fields.
      final legacy = jsonEncode({
        'id': 'old-1',
        'name': 'Old Template',
        'paperSize': 'a4',
        'primaryColor': '#1E88E5',
        'accentColor': '#E3F2FD',
        'showLogo': true,
        'showGst': true,
        'showHsn': true,
        'showBankDetails': true,
        'showSignature': true,
        'showQrCode': false,
        'itemColumns': ['item', 'qty'],
        'titleLabel': 'TAX INVOICE',
        'invoiceNoLabel': 'Invoice No',
        'dateLabel': 'Date',
        'billToLabel': 'Bill To',
        'termsText': '',
        'layoutFamily': 'CLASSIC',
        'layoutSpacing': 12,
        'borderThickness': 1,
        'headerDensity': 'COMFORTABLE',
      });
      final decoded = InvoiceTemplateConfig.decode(legacy);

      expect(decoded.showDueDate, isTrue);
      expect(decoded.showPlaceOfSupply, isTrue);
      expect(decoded.showAmountInWords, isTrue);
      expect(decoded.tableBorderStyle, 'FULL');
      expect(decoded.watermarkText, isNull);
      expect(decoded.footerText, isNull);
      expect(decoded.fontFamily, isNull);
    });

    test('copyWith leaves every other field untouched', () {
      final base = InvoiceTemplateConfig.defaults(id: 't', name: 'T');
      final copy = base.copyWith(watermarkText: 'DRAFT');

      expect(copy.watermarkText, 'DRAFT');
      expect(copy.id, base.id);
      expect(copy.layoutFamily, base.layoutFamily);
      // The original is not mutated.
      expect(base.watermarkText, isNull);
    });
  });
}
