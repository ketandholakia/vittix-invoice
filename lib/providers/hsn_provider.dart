import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/models/hsn_code_lookup.dart';
import 'database_provider.dart';

final hsnSearchQueryProvider = StateProvider<String>((ref) => '');

final hsnListProvider =
    FutureProvider.autoDispose.family<List<HsnCodeLookup>, DateTime?>((ref, asOf) async {
  final query = ref.watch(hsnSearchQueryProvider);
  final dao = ref.watch(hsnDaoProvider);
  return dao.searchHsnCodes(query, asOf: asOf);
});

final hsnRateVersionsProvider =
    FutureProvider.autoDispose.family<List<HsnCodeRate>, String>((ref, code) async {
  final dao = ref.watch(hsnDaoProvider);
  return dao.listHsnCodeRates(code);
});

final hsnSeedProvider = FutureProvider.autoDispose<void>((ref) async {
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
    HsnCodesCompanion.insert(
      code: '1006',
      description: 'Rice',
    ),
    HsnCodesCompanion.insert(
      code: '4901',
      description: 'Printed books (Nil rated)',
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
    // Verified against the CBIC rate schedule: rice is 5% and printed books
    // (4901) are Nil rated. The seeded catalogue is deliberately small — treat
    // it as a starting point and add your own codes/rates for anything else.
    HsnCodeRatesCompanion.insert(
      code: '1006',
      gstRate: const drift.Value(5.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    HsnCodeRatesCompanion.insert(
      code: '4901',
      gstRate: const drift.Value(0.0),
      effectiveFrom: DateTime(2017, 7, 1),
    ),
    // Reviewed against the 22 Sep 2025 GST rate revision. Telephones (8517),
    // computers (8471) and SAC 9983 services remain 18%. For readymade
    // garments the 12% slab was removed: 5% up to Rs.2,500 per piece and 18%
    // above, so both garment codes are seeded as two price bands.
    HsnCodeRatesCompanion.insert(
      code: '6109',
      gstRate: const drift.Value(5.0),
      effectiveFrom: DateTime(2025, 9, 22),
      maxUnitPrice: const drift.Value(2500.0),
    ),
    HsnCodeRatesCompanion.insert(
      code: '6109',
      gstRate: const drift.Value(18.0),
      effectiveFrom: DateTime(2025, 9, 22),
      minUnitPrice: const drift.Value(2500.0),
    ),
    HsnCodeRatesCompanion.insert(
      code: '6203',
      gstRate: const drift.Value(5.0),
      effectiveFrom: DateTime(2025, 9, 22),
      maxUnitPrice: const drift.Value(2500.0),
    ),
    HsnCodeRatesCompanion.insert(
      code: '6203',
      gstRate: const drift.Value(18.0),
      effectiveFrom: DateTime(2025, 9, 22),
      minUnitPrice: const drift.Value(2500.0),
    ),
  ];

  await dao.seedInitialHsnCodes(seedData, rateSeedData);
});
