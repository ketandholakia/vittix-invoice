import '../../models/gst_breakdown.dart';

class GstCalculator {
  static GstBreakdown calculate({
    required double taxableAmount,
    required double gstRate,
    required bool isInterState,
    double cessRate = 0,
  }) {
    if (isInterState) {
      final igst = taxableAmount * gstRate / 100;
      final cess = taxableAmount * cessRate / 100;
      return GstBreakdown(
        igst: igst,
        cess: cess,
        total: taxableAmount + igst + cess,
      );
    } else {
      final half = taxableAmount * (gstRate / 2) / 100;
      final cess = taxableAmount * cessRate / 100;
      return GstBreakdown(
        cgst: half,
        sgst: half,
        cess: cess,
        total: taxableAmount + half * 2 + cess,
      );
    }
  }
}
