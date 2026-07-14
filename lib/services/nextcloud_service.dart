import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../database/app_database.dart';
import '../providers/nextcloud_provider.dart';
import 'database_backup_service.dart';

class NextcloudUploadResult {
  final String fileName;

  const NextcloudUploadResult({
    required this.fileName,
  });
}

class NextcloudService {
  NextcloudService._();

  static final NextcloudService instance = NextcloudService._();
  static const _backupFolder = 'VittixInvoiceBackups';

  String _buildAuthHeader(NextcloudConfig config) {
    final credentials = '${config.username}:${config.password}';
    final base64Credentials = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Credentials';
  }

  String _buildBaseUrl(NextcloudConfig config) {
    var url = config.serverUrl;
    if (!url.endsWith('/')) {
      url += '/';
    }
    // Try to ensure we point to the webdav root
    if (!url.contains('/remote.php/webdav/')) {
      url += 'remote.php/webdav/';
    }
    return url;
  }

  Future<void> _ensureBackupDirectory(NextcloudConfig config) async {
    final baseUrl = _buildBaseUrl(config);
    final folderUrl = Uri.parse('$baseUrl$_backupFolder');
    
    final response = await http.Client().send(
      http.Request('PROPFIND', folderUrl)
        ..headers['Authorization'] = _buildAuthHeader(config)
        ..headers['Depth'] = '0',
    );

    if (response.statusCode == 404) {
      // Create folder
      final createResponse = await http.Client().send(
        http.Request('MKCOL', folderUrl)
          ..headers['Authorization'] = _buildAuthHeader(config),
      );
      if (createResponse.statusCode >= 400) {
        throw StateError('Failed to create backup directory on Nextcloud');
      }
    } else if (response.statusCode >= 400) {
      throw StateError('Failed to connect to Nextcloud (Status: ${response.statusCode})');
    }
  }

  Future<NextcloudUploadResult> uploadBackup(
    AppDatabase db,
    NextcloudConfig config,
  ) async {
    if (!config.isValid) throw StateError('Invalid Nextcloud configuration');

    await _ensureBackupDirectory(config);

    final backupJson = await DatabaseBackupService.buildBackupJson(db);
    final fileName =
        'vittix_invoice_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    
    final baseUrl = _buildBaseUrl(config);
    final fileUrl = Uri.parse('$baseUrl$_backupFolder/$fileName');

    final response = await http.Client().send(
      http.Request('PUT', fileUrl)
        ..headers['Authorization'] = _buildAuthHeader(config)
        ..headers['Content-Type'] = 'application/json'
        ..bodyBytes = utf8.encode(backupJson),
    );

    if (response.statusCode >= 400) {
      throw StateError('Failed to upload backup to Nextcloud (Status: ${response.statusCode})');
    }

    return NextcloudUploadResult(fileName: fileName);
  }

  Future<int?> restoreLatestBackup(
    AppDatabase db,
    NextcloudConfig config,
  ) async {
    if (!config.isValid) throw StateError('Invalid Nextcloud configuration');

    await _ensureBackupDirectory(config);

    final baseUrl = _buildBaseUrl(config);
    final folderUrl = Uri.parse('$baseUrl$_backupFolder/');

    final propfindBody = '''<?xml version="1.0" encoding="utf-8" ?>
<d:propfind xmlns:d="DAV:">
  <d:prop>
    <d:getlastmodified/>
  </d:prop>
</d:propfind>''';

    final response = await http.Client().send(
      http.Request('PROPFIND', folderUrl)
        ..headers['Authorization'] = _buildAuthHeader(config)
        ..headers['Depth'] = '1'
        ..headers['Content-Type'] = 'application/xml'
        ..body = propfindBody,
    );

    if (response.statusCode >= 400) {
      throw StateError('Failed to list backups on Nextcloud (Status: ${response.statusCode})');
    }

    final responseBody = await response.stream.bytesToString();
    final latestFileName = _parseLatestFileFromPropfind(responseBody, folderUrl.path);
    
    if (latestFileName == null) {
      throw StateError('No cloud backup found on Nextcloud');
    }

    final fileUrl = Uri.parse('$baseUrl$_backupFolder/$latestFileName');
    final getResponse = await http.get(
      fileUrl,
      headers: {'Authorization': _buildAuthHeader(config)},
    );

    if (getResponse.statusCode >= 400) {
      throw StateError('Failed to download backup from Nextcloud (Status: ${getResponse.statusCode})');
    }

    final jsonString = utf8.decode(getResponse.bodyBytes);
    return DatabaseBackupService.restoreFromJson(db, jsonString);
  }

  String? _parseLatestFileFromPropfind(String xmlString, String basePath) {
    try {
      final document = xml.XmlDocument.parse(xmlString);
      final responses = document.findAllElements('d:response');
      
      String? latestFile;
      DateTime? latestDate;

      for (final resp in responses) {
        final href = resp.findElements('d:href').firstOrNull?.innerText;
        if (href == null || href.endsWith('/')) continue; // Skip directories

        final propstat = resp.findElements('d:propstat').firstOrNull;
        final prop = propstat?.findElements('d:prop').firstOrNull;
        final getlastmodified = prop?.findElements('d:getlastmodified').firstOrNull?.innerText;

        if (href.isNotEmpty && getlastmodified != null) {
          final fileName = Uri.decodeComponent(href.split('/').last);
          if (fileName.endsWith('.json')) {
            // WebDAV uses RFC 1123 date format
            final date = HttpDate.parse(getlastmodified);
            if (latestDate == null || date.isAfter(latestDate)) {
              latestDate = date;
              latestFile = fileName;
            }
          }
        }
      }
      return latestFile;
    } catch (e) {
      return null;
    }
  }
}
