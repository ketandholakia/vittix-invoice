import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final businessListProvider = FutureProvider<List<Business>>((ref) async {
  final dao = ref.watch(businessDaoProvider);
  return dao.getAllBusinesses();
});

final activeBusinessProvider = FutureProvider<Business?>((ref) async {
  final activeBusinessId = ref.watch(activeBusinessIdProvider);
  if (activeBusinessId == null) {
    return null;
  }

  return ref.watch(businessDaoProvider).getBusinessById(activeBusinessId);
});

final businessProvider = Provider<BusinessNotifier>((ref) {
  return BusinessNotifier(ref);
});

class BusinessNotifier {
  final Ref _ref;

  BusinessNotifier(this._ref);

  Future<int> addBusiness(BusinessesCompanion business) async {
    final dao = _ref.read(businessDaoProvider);
    final id = await dao.insertBusiness(business);
    _ref.invalidate(businessListProvider);
    return id;
  }

  Future<bool> updateBusiness(Business business) async {
    final dao = _ref.read(businessDaoProvider);
    final success = await dao.updateBusiness(business);
    _ref.invalidate(businessListProvider);
    return success;
  }

  Future<void> deleteBusiness(int id) async {
    final dao = _ref.read(businessDaoProvider);
    await dao.deleteBusiness(id);
    _ref.invalidate(businessListProvider);
  }
}
