import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import 'database_provider.dart';

final uomListProvider = FutureProvider<List<Uom>>((ref) async {
  final dao = ref.watch(uomDaoProvider);
  return dao.listActiveUoms();
});

final uomCatalogProvider = FutureProvider<List<Uom>>((ref) async {
  final dao = ref.watch(uomDaoProvider);
  return dao.listAllUoms();
});

final uomSeedProvider = FutureProvider<void>((ref) async {
  final dao = ref.watch(uomDaoProvider);

  final seedData = [
    UomsCompanion.insert(code: 'PCS', name: 'Pieces').copyWith(
      family: const Value('COUNT'),
      baseCode: const Value<String?>(null),
      conversionFactor: const Value(1.0),
      sortOrder: const Value(0),
    ),
    UomsCompanion.insert(code: 'KG', name: 'Kilograms').copyWith(
      family: const Value('MASS'),
      baseCode: const Value<String?>('KG'),
      conversionFactor: const Value(1.0),
      sortOrder: const Value(1),
    ),
    UomsCompanion.insert(code: 'GRM', name: 'Grams').copyWith(
      family: const Value('MASS'),
      baseCode: const Value<String?>('KG'),
      conversionFactor: const Value(0.001),
      sortOrder: const Value(2),
    ),
    UomsCompanion.insert(code: 'MTR', name: 'Meters').copyWith(
      family: const Value('LENGTH'),
      baseCode: const Value<String?>('MTR'),
      conversionFactor: const Value(1.0),
      sortOrder: const Value(3),
    ),
    UomsCompanion.insert(code: 'CM', name: 'Centimeters').copyWith(
      family: const Value('LENGTH'),
      baseCode: const Value<String?>('MTR'),
      conversionFactor: const Value(0.01),
      sortOrder: const Value(4),
    ),
    UomsCompanion.insert(code: 'LTR', name: 'Litres').copyWith(
      family: const Value('VOLUME'),
      baseCode: const Value<String?>('LTR'),
      conversionFactor: const Value(1.0),
      sortOrder: const Value(5),
    ),
    UomsCompanion.insert(code: 'ML', name: 'Millilitres').copyWith(
      family: const Value('VOLUME'),
      baseCode: const Value<String?>('LTR'),
      conversionFactor: const Value(0.001),
      sortOrder: const Value(6),
    ),
    UomsCompanion.insert(code: 'BOX', name: 'Box').copyWith(
      family: const Value('COUNT'),
      baseCode: const Value<String?>('PCS'),
      conversionFactor: const Value(10.0),
      sortOrder: const Value(7),
    ),
    UomsCompanion.insert(code: 'NOS', name: 'Nos').copyWith(
      family: const Value('COUNT'),
      baseCode: const Value<String?>('PCS'),
      conversionFactor: const Value(1.0),
      sortOrder: const Value(8),
    ),
  ];

  await dao.seedInitialUoms(seedData);
});
