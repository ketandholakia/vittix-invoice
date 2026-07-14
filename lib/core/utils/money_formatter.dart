import 'package:intl/intl.dart';

String formatMoney(
  double amount, {
  String currencyCode = 'INR',
  int decimalDigits = 2,
}) {
  final normalizedCode = currencyCode.trim().toUpperCase();
  final formatter = NumberFormat.simpleCurrency(
    name: normalizedCode,
    decimalDigits: decimalDigits,
  );
  return formatter.format(amount);
}

String currencySymbol(String currencyCode) {
  final normalizedCode = currencyCode.trim().toUpperCase();
  return NumberFormat.simpleCurrency(name: normalizedCode).currencySymbol;
}
