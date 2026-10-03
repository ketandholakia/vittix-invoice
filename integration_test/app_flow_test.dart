import 'package:integration_test/integration_test.dart';
import '../test/end_to_end_flow_test.dart' as flow;

/// On-device runner for the end-to-end document pipeline smoke test.
/// The flow itself lives in `test/end_to_end_flow_test.dart` so the same code
/// also runs in the plain `flutter test` VM.
///
/// Run with:
///   flutter test integration_test -d `<device-id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  flow.main();
}