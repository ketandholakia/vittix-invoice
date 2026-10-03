import 'package:flutter/foundation.dart';

/// Central place for non-fatal error reporting.
///
/// Best-effort work (background sync, silent backups, optional plugin calls)
/// must never break the app, but silently discarding the error makes failures
/// invisible. Everything funnelled through here is surfaced to
/// [FlutterError.reportError], so a crash reporter can be attached in one place
/// later.
void reportNonFatal(
  Object error,
  StackTrace stackTrace, {
  required String context,
}) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: error,
      stack: stackTrace,
      library: 'vittix',
      context: ErrorDescription(context),
    ),
  );
}
