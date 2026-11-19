package com.vittix.vittix_invoice

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

// FlutterFragmentActivity is required by local_auth so the biometric prompt can
// attach to a FragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // The Dart side calls this the moment the app lock is toggled, so
        // FLAG_SECURE applies to the current session without waiting for a
        // pause/resume cycle. onResume below re-reads the preference as the
        // fallback for process restarts.
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "vittix_invoice/secure_screen",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "setSecure" -> {
                    applyScreenCaptureFlag(call.arguments == true)
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResume() {
        super.onResume()
        // Mirrors the Dart side's `app_lock_enabled` preference.
        // shared_preferences stores values in the FlutterSharedPreferences
        // file under the "flutter." key prefix, booleans as boolean entries.
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        applyScreenCaptureFlag(prefs.getBoolean("flutter.app_lock_enabled", false))
    }

    // Blocks screenshots and blurs the app in the recents screen while the
    // in-app lock is enabled.
    private fun applyScreenCaptureFlag(secure: Boolean) {
        if (secure) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
