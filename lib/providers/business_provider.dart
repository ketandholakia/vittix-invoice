import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return dao.updateBusiness(business);
  }

  Future<void> deleteBusiness(int id) async {
    final dao = _ref.read(businessDaoProvider);
    await dao.deleteBusiness(id);
  }
}