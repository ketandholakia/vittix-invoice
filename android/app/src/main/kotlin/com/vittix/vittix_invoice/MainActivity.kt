package com.vittix.vittix_invoice

import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity is required by local_auth so the biometric prompt can
// attach to a FragmentActivity.
class MainActivity : FlutterFragmentActivity() {
    override fun onResume() {
        super.onResume()
        applyScreenCaptureFlag()
    }

    // Blocks screenshots and blurs the app in the recents screen while the
    // in-app lock is enabled. The flag mirrors the Dart side's
    // `app_lock_enabled` preference (shared_preferences stores it in the
    // FlutterSharedPreferences file under the "flutter." prefix), so turning
    // the lock off also clears the flag on the next resume.
    private fun applyScreenCaptureFlag() {
        val prefs = getSharedPreferences("FlutterSharedPreferences", MODE_PRIVATE)
        val lockEnabled = prefs.getBoolean("flutter.app_lock_enabled", false)
        if (lockEnabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }
}
