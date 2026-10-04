
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PdfFonts', () {
    test('bundled PDF fonts are available offline', () async {
      TestWidgetsFlutterBinding.ensureInitialized();

      final regular = await rootBundle.load('assets/fonts/NotoSans-Regular.ttf');
      final bold = await rootBundle.load('assets/fonts/NotoSans-Bold.ttf');
      final devanagari = await rootBundle.load(
        'assets/fonts/NotoSansDevanagari-Regular.ttf',
      );
      final gujarati = await rootBundle.load(
        'assets/fonts/NotoSansGujarati-Regular.ttf',
      );

      expect(regular.lengthInBytes, greaterThan(1000));
      expect(bold.lengthInBytes, greaterThan(1000));
      expect(devanagari.lengthInBytes, greaterThan(1000));
      expect(gujarati.lengthInBytes, greaterThan(1000));
    });
  });
}
