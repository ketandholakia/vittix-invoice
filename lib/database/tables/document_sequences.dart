import 'package:drift/drift.dart';
import 'businesses.dart';

/// Per-business, per-document-type, per-financial-year sequence counters.
///
/// Replaces the legacy in-memory scan of every document number (which was
/// O(N) per allocation) with an O(1) counter. The counter is bumped inside
/// the same transaction that inserts the document, so SQLite serializes
/// concurrent allocations within the app. Keys mirror the legacy scan
/// semantics exactly: counters are scoped by business, document type,
/// financial year (from the document date), and the normalized series
/// format, so backdated documents and mid-year format changes behave the
/// same as before.
@DataClassName('DocumentSequence')
class DocumentSequences extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get businessId => integer().references(Businesses, #id)();
  TextColumn get docType => text()(); // INV | QT
  TextColumn get fiscalYear => text()(); // e.g. 2627
  TextColumn get format => text()();
  IntColumn get sequence => integer().withDefault(const Constant(0))();

  @override
  List<Set<Column<Object>>> get uniqueKeys => [
    {businessId, docType, fiscalYear, format},
  ];
}
