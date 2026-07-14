class HsnCodeLookup {
  final String code;
  final String description;
  final String type;
  final double? gstRate;
  final DateTime? effectiveFrom;

  const HsnCodeLookup({
    required this.code,
    required this.description,
    required this.type,
    required this.gstRate,
    required this.effectiveFrom,
  });
}
