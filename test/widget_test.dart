import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vittix_invoice/app.dart';
import 'package:vittix_invoice/providers/shared_preferences_provider.dart';

void main() {
  testWidgets('shows onboarding when no active business is selected', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const VittixInvoiceApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Welcome to VittixInvoice'), findsOneWidget);
    expect(find.text('Add Business'), findsOneWidget);

    // Drift stream queries schedule a zero-duration close timer when the
    // ProviderScope is disposed; flush the tree so no timer is pending.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
