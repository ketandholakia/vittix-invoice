# VittixInvoice

VittixInvoice is a Flutter invoice and quotation app for small businesses. It uses Riverpod for state management and Drift/SQLite for local data storage.

## Supported platforms

**Android is the only supported platform** (minSdk 24, targetSdk 36, package `com.vittix.invoice`).

The `ios/`, `macos/`, `linux/`, `windows/`, and `web/` folders are Flutter scaffolding kept for local development convenience; they are not shipped or verified. Known gaps there: iOS lacks the Google Sign-In URL scheme (Drive backup cannot work), macOS lacks the Keychain entitlement for secure storage, and Linux has no `local_auth`/notification plugin builds. Do not file platform issues for non-Android targets.

CI runs analyze, tests, a drift generated-code drift check, and a debug-APK compile gate on every push; tag-triggered release jobs build the signed AAB/APK.

## Development

Install dependencies:

```bash
flutter pub get
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Regenerate Drift/Riverpod generated files after schema or provider annotation changes:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Development Reference

- [Development reference](docs/development-reference.md)
- [Phase log](docs/development-phase-log.md)
- [Development roadmap](docs/MISSING_FEATURES.md)
