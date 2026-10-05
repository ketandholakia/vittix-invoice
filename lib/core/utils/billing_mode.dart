import '../../database/tables/businesses.dart';
import 'invoice_type.dart';

/// Whether a business charges GST on its documents.
///
/// GST is charged only when the global GST feature toggle is on AND the
/// business is a regular registered dealer. Composition-scheme dealers are
/// not permitted to collect tax, and unregistered dealers issue no tax —
/// both bill with Bills of Supply.
bool chargesGstForBusiness(
  BusinessType? businessType, {
  required bool gstFeaturesEnabled,
}) =>
    gstFeaturesEnabled && businessType == BusinessType.gstRegistered;

/// The document type a business issues for a supply: a tax invoice when GST
/// is charged, otherwise a bill of supply.
String documentTypeForBusiness(
  BusinessType? businessType, {
  required bool gstFeaturesEnabled,
}) =>
    invoiceTypeForGst(
      isGstEnabled: chargesGstForBusiness(
        businessType,
        gstFeaturesEnabled: gstFeaturesEnabled,
      ),
    );

/// The statutory declaration printed on a composition dealer's bill of supply.
const String compositionDeclaration =
    'Composition taxable person, not eligible to collect taxes on supplies.';
