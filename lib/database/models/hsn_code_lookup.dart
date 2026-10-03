class HsnCodeLookup {
  final String code;
  final String description;
  final String type;
  final double? gstRate;
  final DateTime? effectiveFrom;
  final double? minUnitPrice;
  final double? maxUnitPrice;

  const HsnCodeLookup({
    required this.code,
    required this.description,
    required this.type,
    required this.gstRate,
    required this.effectiveFrom,
    this.minUnitPrice,
    this.maxUnitPrice,
  });

  /// A human label for a price-conditioned band, or null when the rate applies
  /// to every price.
  String? get priceBandLabel {
    final min = minUnitPrice;
    final max = maxUnitPrice;
    if (min == null || max == null) return null;
    if (min <= 0 && max >= unboundedRatePrice) return null;
    if (min <= 0) return 'up to \u20b9${max.toStringAsFixed(0)}';
    if (max >= unboundedRatePrice) return 'above \u20b9${min.toStringAsFixed(0)}';
    return '\u20b9${min.toStringAsFixed(0)}\u2013\u20b9${max.toStringAsFixed(0)}';
  }
}

/// Upper sentinel for an unbounded band, mirroring the `HsnCodeRates` default.
const double unboundedRatePrice = 1e12;
