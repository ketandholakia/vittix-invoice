import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/businesses.dart';

part 'business_dao.g.dart';

@DriftAccessor(tables: [Businesses])
class BusinessDao extends DatabaseAccessor<AppDatabase>
    with _$BusinessDaoMixin {
  BusinessDao(super.db);

  Future<List<Business>> getAllBusinesses() => select(businesses).get();
  Future<Business?> getBusinessById(int id) =>
      (select(businesses)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertBusiness(BusinessesCompanion business) =>
      into(businesses).insert(business);
  Future<bool> updateBusiness(Business business) =>
      update(businesses).replace(business);
  Future<int> deleteBusiness(int id) =>
      (delete(businesses)..where((t) => t.id.equals(id))).go();
}
