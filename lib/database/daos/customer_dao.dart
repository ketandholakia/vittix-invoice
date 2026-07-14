import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/customers.dart';

part 'customer_dao.g.dart';

@DriftAccessor(tables: [Customers])
class CustomerDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerDaoMixin {
  CustomerDao(super.db);

  Future<List<Customer>> getCustomersForBusiness(int businessId) =>
      (select(customers)..where((t) => t.businessId.equals(businessId))).get();

  Future<Customer?> getCustomerById(int id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<int> insertCustomer(CustomersCompanion customer) =>
      into(customers).insert(customer);
  Future<bool> updateCustomer(Customer customer) =>
      update(customers).replace(customer);
  Future<int> deleteCustomer(int id) =>
      (delete(customers)..where((t) => t.id.equals(id))).go();
}
