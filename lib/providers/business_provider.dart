import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/utils/invoice_number.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final businessListProvider = StreamProvider.autoDispose<List<Business>>(
  (ref) => ref.watch(businessDaoProvider).watchAllBusinesses(),
);

final activeBusinessProvider = StreamProvider.autoDispose<Business?>((ref) {
  final activeBusinessId = ref.watch(activeBusinessIdProvider);
  if (activeBusinessId == null) {
    return Stream.value(null);
  }

  return ref.watch(businessDaoProvider).watchBusinessById(activeBusinessId);
});

final businessDetailProvider =
    StreamProvider.autoDispose.family<Business?, int>(
      (ref, businessId) =>
          ref.watch(businessDaoProvider).watchBusinessById(businessId),
    );

final businessProvider = Provider<BusinessNotifier>((ref) {
  return BusinessNotifier(ref);
});

class BusinessNotifier {
  final Ref _ref;

  BusinessNotifier(this._ref);

  Future<int> addBusiness(BusinessesCompanion business) async {
    final dao = _ref.read(businessDaoProvider);
    return dao.insertBusiness(business);
  }

  Future<bool> updateBusiness(Business business) async {
    final dao = _ref.read(businessDaoProvider);

    // Every save of the series formats runs the GST numbering validation —
    // not only the document numbering screen. Formats already stored before
    // the rules existed are left alone so legacy businesses keep working.
    final existing = await dao.getBusinessById(business.id);
    if (existing != null) {
      final changedFormats = <String, String>{
        if (business.invoiceSeriesFormat != existing.invoiceSeriesFormat)
          'Invoice series format': business.invoiceSeriesFormat,
        if (business.quoteSeriesFormat != existing.quoteSeriesFormat)
          'Quote series format': business.quoteSeriesFormat,
        if (business.creditNoteSeriesFormat != existing.creditNoteSeriesFormat)
          'Credit note series format': business.creditNoteSeriesFormat,
        if (business.debitNoteSeriesFormat != existing.debitNoteSeriesFormat)
          'Debit note series format': business.debitNoteSeriesFormat,
        if (business.billOfSupplySeriesFormat !=
            existing.billOfSupplySeriesFormat)
          'Bill of Supply series format': business.billOfSupplySeriesFormat,
      };
      for (final entry in changedFormats.entries) {
        final issue = InvoiceNumberGenerator.validateFormat(entry.value);
        if (issue != null) {
          throw Exception('${entry.key}: $issue');
        }
      }
    }

    return dao.updateBusiness(business);
  }

  Future<void> deleteBusiness(int id) async {
    final dao = _ref.read(businessDaoProvider);
    await dao.deleteBusiness(id);
  }
}