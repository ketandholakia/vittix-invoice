import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final businessDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).businessDao,
);
final customerDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).customerDao,
);
final productDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).productDao,
);
final invoiceDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).invoiceDao,
);
final quoteDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).quoteDao,
);
final customerActivityDaoProvider = Provider(
  (ref) => ref.watch(databaseProvider).customerActivityDao,
);
final hsnDaoProvider = Provider((ref) => ref.watch(databaseProvider).hsnDao);
final uomDaoProvider = Provider((ref) => ref.watch(databaseProvider).uomDao);
final templateConfigDaoProvider =
    Provider((ref) => ref.watch(databaseProvider).templateConfigDao);
