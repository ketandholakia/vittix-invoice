import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;
import '../core/utils/app_diagnostics.dart';
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
  /// The [client] seam exists for tests; production always uses the
  /// [instance] singleton with a real client.
  NextcloudService._([http.Client? client]) : _client = client ?? http.Client();

  static final NextcloudService instance = NextcloudService._();

  /// Builds a service over a scripted client; production code uses
  /// [instance].
  @visibleForTesting
  NextcloudService.forTests(http.Client client) : this._(client);

  static const _backupFolder = 'VittixInvoiceBackups';

  /// Single client reused for every request. Creating a client per request
  /// leaked a connection pool each time.
  final http.Client _client;

  static const _controlTimeout = Duration(seconds: 30);
  static const _dataTimeout = Duration(seconds: 120);

  /// Runs [action], retrying once on transient network failures (connection
  /// drops, timeouts). Requests are rebuilt by the closure, so retrying never
  /// re-sends a consumed body.
  Future<T> _withRetry<T>(
    Future<T> Function() action, {
    required String context,
  }) async {
    try {
      return await action();
    } on SocketException catch (error, stackTrace) {
      reportNonFatal(error, stackTrace, context: 'nextcloud $context (retrying)');
      return action();
    } on TimeoutException catch (error, stackTrace) {
      reportNonFatal(error, stackTrace, context: 'nextcloud $context (retrying)');
      return action();
    }
  }

  String _buildAuthHeader(NextcloudConfig config) {
    final credentials = '${config.username}:${config.password}';
    final base64Credentials = base64Encode(utf8.encode(credentials));
    return 'Basic $base64Credentials';
  }

  /// Returns an actionable error message for an invalid or insecure server
  /// URL, or `null` when the URL may be used. Plain `http://` is always
  /// rejected; schemeless input is allowed and normalized to `https://` by
  /// [buildBaseUrl].
  static String? validateServerUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      return 'Enter a Nextcloud server URL.';
    }
    final uri = Uri.tryParse(trimmed);
    if (uri == null ||
        (uri.scheme.isNotEmpty && uri.scheme != 'https' && uri.scheme != 'http')) {
      return 'Enter a valid Nextcloud server URL.';
    }
    if (uri.scheme == 'http') {
      return 'HTTP is not allowed for security reasons. '
          'Use an https:// server URL.';
    }
    return null;
  }

  /// Builds the WebDAV base URL, enforcing HTTPS for credentials in transit.
  static String buildBaseUrl(NextcloudConfig config) {
    var url = config.serverUrl.trim();
    if (url.isEmpty) {
      throw StateError('Enter a Nextcloud server URL.');
    }
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final error = validateServerUrl(url);
    if (error != null) {
      throw StateError(error);
    }
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
    final baseUrl = buildBaseUrl(config);
    final folderUrl = Uri.parse('$baseUrl$_backupFolder');
    
    final response = await _withRetry(
      () => _client
          .send(
            http.Request('PROPFIND', folderUrl)
              ..headers['Authorization'] = _buildAuthHeader(config)
              ..headers['Depth'] = '0',
          )
          .timeout(_controlTimeout),
      context: 'folder probe',
    );

    if (response.statusCode == 404) {
      // Create folder
      final createResponse = await _client.send(
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
    NextcloudConfig config, {
    String? passphrase,
  }) async {
    if (!config.isValid) throw StateError('Invalid Nextcloud configuration');

    await _ensureBackupDirectory(config);

    final backupJson = await DatabaseBackupService.buildBackupJson(
      db,
      passphrase: passphrase,
    );
    final fileName =
        'vittix_invoice_backup_${DateTime.now().toIso8601String().replaceAll(':', '-')}.json';
    
    final baseUrl = buildBaseUrl(config);
    final fileUrl = Uri.parse('$baseUrl$_backupFolder/$fileName');

    final response = await _withRetry(
      () => _client
          .send(
            http.Request('PUT', fileUrl)
              ..headers['Authorization'] = _buildAuthHeader(config)
              ..headers['Content-Type'] = 'application/json'
              ..bodyBytes = utf8.encode(backupJson),
          )
          .timeout(_dataTimeout),
      context: 'backup upload',
    );

    if (response.statusCode >= 400) {
      throw StateError('Failed to upload backup to Nextcloud (Status: ${response.statusCode})');
    }

    return NextcloudUploadResult(fileName: fileName);
  }

  Future<int?> restoreLatestBackup(
    AppDatabase db,
    NextcloudConfig config, {
    String? passphrase,
  }) async {
    if (!config.isValid) throw StateError('Invalid Nextcloud configuration');

    await _ensureBackupDirectory(config);

    final baseUrl = buildBaseUrl(config);
    final folderUrl = Uri.parse('$baseUrl$_backupFolder/');

    final propfindBody = '''<?xml version="1.0" encoding="utf-8" ?>
<d:propfind xmlns:d="DAV:">
  <d:prop>
    <d:getlastmodified/>
  </d:prop>
</d:propfind>''';

    final response = await _withRetry(
      () => _client
          .send(
            http.Request('PROPFIND', folderUrl)
              ..headers['Authorization'] = _buildAuthHeader(config)
              ..headers['Depth'] = '1'
              ..headers['Content-Type'] = 'application/xml'
              ..body = propfindBody,
          )
          .timeout(_controlTimeout),
      context: 'backup listing',
    );

    if (response.statusCode >= 400) {
      throw StateError('Failed to list backups on Nextcloud (Status: ${response.statusCode})');
    }

    final responseBody = await response.stream.bytesToString();
    final String? latestFileName;
    try {
      latestFileName = _parseLatestFileFromPropfind(responseBody, folderUrl.path);
    } on Exception catch (error, stackTrace) {
      reportNonFatal(
        error,
        stackTrace,
        context: 'nextcloud backup listing parse',
      );
      throw StateError(
        'Could not read the backup listing from Nextcloud. '
        'Check the server URL and sign in again.',
      );
    }
    
    if (latestFileName == null) {
      throw StateError('No cloud backup found on Nextcloud');
    }

    final fileUrl = Uri.parse('$baseUrl$_backupFolder/$latestFileName');
    final getResponse = await _withRetry(
      () => _client
          .get(fileUrl, headers: {'Authorization': _buildAuthHeader(config)})
          .timeout(_dataTimeout),
      context: 'backup download',
    );

    if (getResponse.statusCode >= 400) {
      throw StateError('Failed to download backup from Nextcloud (Status: ${getResponse.statusCode})');
    }

    final jsonString = utf8.decode(getResponse.bodyBytes);
    return DatabaseBackupService.restoreFromJson(
      db,
      jsonString,
      passphrase: passphrase,
    );
  }

  /// Returns the newest `.json` backup file name in the listing, or null when
  /// the folder parsed cleanly but holds no backups.
  ///
  /// A response that cannot be parsed at all throws instead of masquerading
  /// as an empty folder — "No cloud backup found" used to hide server errors,
  /// proxy HTML login pages, and XML shape changes from the user.
  String? _parseLatestFileFromPropfind(String xmlString, String basePath) {
    final document = xml.XmlDocument.parse(xmlString);
    final responses = document.findAllElements('d:response');

    String? latestFile;
    DateTime? latestDate;

    for (final resp in responses) {
      final href = resp.findElements('d:href').firstOrNull?.innerText;
      if (href == null || href.endsWith('/')) continue; // Skip directories

      final propstat = resp.findElements('d:propstat').firstOrNull;
      final prop = propstat?.findElements('d:prop').firstOrNull;
      final getlastmodified =
          prop?.findElements('d:getlastmodified').firstOrNull?.innerText;

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
  }
}
