# Changelog

All notable changes to Vittix Invoice are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and the project versioning is
`MAJOR.MINOR.PATCH+BUILD` — `0.x.y` until the first store release.

## [Unreleased] — checkpoint of Phases 32–40 (2026-10-04)

### Fixed — October 2026 hardening pass (Phases 41-42)
- GSTR-1 export no longer truncates at the 500 newest invoices; it reads the
  full date range from the database.
- Pre-export GST validation lists offending documents (invalid GSTIN, B2B
  without customer GSTIN, bad place of supply, missing HSN/SAC, negative
  taxable) with tap-to-fix navigation before the export proceeds.
- GSTR-1 export gained an EXP/SEZ section and UQC units in the HSN summary;
  export supplies no longer mix into the domestic B2B/B2CS sections.
- Database migrations now run in ascending schema order with duplicate-column
  guards, fixing upgrade crashes for any pre-v21 database (and pre-v11 for
  tables recreated with the current schema).
- The app-lock PIN is stretched with PBKDF2 (random per-install salt) instead
  of a single salted SHA-256; existing digests upgrade on first unlock; wrong
  attempts trigger a persisted lockout with an on-screen countdown.
- Non-fatal failures are recorded in a diagnostics ring buffer exportable from
  Settings; the remaining silent error swallowing was removed.

### Fixed — data integrity
- Money is rounded (`round2`) at every computation boundary; amounts-in-words
  derive from a single rounded paise value.
- Document numbering uses per-business/per-type/per-FY counters instead of
  O(N) scans, with unique-constraint-aware resync for legacy numbers.
- Backup restore gated on exact schema version and required tables; a failed
  restore can no longer wipe existing data.
- Foreign-key indexes across invoices, quotes, items, payments, customers,
  products, activity events, and template configs.

### Security
- Nextcloud credentials moved to platform secure storage with one-time
  migration; HTTPS enforced for WebDAV.
- Dedicated release keystore (gitignored `key.properties`); release builds
  never fall back to debug keys.
- Passphrase-encrypted backups (PBKDF2 + AES-256-GCM envelope); `allowBackup`
  disabled on Android.
- App lock with PIN and biometric unlock.

### Added — GST compliance
- Credit/debit notes with `CN-`/`DN-` series; cancelled/draft documents
  excluded from dashboards, reports, statements, and exports.
- Supply type / place of supply derivation with B2B/B2C and EXPORT/SEZ
  overrides, reverse charge, ship-to, TDS/TCS, LUT zero-rating.
- HSN/SAC summary on invoice PDFs; GSTR-1 style summary export (B2B, B2CS,
  CDNR, HSN); HSN rate versioning updated for the 22 Sep 2025 revision.
- Recurring invoices with month-end clamping and catch-up.
- Append-only stock movement ledger; low-stock reorder thresholds surfaced in
  product list, dashboard, and reports.

### Added — UX and platform
- Dark theme, responsive layouts, shared status palette, template and money
  formatting helpers; deep-link hardening with a not-found screen.
- Editable PDF templates (classic/modern families, watermark, UPI QR).
- Google Drive and Nextcloud backup/restore; pre-restore snapshot pruning.
- CI (analyze + tests + drift-diff gate) and tag-triggered release builds;
  R8-minified release APK; aligned bundle IDs and app icons.

### Changed
- Providers rebuilt on Drift streams (`autoDispose`); invoice/quote logic
  unified behind a shared document service core.
- 137 tests total; `flutter analyze --fatal-infos` is the quality bar.
