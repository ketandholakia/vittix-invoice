class InvoiceSummary {
  final double subtotal;
  final double totalDiscount;
  final double taxableAmount;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;
  final double totalCess;
  final double grandTotal;

  const InvoiceSummary({
    required this.subtotal,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
    required this.totalCess,
    required this.grandTotal,
  });

  factory InvoiceSummary.fromItems(List<dynamic> items) {
    // Assuming items have properties matching InvoiceItem
    double subtotal = 0;
    double totalDiscount = 0;
    double taxableAmount = 0;
    double totalCgst = 0;
    double totalSgst = 0;
    double totalIgst = 0;
    double totalCess = 0;

    for (final item in items) {
      subtotal += item.rate * item.quantity;
      totalDiscount += (item.rate * item.quantity) * (item.discountPct / 100);
      taxableAmount += item.taxableAmount;
      totalCgst += item.cgstAmount;
      totalSgst += item.sgstAmount;
      totalIgst += item.igstAmount;
      totalCess += item.cessAmount;
    }

    final grandTotal =
        taxableAmount + totalCgst + totalSgst + totalIgst + totalCess;

    return InvoiceSummary(
      subtotal: subtotal,
      totalDiscount: totalDiscount,
      taxableAmount: taxableAmount,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      totalIgst: totalIgst,
      totalCess: totalCess,
      grandTotal: grandTotal,
    );
  }
}
