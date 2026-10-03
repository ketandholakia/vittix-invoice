import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';
import 'shared_preferences_provider.dart';

final customerListProvider =
    StreamProvider.autoDispose<List<Customer>>((ref) {
  final dao = ref.watch(customerDaoProvider);
  final activeBusinessId = ref.watch(activeBusinessIdProvider);

  if (activeBusinessId == null) return Stream.value(const []);
  return dao.watchCustomersForBusiness(activeBusinessId);
});

final customerProvider = Provider<CustomerNotifier>((ref) {
  return CustomerNotifier(ref);
});

class CustomerNotifier {
  final Ref _ref;

  CustomerNotifier(this._ref);

  Future<int> addCustomer(CustomersCompanion customer) async {
    final dao = _ref.read(customerDaoProvider);
    return dao.insertCustomer(customer);
  }

  Future<bool> updateCustomer(Customer customer) async {
    final dao = _ref.read(customerDaoProvider);
    return dao.updateCustomer(customer);
  }

  Future<void> deleteCustomer(int id) async {
    final dao = _ref.read(customerDaoProvider);
    await dao.deleteCustomer(id);
  }
}