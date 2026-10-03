/// Rounds a monetary value to two decimal places (paise / cents).
///
/// All money computations must pass through this helper at every boundary
/// (per-item tax, discounts, invoice totals, payments) so that stored values,
/// PDF numerals, and amount-in-words never disagree.
double round2(double value) => (value * 100).round() / 100;

/// The adjustment needed to take [total] to the nearest whole rupee, as shown
/// on the "Round Off" line of an Indian invoice.
///
/// Positive when rounding up, negative when rounding down, zero when [total]
/// is already a whole rupee.
double roundOffForTotal(double total) =>
    round2(total.roundToDouble() - total);

/// The payable amount once [roundOffForTotal] is applied (a whole rupee).
double payableTotal(double total) => total.roundToDouble();
