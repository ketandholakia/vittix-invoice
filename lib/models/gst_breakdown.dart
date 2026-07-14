class GstBreakdown {
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;
  final double total;

  const GstBreakdown({
    this.cgst = 0,
    this.sgst = 0,
    this.igst = 0,
    this.cess = 0,
    required this.total,
  });
}
