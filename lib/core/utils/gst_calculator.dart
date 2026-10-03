import '../../models/gst_breakdown.dart';
import 'money.dart';

/// Rate and amount split of a single line item for one supply type.
typedef LineTaxSplit = ({
  double cgstRate,
  double sgstRate,
  double igstRate,
  double cgstAmount,
  double sgstAmount,
  double igstAmount,
  double cessAmount,
  double totalAmount,
});

class GstCalculator {
  static GstBreakdown calculate({
    required double taxableAmount,
    required double gstRate,
    required bool isInterState,
    double cessRate = 0,
  }) {
    if (isInterState) {
      final igst = round2(taxableAmount * gstRate / 100);
      final cess = round2(taxableAmount * cessRate / 100);
      return GstBreakdown(
        igst: igst,
        cess: cess,
        total: round2(taxableAmount + igst + cess),
      );
    } else {
      final half = round2(taxableAmount * (gstRate / 2) / 100);
      final cess = round2(taxableAmount * cessRate / 100);
      return GstBreakdown(
        cgst: half,
        sgst: half,
        cess: cess,
        total: round2(taxableAmount + half * 2 + cess),
      );
    }
  }

  /// Recomputes a line's rate split and tax amounts from its [taxableAmount]
  /// and [gstRate] for the given supply type.
  ///
  /// Used at document-save time so the stored per-line CGST/SGST/IGST always
  /// agrees with the document's `isIgst` flag, even when the customer (and
  /// therefore the supply type) changes after the line was entered.
  static LineTaxSplit splitLine({
    required double taxableAmount,
    required double gstRate,
    required bool isInterState,
    double cessRate = 0,
  }) {
    final breakdown = calculate(
      taxableAmount: taxableAmount,
      gstRate: gstRate,
      isInterState: isInterState,
      cessRate: cessRate,
    );
    final half = gstRate / 2;
    return (
      cgstRate: isInterState ? 0 : half,
      sgstRate: isInterState ? 0 : half,
      igstRate: isInterState ? gstRate : 0,
      cgstAmount: breakdown.cgst,
      sgstAmount: breakdown.sgst,
      igstAmount: breakdown.igst,
      cessAmount: breakdown.cess,
      totalAmount: breakdown.total,
    );
  }
}
