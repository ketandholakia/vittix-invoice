import 'package:flutter/services.dart';

/// Mirrors the app-lock toggle to the Android side so FLAG_SECURE applies
/// immediately.
///
/// The native side also re-reads the stored preference on every activity
/// resume, but that alone would leave the current session unprotected from
/// the moment the lock is enabled in Settings until the next pause/resume
/// cycle — exactly the window a screenshot or recents thumbnail would
/// capture.
class SecureScreenGuard {
  static const _channel = MethodChannel('vittix_invoice/secure_screen');

  /// Applies or lifts the screen-capture block. Best effort: on platforms
  /// with no handler (tests, desktops) the native resume fallback still
  /// applies the flag from the stored preference.
  static Future<void> apply(bool secure) async {
    try {
      await _channel.invokeMethod<void>('setSecure', secure);
    } on MissingPluginException {
      // No platform implementation (tests, desktop).
    } on PlatformException {
      // The platform refused or errored; the resume fallback covers it.
    }
  }
}
