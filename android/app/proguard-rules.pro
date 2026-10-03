# R8 / ProGuard rules for release builds.
#
# Vittix Invoice ships with no reflection-heavy first-party code, but a few
# plugin entry points must survive shrinking because they are wired through
# the Android manifest (not referenced from Dart-compiled bytecode).

# flutter_local_notifications receivers/activities referenced in the manifest.
-keep class com.dexterous.** { *; }

# flutter_secure_storage (KeychainAccess) accessors.
-keep class com.it_nomads.** { *; }

# Google Play services client models (google_sign_in / googleapis) are
# instantiated reflectively by generated ApiProxy stubs.
-keep class com.google.android.gms.** { *; }