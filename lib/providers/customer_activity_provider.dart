import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final customerActivityProvider =
    StreamProvider.autoDispose.family<List<CustomerActivityEvent>, int>(
      (ref, customerId) => ref
          .watch(customerActivityDaoProvider)
          .watchEventsForCustomer(customerId),
    );