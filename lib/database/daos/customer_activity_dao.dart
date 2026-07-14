import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/customer_activity_events.dart';

part 'customer_activity_dao.g.dart';

@DriftAccessor(tables: [CustomerActivityEvents])
class CustomerActivityDao extends DatabaseAccessor<AppDatabase>
    with _$CustomerActivityDaoMixin {
  CustomerActivityDao(super.db);

  Future<int> insertEvent(CustomerActivityEventsCompanion event) =>
      into(customerActivityEvents).insert(event);

  Future<List<CustomerActivityEvent>> getEventsForCustomer(int customerId) =>
      (select(customerActivityEvents)
            ..where((t) => t.customerId.equals(customerId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();
}
