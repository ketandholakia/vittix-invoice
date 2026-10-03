import 'package:drift/drift.dart';
import '../app_database.dart';
import '../models/hsn_code_lookup.dart';
import '../tables/hsn_code_rates.dart';
import '../tables/hsn_codes.dart';

part 'hsn_dao.g.dart';

@DriftAccessor(tables: [HsnCodes, HsnCodeRates])
class HsnDao extends DatabaseAccessor<AppDatabase> with _$HsnDaoMixin {
  HsnDao(super.db);

  Future<List<HsnCodeLookup>> searchHsnCodes(
    String query, {
    DateTime? asOf,
    double? unitPrice,
  }) async {
    final normalizedAsOf = asOf ?? DateTime.now();
    final baseQuery = select(hsnCodes);

    if (query.isEmpty) {
      baseQuery.limit(50);
    } else {
      baseQuery.where(
        (t) => t.code.like('%$query%') | t.description.like('%$query%'),
      );
      baseQuery.limit(50);
    }

    final codes = await (baseQuery
          ..orderBy([(t) => OrderingTerm(expression: t.code)]))
        .get();

    final lookups = await Future.wait(
      codes.map((code) async {
        final latestRate = await _latestRateForCode(
          code.code,
          asOf: normalizedAsOf,
          unitPrice: unitPrice,
        );
        return HsnCodeLookup(
          code: code.code,
          description: code.description,
          type: code.type,
          gstRate: latestRate?.gstRate,
          effectiveFrom: latestRate?.effectiveFrom,
          minUnitPrice: latestRate?.minUnitPrice,
          maxUnitPrice: latestRate?.maxUnitPrice,
        );
      }),
    );

    return lookups;
  }

  Future<HsnCodeLookup?> getHsnCodeByCode(
    String code, {
    DateTime? asOf,
    double? unitPrice,
  }) async {
    final matches = await searchHsnCodes(code, asOf: asOf, unitPrice: unitPrice);
    for (final match in matches) {
      if (match.code == code) {
        return match;
      }
    }
    return null;
  }

  Future<void> seedInitialHsnCodes(
    List<HsnCodesCompanion> codes,
    List<HsnCodeRatesCompanion> rates,
  ) async {
    await batch((batch) {
      batch.insertAll(hsnCodes, codes, mode: InsertMode.insertOrIgnore);
      batch.insertAll(hsnCodeRates, rates, mode: InsertMode.insertOrIgnore);
    });
  }

  Future<List<HsnCodeRate>> listHsnCodeRates(String code) {
    return (select(hsnCodeRates)
          ..where((t) => t.code.equals(code))
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.effectiveFrom,
              mode: OrderingMode.desc,
            ),
          ]))
        .get();
  }

  Future<void> addHsnCodeRate({
    required String code,
    required double gstRate,
    required DateTime effectiveFrom,
  }) {
    return into(hsnCodeRates).insert(
      HsnCodeRatesCompanion.insert(
        code: code,
        gstRate: Value(gstRate),
        effectiveFrom: effectiveFrom,
      ),
    );
  }

  Future<HsnCodeRate?> _latestRateForCode(
    String code, {
    required DateTime asOf,
    double? unitPrice,
  }) {
    return (select(hsnCodeRates)
          ..where(
            (t) =>
                t.code.equals(code) &
                t.effectiveFrom.isSmallerOrEqualValue(asOf) &
                (unitPrice == null
                    // No price supplied: fall back to the base band so the
                    // lookup still returns a representative rate.
                    ? t.minUnitPrice.equals(0)
                    : t.minUnitPrice.isSmallerThanValue(unitPrice) &
                          t.maxUnitPrice.isBiggerOrEqualValue(unitPrice)),
          )
          ..orderBy([
            (t) => OrderingTerm(
              expression: t.effectiveFrom,
              mode: OrderingMode.desc,
            ),
          ])
          ..limit(1))
        .getSingleOrNull();
  }
}
