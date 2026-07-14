import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/uoms.dart';

part 'uom_dao.g.dart';

@DriftAccessor(tables: [Uoms])
class UomDao extends DatabaseAccessor<AppDatabase> with _$UomDaoMixin {
  UomDao(super.db);

  Future<List<Uom>> listActiveUoms() {
    return (select(uoms)
          ..where((t) => t.isActive.equals(true))
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.code),
      ]))
        .get();
  }

  Future<Uom?> getUomByCode(String code) {
    return (select(uoms)..where((t) => t.code.equals(code))).getSingleOrNull();
  }

  Future<List<Uom>> listAllUoms() {
    return (select(uoms)
          ..orderBy([
            (t) => OrderingTerm(expression: t.sortOrder),
            (t) => OrderingTerm(expression: t.code),
          ]))
        .get();
  }

  Future<void> upsertUom(UomsCompanion uom) {
    return into(uoms).insertOnConflictUpdate(uom);
  }

  Future<void> seedInitialUoms(List<UomsCompanion> uomData) async {
    await batch((batch) {
      batch.insertAll(uoms, uomData, mode: InsertMode.insertOrIgnore);
    });
  }

  double convertQuantity({
    required double quantity,
    required String fromCode,
    required String toCode,
    required List<Uom> uomCatalog,
  }) {
    if (fromCode == toCode) return quantity;

    final fromUom = uomCatalog.firstWhere(
      (uom) => uom.code == fromCode,
      orElse: () => throw ArgumentError('Unknown source UOM: $fromCode'),
    );
    final toUom = uomCatalog.firstWhere(
      (uom) => uom.code == toCode,
      orElse: () => throw ArgumentError('Unknown target UOM: $toCode'),
    );

    if (fromUom.family != toUom.family) {
      throw ArgumentError('Cannot convert between different UOM families');
    }

    final fromBase = fromUom.baseCode?.trim().isNotEmpty == true
        ? fromUom.conversionFactor
        : 1.0;
    final toBase = toUom.baseCode?.trim().isNotEmpty == true
        ? toUom.conversionFactor
        : 1.0;

    return quantity * fromBase / toBase;
  }
}
