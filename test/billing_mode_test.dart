import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/billing_mode.dart';
import 'package:vittix_invoice/database/tables/businesses.dart';

void main() {
  group('chargesGstForBusiness', () {
    test('regular dealers charge GST when the feature toggle is on', () {
      expect(
        chargesGstForBusiness(
          BusinessType.gstRegistered,
          gstFeaturesEnabled: true,
        ),
        isTrue,
      );
    });

    test('composition and unregistered dealers never collect tax', () {
      for (final type in [
        BusinessType.compositionScheme,
        BusinessType.unregistered,
        null,
      ]) {
        expect(
          chargesGstForBusiness(type, gstFeaturesEnabled: true),
          isFalse,
          reason: '$type must not charge GST',
        );
      }
    });

    test('the global toggle off means no GST for anyone', () {
      expect(
        chargesGstForBusiness(
          BusinessType.gstRegistered,
          gstFeaturesEnabled: false,
        ),
        isFalse,
      );
    });
  });

  group('documentTypeForBusiness', () {
    test('regular dealer with GST on issues tax invoices', () {
      expect(
        documentTypeForBusiness(
          BusinessType.gstRegistered,
          gstFeaturesEnabled: true,
        ),
        'TAX_INVOICE',
      );
    });

    test('composition and unregistered dealers issue bills of supply', () {
      expect(
        documentTypeForBusiness(
          BusinessType.compositionScheme,
          gstFeaturesEnabled: true,
        ),
        'BILL_OF_SUPPLY',
      );
      expect(
        documentTypeForBusiness(
          BusinessType.unregistered,
          gstFeaturesEnabled: true,
        ),
        'BILL_OF_SUPPLY',
      );
    });
  });
}
