import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';
import 'package:vittix_invoice/services/google_drive_service.dart';

/// Serves canned JSON for the Drive v3 REST endpoints the service touches,
/// so upload/list/restore/revoke run without Google Sign-In.
class FakeDriveClient extends http.BaseClient {
  FakeDriveClient(this.routes);

  final List<({String method, String path, int status, String body})> routes;
  final List<(String, String)> calls = [];
  bool listQueryContainsOrderBy = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final path = request.url.path;
    calls.add((request.method, path));
    if (request.method == 'GET' && path == '/drive/v3/files') {
      listQueryContainsOrderBy =
          request.url.query.contains('modifiedTime+desc') ||
          request.url.query.contains('modifiedTime%20desc') ||
          request.url.query.contains('modifiedTime desc');
    }
    final index = routes.indexWhere(
      (route) =>
          request.method == route.method &&
          (route.path.isEmpty || path == route.path || path.endsWith(route.path)),
    );
    if (index < 0) {
      throw StateError('No scripted Drive route for '
          '${request.method} $path?${request.url.query}');
    }
    final route = routes.removeAt(index);
    return http.StreamedResponse(
      Stream.value(utf8.encode(route.body)),
      route.status,
      headers: const {'content-type': 'application/json; charset=utf-8'},
    );
  }
}

Future<AppDatabase> seededDatabase(String name) async {
  final database = AppDatabase.forTesting(NativeDatabase.memory());
  await database.into(database.businesses).insert(
        BusinessesCompanion.insert(
          name: name,
          gstin: '27AAPFU0939F1ZV',
          address: 'a',
          city: 'b',
          stateCode: 27,
          createdAt: DateTime(2026, 6, 1),
        ),
      );
  return database;
}

void main() {
  drive.DriveApi apiFor(FakeDriveClient client) => drive.DriveApi(client);

  test('uploadBackup stores the snapshot in the app data folder', () async {
    final source = await seededDatabase('DriveUpload');
    addTearDown(source.close);
    final client = FakeDriveClient([
      (
        method: 'POST',
        path: '/upload/drive/v3/files',
        status: 200,
        body: '{"id": "new-backup-1", "name": "vittix_invoice_backup.json"}',
      ),
    ]);
    final service = GoogleDriveService.forTests(apiFor(client));

    final result = await service.uploadBackup(source);

    expect(result.fileId, 'new-backup-1');
    expect(result.fileName, 'vittix_invoice_backup.json');
    // The upload must target the appDataFolder space.
    final upload = client.calls
        .where((call) => call.$2 == '/upload/drive/v3/files')
        .single;
    expect(upload, isNotNull);
  });

  test('restoreLatestBackup downloads the newest app-data backup', () async {
    final source = await seededDatabase('DriveRestoreSource');
    addTearDown(source.close);
    final backupJson = await DatabaseBackupService.buildBackupJson(source);

    final client = FakeDriveClient([
      (
        method: 'GET',
        path: '/drive/v3/files',
        status: 200,
        // The service asks Drive for modifiedTime-desc order and takes the
        // first entry, so the fixture must mirror that contract.
        body: jsonEncode({
          'files': [
            {
              'id': 'newer',
              'name': 'vittix_invoice_backup_new.json',
              'modifiedTime': '2026-07-01T00:00:00Z',
            },
            {
              'id': 'older',
              'name': 'vittix_invoice_backup_old.json',
              'modifiedTime': '2026-06-01T00:00:00Z',
            },
          ],
        }),
      ),
      (
        method: 'GET',
        path: '/drive/v3/files/newer',
        status: 200,
        body: backupJson,
      ),
    ]);
    final service = GoogleDriveService.forTests(apiFor(client));

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    final activeId = await service.restoreLatestBackup(target);

    expect(activeId, 1);
    expect(await target.select(target.businesses).get(), hasLength(1));
    // The listing must request newest-first ordering.
    expect(client.listQueryContainsOrderBy, isTrue);
    expect(
      client.calls.where((call) => call.$2 == '/drive/v3/files/older').isEmpty,
      isTrue,
      reason: 'the older backup must not be downloaded',
    );
  });

  test('restore fails loudly when the app data folder is empty', () async {
    final client = FakeDriveClient([
      (
        method: 'GET',
        path: '/drive/v3/files',
        status: 200,
        body: '{"files": []}',
      ),
    ]);
    final service = GoogleDriveService.forTests(apiFor(client));
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);

    expect(
      () => service.restoreLatestBackup(target),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('No cloud backup found'),
        ),
      ),
    );
  });

  test('uploadShareablePdf creates the file and a public reader permission',
      () async {
    final client = FakeDriveClient([
      (
        method: 'POST',
        path: '/upload/drive/v3/files',
        status: 200,
        body: '{"id": "pdf-1", "name": "INV-1.pdf"}',
      ),
      (
        method: 'POST',
        path: '/drive/v3/files/pdf-1/permissions',
        status: 200,
        body: '{"id": "perm-9"}',
      ),
    ]);
    final service = GoogleDriveService.forTests(apiFor(client));

    final result = await service.uploadShareablePdf(
      Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
      'INV-1.pdf',
    );

    expect(result.fileId, 'pdf-1');
    expect(result.publicPermissionId, 'perm-9');
    expect(
      result.webViewLink,
      'https://drive.google.com/file/d/pdf-1/view?usp=sharing',
    );
  });

  test('revokePublicAccess deletes the permission', () async {
    final client = FakeDriveClient([
      (
        method: 'DELETE',
        path: '/drive/v3/files/pdf-1/permissions/perm-9',
        status: 204,
        body: '',
      ),
    ]);
    final service = GoogleDriveService.forTests(apiFor(client));

    await service.revokePublicAccess(
      fileId: 'pdf-1',
      permissionId: 'perm-9',
    );

    expect(client.calls.single, ('DELETE', '/drive/v3/files/pdf-1/permissions/perm-9'));
  });
}
