import 'package:drift/drift.dart' as drift;
import '../database/app_database.dart';
import '../database/daos/customer_activity_dao.dart';
import '../core/utils/document_edit_summary.dart';

/// Typed accessor snapshot of a document row, so the shared flows can read
/// the fields they need without knowing the concrete document type.
typedef DocumentInfo = ({
  int id,
  int businessId,
  int customerId,
  String number,
  double totalAmount,
  DateTime? dueDate,
});

/// Shared write core for invoice/quote documents: sequence allocation,
/// transactional create/duplicate/update-with-items, stock side effects,
/// edit-audit events and lifecycle operations.
///
/// [D] is the document row type, [IR] the item row type, [C] the document
/// companion type and [IC] the item companion type.
abstract class DocumentServiceBase<D, IR, C, IC> {
  /// DAOs are constructor-injected: services carry no Riverpod [Ref], so
  /// every flow here is unit-testable with an in-memory database.
  final AppDatabase db;
  final CustomerActivityDao activityDao;

  DocumentServiceBase({required this.db, required this.activityDao});

  // ---- identity & labels ----

  String get entityType;

  String get editEventType;

  String get docNoun;

  String get dateLabel;

  String get contactEventType;

  String get contactTitle;

  String contactNote(String number);

  bool get contactTouchesUpdatedAt;

  // ---- typed DAO seams ----

  Future<D?> getDocument(int id);

  Future<List<IR>> getItems(int documentId);

  Future<Business?> getBusiness(int businessId);

  String seriesFormatOf(Business? business);

  DateTime dateOf(C companion);

  int businessIdOfCompanion(C companion);

  Future<int> insertWithGeneratedNumber({
    required C companion,
    required String format,
    required DateTime date,
  });

  Future<void> insertItemForDocument({required int documentId, required IC item});

  Future<void> deleteItems(int documentId);

  Future<void> deleteDocumentRow(int documentId);

  Future<bool> updateDocument(D document);

  D buildUpdatedDocument(D existing, C companion);

  C duplicatedCompanion({required D source, required DateTime duplicateDate});

  IC itemCompanionFrom(IR source, {required int documentId});

  D documentCopyWithStatus(D document, String status);

  D documentCopyWithTemplate(D document, int? templateId);

  D documentCopyWithTouched(D document);

  DocumentInfo infoOf(D document);

  void validateStatusTransition(D document, String status);

  void validateDelete(D document);

  /// Throws when [document] may not be edited in its current lifecycle state
  /// (for example a paid, cancelled or converted document).
  void validateEdit(D document);

  Future<void> applyItemSideEffects({required int documentId, required IC item});

  Future<void> reverseItemEffects({required int documentId, required IR item});

  // ---- shared flows ----

  Future<int> createWithItems({
    required C companion,
    required List<IC> items,
    String? formatOverride,
  }) async {
    final documentId = await db.transaction(() async {
      final business = await getBusiness(businessIdOfCompanion(companion));
      final format = formatOverride ?? seriesFormatOf(business);
      final createdId = await insertWithGeneratedNumber(
        companion: companion,
        format: format,
        date: dateOf(companion),
      );

      for (final item in items) {
        await insertItemForDocument(documentId: createdId, item: item);
        await applyItemSideEffects(documentId: createdId, item: item);
      }
      return createdId;
    });
    return documentId;
  }

  Future<int> duplicate(int documentId) async {
    final source = await getDocument(documentId);
    if (source == null) throw Exception('$docNoun not found');
    final sourceItems = await getItems(documentId);
    final duplicateDate = DateTime.now();

    final duplicatedId = await db.transaction(() async {
      final business = await getBusiness(infoOf(source).businessId);
      final format = seriesFormatOf(business);

      final createdId = await insertWithGeneratedNumber(
        companion: duplicatedCompanion(source: source, duplicateDate: duplicateDate),
        format: format,
        date: duplicateDate,
      );

      for (final item in sourceItems) {
        final companion = itemCompanionFrom(item, documentId: createdId);
        await insertItemForDocument(documentId: createdId, item: companion);
        await applyItemSideEffects(documentId: createdId, item: companion);
      }
      return createdId;
    });
    return duplicatedId;
  }

  Future<void> updateWithItems(D existingDocument, C companion, List<IC> items) async {
    validateEdit(existingDocument);
    final documentId = infoOf(existingDocument).id;
    final previousItems = await getItems(documentId);

    await db.transaction(() async {
      await updateDocument(buildUpdatedDocument(existingDocument, companion));

      await deleteItems(documentId);
      for (final previousItem in previousItems) {
        await reverseItemEffects(documentId: documentId, item: previousItem);
      }
      for (final item in items) {
        await insertItemForDocument(documentId: documentId, item: item);
        await applyItemSideEffects(documentId: documentId, item: item);
      }
    });

    final maybeCurrentDocument = await getDocument(documentId);
    if (maybeCurrentDocument == null) throw Exception('$docNoun not found');
    final currentDocument = maybeCurrentDocument;
    final newItems = await getItems(documentId);
    final previousInfo = infoOf(existingDocument);
    final currentInfo = infoOf(currentDocument);

    final changeSummary = buildDocumentEditSummary(
      docNoun: docNoun,
      dateLabel: dateLabel,
      previousCustomerId: previousInfo.customerId,
      currentCustomerId: currentInfo.customerId,
      previousTotal: previousInfo.totalAmount,
      currentTotal: currentInfo.totalAmount,
      previousDate: previousInfo.dueDate,
      currentDate: currentInfo.dueDate,
      previousItemCount: previousItems.length,
      currentItemCount: newItems.length,
    );

    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: currentInfo.businessId,
        customerId: currentInfo.customerId,
        eventType: editEventType,
        entityType: drift.Value(entityType),
        entityId: drift.Value(currentInfo.id),
        title: '$docNoun updated',
        note: drift.Value(changeSummary),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateStatus(int documentId, String status) async {
    final document = await getDocument(documentId);
    if (document == null) throw Exception('$docNoun not found');
    validateStatusTransition(document, status);

    await updateDocument(documentCopyWithStatus(document, status));
  }

  Future<void> updateTemplate(int documentId, int? templateId) async {
    final document = await getDocument(documentId);
    if (document == null) throw Exception('$docNoun not found');

    await updateDocument(documentCopyWithTemplate(document, templateId));
  }

  Future<void> delete(int documentId) async {
    final document = await getDocument(documentId);
    if (document == null) throw Exception('$docNoun not found');
    validateDelete(document);

    final items = await getItems(documentId);
    await db.transaction(() async {
      for (final item in items) {
        await reverseItemEffects(documentId: documentId, item: item);
      }
      await deleteDocumentRow(documentId);
    });
  }

  Future<void> markContacted(int documentId) async {
    final document = await getDocument(documentId);
    if (document == null) throw Exception('$docNoun not found');
    final info = infoOf(document);

    if (contactTouchesUpdatedAt) {
      await updateDocument(documentCopyWithTouched(document));
    }

    await activityDao.insertEvent(
      CustomerActivityEventsCompanion.insert(
        businessId: info.businessId,
        customerId: info.customerId,
        eventType: contactEventType,
        entityType: drift.Value(entityType),
        entityId: drift.Value(info.id),
        title: contactTitle,
        note: drift.Value(contactNote(info.number)),
        createdAt: DateTime.now(),
      ),
    );
  }
}
