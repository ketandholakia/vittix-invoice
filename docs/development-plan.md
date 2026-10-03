# Development Plan (Audit-Driven)

Master development plan produced from the full codebase audit. It supersedes the phase ordering in `MISSING_FEATURES.md` (roadmap phases 31-36 are folded into Phases P9-P12 below). Read together with `development-reference.md` and `development-phase-log.md`.

## How to use this plan

- Work phases in order where dependencies exist; `Depends on` lists the hard prerequisites.
- When a phase is complete: run `flutter analyze` (0 errors), `flutter test` (all green), and `dart run build_runner build --delete-conflicting-outputs` if the Drift schema changed, then move a phase summary into `development-phase-log.md` (and remove the corresponding item from `MISSING_FEATURES.md` for feature phases).
- Scope creep beyond a phase should be opened as a new phase before adding items.

## Priority summary

| Priority | Item | Phase |
|---|---|---|
| Critical | Backup restore FK bug + schemaVersion gate | P1 |
| Critical | Money rounding + amount-in-words correctness | P1 |
| Critical | Nextcloud credentials in plaintext SharedPreferences | P2 |
| Critical | Release builds signed with debug keystore | P2 |
| High | O(N) invoice number sequence scan, missing FK indexes | P1 |
| High | Zero test coverage for UI/PDF/words, 7 analyze warnings | P3 |
| High | No CI/CD, store-unready Android/iOS/macOS configs | P4 |
| High | 7 duplicate FutureBuilders in invoice preview | P5 |
| High | Stale data from incomplete provider invalidation | P5 |
| High | ~4,000 lines of duplicated invoice/quote code | P6 |
| Medium | No responsive layouts, no dark theme, `'Rs. '` hardcoding | P7 |
| Medium | Google Drive backup non-functional; auto-backup dead code | P8 |
| Medium | Missing features: recurring invoices, inventory ledger, GST exports | P9-P12 |

## Phase dependency map

```
P1 (integrity) [DONE] ──► P2 (security) [DONE] ──► P3 (quality gates) [DONE] ──► P4 (devops/release) [DONE]
                                                              │
P5 (state/perf) [DONE] ──► P6 (unification) [DONE] ──► P7 (UX/i18n) ─┘
P8 (backup automation) ──► P9 (recurring) ──► P10 (inventory) ──► P11 (GST exports) ──► P12 (margin/imports)
```

---

## P1: Core Data Integrity Fixes

**Status:** COMPLETED (2026-08) — see Phase 32 in `development-phase-log.md`.

**Priority:** Critical · **Effort:** M · **Depends on:** nothing

**Audit findings addressed**
- Restore from JSON breaks when template configs exist: `template_configs` is neither exported nor deleted, so `db.delete(businesses)` violates the FK and rolls back the whole restore (`lib/services/database_backup_service.dart`).
- `schemaVersion` is written to the backup but never validated; a backup missing the `businesses` key silently wipes the local DB.
- All money is `double` with no rounding at computation boundaries; totals/words/numerals can disagree by a paise (`lib/core/utils/gst_calculator.dart`, `lib/features/invoices/create/invoice_form.dart:159-167`).
- `AmountInWords` bugs: paise can round to 100, "One Rupees" (no singular), zero-amount leading space (`lib/core/utils/amount_in_words.dart:38-52`).
- Invoice/quote numbering allocates by loading all numbers into Dart per create — O(N) per create, O(N²) overall (`lib/database/daos/invoice_dao.dart:76-102`, `lib/database/daos/quote_dao.dart:37-63`).
- No indexes on any foreign key (only the two unique composite indexes), so all traversal queries are unindexed scans.

**Tasks**
1. Fix `DatabaseBackupService`:
   - Export `template_configs` in `buildBackupJson` and include it in the restore delete/insert sequence (FK-safe order).
   - Gate restore on `schemaVersion`; add a friendly `BackupVersionMismatch` error and a pre-restore dry-run validation (validate keys/types before deleting anything).
   - Add a regression test: backup → create template config → restore → all 13 tables present and FK-consistent.
2. Introduce a single money-rounding helper (`round2(double)`) and apply it at every boundary: per-item taxable/GST/discount, invoice grand total, payment amounts. Guard against reformatting drift by keeping one shared `Money` util for both the form layer and the service layer.
3. Fix `AmountInWords`:
   - Carry paise forward correctly (`(amount * 100).roundToInt() % 100`) so 100-paise overflow is impossible.
   - Add singular "Rupee" and explicit "Zero Rupees" handling for amounts < 1.
   - Unit-test `1`, `0.99`, `1.995`, `99999999.99`, `0`.
4. Numbering scalability (`schema v19` candidate — bundle with 5 if not urgent):
   - Simplest correct change: a per-business counter table (`invoice_seq`, `quote_seq`) updated inside the existing insert transaction; or compute `MAX(sequence)` via SQL against the stored numbers when the format ends in a `{SEQ}` token, keeping the regex path as fallback.
   - Keep the unique `(business_id, invoice_number)` constraint as the collision backstop.
5. FK indexes: add Drift `@TableIndex` on `invoice_items.invoiceId/productId`, `invoice_payments.invoiceId`, `invoices.customerId/businessId`, `customers.businessId`, `quotes.customerId/businessId`, `customer_activity_events.customerId/businessId`, `products.businessId`. Verify plan via EXPLAIN on a seeded DB.
6. Run `build_runner`, add migration steps for any changed tables, and rerun the full test suite.

**Acceptance criteria**
- Backup/restore roundtrip passes with template configs present; version-mismatched backups are rejected before mutation.
- `AmountInWords` and computed totals agree to the paise for all tests, including 3-decimal GST rates.
- Creating invoice #N does not scan all prior numbers (assert via test instrumentation or SQL plan).
- `flutter analyze` clean; full suite green.

**Out of scope:** currency-amount migration to integer paise (defer to a deliberate schema v20 decision; see note in P7).

---

## P2: Security Hardening

**Status:** COMPLETED (2026-08) — see Phase 33 in `development-phase-log.md`.

**Priority:** Critical · **Effort:** S-M · **Depends on:** P1 (restore test infra reused for credential migration tests)

**Audit findings addressed**
- Nextcloud app password stored in plaintext `SharedPreferences` (`lib/providers/nextcloud_provider.dart:47-49`).
- Basic auth sent over the scheme the user typed; HTTPS not enforced (`lib/services/nextcloud_service.dart:23-39`).
- Release builds signed with the debug keystore (`android/app/build.gradle.kts:29-35`).
- Backups (JSON + DB file) are unencrypted plaintext containing GSTINs/PANs/financial data.

**Tasks**
1. Add `flutter_secure_storage`. One-time migration: read Nextcloud credentials from SharedPreferences and write to secure storage; clear the plaintext keys afterwards. Keep the provider API the same so the UI is untouched.
2. Enforce `https://` in `_buildBaseUrl` (reject `http://` with a clear settings error, or add an explicit `allowInsecure` opt-in flag off by default).
3. Release signing:
   - Generate a real keystore; add `key.properties` (gitignored); configure `signingConfigs.getByName("release")`; never fall back to debug.
   - Consider `flutter build appbundle` step in CI (P4).
4. Optional hardening: encrypt exported backup JSON (`database_backup_service.dart`) with a user passphrase (e.g., AES-GCM via `encrypt`/`cryptography` packages); document that encrypted exports bypass the share-as-JSON flow.

**Acceptance criteria**
- No credentials stored in plaintext; migration works for users with existing saved Nextcloud settings (test with mocked secure storage).
- HTTP Nextcloud URLs are rejected with actionable UI feedback.
- `flutter build apk --release` produces a keystore-signed artifact (verify with `apksigner`).

**Out of scope:** full disk encryption of the SQLite file (system-level concern), multi-user auth.

---

## P3: Quality Gates And Test Expansion

**Status:** COMPLETED (2026-08) — see Phase 34 in `development-phase-log.md`.

**Priority:** High · **Effort:** M · **Depends on:** P1-P2 (so tests assert fixed behavior)

**Audit findings addressed**
- Only 26 unit tests; single widget test; zero coverage for words, money, PDF, notifications, cloud services, screens; no integration tests.
- 7 `unused_import` warnings; stock `flutter_lints` with no custom rules.
- Hardcoded error strings with no retry affordances (covered in P5/P7).

**Tasks**
1. Fix the 7 unused imports (`lib/main.dart:9-10`, `lib/providers/invoice_provider.dart:2,4-6,9`).
2. Unit tests (pure logic, no plugins):
   - `AmountInWords` edge cases (P1 regressions), `GstCalculator` rounding, `InvoiceNumberGenerator` full format token matrix (`{FY}`, `{SEQ2..6}`, `{MON}`, backdated FY).
   - `invoiceBalanceDue`/overpayment, `buildCustomerStatementRows` direction already covered — extend to multi-currency.
3. Widget tests:
   - Invoice form validation snapshots (items required, GST field validation).
   - Invoice list empty/filtered-empty/error states with retry action.
   - Onboarding → business creation happy path.
4. Integration test skeleton (`integration_test/`):
   - Drive a full flow against a real in-memory/temp DB: create business + customer + product, create invoice, record payment, render PDF (mock `printing`'s platform), export backup, restore.
5. Tighten `analysis_options.yaml` (enable `recommended` set, `avoid_print`, `use_build_context_synchronously` already on, `prefer_const_constructors`, `unnecessary_lambdas`, `discarded_futures` in test dir). Make `flutter analyze --fatal-infos` the bar.

**Acceptance criteria**
- `flutter analyze` 0 issues; `flutter test` green; integration test passes on at least one platform (Android emulator or Windows desktop).
- Coverage for P1/P2 regressions locked in before P5 refactors begin.

**Out of scope:** snapshot testing of PDF bytes (brittle), full golden tests.

---

## P4: DevOps And Release Readiness

**Status:** COMPLETED (2026-08) — see Phase 35 in `development-phase-log.md`.

**Priority:** High · **Effort:** M · **Depends on:** P3 (CI gates on analyze+tests)

**Audit findings addressed**
- No CI/CD at all; no lint/analyze/test automation; no PR builds.
- Android: stock label `vittix_invoice`, default icons, white splash, no ProGuard/R8, no ABI splits; TODO placeholder for applicationId config (`android/app/build.gradle.kts:19,31`).
- iOS bundle ID `com.vittix.vittixInvoice` differs from Android `com.vittix.vittix_invoice`; missing `NSCameraUsageDescription`/`NSPhotoLibraryUsageDescription`; no notification usage text.
- macOS release entitlements lack `com.apple.security.network.client` (Drive/Nextcloud fail in sandboxed release builds).
- Web manifest/title still template defaults; dead deps remain in `pubspec.yaml`.

**Tasks**
1. GitHub Actions workflow `.github/workflows/ci.yml`:
   - Jobs: `flutter analyze --fatal-infos`, `flutter test`, `build_runner` drift-diff check (fail if `*.g.dart` stale: run build_runner and `git diff --exit-code`).
   - Optional release job: `flutter build appbundle` + upload artifact; inject `google-services.json` and `key.properties` from secrets.
2. Android polish: rename label to "Vittix Invoice"; `flutter_launcher_icons`; `flutter_native_splash`; enable R8 minify with a minimal `proguard-rules.pro` (before enabling, run release build and smoke-test PDF + notifications); optional ABI splits (`splits { abi { ... } }`) or rely on app bundles.
3. iOS: align bundle ID with a deliberate product decision (e.g., `com.vittix.invoice` on both platforms); add photo-library + camera usage strings (image_picker paths) and notification explanation.
4. macOS: add `com.apple.security.network.client` (and `network.server` where needed) to release entitlements.
5. Web: title/description/manifest polish; keep PWA icons.
6. Prune dead dependencies: remove `mobile_scanner`, `uuid`, `cupertino_icons` (verify zero references after removal with `flutter pub deps`/tree-shake check).

**Acceptance criteria**
- CI green on every PR; stale generated files fail the build.
- Release APK/AAB builds on CI with proper signing, minification on, smoke-tested.
- Bundle IDs consistent; macOS release build can reach the network.

**Out of scope:** store listing copy, screenshots, staged rollout config (do near first release; see P12 wrap-up).

---

## P5: State Management And Performance Refactor

**Status:** COMPLETED (2026-08) — see Phase 36 in `development-phase-log.md`.

**Priority:** High · **Effort:** M-L · **Depends on:** P3 (regression safety net)

**Audit findings addressed**
- Zero `autoDispose`; family providers accumulate per-record entries for the app lifetime; stale-data gaps from incomplete manual invalidation (`customer_provider.dart:26,33,40`; `invoice_service.dart:349-367`).
- Drift `.watch()` streams entirely unused; screens compensate with ad-hoc `ref.invalidate` calls.
- `invoice_preview_screen.dart` runs 7 separate `FutureBuilder<Invoice?>` fetches plus a `Future.wait` on the same data (lines 32-272).
- Filters recomputed in `build` on every rebuild (`invoice_list_screen.dart:373-386`); un-indexed/paginated list loads; O(N) balance math per item.
- `dashboard_screen.dart:17-18` calls a DAO method inside `build`, creating a fresh future per rebuild.

**Tasks**
1. Rebuild providers on `autoDispose` + drift streams:
   - `invoiceDetailProvider`, `invoicePaymentsProvider`, `customerDetailProvider`, `customerActivityProvider`, business detail → `FutureProvider.autoDispose.family` over `dao.watchXxx().first` (or `StreamProvider` where live updates are wanted).
   - Replace mutation-time `ref.invalidate(...)` with stream-driven updates; keep invalidation only where streams cannot express the change (e.g., status flips that change list membership — use `invalidate` on the list provider only).
2. Close the known staleness gaps: editing a customer updates its detail/timeline; `updateInvoiceStatus`/`updateInvoiceTemplate` refresh the open preview; `updateQuoteStatus` refreshes quote detail.
3. Rewrite `invoice_preview_screen.dart` to a single `ref.watch(invoiceDetailProvider(invoiceId))` plus `invoicePaymentsProvider`; delete the FutureBuilder cluster and the nested `Future.wait`; standardize `.when(loading/error/data)` with a retry button.
4. Performance:
   - Memoize the filtered invoice list in a provider (watch list + search/status params via `family` or `select`).
   - Add pagination or a documented scale limit (e.g., 500 loaded, then search-driven narrowing) to `getInvoicesForBusiness`; add the P1 FK indexes first.
   - Remove the side-effects-in-`build` pattern in `invoice_form.dart:242-286`/`quote_form.dart:239-283` (init in `initState`, load edit data in an async `init` method with a loading state).
5. Delete dead code uncovered on the way (`AppColors`, unused `FormValidators.requiredString`, no-op `setState(() {})` calls).

**Acceptance criteria**
- No stale detail screens after edits (test: edit customer → detail shows new values without manual refresh).
- Invoice preview renders from exactly one watch; no duplicate fetch requests (assert via provider call counts in tests).
- No provider without `autoDispose` unless lifecycle-justified; app-wide refactor review passes.

**Out of scope:** full Riverpod codegen migration (do the provider convention unification in P6).

---

## P6: Invoice/Quote Unification

**Status:** COMPLETED (2026-08) — see Phase 37 in `development-phase-log.md`.

**Priority:** High · **Effort:** L · **Depends on:** P5 (stream/state refactor done to avoid rework)

**Audit findings addressed**
- `InvoiceService` and `QuoteNotifier` duplicate ~90% of create/duplicate/update/audit/sequence logic (~4,000 lines across services, providers, forms, item sheets).
- Three inconsistent mutation conventions: service class vs legacy `Notifier` vs `StateNotifierProvider`.

**Tasks**
1. Extract a shared document core (start with the services):
   - `DocumentService<T>` base handling sequence allocation, transactional create/duplicate/update-with-items, stock deltas, edit-audit events, activity events; `InvoiceService`/`QuoteService` become thin subclasses with type parameters.
   - Unify `_describeInvoiceEdit`/`_describeQuoteEdit` into one diff-summary helper.
2. Unify the item entry sheets: one `ItemEntrySheet` widget with a sealed item type (invoice/quote), shared validators from `FormValidators` (delete the private copies in `quote_item_entry_sheet.dart`).
3. Unify the create/edit forms: extract a shared `DocumentFormScreenState` base (fields, GST supply-type logic, save flow); invoice and quote forms keep only their differences (document-type labels, conversion action).
4. Establish one provider convention: migrate quotes/customers/products/businesses to the same pattern as P5 (or do the `@riverpod` codegen migration for the whole `providers/` folder now that everything is autoDisposed — recommended to avoid a third convention).
5. Rerun the full billing test suite untouched as the equivalence proof; add a differential test that invoice and quote paths produce the same events/stock behavior.

**Acceptance criteria**
- Zero duplicated logic between invoice and quote paths (grep-verified); both documents pass the existing 26 tests unchanged plus new shared-core tests.
- One mutation convention across the app.

**Out of scope:** merging the list screens (they legitimately differ in fields/actions).

---

## P7: UX, Responsiveness, Currency And Localization

**Status:** COMPLETED (2026-08) — see Phase 38 in `development-phase-log.md`.

**Priority:** Medium · **Effort:** L · **Depends on:** P6 (shared widgets exist after unification)

**Audit findings addressed**
- No responsive architecture (single broken `LayoutBuilder` use in the whole app); fixed paddings/heights; phone-first everywhere.
- No dark theme; 72+ hardcoded `Colors.*`; status color ternaries duplicated 4+ times.
- Hardcoded `'Rs. '` in ~30 places despite multi-currency support; 47 `toIso8601String().split('T')[0]` date usages; zero localization infrastructure, all strings inline.
- Unsafe navigation: 6 `state.extra! as X` casts and unguarded `int.parse` on path params.
- Giant screens (reports 1,196 lines; settings 796; template manager 1,039) — split during this phase where interaction is localized.

**Tasks**
1. Theme: centralize a `ThemeConfig` helper (status colors → extension on `ColorScheme`), add `darkTheme` + `ThemeMode` persistence, delete `AppColors` after migrating usages.
2. Responsive: introduce a small `ResponsiveLayout` utility (breakpoints <600 / 600-1000 / >1000); adapt dashboard (stat cards via `Wrap`/`GridView`), list screens (master-detail on wide), and forms (two-column on wide); replace fixed-height `SizedBox`es where scroll is expected.
3. Currency correctness: introduce a single `buildAmountFormatter(business)`/`formatMoneyForBusiness` helper and replace every `'Rs. '` literal; render amounts with the business currency in lists, reports, reminders, and sheets.
4. Dates: replace string-splitting with `DateFormat.yMMMd()` (with an app-level locale from step 5).
5. Localization: add `flutter_localizations` + `gen_l10n`, create `l10n.yaml` and an initial `app_en.arb`; migrate strings incrementally (app bars, dialogs, snackbars first; keep status codes machine-read as-is). Do not attempt hi-IN grammar parity in this pass — structure strings to allow it later.
6. Navigation hardening: replace `state.extra!` with id-based routes (`/edit-invoice/:id` + provider lookup) or guard casts with a redirect to a not-found/error route; wrap `int.parse` with try/catch; add `errorBuilder`.
7. Split `reports_screen.dart` into per-report widgets/files (export flags shared via a small config record); extract `template_manager_screen.dart`'s duplicated color parsing into `pdf_service.dart`'s shared helper (or a `template_utils.dart`).

**Acceptance criteria**
- App usable on phone, tablet, and desktop widths without overflow (manual pass + a golden/screenshot check on two breakpoints).
- No `'Rs. '` literals remain; no `toString().split(...)` date parsing remains.
- Deep links to edit/detail routes fail gracefully instead of crashing.
- Dark theme toggle persists across restarts.

**Out of scope:** full hi-IN translation content; complete i18n of generated PDF text (PDF stays business-language per template).

---

## P8: Backup Automation And Cloud Reliability

**Priority:** Medium · **Effort:** M-L · **Depends on:** P1 (restore fixes), P2 (secure storage), P4 (Google client config + CI)

**Audit findings addressed**
- Google Drive backup non-functional as shipped: no `google-services.json`, no `com.google.gms.google-services` plugin, no iOS `CFBundleURLTypes` scheme.
- "Auto Backup to Drive" toggle is dead code: the Workmanager task is commented out (`lib/main.dart:12-36,64-78`) because Google Sign-In needs foreground auth.
- Backups accumulate unbounded (new file per upload, no pruning).
- Backup path is mostly UI-driven with little automated coverage; restore bypasses schema bookkeeping (fixed in P1).

**Tasks**
1. Make Drive work:
   - Add `google-services.json` (injected via CI from secrets, gitignored), apply the GMS plugin, add the iOS reversed-client-ID URL scheme and `default_web_client_id` wiring.
2. Auto-backup strategy (choose one, document in the phase log):
   - Foreground-safe window: prompt/schedule a backup when the app is next opened with connectivity (respects the Google Sign-In foreground requirement), or
   - Nextcloud-first auto-backup (pure HTTP, no OAuth) with a periodic check at app open; keep Drive as manual.
   - Remove or implement the Workmanager path deliberately — no half-wired toggles.
3. Backup rotation: keep last N backups (e.g., 10) on Drive/Nextcloud; delete older ones.
4. Backup history screen: list local/Drive/Nextcloud backups with timestamp, size, and restore/delete actions (reuse the P1-gated restore).
5. Integration tests: mocked Drive/Nextcloud HTTP layer (e.g., `http.Client` override) covering upload, "latest backup" selection, rotation, and the P1 restore path end-to-end.

**Acceptance criteria**
- Drive and Nextcloud backup/restore verified on at least one platform each.
- No settings toggle exists that does nothing; every toggle has a wired path.
- Rotation keeps storage bounded; tests prove newest-picked and old-pruned.

**Out of scope:** true multi-device sync/conflict resolution (a separate product decision).

---

## P9: Recurring And Subscription Invoices

**Priority:** Medium · **Effort:** M · **Depends on:** P5, P6 (document engine reuse)

**Source:** MISSING_FEATURES.md Phase 31.

**Tasks**
1. New `RecurringProfiles` table (business, customer, schedule type + interval, next-run date, end condition, template invoice data snapshot, active/paused/ended status); schema v20 with migration + `@TableIndex` on `(businessId, status)`.
2. Generation service: when run date ≤ today, create draft invoice via the P6 document engine with correct numbering, record `RECURRING_GENERATION` activity events, compute next run.
3. Management screen (list, pause/resume/end, edit schedule) under Settings.
4. Tests: monthly/yearly schedules, skipped runs (missed while app closed — catch up logic), end dates, per-FY numbering for generated invoices, invoice numbering continuity.

**Acceptance criteria:** scheduled invoices generate as drafts with correct numbering and audit trail; catch-up after app downtime is defined and tested.

---

## P10: Inventory Operations Ledger And Low-Stock Alerts

**Priority:** Medium · **Effort:** M · **Depends on:** P5, P6

**Source:** MISSING_FEATURES.md Phase 32.

**Tasks**
1. New `StockMovements` table (product, delta, reason: PURCHASE/INVOICE/EDIT/REVERSE/MANUAL, reference invoice id, timestamp); stock quantity becomes derived/validated ledger balance.
2. Route all existing stock changes through the ledger (invoice create/update/delete already call `_applyStockChangeForInvoiceItem` — wrap with ledger writes; make `adjustStockQuantity` transactional).
3. Reorder thresholds per product; low-stock surface in product list, dashboard, and reports gated on `lowStockWarningsEnabledProvider`.
4. Tests: ledger balance vs stock quantity invariants, invoice edit rollback, low-stock filtering.

**Acceptance criteria:** stock never mutates outside the ledger; invoice edit/delete reverses entries exactly; low-stock list matches thresholds.

---

## P11: GST Compliance Exports

**Priority:** Medium · **Effort:** M · **Depends on:** P3 (test harness), P7 (currency/date helpers finalized)

**Source:** MISSING_FEATURES.md Phase 34.

**Tasks**
1. GSTR-1 style export: B2B invoices, HSN summary (HSN/description, UQC, qty, taxable, GST rate, tax), credit/debit note adjustments, document numbering ranges per GSTIN.
2. Export formats: CSV (share via existing `ShareService`) and a JSON bundle for tooling; validate required GST fields before export with actionable error lists.
3. Tests with representative intra- and inter-state invoices; validate totals reconcile with the rounding rules from P1.

**Acceptance criteria:** export reconciles to database totals to the paise; validation failures list each offending invoice.

**Out of scope:** e-invoice/e-way bill payload APIs until the required shape is externally finalized (per roadmap guidance).

---

## P12: Profit Reporting, Data Quality And Release Wrap-Up

**Priority:** Low-Medium · **Effort:** M-L · **Depends on:** P7, P10 (purchase cost/lives with stock ledger)

**Sources:** MISSING_FEATURES.md Phases 35-36.

**Tasks**
1. Profit/margin reporting: revenue per invoice/customer, COGS from `purchasePrice` (and eventually ledger purchase movements), margin filters by date/customer/product; negative-margin tests.
2. Data quality/import: customer/product/HSN/UOM bulk import with dedupe preview; duplicate detection on existing data.
3. Reports refactor completion: per-report files, shared export controller (from P7).
4. Store readiness wrap-up: listing copy, screenshots at two breakpoints, staged rollout notes, crash reporting decision — add `firebase_crashlytics` (or `sentry_flutter`) only after committing to the Google backend setup from P8; otherwise keep `FlutterError.onError` logging structured.

**Acceptance criteria:** margin reports reconcile with the ledger; import previews report exact skipped/merged rows; app store metadata drafted.

---

## Risk register (from audit, tracked with phases)

| Risk | Mitigation phase |
|---|---|
| Restore can silently wipe/reject data | P1 (schemaVersion gate + dry-run) |
| Paise-level document inconsistencies | P1 (rounding + words) |
| Credential loss/theft (Nextcloud) | P2 (secure storage) |
| Refactor regressions in billing logic | P3 (tests first), P6 (differential tests) |
| Generated Drift files staleness in PRs | P4 (CI drift check) |
| Cloud backup feature unverifiable without Google client config | P4, P8 |
| Recurring invoice numbering collisions | P9 (sequence via P1 counters) |
| iOS 64-pending-notification cap for reminders | P8 wrap-up (document cadence limit) |