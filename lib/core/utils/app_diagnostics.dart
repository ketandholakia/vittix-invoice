import 'package:flutter/foundation.dart';

/// One captured non-fatal failure.
class DiagnosticsRecord {
  DiagnosticsRecord({
    required this.timestamp,
    required this.context,
    required this.error,
    required this.stackTrace,
  });

  final DateTime timestamp;
  final String context;
  final Object error;
  final StackTrace stackTrace;
}

/// Bounded in-memory ring of recent non-fatal failures.
///
/// Release builds have no console to read, so without this a silently failed
/// backup or notification was invisible to everyone. The ring keeps the last
/// [maxRecords] entries; [exportDiagnostics] formats them for the Settings
/// "export diagnostics" share action. A crash reporter can still be attached
/// at the single [reportNonFatal] seam.
class DiagnosticsLog {
  DiagnosticsLog({this.maxRecords = 200});

  final int maxRecords;
  final List<DiagnosticsRecord> _records = [];

  List<DiagnosticsRecord> get records => List.unmodifiable(_records);

  void add(DiagnosticsRecord record) {
    _records.add(record);
    if (_records.length > maxRecords) {
      _records.removeRange(0, _records.length - maxRecords);
    }
  }

  void clear() => _records.clear();
}

/// App-wide diagnostics ring; kept as a plain global so capture works from
/// anywhere (services, providers, static helpers) without a Ref.
final diagnosticsLog = DiagnosticsLog();

/// Central place for non-fatal error reporting.
///
/// Best-effort work (background sync, silent backups, optional plugin calls)
/// must never break the app, but silently discarding the error makes failures
/// invisible. Everything funnelled through here is recorded in [diagnosticsLog]
/// and surfaced to [FlutterError.reportError], so a crash reporter can be
/// attached in one place later.
void reportNonFatal(
  Object error,
  StackTrace stackTrace, {
  required String context,
}) {
  diagnosticsLog.add(
    DiagnosticsRecord(
      timestamp: DateTime.now(),
      context: context,
      error: error,
      stackTrace: stackTrace,
    ),
  );
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'vittix',
      context: ErrorDescription(context),
    ),
  );
}

/// Renders the ring as a readable text log, newest last.
String exportDiagnostics() {
  final buffer = StringBuffer()
    ..writeln('Vittix Invoice diagnostics')
    ..writeln('Exported ${DateTime.now().toIso8601String()}')
    ..writeln('${diagnosticsLog.records.length} record(s)')
    ..writeln();

  if (diagnosticsLog.records.isEmpty) {
    buffer.writeln('No non-fatal failures recorded this session.');
    return buffer.toString();
  }

  for (final record in diagnosticsLog.records) {
    final local = record.timestamp.toIso8601String();
    buffer
      ..writeln('[$local] ${record.context}')
      ..writeln('  ${record.error}')
      ..writeln('  ${record.stackTrace.toString().split('\n').take(6).join('\n  ')}')
      ..writeln();
  }
  return buffer.toString();
}
