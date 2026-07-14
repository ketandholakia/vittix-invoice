import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'providers/shared_preferences_provider.dart';
import 'providers/hsn_provider.dart';
import 'providers/uom_provider.dart';
import 'services/reminder_notification_service.dart';
import 'services/google_drive_service.dart';
import 'database/app_database.dart';
import 'dart:async';
// import 'package:workmanager/workmanager.dart';

/*
@pragma('vm:entry-point')
void callbackDispatcher() {
  WidgetsFlutterBinding.ensureInitialized();
  Workmanager().executeTask((task, inputData) async {
    try {
      if (task == 'syncToDrive') {
        final prefs = await SharedPreferences.getInstance();
        if (prefs.getBool('auto_backup_enabled') == true) {
          // We can't use GoogleSignIn in a background isolate because it requires an Activity.
          // This causes the app to crash natively when the task triggers.
          // A proper background backup would require a different authentication approach.
          print('Background backup triggered, but GoogleSignIn requires foreground.');
        }
      }
      return Future.value(true);
    } catch (e, stack) {
      print('Background task error: $e\n$stack');
      return Future.value(false);
    }
  });
}
*/

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

Future<void> _bootstrapBackgroundServices(ProviderContainer container) async {
  try {
    // Fire the one-time seeders without blocking first paint.
    container.read(hsnSeedProvider);
    container.read(uomSeedProvider);
    await ReminderNotificationService.instance.initialize();
    
    /* 
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );
    
    await Workmanager().registerPeriodicTask(
      'drive-backup-task',
      'syncToDrive',
      frequency: const Duration(hours: 24),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );
    */
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
