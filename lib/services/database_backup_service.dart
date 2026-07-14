import 'dart:convert';
import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class DatabaseBackupService {
  static const _backupExtension = 'json';

  static Future<String> buildBackupJson(AppDatabase db) async {
    final businesses = await db.select(db.businesses).get();
    final customers = await db.select(db.customers).get();
    final products = await db.select(db.products).get();
    final invoices = await db.select(db.invoices).get();
    final invoiceItems = await db.select(db.invoiceItems).get();
    final invoicePayments = await db.select(db.invoicePayments).get();
    final customerActivityEvents = await db.select(db.customerActivityEvents).get();
    final quotes = await db.select(db.quotes).get();
    final quoteItems = await db.select(db.quoteItems).get();
    final hsnCodes = await db.select(db.hsnCodes).get();
    final hsnCodeRates = await db.select(db.hsnCodeRates).get();
    final uoms = await db.select(db.uoms).get();

    return jsonEncode({
      'schemaVersion': db.schemaVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'businesses': businesses.map((row) => row.toJson()).toList(),
      'customers': customers.map((row) => row.toJson()).toList(),
      'products': products.map((row) => row.toJson()).toList(),
      'invoices': invoices.map((row) => row.toJson()).toList(),
      'invoiceItems': invoiceItems.map((row) => row.toJson()).toList(),
      'invoicePayments': invoicePayments.map((row) => row.toJson()).toList(),
      'customerActivityEvents':
          customerActivityEvents.map((row) => row.toJson()).toList(),
      'quotes': quotes.map((row) => row.toJson()).toList(),
      'quoteItems': quoteItems.map((row) => row.toJson()).toList(),
      'hsnCodes': hsnCodes.map((row) => row.toJson()).toList(),
      'hsnCodeRates': hsnCodeRates.map((row) => row.toJson()).toList(),
      'uoms': uoms.map((row) => row.toJson()).toList(),
    });
  }

  static Future<File> createBackupFile(
    AppDatabase db, {
    String? fileName,
  }) async {
    final directory = await getTemporaryDirectory();
    final name =
        fileName ?? 'vittix_invoice_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(p.join(directory.path, name));
    await file.writeAsString(await buildBackupJson(db));
    return file;
  }

  static Future<void> shareBackup(AppDatabase db) async {
    final file = await createBackupFile(db);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Database backup attached.',
        subject: 'VittixInvoice database backup',
      ),
    );
  }

  static Future<int?> restoreFromPickedFile(AppDatabase db) async {
    final file = await openFile(
      acceptedTypeGroups: const [
        XTypeGroup(
          label: 'JSON',
          extensions: [_backupExtension],
        ),
      ],
    );
    final path = file?.path;
    if (path == null || path.isEmpty) return null;
    return restoreFromFile(db, path);
  }

  static Future<int?> restoreFromFile(AppDatabase db, String path) async {
    final contents = await File(path).readAsString();
    return restoreFromJson(db, contents);
  }

  static Future<int?> restoreFromJson(AppDatabase db, String jsonString) async {
    final decoded = jsonDecode(jsonString);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Invalid backup payload');
    }

    await db.transaction(() async {
      await db.delete(db.customerActivityEvents).go();
      await db.delete(db.invoicePayments).go();
      await db.delete(db.invoiceItems).go();
      await db.delete(db.quoteItems).go();
      await db.delete(db.invoices).go();
      await db.delete(db.quotes).go();
      await db.delete(db.products).go();
      await db.delete(db.customers).go();
      await db.delete(db.businesses).go();
      await db.delete(db.hsnCodeRates).go();
      await db.delete(db.hsnCodes).go();
      await db.delete(db.uoms).go();

      await db.batch((batch) {
        batch.insertAll(
          db.businesses,
          _decodeList(decoded['businesses'], Business.fromJson),
        );
        batch.insertAll(
          db.hsnCodes,
          _decodeList(decoded['hsnCodes'], HsnCode.fromJson),
        );
        batch.insertAll(
          db.hsnCodeRates,
          _decodeList(decoded['hsnCodeRates'], HsnCodeRate.fromJson),
        );
        batch.insertAll(
          db.uoms,
          _decodeList(decoded['uoms'], Uom.fromJson),
        );
        batch.insertAll(
          db.customers,
          _decodeList(decoded['customers'], Customer.fromJson),
        );
        batch.insertAll(
          db.products,
          _decodeList(decoded['products'], Product.fromJson),
        );
        batch.insertAll(
          db.invoices,
          _decodeList(decoded['invoices'], Invoice.fromJson),
        );
        batch.insertAll(
          db.quotes,
          _decodeList(decoded['quotes'], Quote.fromJson),
        );
        batch.insertAll(
          db.invoiceItems,
          _decodeList(decoded['invoiceItems'], InvoiceItem.fromJson),
        );
        batch.insertAll(
          db.quoteItems,
          _decodeList(decoded['quoteItems'], QuoteItem.fromJson),
        );
        batch.insertAll(
          db.invoicePayments,
          _decodeList(decoded['invoicePayments'], InvoicePayment.fromJson),
        );
        batch.insertAll(
          db.customerActivityEvents,
          _decodeList(
            decoded['customerActivityEvents'],
            CustomerActivityEvent.fromJson,
          ),
        );
      });
    });

    final restoredBusinesses = await db.select(db.businesses).get();
    if (restoredBusinesses.isEmpty) return null;

    final activeBusinesses =
        restoredBusinesses.where((business) => business.isActive).toList();
    return activeBusinesses.isNotEmpty
        ? activeBusinesses.first.id
        : restoredBusinesses.first.id;
  }

  static List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((entry) => fromJson(Map<String, dynamic>.from(entry)))
        .toList();
  }
}
