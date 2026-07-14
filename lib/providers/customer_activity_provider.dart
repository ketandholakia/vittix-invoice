import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final customerActivityProvider =
    FutureProvider.family<List<CustomerActivityEvent>, int>((ref, customerId) async {
  return ref.watch(customerActivityDaoProvider).getEventsForCustomer(customerId);
});
