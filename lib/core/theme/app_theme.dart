import 'package:flutter/material.dart';

/// Builds the app theme for a given brightness.
ThemeData buildAppTheme(Brightness brightness) {
  final colorScheme = ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    brightness: brightness,
  );
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
  );
}

/// Semantic status colors that stay readable on light and dark surfaces.
/// Replaces ad-hoc `Colors.green` / `Colors.red` / `Colors.orange` ternaries.
abstract final class StatusPalette {
  static const Color paid = Color(0xFF2E7D32);
  static const Color overdue = Color(0xFFD32F2F);
  static const Color pending = Color(0xFFF57C00);
  static const Color expiringSoon = Color(0xFFE64A19);
  static const Color rejected = Color(0xFFC62828);
}

/// Invoice status color, honoring the paid / overdue / pending semantics.
Color invoiceStatusColor(String status, {required bool isOverdue}) {
  if (status == 'PAID') return StatusPalette.paid;
  if (isOverdue) return StatusPalette.overdue;
  return StatusPalette.pending;
}

/// Quote status color, honoring the converted / expired / expiring semantics.
Color quoteStatusColor(
  String status, {
  required bool isExpired,
  required bool isExpiringSoon,
}) {
  if (status == 'CONVERTED') return StatusPalette.paid;
  if (isExpired || status == 'REJECTED') return StatusPalette.rejected;
  if (isExpiringSoon) return StatusPalette.expiringSoon;
  return StatusPalette.pending;
}
