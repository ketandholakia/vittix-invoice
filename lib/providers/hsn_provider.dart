import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/models/hsn_code_lookup.dart';
import 'database_provider.dart';

final hsnSearchQueryProvider = StateProvider<String>((ref) => '');

final hsnListProvider =
    FutureProvider.family<List<HsnCodeLookup>, DateTime?>((ref, asOf) async {
  final query = ref.watch(hsnSearchQueryProvider);
  final dao = ref.watch(hsnDaoProvider);
  return dao.searchHsnCodes(query, asOf: asOf);
});

final hsnRateVersionsProvider =
    FutureProvider.family<List<HsnCodeRate>, String>((ref, code) async {
  final dao = ref.watch(hsnDaoProvider);
  return dao.listHsnCodeRates(code);
});

final hsnSeedProvider = FutureProvider<void>((ref) async {
  final dao = ref.watch(hsnDaoProvider);

  // Basic seed logic for common items
  final seedData = [
    HsnCodesCompanion.insert(
      code: '8517',
      description: 'Telephones and mobile phones',
    ),
    HsnCodesCompanion.insert(
      code: '8471',
      description: 'Computers and laptops',
    ),
    HsnCodesCompanion.insert(
      code: '6109',
      description: 'T-shirts and vests',
    ),
    HsnCodesCompanion.insert(
      code: '6203',
      description: 'Men\'s suits and trousers',
    ),
    HsnCodesCompanion.insert(
      code: '9983',
      description: 'IT and accounting services (SAC)',
      type: const drift.Value('SAC'),
    ),
  ];

  final rateSeedData = [
    HsnCodeRatesCompanion.insert(
      code: '8517',
      gstRate: const drift.Value(18.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    HsnCodeRatesCompanion.insert(
      code: '8471',
      gstRate: const drift.Value(18.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    HsnCodeRatesCompanion.insert(
      code: '6109',
      gstRate: const drift.Value(5.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    HsnCodeRatesCompanion.insert(
      code: '6203',
      gstRate: const drift.Value(12.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    HsnCodeRatesCompanion.insert(
      code: '9983',
      gstRate: const drift.Value(18.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
  ];

  await dao.seedInitialHsnCodes(seedData, rateSeedData);
});
