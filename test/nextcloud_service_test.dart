import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:vittix_invoice/database/app_database.dart';
import 'package:vittix_invoice/providers/nextcloud_provider.dart';
import 'package:vittix_invoice/services/database_backup_service.dart';
import 'package:vittix_invoice/services/nextcloud_service.dart';

/// A scripted HTTP client: pops one [Route] per request and records every
/// request for assertions.
class FakeHttpClient extends http.BaseClient {
  FakeHttpClient(this.routes);

  final List<({String method, String pathContains, int status, String body,
      Map<String, String> headers})> routes;
  final List<http.BaseRequest> requests = [];
  final List<String> bodies = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    requests.add(request);
    // http.Request keeps its body as a plain field until finalization, and
    // this fake never finalizes, so the payload stays inspectable.
    bodies.add(request is http.Request ? request.body : '');
    final index = routes.indexWhere(
      (route) =>
          request.method == route.method &&
          request.url.toString().contains(route.pathContains),
    );
    if (index < 0) {
      throw StateError(
        'No scripted route for ${request.method} ${request.url}',
      );
    }
    final route = routes.removeAt(index);
    return http.StreamedResponse(
      Stream.value(utf8.encode(route.body)),
      route.status,
      headers: route.headers,
    );
  }
}

NextcloudConfig config(String serverUrl) => NextcloudConfig(
      serverUrl: serverUrl,
      username: 'user',
      password: 'token',
    );

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

const propfindTwoBackups = '''
<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/remote.php/webdav/VittixInvoiceBackups/</d:href>
    <d:propstat><d:prop><d:getlastmodified>Mon, 01 Jun 2026 00:00:00 GMT</d:getlastmodified></d:prop></d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/webdav/VittixInvoiceBackups/vittix_invoice_backup_older.json</d:href>
    <d:propstat><d:prop><d:getlastmodified>Mon, 01 Jun 2026 00:00:00 GMT</d:getlastmodified></d:prop></d:propstat>
  </d:response>
  <d:response>
    <d:href>/remote.php/webdav/VittixInvoiceBackups/vittix_invoice_backup_newer.json</d:href>
    <d:propstat><d:prop><d:getlastmodified>Wed, 01 Jul 2026 08:00:00 GMT</d:getlastmodified></d:prop></d:propstat>
  </d:response>
</d:multistatus>
''';

void main() {
  test('uploadBackup creates the folder when missing and PUTs a backup', () async {
    final source = await seededDatabase('Upload');
    addTearDown(source.close);
    final client = FakeHttpClient([
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 404,
        body: '',
        headers: const {},
      ),
      (
        method: 'MKCOL',
        pathContains: 'VittixInvoiceBackups',
        status: 201,
        body: '',
        headers: const {},
      ),
      (
        method: 'PUT',
        pathContains: 'vittix_invoice_backup_',
        status: 201,
        body: '',
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);

    final result = await service.uploadBackup(source, config('cloud.example.com'));

    expect(result.fileName, startsWith('vittix_invoice_backup_'));
    expect(result.fileName, endsWith('.json'));

    final put = client.requests
        .where((request) => request.method == 'PUT')
        .single;
    // The PUT body must be the real backup JSON, not an empty payload.
    final body = client.bodies[client.requests.indexOf(put)];
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    expect(decoded['schemaVersion'], greaterThan(0));
    // Every request carries the basic-auth header over https.
    expect(put.url.scheme, 'https');
    for (final request in client.requests) {
      expect(request.headers['Authorization'], startsWith('Basic '));
    }
  });

  test('restoreLatestBackup picks the newest file and restores it', () async {
    final source = await seededDatabase('RestoreSource');
    addTearDown(source.close);
    final backupJson = await DatabaseBackupService.buildBackupJson(source);

    final client = FakeHttpClient([
      // Folder-existence probe (Depth 0) followed by the Depth-1 listing.
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: '',
        headers: const {},
      ),
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: propfindTwoBackups,
        headers: const {},
      ),
      (
        method: 'GET',
        pathContains: 'vittix_invoice_backup_newer.json',
        status: 200,
        body: backupJson,
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);

    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    final activeId = await service.restoreLatestBackup(
      target,
      config('cloud.example.com'),
    );

    expect(activeId, 1);
    expect(await target.select(target.businesses).get(), hasLength(1));
    // The older backup must not have been downloaded.
    expect(
      client.requests
          .where((request) => request.url.toString().contains('older'))
          .isEmpty,
      isTrue,
    );
  });

  test('an empty backup folder is reported as no backup found', () async {
    final client = FakeHttpClient([
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: '',
        headers: const {},
      ),
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: '''
<?xml version="1.0" encoding="utf-8"?>
<d:multistatus xmlns:d="DAV:">
  <d:response>
    <d:href>/remote.php/webdav/VittixInvoiceBackups/</d:href>
    <d:propstat><d:prop><d:getlastmodified>Mon, 01 Jun 2026 00:00:00 GMT</d:getlastmodified></d:prop></d:propstat>
  </d:response>
</d:multistatus>
''',
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);

    expect(
      () => service.restoreLatestBackup(target, config('cloud.example.com')),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          contains('No cloud backup found'),
        ),
      ),
    );
  });

  test('a broken listing surfaces as a read error, not "no backup"', () async {
    // Truncated/garbage responses (proxies, cancelled uploads) used to be
    // swallowed into a misleading "No cloud backup found".
    final client = FakeHttpClient([
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: '',
        headers: const {},
      ),
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 200,
        body: '<?xml version="1.0"?><d:multistatus><d:response>',
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);

    expect(
      () => service.restoreLatestBackup(target, config('cloud.example.com')),
      throwsA(
        isA<StateError>().having(
          (error) => error.message,
          'message',
          allOf(contains('Could not read the backup listing'),
              isNot(contains('No cloud backup found'))),
        ),
      ),
    );
  });

  test('server errors on listing propagate with the status code', () async {
    final client = FakeHttpClient([
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 507,
        body: '',
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);

    expect(
      () => service.restoreLatestBackup(target, config('cloud.example.com')),
      throwsA(
        isA<StateError>()
            .having((error) => error.message, 'message', contains('507')),
      ),
    );
  });

  test('upload fails loudly when the server rejects the PUT', () async {
    final source = await seededDatabase('UploadFail');
    addTearDown(source.close);
    final client = FakeHttpClient([
      (
        method: 'PROPFIND',
        pathContains: 'VittixInvoiceBackups',
        status: 207,
        body: '',
        headers: const {},
      ),
      (
        method: 'PUT',
        pathContains: 'vittix_invoice_backup_',
        status: 507,
        body: '',
        headers: const {},
      ),
    ]);
    final service = NextcloudService.forTests(client);

    expect(
      () => service.uploadBackup(source, config('cloud.example.com')),
      throwsA(
        isA<StateError>()
            .having((error) => error.message, 'message', contains('507')),
      ),
    );
  });
}
