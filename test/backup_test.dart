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

    test('rejects backups from another schema version without touching data',
        () async {
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

      final backup = jsonEncode(<String, Object>{'schemaVersion': 1, 'businesses': <Object>[]});
      await expectLater(
        DatabaseBackupService.restoreFromJson(target, backup),
        throwsA(isA<BackupVersionMismatch>()),
      );
      expect((await target.select(target.businesses).get()), hasLength(1));
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
  });

  group('BackupEncryption', () {
    test('round-trips a payload and rejects a wrong passphrase', () {
      const plaintext = '{"hello":"world"}';
      final envelope = BackupCipher.encrypt(plaintext, 'correct horse');

      expect(BackupCipher.isEncrypted(envelope), isTrue);
      expect(BackupCipher.isEncrypted(plaintext), isFalse);
      expect(BackupCipher.decrypt(envelope, 'correct horse'), plaintext);
      expect(
        () => BackupCipher.decrypt(envelope, 'wrong'),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a tampered envelope', () {
      final envelope = BackupCipher.encrypt('{"a":1}', 'pw');
      final tampered = envelope.replaceFirst('"payload":"', '"payload":"!!');

      expect(
        () => BackupCipher.decrypt(tampered, 'pw'),
        throwsA(isA<FormatException>()),
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
        passphrase: 'secret',
      );
      expect(BackupCipher.isEncrypted(encrypted), isTrue);

      final target = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(target.close);
      expect(
        await DatabaseBackupService.restoreFromJson(
          target,
          encrypted,
          passphrase: 'secret',
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
