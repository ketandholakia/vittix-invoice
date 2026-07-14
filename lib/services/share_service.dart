import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  static Future<void> sharePdf(
    Uint8List pdfData,
    String fileName, {
    String? subject,
    String? text,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(pdfData);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: text ?? 'Attached PDF.',
        subject: subject ?? fileName,
      ),
    );
  }

  static Future<void> shareCsv(
    List<List<String>> rows,
    String fileName, {
    String? subject,
    String? text,
  }) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    final csv = rows.map(_csvRow).join('\n');
    await file.writeAsString(csv, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: text ?? 'CSV export attached.',
        subject: subject ?? fileName,
      ),
    );
  }

  static Future<void> shareText(
    String text, {
    String? subject,
  }) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject),
    );
  }

  static String _csvRow(List<String> values) {
    return values
        .map((value) {
          final escaped = value.replaceAll('"', '""');
          return '"$escaped"';
        })
        .join(',');
  }
}
