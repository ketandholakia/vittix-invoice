import 'package:intl/intl.dart';
import 'money_formatter.dart';

/// Formats an amount with the business currency (e.g. '₹ 1,234.50').
/// The single replacement for hardcoded 'Rs. ' string prefixes.
String formatMoneyForBusiness(
  double amount,
  String currencyCode, {
  int decimalDigits = 2,
}) => formatMoney(
  amount,
  currencyCode: currencyCode,
  decimalDigits: decimalDigits,
);

/// Formats a date for display (e.g. 'Jul 7, 2026'). The single replacement
/// for `toIso8601String().split('T')[0]` / `toString().split(' ')[0]`.
String formatDate(DateTime date) => DateFormat.yMMMd().format(date);

/// Numeric Indian date format (dd-MM-yyyy), used on printed documents.
String formatDateNumeric(DateTime date) =>
    DateFormat('dd-MM-yyyy').format(date);

/// Formats a nullable date for display, using 'none' for absent dates.
String formatDateOrNone(DateTime? date) => date == null ? 'none' : formatDate(date);

/// Formats a date-time for display (e.g. 'Jul 7, 2026, 3:45 PM').
String formatDateTime(DateTime dateTime) =>
    DateFormat.yMMMd().add_jm().format(dateTime);
