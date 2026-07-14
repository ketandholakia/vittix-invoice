import '../../database/app_database.dart';

double invoiceBalanceDue(Invoice invoice) {
  final balance = invoice.totalAmount - invoice.amountPaid;
  return balance > 0 ? balance : 0;
}

double invoiceOverpaidAmount(Invoice invoice) {
  final overpaid = invoice.amountPaid - invoice.totalAmount;
  return overpaid > 0 ? overpaid : 0;
}
