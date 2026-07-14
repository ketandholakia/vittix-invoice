import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final customerListProvider = FutureProvider<List<Customer>>((ref) async {
  final dao = ref.watch(customerDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return [];
  return dao.getCustomersForBusiness(activeBusinessId);
});

final customerProvider = Provider<CustomerNotifier>((ref) {
  return CustomerNotifier(ref);
});

class CustomerNotifier {
  final Ref _ref;

  CustomerNotifier(this._ref);

  Future<int> addCustomer(CustomersCompanion customer) async {
    final dao = _ref.read(customerDaoProvider);
    final id = await dao.insertCustomer(customer);
    _ref.invalidate(customerListProvider);
    return id;
  }

  Future<bool> updateCustomer(Customer customer) async {
    final dao = _ref.read(customerDaoProvider);
    final success = await dao.updateCustomer(customer);
    _ref.invalidate(customerListProvider);
    return success;
  }

  Future<void> deleteCustomer(int id) async {
    final dao = _ref.read(customerDaoProvider);
    await dao.deleteCustomer(id);
    _ref.invalidate(customerListProvider);
  }
}
