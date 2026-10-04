
import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/database_provider.dart';
import 'package:vittix_invoice/providers/uom_provider.dart';

void main() {
  group('UomDao', () {
    late AppDatabase database;
    late ProviderContainer container;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(database),
        ],
      );

      await container.read(uomSeedProvider.future);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('seeds the default unit of measure catalog', () async {
      final units = await container.read(uomListProvider.future);

      expect(
        units.map((unit) => unit.code).toList(),
        equals(['PCS', 'KG', 'GRM', 'MTR', 'CM', 'LTR', 'ML', 'BOX', 'NOS']),
      );
      expect(units.first.name, 'Pieces');
      expect(units[2].name, 'Grams');
      expect(units.last.name, 'Nos');
    });

    test('converts quantities within the same UOM family', () async {
      final uoms = await container.read(uomCatalogProvider.future);

      expect(
        container.read(uomDaoProvider).convertQuantity(
          quantity: 2500,
          fromCode: 'GRM',
          toCode: 'KG',
          uomCatalog: uoms,
        ),
        2.5,
      );
      expect(
        container.read(uomDaoProvider).convertQuantity(
          quantity: 3,
          fromCode: 'BOX',
          toCode: 'PCS',
          uomCatalog: uoms,
        ),
        30,
      );
    });
  });

  group('HsnDao', () {
    late AppDatabase database;

    setUp(() async {
      database = AppDatabase.forTesting(NativeDatabase.memory());

      await database
          .into(database.hsnCodes)
          .insert(
            HsnCodesCompanion.insert(
              code: '8517',
              description: 'Telephones and mobile phones',
            ),
          );

      await database.batch((batch) {
        batch.insertAll(
          database.hsnCodeRates,
          [
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(18.0),
              effectiveFrom: DateTime(2017, 7, 1),
            ),
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(12.0),
              effectiveFrom: DateTime(2026, 1, 1),
            ),
          ],
        );
      });
    });

    tearDown(() async {
      await database.close();
    });

    test('returns the latest applicable GST rate for the requested date', () async {
      final historical = await database.hsnDao.searchHsnCodes(
        '8517',
        asOf: DateTime(2025, 6, 30),
      );
      final current = await database.hsnDao.searchHsnCodes(
        '8517',
        asOf: DateTime(2026, 6, 30),
      );

      expect(historical.single.gstRate, 18.0);
      expect(current.single.gstRate, 12.0);
    });

    test('stores and lists rate versions in descending effective date order', () async {
      await database.hsnDao.addHsnCodeRate(
        code: '8517',
        gstRate: 5.0,
        effectiveFrom: DateTime(2026, 4, 1),
      );

      final versions = await database.hsnDao.listHsnCodeRates('8517');

      expect(versions.first.gstRate, 5.0);
      expect(versions.first.effectiveFrom, DateTime(2026, 4, 1));
      expect(versions.length, 3);
    });
  });
}
