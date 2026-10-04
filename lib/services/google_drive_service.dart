import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../database/app_database.dart';
import 'database_backup_service.dart';

class DriveUploadResult {
  final String fileId;
  final String fileName;
  final String? webViewLink;

  /// Id of the public "anyone with the link" permission, when one was created.
  /// Kept so the share can be revoked later.
  final String? publicPermissionId;

  const DriveUploadResult({
    required this.fileId,
    required this.fileName,
    this.webViewLink,
    this.publicPermissionId,
  });
}

class GoogleDriveService {
  /// The [testApi] seam exists for tests: a `DriveApi` backed by a fake HTTP
  /// client exercises upload/list/restore without Google Sign-In. Production
  /// always uses the [instance] singleton, which signs in for real.
  GoogleDriveService._([drive.DriveApi? testApi]) : _testApi = testApi;

  static final GoogleDriveService instance = GoogleDriveService._();

  /// Builds a service over a scripted Drive API; production code uses
  /// [instance], which signs in for real.
  @visibleForTesting
  GoogleDriveService.forTests(drive.DriveApi api) : this._(api);

  static const List<String> _driveScopes = [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ];

  final drive.DriveApi? _testApi;
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize();
    _initialized = true;
  }

  Future<GoogleSignInAccount?> currentAccount() async {
    await _ensureInitialized();
    final lightweight = GoogleSignIn.instance.attemptLightweightAuthentication(
      reportAllExceptions: false,
    );
    return lightweight == null ? null : await lightweight;
  }

  Future<GoogleSignInAccount> signIn() async {
    await _ensureInitialized();
    return GoogleSignIn.instance.authenticate(scopeHint: _driveScopes);
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }

  Future<DriveUploadResult> uploadBackup(
    AppDatabase db, {
    String? passphrase,
  }) async {
    final backupJson = await DatabaseBackupService.buildBackupJson(
      db,
      passphrase: passphrase,
    );
    final fileName =
        'vittix_invoice_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    return _uploadText(
      backupJson,
      fileName,
      mimeType: 'application/json',
      parentFolder: 'appDataFolder',
      shareable: false,
    );
  }

  Future<int?> restoreLatestBackup(
    AppDatabase db, {
    String? passphrase,
  }) async {
    final api = await _driveApi();
    final listing = await api.files.list(
      spaces: 'appDataFolder',
      orderBy: 'modifiedTime desc',
      $fields: 'files(id,name,modifiedTime)',
    );
    final latest = listing.files?.firstWhere(
      (file) => file.id != null,
      orElse: () => throw StateError('No cloud backup found'),
    );
    if (latest == null || latest.id == null) {
      throw StateError('No cloud backup found');
    }

    final media = await api.files.get(
      latest.id!,
      downloadOptions: drive.DownloadOptions.fullMedia,
    ) as drive.Media;
    final jsonString = await utf8.decoder.bind(media.stream).join();
    return DatabaseBackupService.restoreFromJson(
      db,
      jsonString,
      passphrase: passphrase,
    );
  }

  Future<DriveUploadResult> uploadShareablePdf(
    Uint8List bytes,
    String fileName, {
    String? description,
  }) async {
    final result = await _uploadBytes(
      bytes,
      fileName,
      mimeType: 'application/pdf',
      shareable: true,
      description: description,
    );
    return result;
  }

  Future<DriveUploadResult> _uploadText(
    String text,
    String fileName, {
    required String mimeType,
    required String parentFolder,
    required bool shareable,
    String? description,
  }) async {
    final bytes = utf8.encode(text);
    return _uploadBytes(
      Uint8List.fromList(bytes),
      fileName,
      mimeType: mimeType,
      parentFolder: parentFolder,
      shareable: shareable,
      description: description,
    );
  }

  Future<DriveUploadResult> _uploadBytes(
    Uint8List bytes,
    String fileName, {
    required String mimeType,
    String? parentFolder,
    required bool shareable,
    String? description,
  }) async {
    final api = await _driveApi();
    final file = drive.File()
      ..name = fileName
      ..mimeType = mimeType
      ..description = description;
    if (parentFolder != null) {
      file.parents = [parentFolder];
    }

    final media = drive.Media(
      Stream<List<int>>.value(bytes),
      bytes.length,
      contentType: mimeType,
    );
    final uploaded = await api.files.create(
      file,
      uploadMedia: media,
      $fields: 'id,name,webViewLink',
    );
    if (uploaded.id == null) {
      throw StateError('Drive upload did not return a file id');
    }

    String? publicPermissionId;

    if (shareable) {
      final permission = await api.permissions.create(
        drive.Permission(
          type: 'anyone',
          role: 'reader',
        ),
        uploaded.id!,
      );
      publicPermissionId = permission.id;
    }

    return DriveUploadResult(
      fileId: uploaded.id!,
      fileName: uploaded.name ?? fileName,
      webViewLink: _shareableLink(uploaded.id!),
      publicPermissionId: publicPermissionId,
    );
  }

  /// Removes public ("anyone with the link") access from a shared file.
  ///
  /// Call this once the recipient no longer needs the link — the PDF contains
  /// GSTIN, address and possibly bank/UPI details.
  Future<void> revokePublicAccess({
    required String fileId,
    String? permissionId,
  }) async {
    final api = await _driveApi();
    await api.permissions.delete(fileId, permissionId ?? 'anyoneWithLink');
  }

  Future<drive.DriveApi> _driveApi() async {
    if (_testApi != null) return _testApi;
    await _ensureInitialized();
    final account = await currentAccount() ?? await signIn();
    final headers = await account.authorizationClient.authorizationHeaders(
      _driveScopes,
      promptIfNecessary: true,
    );
    if (headers == null) {
      throw StateError('Google account not connected');
    }
    return drive.DriveApi(_GoogleAuthClient(headers));
  }

  String _shareableLink(String fileId) =>
      'https://drive.google.com/file/d/$fileId/view?usp=sharing';
}

class _GoogleAuthClient extends http.BaseClient {
  _GoogleAuthClient(this._headers);

  final Map<String, String> _headers;
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
