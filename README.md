# VittixInvoice

VittixInvoice is a Flutter invoice and quotation app for small businesses. It uses Riverpod for state management and Drift/SQLite for local data storage.

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
