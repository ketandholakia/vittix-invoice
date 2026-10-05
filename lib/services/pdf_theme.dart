part of 'pdf_service.dart';

// Bundled fonts, themes and the logo cache for the PDF pipeline.

pw.MemoryImage? _getLogoImage(Business business) {
  if (business.logoPath != null && File(business.logoPath!).existsSync()) {
    return pw.MemoryImage(File(business.logoPath!).readAsBytesSync());
  }
  return null;
}
final Map<String, ByteData> _fontDataCache = {};
Future<ByteData> _loadFontAsset(String asset) async {
  final cached = _fontDataCache[asset];
  if (cached != null) return cached;
  final data = await rootBundle.load(asset);
  _fontDataCache[asset] = data;
  return data;
}
Future<List<pw.Font>> _indicFallbacks() async => [
  pw.Font.ttf(
    await _loadFontAsset('assets/fonts/NotoSansDevanagari-Regular.ttf'),
  ),
  pw.Font.ttf(
    await _loadFontAsset('assets/fonts/NotoSansGujarati-Regular.ttf'),
  ),
];

/// The default theme, built from fonts bundled with the app. This replaces
/// the built-in Helvetica (which cannot draw the rupee sign or Indic text)
/// and needs no network access.
Future<pw.ThemeData> _bundledTheme() async => pw.ThemeData.withFont(
  base: pw.Font.ttf(
    await _loadFontAsset('assets/fonts/NotoSans-Regular.ttf'),
  ),
  bold: pw.Font.ttf(await _loadFontAsset('assets/fonts/NotoSans-Bold.ttf')),
  fontFallback: await _indicFallbacks(),
);

Future<pw.ThemeData?> _getThemeForFont(String? fontFamily) async {
  final bundled = await _bundledTheme();
  if (fontFamily == null || fontFamily.isEmpty) return bundled;

  // A named template font is fetched on demand; if it is unavailable (for
  // example offline) fall back to the bundled fonts rather than Helvetica.
  try {
    pw.Font? baseFont;
    pw.Font? boldFont;
    switch (fontFamily) {
      case 'Open Sans':
        baseFont = await PdfGoogleFonts.openSansRegular();
        boldFont = await PdfGoogleFonts.openSansBold();
        break;
      case 'Lato':
        baseFont = await PdfGoogleFonts.latoRegular();
        boldFont = await PdfGoogleFonts.latoBold();
        break;
      case 'Montserrat':
        baseFont = await PdfGoogleFonts.montserratRegular();
        boldFont = await PdfGoogleFonts.montserratBold();
        break;
      default:
        baseFont = await PdfGoogleFonts.robotoRegular();
        boldFont = await PdfGoogleFonts.robotoBold();
    }
    return pw.ThemeData.withFont(
      base: baseFont,
      bold: boldFont,
      fontFallback: await _indicFallbacks(),
    );
  } catch (_) {
    return bundled;
  }
}
