import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'core/utils/app_diagnostics.dart';
import 'providers/invoice_provider.dart';
import 'providers/database_provider.dart';
import 'providers/shared_preferences_provider.dart';
import 'providers/hsn_provider.dart';
import 'providers/uom_provider.dart';
import 'services/google_drive_service.dart';
import 'services/reminder_notification_service.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  );

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const VittixInvoiceApp(),
    ),
  );

  unawaited(_bootstrapBackgroundServices(container));
}

/// Generates a draft for any recurring invoice schedule that has come due.
Future<void> _runDueRecurrences(ProviderContainer container) async {
  try {
    await container.read(recurringInvoiceProvider).runDue();
  } catch (error, stackTrace) {
    reportNonFatal(
      error,
      stackTrace,
      context: 'while generating recurring invoices',
    );
  }
}

Future<void> _bootstrapBackgroundServices(ProviderContainer container) async {
  try {
    // Fire the one-time seeders without blocking first paint.
    container.read(hsnSeedProvider);
    container.read(uomSeedProvider);
    await ReminderNotificationService.instance.initialize();

    // Background isolates cannot use GoogleSignIn, so automatic Drive backups
    // run in the foreground on launch instead: at most once every 24 hours, and
    // only when the user enabled the toggle and is already signed in.
    await _maybeRunAutoBackup(container);
    await _runDueRecurrences(container);
  } catch (error, stackTrace) {
    // Keep startup resilient on Android if a plugin call fails.
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app bootstrap',
        context: ErrorDescription('while initializing background services'),
      ),
    );
  }
}

/// Best-effort foreground auto-backup. Runs at most once every 24 hours when
/// "Auto Backup to Drive" is enabled and a Google account is already available
/// without prompting. Any failure is swallowed so startup is never affected.
Future<void> _maybeRunAutoBackup(ProviderContainer container) async {
  try {
    final prefs = container.read(sharedPreferencesProvider);
    if (prefs.getBool('auto_backup_enabled') != true) return;

    const intervalMs = 24 * 60 * 60 * 1000;
    final now = DateTime.now().millisecondsSinceEpoch;
    final last = prefs.getInt('last_auto_backup_at');
    if (last != null && now - last < intervalMs) return;

    final account = await GoogleDriveService.instance.currentAccount();
    if (account == null) return; // Not connected; never prompt at startup.

    await GoogleDriveService.instance.uploadBackup(
      container.read(databaseProvider),
    );
    await prefs.setInt('last_auto_backup_at', now);
  } catch (error, stackTrace) {
    // Best-effort: a failed silent backup must never break startup, but it
    // should still be visible to diagnostics.
    reportNonFatal(error, stackTrace, context: 'while running the auto backup');
  }
}
