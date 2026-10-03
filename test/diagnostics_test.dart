import 'package:flutter_test/flutter_test.dart';
import 'package:vittix_invoice/core/utils/app_diagnostics.dart';

void main() {
  test('reportNonFatal records into the bounded ring', () {
    diagnosticsLog.clear();

    for (var i = 0; i < 250; i++) {
      reportNonFatal(
        StateError('failure $i'),
        StackTrace.current,
        context: 'test context $i',
      );
    }

    // The ring keeps only the newest maxRecords entries.
    expect(diagnosticsLog.records.length, 200);
    expect(diagnosticsLog.records.first.context, 'test context 50');
    expect(diagnosticsLog.records.last.context, 'test context 249');
  });

  test('exportDiagnostics renders a readable log', () {
    diagnosticsLog.clear();

    final empty = exportDiagnostics();
    expect(empty, contains('No non-fatal failures recorded'));

    reportNonFatal(
      const FormatException('broken envelope'),
      StackTrace.current,
      context: 'backup decrypt',
    );

    final exported = exportDiagnostics();
    expect(exported, contains('backup decrypt'));
    expect(exported, contains('broken envelope'));
    expect(exported, contains('1 record(s)'));
  });
}
