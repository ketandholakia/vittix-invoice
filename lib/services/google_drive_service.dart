import 'dart:convert';
import 'dart:typed_data';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;

import '../database/app_database.dart';
import 'database_backup_service.dart';

class DriveUploadResult {
  final String fileId;
  final String fileName;
  final String? webViewLink;

  const DriveUploadResult({
    required this.fileId,
    required this.fileName,
    this.webViewLink,
  });
}

class GoogleDriveService {
  GoogleDriveService._();

  static final GoogleDriveService instance = GoogleDriveService._();

  static const List<String> _driveScopes = [
    drive.DriveApi.driveAppdataScope,
    drive.DriveApi.driveFileScope,
  ];

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

  Future<DriveUploadResult> uploadBackup(AppDatabase db) async {
    final backupJson = await DatabaseBackupService.buildBackupJson(db);
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

  Future<int?> restoreLatestBackup(AppDatabase db) async {
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
    return DatabaseBackupService.restoreFromJson(db, jsonString);
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

    if (shareable) {
      await api.permissions.create(
        drive.Permission(
          type: 'anyone',
          role: 'reader',
        ),
        uploaded.id!,
      );
    }

    return DriveUploadResult(
      fileId: uploaded.id!,
      fileName: uploaded.name ?? fileName,
      webViewLink: _shareableLink(uploaded.id!),
    );
  }

  Future<drive.DriveApi> _driveApi() async {
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
