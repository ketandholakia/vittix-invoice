import 'money.dart';

/// Per-line money fields used to build document totals.
typedef LineTotals = ({
  /// Line gross before discount (quantity x rate).
  double gross,
  /// Discount amount (gross - taxable).
  double discount,
  double taxable,
  double cgst,
  double sgst,
  double igst,
  double cess,
});

/// Document-level totals derived from line totals.
class DocumentTotals {
  final double subtotal;
  final double discount;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;

  /// Whole-rupee adjustment applied to reach [grandTotal].
  final double roundOff;
  final double grandTotal;

  /// Tax collected at source (added) and tax deducted at source (subtracted).
  final double tcsAmount;
  final double tdsAmount;

  const DocumentTotals({
    required this.subtotal,
    required this.discount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
    required this.roundOff,
    required this.grandTotal,
    this.tcsAmount = 0,
    this.tdsAmount = 0,
  });
}

/// Sums the line totals, rounds each component to paise, then rounds the
/// payable amount to the nearest rupee and records the difference as the
/// round off.
DocumentTotals computeDocumentTotals(
  Iterable<LineTotals> lines, {
  double tcsAmount = 0,
  double tdsAmount = 0,
  bool applyRoundOff = true,
}) {
  var subtotal = 0.0;
  var discount = 0.0;
  var taxable = 0.0;
  var cgst = 0.0;
  var sgst = 0.0;
  var igst = 0.0;
  var cess = 0.0;

  for (final line in lines) {
    subtotal += line.gross;
    discount += line.discount;
    taxable += line.taxable;
    cgst += line.cgst;
    sgst += line.sgst;
    igst += line.igst;
    cess += line.cess;
  }

  subtotal = round2(subtotal);
  discount = round2(discount);
  taxable = round2(taxable);
  cgst = round2(cgst);
  sgst = round2(sgst);
  igst = round2(igst);
  cess = round2(cess);

  final exactTotal = round2(
    taxable + cgst + sgst + igst + cess + tcsAmount - tdsAmount,
  );

  return DocumentTotals(
    subtotal: subtotal,
    discount: discount,
    taxable: taxable,
    cgst: cgst,
    sgst: sgst,
    igst: igst,
    cess: cess,
    tcsAmount: round2(tcsAmount),
    tdsAmount: round2(tdsAmount),
    roundOff: applyRoundOff ? roundOffForTotal(exactTotal) : 0,
    grandTotal: applyRoundOff ? payableTotal(exactTotal) : exactTotal,
  );
}
