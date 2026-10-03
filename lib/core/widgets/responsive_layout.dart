import 'package:flutter/material.dart';

/// Screen size buckets used across layouts.
enum ScreenSize { compact, medium, expanded }

/// Width breakpoints: <600 phone (compact), 600-1000 tablet (medium),
/// >1000 desktop (expanded).
ScreenSize screenSizeOf(BuildContext context) {
  final width = MediaQuery.sizeOf(context).width;
  if (width < 600) return ScreenSize.compact;
  if (width < 1000) return ScreenSize.medium;
  return ScreenSize.expanded;
}

/// Builds a different widget tree per screen size bucket.
class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    super.key,
    required this.compact,
    this.medium,
    this.expanded,
  });

  final Widget compact;
  final Widget? medium;
  final Widget? expanded;

  @override
  Widget build(BuildContext context) {
    return switch (screenSizeOf(context)) {
      ScreenSize.compact => compact,
      ScreenSize.medium => medium ?? compact,
      ScreenSize.expanded => expanded ?? medium ?? compact,
    };
  }
}
