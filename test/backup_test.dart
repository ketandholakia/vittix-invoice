import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' as drift;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/database/tables/template_configs.dart';
import 'package:vittix_invoice/services/backup_cipher.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';

void main() {
  group('DatabaseBackupService', () {
    test('exports and restores a full database snapshot', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());

      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Backup Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.customers).insert(
            CustomersCompanion.insert(
              businessId: 1,
              name: 'Backup Customer',
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.products).insert(
            ProductsCompanion.insert(
              businessId: 1,
              name: 'Backup Product',
              hsnSac: '8517',
              unit: 'PCS',
              salePrice: 100,
              gstRate: 18,
              stockQuantity: const drift.Value(5),
              isService: const drift.Value(false),
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      await source.into(source.uoms).insert(
            UomsCompanion.insert(code: 'PCS', name: 'Pieces').copyWith(
              sortOrder: const drift.Value(0),
            ),
          );

      await source.into(source.hsnCodes).insert(
            HsnCodesCompanion.insert(
              code: '8517',
              description: 'Telephones and mobile phones',
            ),
          );

      await source.into(source.hsnCodeRates).insert(
            HsnCodeRatesCompanion.insert(
              code: '8517',
              gstRate: const drift.Value(18.0),
              effectiveFrom: DateTime(2017, 7, 1),
            ),
          );

      final backupJson = await DatabaseBackupService.buildBackupJson(source);
      await source.close();

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        backupJson,
      );

      final restoredBusinesses = await target.select(target.businesses).get();
      final restoredCustomers = await target.select(target.customers).get();
      final restoredProducts = await target.select(target.products).get();
      final restoredHsnRates = await target.select(target.hsnCodeRates).get();

      expect(restoredActiveId, 1);
      expect(restoredBusinesses, hasLength(1));
      expect(restoredCustomers, hasLength(1));
      expect(restoredProducts, hasLength(1));
      expect(restoredHsnRates, hasLength(1));
      expect(restoredProducts.first.name, 'Backup Product');
    });
  });

  group('DatabaseBackupService regression tests', () {
    test('restores template configs along with the rest of the data', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Backup Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      await source.into(source.templateConfigs).insert(
        TemplateConfigsCompanion.insert(
          businessId: 1,
          scope: TemplateScope.invoice,
          name: 'My Template',
          configJson: '{"layoutFamily":"MODERN"}',
          createdAt: DateTime(2026, 6, 30),
          updatedAt: DateTime(2026, 6, 30),
        ),
      );
      final backupJson = await DatabaseBackupService.buildBackupJson(source);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId =
          await DatabaseBackupService.restoreFromJson(target, backupJson);

      final templates = await target.select(target.templateConfigs).get();
      expect(restoredActiveId, 1);
      expect(templates, hasLength(1));
      expect(templates.single.name, 'My Template');
      expect(templates.single.configJson, contains('MODERN'));
    });

    test('restores backups created before optional tables existed', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Legacy Backup Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      final decoded =
          jsonDecode(await DatabaseBackupService.buildBackupJson(source))
              as Map<String, dynamic>;
      decoded.remove('templateConfigs');
      decoded.remove('documentSequences');

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId =
          await DatabaseBackupService.restoreFromJson(target, jsonEncode(decoded));

      expect(restoredActiveId, 1);
      expect(await target.select(target.templateConfigs).get(), isEmpty);
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('rejects NEWER backups without touching data', () async {
      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      await target.into(target.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Existing Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final backup = jsonEncode(<String, Object>{
        'schemaVersion': target.schemaVersion + 1,
        'businesses': <Object>[],
      });
      await expectLater(
        DatabaseBackupService.restoreFromJson(target, backup),
        throwsA(isA<BackupVersionMismatch>()),
      );
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('restores recurring schedules along with the rest of the data',
        () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Recurring Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      await source.into(source.customers).insert(
        CustomersCompanion.insert(
          businessId: 1,
          name: 'Recurring Customer',
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      final invoiceId = await source.into(source.invoices).insert(
        InvoicesCompanion.insert(
          businessId: 1,
          customerId: 1,
          invoiceNumber: 'INV-2627-0001',
          invoiceDate: DateTime(2026, 6, 30),
          invoiceType: 'TAX_INVOICE',
          supplyType: 'B2B',
          placeOfSupply: 27,
          subtotal: 100,
          taxableAmount: 100,
          totalAmount: 118,
          status: const drift.Value('SENT'),
          createdAt: DateTime(2026, 6, 30),
          updatedAt: DateTime(2026, 6, 30),
        ),
      );
      await source.into(source.recurringInvoices).insert(
        RecurringInvoicesCompanion.insert(
          businessId: 1,
          sourceInvoiceId: invoiceId,
          nextRunDate: DateTime(2026, 7, 1),
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final backupJson = await DatabaseBackupService.buildBackupJson(source);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        backupJson,
      );

      expect(restoredActiveId, 1);
      final schedules = await target.select(target.recurringInvoices).get();
      expect(schedules, hasLength(1));
      expect(schedules.single.sourceInvoiceId, invoiceId);
      expect(schedules.single.nextRunDate, DateTime(2026, 7, 1));
      expect(
        await target.select(target.invoices).get(),
        hasLength(1),
      );
    });

    test('restores an older (v30) backup into the current schema', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Legacy Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );
      final decoded =
          jsonDecode(await DatabaseBackupService.buildBackupJson(source))
              as Map<String, dynamic>;
      // Shape the payload the way a v30 app produced it: no Bill of Supply
      // series column on businesses (added in v31) and no recurring
      // invoices section (the table existed but backups skipped it).
      decoded['schemaVersion'] = 30;
      decoded.remove('recurringInvoices');
      for (final row in decoded['businesses'] as List) {
        (row as Map).remove('bill_of_supply_series_format');
      }

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        jsonEncode(decoded),
      );

      expect(restoredActiveId, 1);
      final business = await target.select(target.businesses).getSingle();
      expect(business.billOfSupplySeriesFormat, 'BOS-{FY}-{SEQ4}');
      expect(await target.select(target.recurringInvoices).get(), isEmpty);
    });

    test('rejects malformed backups without touching data', () async {
      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      await target.into(target.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Existing Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final backup = jsonEncode(<String, Object>{
        'schemaVersion': target.schemaVersion,
        'businesses': <Object>[],
      });
      await expectLater(
        DatabaseBackupService.restoreFromJson(target, backup),
        throwsA(isA<FormatException>()),
      );
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('writes a restorable pre-restore safety snapshot', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Snapshot Business',
              gstin: '27AAPFU0939F1ZV',
              address: 'Address',
              city: 'Mumbai',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final directory = await Directory.systemTemp.createTemp('vittix_snapshot');
      addTearDown(() => directory.delete(recursive: true));

      final path = await DatabaseBackupService.createRestoreSafetySnapshot(
        source,
        directory: directory,
      );

      final snapshot = File(path);
      expect(await snapshot.exists(), isTrue);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      final restoredActiveId = await DatabaseBackupService.restoreFromJson(
        target,
        await snapshot.readAsString(),
      );

      expect(restoredActiveId, 1);
      expect((await target.select(target.businesses).get()), hasLength(1));
    });

    test('prunes pre-restore snapshots by age (7 days) and count (3)',
        () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
        BusinessesCompanion.insert(
          name: 'Snapshot Business',
          gstin: '27AAPFU0939F1ZV',
          address: 'Address',
          city: 'Mumbai',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 30),
        ),
      );

      final directory = await Directory.systemTemp.createTemp('vittix_snapshot');
      addTearDown(() => directory.delete(recursive: true));

      // Snapshots live in the pre_restore_snapshots subfolder the service
      // manages; seed it with four stale snapshots (older than 7 days) and
      // two recent ones.
      final snapshotsDir = Directory(
        '${directory.path}${Platform.pathSeparator}pre_restore_snapshots',
      );
      await snapshotsDir.create(recursive: true);

      Future<void> seed(String name, DateTime mtime) async {
        final file = File('${snapshotsDir.path}${Platform.pathSeparator}$name');
        await file.writeAsString('{}');
        await file.setLastModified(mtime);
      }

      final now = DateTime.now();
      await seed('pre_restore_a.json', now.subtract(const Duration(days: 30)));
      await seed('pre_restore_b.json', now.subtract(const Duration(days: 20)));
      await seed('pre_restore_c.json', now.subtract(const Duration(days: 10)));
      await seed('pre_restore_d.json', now.subtract(const Duration(days: 8)));
      await seed('pre_restore_e.json', now.subtract(const Duration(hours: 1)));
      await seed('pre_restore_f.json', now.subtract(const Duration(minutes: 1)));

      await DatabaseBackupService.createRestoreSafetySnapshot(
        source,
        directory: directory,
      );

      final remaining = snapshotsDir
          .listSync()
          .whereType<File>()
          .map((file) => file.path.split(Platform.pathSeparator).last)
          .where((name) => name.startsWith('pre_restore_'))
          .toList()
        ..sort();

      // The 7-day cutoff removes the four stale snapshots; the count cap
      // keeps at most 3 of what is left (the new snapshot included).
      expect(remaining.where((name) => name.endsWith('_a.json')), isEmpty);
      expect(remaining.where((name) => name.endsWith('_d.json')), isEmpty);
      expect(remaining, hasLength(3));
    });
  });

  group('BackupEncryption', () {
    test('round-trips a payload and rejects a wrong passphrase', () async {
      const plaintext = '{"hello":"world"}';
      // Fast test iterations; the production count is asserted separately.
      final envelope = await BackupCipher.encrypt(
        plaintext,
        'correct horse',
        kdfIterations: 1000,
      );

      expect(BackupCipher.isEncrypted(envelope), isTrue);
      expect(BackupCipher.isEncrypted(plaintext), isFalse);
      expect(await BackupCipher.decrypt(envelope, 'correct horse'), plaintext);
      await expectLater(
        BackupCipher.decrypt(envelope, 'wrong'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a tampered envelope', () async {
      final envelope = await BackupCipher.encrypt(
        '{"a":1}',
        'pw-stdin-ok',
        kdfIterations: 1000,
      );
      final tampered = envelope.replaceFirst('"payload":"', '"payload":"!!');

      await expectLater(
        BackupCipher.decrypt(tampered, 'pw-stdin-ok'),
        throwsA(isA<FormatException>()),
      );
    });

    test('records the KDF iteration count in the envelope', () {
      final envelope = BackupCipher.encryptSync('{"a":1}', 'long enough');
      final decoded = jsonDecode(envelope) as Map<String, dynamic>;

      expect(decoded['kdfIterations'], 600000);
    });

    test('still decrypts legacy envelopes without an iteration count',
        () async {
      // An envelope produced by the pre-600k scheme: version 1, 100k
      // iterations, no kdfIterations field.
      final legacyEnvelope =
          BackupCipher.legacyEnvelopeForTest('{"a":1}', 'legacy ok');

      expect(
        await BackupCipher.decrypt(legacyEnvelope, 'legacy ok'),
        '{"a":1}',
      );
    });

    test('rejects a too-short passphrase', () async {
      await expectLater(
        BackupCipher.encrypt('{"a":1}', 'short'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('an encrypted backup round-trips through the service', () async {
      final source = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(source.close);
      await source.into(source.businesses).insert(
            BusinessesCompanion.insert(
              name: 'Encrypted',
              gstin: '27AAPFU0939F1ZV',
              address: 'a',
              city: 'b',
              stateCode: 27,
              createdAt: DateTime(2026, 6, 30),
            ),
          );

      final encrypted = await DatabaseBackupService.buildBackupJson(
        source,
        passphrase: 'secret-passphrase',
      );
      expect(BackupCipher.isEncrypted(encrypted), isTrue);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      expect(
        await DatabaseBackupService.restoreFromJson(
          target,
          encrypted,
          passphrase: 'secret-passphrase',
        ),
        1,
      );

      // A wrong passphrase must leave the target database untouched.
      final other = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(other.close);
      await expectLater(
        DatabaseBackupService.restoreFromJson(
          other,
          encrypted,
          passphrase: 'nope',
        ),
        throwsA(isA<FormatException>()),
      );
      expect(await other.select(other.businesses).get(), isEmpty);

      // With no passphrase at all the service asks for one rather than
      // guessing, and still leaves the target untouched.
      final missing = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(missing.close);
      await expectLater(
        DatabaseBackupService.restoreFromJson(missing, encrypted),
        throwsA(isA<BackupPassphraseRequired>()),
      );
      expect(await missing.select(missing.businesses).get(), isEmpty);
    });
  });
}
