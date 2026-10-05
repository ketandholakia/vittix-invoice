# Changelog

All notable changes to Vittix Invoice are documented here. The format follows
[Keep a Changelog](https://keepachangelog.com/) and the project versioning is
`MAJOR.MINOR.PATCH+BUILD` — `0.x.y` until the first store release.

## [Unreleased] — checkpoint of Phases 32–40 (2026-10-04)

### Added — Composition scheme & Bill of Supply (Phase 47)
- Per-business billing mode: composition-scheme and unregistered dealers
  issue Bills of Supply with no tax collection (with the statutory
  declaration printed), while regular dealers keep tax invoices.
- Bills of Supply run on their own configurable numbering series
  (`BOS-{FY}-{SEQ4}` by default, editable in Document Numbering) and never
  appear in the GSTR-1 export; schema v31.

### Added — Profit & margin report (Phase 46)
- New Reports section: revenue (taxable, GST excluded) against COGS from
  product purchase prices, with per-invoice/customer/product breakdowns,
  margin percent, CSV export, and explicit flagging of lines whose product
  has no purchase price. Credit notes reverse revenue and COGS; drafts and
  cancelled documents are excluded; totals reconcile to the paise.

### Changed — October 2026 refactor pass (Phase 45)
- The PDF, reports, settings, and template-manager files are split into
  navigable parts; services no longer depend on Riverpod internals; Nextcloud
  calls have timeouts and a retry; reminder re-syncs are debounced and skip
  no-op work.

### Fixed — October 2026 test pass (Phase 44)
- Thermal (80 mm roll) PDF templates no longer crash the render: the
  unbounded roll height asserted inside the PDF layout engine; thermal now
  renders on a tall finite page.
- Nextcloud restore failures now distinguish a broken server listing from an
  empty backup folder instead of always reporting "no backup found".
- First automated coverage for the PDF template pipeline, Google Drive
  backup, Nextcloud round trip, and reminder scheduling; the 3,900-line
  billing test monolith is split into 14 domain files (192 tests total).

### Fixed — October 2026 hardening pass (Phases 41-42)
- Platform policy: Android is the only supported platform, declared in the
  README; non-Android scaffolding is unmaintained.
- CI now triggers on `master` (it previously only watched `main` and never
  ran on regular pushes) and proves the Android build on every push with a
  debug-APK compile gate; the signed release APK was re-verified after the
  hardening changes.
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
