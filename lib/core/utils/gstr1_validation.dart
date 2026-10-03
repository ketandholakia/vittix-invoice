import '../../database/app_database.dart';
import '../constants/gst_states.dart';
import 'gstin_validator.dart';
import 'invoice_status.dart';
import 'invoice_type.dart';

/// One actionable pre-export problem found on one document.
class Gstr1Issue {
  const Gstr1Issue({
    required this.invoiceId,
    required this.invoiceNumber,
    required this.field,
    required this.message,
  });

  /// The invoice row to open when the user taps "fix".
  final int invoiceId;
  final String invoiceNumber;
  final String field;
  final String message;

  @override
  String toString() => '$invoiceNumber — $field: $message';
}

/// Pre-export GST field checks for the GSTR-1 summary.
///
/// Catches documents that would otherwise be silently summarised wrong: a
/// registered customer with a broken GSTIN, lines without an HSN/SAC code
/// (the export buckets those as UNSPECIFIED), and impossible places of
/// supply. Only documents the export would actually count are checked;
/// bills of supply carry no GST to report.
List<Gstr1Issue> validateInvoicesForGstr1({
  required List<Customer> customers,
  required List<Invoice> invoices,
  required List<InvoiceItem> items,
}) {
  final customerById = {for (final customer in customers) customer.id: customer};
  final itemsByInvoice = <int, List<InvoiceItem>>{};
  for (final item in items) {
    itemsByInvoice.putIfAbsent(item.invoiceId, () => []).add(item);
  }

  final issues = <Gstr1Issue>[];
  void add(
    Invoice invoice,
    String field,
    String message,
  ) => issues.add(
    Gstr1Issue(
      invoiceId: invoice.id,
      invoiceNumber: invoice.invoiceNumber,
      field: field,
      message: message,
    ),
  );

  for (final invoice in invoices) {
    if (!isInvoiceCountedInTotals(invoice.status)) continue;
    if (invoice.invoiceType == billOfSupplyType) continue;

    final isForeignSupply =
        invoice.supplyType == 'EXPORT' || invoice.supplyType == 'SEZ';
    final gstin = customerById[invoice.customerId]?.gstin?.trim() ?? '';

    if (isForeignSupply) {
      if (invoice.supplyType == 'SEZ' && gstin.isEmpty) {
        add(
          invoice,
          'GSTIN',
          'SEZ supplies must carry the SEZ unit\u2019s GSTIN.',
        );
      }
      if (gstin.isNotEmpty && !GstinValidator.isValid(gstin)) {
        add(invoice, 'GSTIN', '\u2018$gstin\u2019 is not a valid GSTIN.');
      }
    } else {
      if (invoice.supplyType == 'B2B') {
        if (gstin.isEmpty) {
          add(
            invoice,
            'GSTIN',
            'Marked B2B but the customer has no GSTIN; the export would '
            'report it as B2C.',
          );
        } else if (!GstinValidator.isValid(gstin)) {
          add(invoice, 'GSTIN', '\u2018$gstin\u2019 is not a valid GSTIN.');
        }
      }
      if (!GstStates.states.containsKey(invoice.placeOfSupply)) {
        add(
          invoice,
          'Place of supply',
          '${invoice.placeOfSupply} is not an Indian state code (1-38).',
        );
      }
    }

    for (final item in itemsByInvoice[invoice.id] ?? const <InvoiceItem>[]) {
      final code = item.hsnSac.trim();
      if (code.isEmpty) {
        add(
          invoice,
          'HSN/SAC',
          'Line \u2018${item.name}\u2019 has no HSN/SAC code and would be '
          'reported as UNSPECIFIED.',
        );
      } else if (code.length < 4) {
        add(
          invoice,
          'HSN/SAC',
          '\u2018$code\u2019 on line \u2018${item.name}\u2019 is shorter '
          'than the 4-digit SAC minimum.',
        );
      }
    }

    if (invoice.taxableAmount < 0) {
      add(
        invoice,
        'Taxable amount',
        'Negative taxable amount; correct the document or issue a credit '
        'note instead.',
      );
    }
  }

  return issues;
}
