import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:file_selector/file_selector.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';
import 'backup_cipher.dart';

class BackupVersionMismatch implements Exception {  final Object? backupVersion;
  final int currentVersion;

  BackupVersionMismatch({
    required this.backupVersion,
    required this.currentVersion,
  });

  @override
  String toString() =>
      'This backup was created with schema version $backupVersion but the '
      'app uses version $currentVersion. Restore it with an app version that '
      'matches the backup, or export a new backup from this app.';
}

/// Thrown when a restore is attempted against an encrypted backup without a
/// usable passphrase, so the UI can prompt and retry.
class BackupPassphraseRequired implements Exception {
  const BackupPassphraseRequired();

  @override
  String toString() =>
      'This backup is encrypted. Enter its passphrase to restore it.';
}

class DatabaseBackupService {
  static const _backupExtension = 'json';

  /// How many pre-restore snapshots to keep on disk.
  static const _maxSnapshots = 5;

  /// App preferences carried in the backup (and restored with it).
  static const _settingsKeys = [
    'is_gst_enabled',
    'reminder_notifications_enabled',
    'reminder_notification_offsets',
    'low_stock_warnings_enabled',
    'print_bank_details_on_invoice',
    'round_off_enabled',
    'theme_mode',
  ];

  /// Tables whose data must be present for a restore to be safe. A backup
  /// missing one of these would otherwise silently wipe that table.
  static const _requiredTables = [
    'businesses',
    'customers',
    'products',
    'invoices',
    'invoiceItems',
    'invoicePayments',
    'customerActivityEvents',
    'quotes',
    'quoteItems',
    'hsnCodes',
    'hsnCodeRates',
    'uoms',
    'stockMovements',
  ];

  /// Validates the payload before any data is touched: schema version must
  /// match, and required tables must be present and well-formed lists.
  /// Tables introduced after the first release (`templateConfigs`,
  /// `documentSequences`) are optional and decode as empty when missing.
  /// Throws [BackupVersionMismatch] or [FormatException] on failure.

  static Future<String> buildBackupJson(
    AppDatabase db, {
    String? passphrase,
  }) async {
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
    final templateConfigs = await db.select(db.templateConfigs).get();
    final documentSequences = await db.select(db.documentSequences).get();
    final stockMovements = await db.select(db.stockMovements).get();

    // Preferences are best-effort metadata: a headless or plugin-less host
    // must still be able to export the database itself.
    var settings = <String, Object?>{};
    try {
      final prefs = await SharedPreferences.getInstance();
      settings = {
        for (final key in _settingsKeys)
          if (prefs.containsKey(key)) key: prefs.get(key),
      };
    } catch (_) {
      settings = <String, Object?>{};
    }

    final logos = <String, Object?>{};
    for (final business in businesses) {
      final path = business.logoPath;
      if (path == null || path.isEmpty) continue;
      final file = File(path);
      if (!file.existsSync()) continue;
      logos[business.id.toString()] = {
        'name': p.basename(path),
        'bytes': base64Encode(await file.readAsBytes()),
      };
    }

    final payload = jsonEncode({
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
      'templateConfigs': templateConfigs.map((row) => row.toJson()).toList(),
      'documentSequences':
          documentSequences.map((row) => row.toJson()).toList(),
      'stockMovements': stockMovements.map((row) => row.toJson()).toList(),
      'settings': settings,
      'logos': logos,
    });

    // Optionally sealed with a user passphrase so a backup stored in Drive or
    // Nextcloud is useless without it.
    if (passphrase == null || passphrase.isEmpty) return payload;
    return BackupCipher.encrypt(payload, passphrase);
  }

  static Future<File> createBackupFile(
    AppDatabase db, {
    String? fileName,
    String? passphrase,
  }) async {
    final directory = await getTemporaryDirectory();
    final name =
        fileName ?? 'vittix_invoice_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    final file = File(p.join(directory.path, name));
    await file.writeAsString(await buildBackupJson(db, passphrase: passphrase));
    return file;
  }

  /// Writes a copy of the current database to the app documents directory
  /// immediately before a destructive restore, so the previous data can be
  /// recovered if the restore turns out to be unwanted. Returns the file path.
  ///
  /// [directory] overrides the destination (used by tests).
  static Future<String> createRestoreSafetySnapshot(
    AppDatabase db, {
    Directory? directory,
  }) async {
    final base = directory ?? await getApplicationDocumentsDirectory();
    final snapshots = Directory(p.join(base.path, 'pre_restore_snapshots'));
    if (!snapshots.existsSync()) {
      await snapshots.create(recursive: true);
    }
    final stamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File(p.join(snapshots.path, 'pre_restore_$stamp.json'));
    await file.writeAsString(await buildBackupJson(db));

    await _pruneSnapshots(snapshots);
    return file.path;
  }

  /// Keeps only the newest [_maxSnapshots] pre-restore snapshots so the
  /// directory cannot grow without bound.
  static Future<void> _pruneSnapshots(Directory snapshots) async {
    try {
      final files =
          snapshots
              .listSync()
              .whereType<File>()
              .where(
                (file) => p.basename(file.path).startsWith('pre_restore_'),
              )
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));

      final excess = files.length - _maxSnapshots;
      for (var i = 0; i < excess; i++) {
        files[i].deleteSync();
      }
    } catch (_) {
      // Pruning is best-effort; never block the restore over it.
    }
  }

  static Future<void> shareBackup(
    AppDatabase db, {
    String? passphrase,
  }) async {
    final file = await createBackupFile(db, passphrase: passphrase);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Database backup attached.',
        subject: 'VittixInvoice database backup',
      ),
    );
  }

  static Future<int?> restoreFromPickedFile(
    AppDatabase db, {
    String? passphrase,
  }) async {
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
    return restoreFromFile(db, path, passphrase: passphrase);
  }

  static Future<int?> restoreFromFile(
    AppDatabase db,
    String path, {
    String? passphrase,
  }) async {
    final contents = await File(path).readAsString();
    return restoreFromJson(db, contents, passphrase: passphrase);
  }

  /// Whether the backup file at [path] is passphrase-encrypted.
  static Future<bool> isEncryptedFile(String path) async =>
      BackupCipher.isEncrypted(await File(path).readAsString());

  static Future<int?> restoreFromJson(
    AppDatabase db,
    String jsonString, {
    String? passphrase,
  }) async {
    // Encrypted backups carry an envelope; decrypt before validating.
    final String resolved;
    if (BackupCipher.isEncrypted(jsonString)) {
      if (passphrase == null || passphrase.isEmpty) {
        throw const BackupPassphraseRequired();
      }
      resolved = BackupCipher.decrypt(jsonString, passphrase);
    } else {
      resolved = jsonString;
    }

    final decoded = jsonDecode(resolved);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid backup payload');
    }

    _validateBackupPayload(decoded, db.schemaVersion);

    await db.transaction(() async {
      await db.delete(db.customerActivityEvents).go();
      await db.delete(db.invoicePayments).go();
      await db.delete(db.invoiceItems).go();
      await db.delete(db.quoteItems).go();
      await db.delete(db.invoices).go();
      await db.delete(db.quotes).go();
      await db.delete(db.products).go();
      await db.delete(db.customers).go();
      await db.delete(db.stockMovements).go();
      await db.delete(db.documentSequences).go();
      await db.delete(db.templateConfigs).go();
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
          db.documentSequences,
          _decodeList(decoded['documentSequences'], DocumentSequence.fromJson),
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
          db.stockMovements,
          _decodeList(decoded['stockMovements'], StockMovement.fromJson),
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
          db.templateConfigs,
          _decodeList(decoded['templateConfigs'], TemplateConfig.fromJson),
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

    // Logos and preferences live outside the database, so they are restored
    // once the tables have been replaced.
    await _restoreLogos(db, decoded['logos']);
    await _restoreSettings(decoded['settings']);

    final restoredBusinesses = await db.select(db.businesses).get();
    if (restoredBusinesses.isEmpty) return null;

    final activeBusinesses =
        restoredBusinesses.where((business) => business.isActive).toList();
    return activeBusinesses.isNotEmpty
        ? activeBusinesses.first.id
        : restoredBusinesses.first.id;
  }

  /// Writes any backed-up logo images back to disk and repoints the businesses
  /// at them, so a restore onto a new device keeps the branding.
  static Future<void> _restoreLogos(AppDatabase db, dynamic raw) async {
    if (raw is! Map) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final logoDirectory = Directory(p.join(directory.path, 'logos'));
      if (!logoDirectory.existsSync()) {
        await logoDirectory.create(recursive: true);
      }

      for (final entry in raw.entries) {
        final businessId = int.tryParse(entry.key.toString());
        final value = entry.value;
        if (businessId == null || value is! Map) continue;

        final bytes = value['bytes'];
        if (bytes is! String) continue;
        final name = p.basename(value['name']?.toString() ?? 'logo.png');

        final file = File(p.join(logoDirectory.path, '${businessId}_$name'));
        await file.writeAsBytes(base64Decode(bytes));
        await (db.update(db.businesses)
              ..where((t) => t.id.equals(businessId)))
            .write(BusinessesCompanion(logoPath: Value(file.path)));
      }
    } catch (_) {
      // A missing platform directory or unreadable logo must not fail the
      // restore; the database content is what matters.
    }
  }

  /// Restores the backed-up app preferences (whitelisted keys only).
  static Future<void> _restoreSettings(dynamic raw) async {
    if (raw is! Map) return;

    try {
      final prefs = await SharedPreferences.getInstance();

      for (final entry in raw.entries) {
        final key = entry.key.toString();
        if (!_settingsKeys.contains(key)) continue;

        final value = entry.value;
        if (value is bool) {
          await prefs.setBool(key, value);
        } else if (value is int) {
          await prefs.setInt(key, value);
        } else if (value is double) {
          await prefs.setDouble(key, value);
        } else if (value is String) {
          await prefs.setString(key, value);
        } else if (value is List) {
          await prefs.setStringList(
            key,
            value.map((item) => item.toString()).toList(),
          );
        }
      }
    } catch (_) {
      // Preferences are optional; ignore failures on hosts without storage.
    }
  }

  /// Validates the payload before any data is touched: schema version must
  /// match, and required tables must be present and well-formed lists.
  /// Tables introduced after the first release (`templateConfigs`,
  /// `documentSequences`) are optional and decode as empty when missing.
  /// Throws [BackupVersionMismatch] or [FormatException] on failure.
  static void _validateBackupPayload(
    Map<String, dynamic> decoded,
    int currentSchemaVersion,
  ) {
    final backupVersion = decoded['schemaVersion'];
    if (backupVersion is! int || backupVersion != currentSchemaVersion) {
      throw BackupVersionMismatch(
        backupVersion: backupVersion,
        currentVersion: currentSchemaVersion,
      );
    }

    final missing = _requiredTables
        .where((table) => decoded[table] is! List)
        .toList();
    if (missing.isNotEmpty) {
      throw FormatException(
        'Backup payload is missing or malformed table data for: '
        '${missing.join(', ')}',
      );
    }
  }

  static List<T> _decodeList<T>(
    dynamic raw,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (raw is! List) return const [];
    final result = <T>[];
    for (final entry in raw) {
      if (entry is! Map) {
        throw const FormatException('Backup payload contains a malformed row.');
      }
      result.add(fromJson(Map<String, dynamic>.from(entry)));
    }
    return result;
  }
}
