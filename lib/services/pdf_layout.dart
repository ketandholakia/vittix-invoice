/// Pure layout and parsing helpers for the PDF pipeline.
///
/// Extracted from `PdfService` so the decisions that shape every rendered
/// document — paper size, colors, density metrics, table borders, the UPI QR
/// payload — are unit-testable without rendering.
library;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../database/app_database.dart';
import '../models/invoice_template_config.dart';

/// Paper size from a template's `paperSize` code. Unknown codes fall back to
/// A4. Thermal uses a tall fixed page rather than an unbounded roll height,
/// which `MultiPage` rejects with an assertion — receipts longer than 80 cm
/// paginate instead of crashing the render.
PdfPageFormat pageFormatFor(String paperSize) {
  switch (paperSize.toLowerCase()) {
    case 'a5':
      return PdfPageFormat.a5;
    case 'thermal':
      return const PdfPageFormat(80 * PdfPageFormat.mm, 800 * PdfPageFormat.mm);
    case 'a4':
    default:
      return PdfPageFormat.a4;
  }
}

/// Parses `#RRGGBB` (or bare/`RRGGBBAA`) into a [PdfColor], returning
/// [fallback] for anything malformed or empty.
PdfColor parseColor(String hexString, PdfColor fallback) {
  if (hexString.isEmpty) return fallback;
  try {
    final hexCode = hexString.replaceAll('#', '');
    if (hexCode.length == 6) {
      return PdfColor.fromInt(int.parse(hexCode, radix: 16) | 0xFF000000);
    } else if (hexCode.length == 8) {
      return PdfColor.fromInt(int.parse(hexCode, radix: 16));
    }
  } catch (_) {}
  return fallback;
}

/// The brand color a template renders with: the template's explicit color
/// wins, then the business's brand color, then indigo.
PdfColor brandColorFor(Business business, InvoiceTemplateConfig config) {
  if (config.primaryColor.isNotEmpty) {
    return parseColor(config.primaryColor, PdfColors.indigo);
  }
  return business.brandColor != null
      ? PdfColor.fromInt(business.brandColor!)
      : PdfColors.indigo;
}

double headerTitleSize(String density) {
  switch (density) {
    case 'COMPACT':
      return 20;
    case 'SPACIOUS':
      return 28;
    default:
      return 24;
  }
}

double headerSubtitleSize(String density) {
  switch (density) {
    case 'COMPACT':
      return 9;
    case 'SPACIOUS':
      return 12;
    default:
      return 11;
  }
}

double headerGap(String density) {
  switch (density) {
    case 'COMPACT':
      return 4;
    case 'SPACIOUS':
      return 12;
    default:
      return 8;
  }
}

/// Returns a [pw.TableBorder] matching the template's `tableBorderStyle`.
pw.TableBorder tableBorderFor(InvoiceTemplateConfig config) {
  switch (config.tableBorderStyle) {
    case 'ROWS_ONLY':
      return pw.TableBorder(
        horizontalInside: pw.BorderSide(
          color: PdfColors.grey300,
          width: config.borderThickness,
        ),
        bottom: pw.BorderSide(
          color: PdfColors.grey300,
          width: config.borderThickness,
        ),
      );
    case 'NONE':
      return const pw.TableBorder();
    case 'FULL':
    default:
      return pw.TableBorder.all(
        color: PdfColors.grey300,
        width: config.borderThickness,
      );
  }
}

/// The UPI intent URI a payment QR encodes. Without a UPI id the payload
/// degrades to a human-readable line so the QR still identifies the invoice.
String buildUpiQrPayload({
  required String businessName,
  String? upiId,
  required double amount,
  required String invoiceNumber,
}) {
  final id = upiId?.trim();
  if (id == null || id.isEmpty) {
    return '$businessName | $invoiceNumber | ${amount.toStringAsFixed(2)}';
  }

  final pa = Uri.encodeComponent(id);
  final pn = Uri.encodeComponent(businessName);
  final tn = Uri.encodeComponent('Invoice $invoiceNumber');
  final am = amount.toStringAsFixed(2);
  return 'upi://pay?pa=$pa&pn=$pn&tn=$tn&am=$am&cu=INR';
}
