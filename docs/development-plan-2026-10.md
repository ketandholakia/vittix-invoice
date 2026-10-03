# Development Plan (October 2026 Audit)

Master plan for the next development cycle, produced from a full independent code review on 2026-10-04. It continues the cycle of `development-plan.md` (whose P1-P12 are complete through Phase 40 in `development-phase-log.md`). Read together with `development-reference.md` and `MISSING_FEATURES.md`.

## Verified current state

Everything below was re-verified in this audit, not taken from the phase log:

- `flutter analyze --fatal-infos` clean; **137/137 tests pass**.
- Schema v30, 16 tables, `PRAGMA foreign_keys = ON`; 126 Dart files (~24k of the ~48k lines are generated Drift output).
- Spot-checks of Phase 39/40 claims (`computeDocumentTotals`, `stock_movements` ledger, `recurring_invoices` launch run, app-lock wiring, GSTR-1 export) all check out in code. The phase log is honest.

## Findings (new, not in any doc)

| # | Finding | Evidence | Severity |
|---|---|---|---|
| F1 | **Phases 32-40 exist only as uncommitted working-tree state.** Last commit is Phase 31 ("Add customer statement reporting", 2026-07-14); 199 files modified, ~18.7k insertions uncommitted. CI's drift-diff gate is validating an unversioned state. | `git status` | Critical |
| F2 | **The GSTR-1 summary export silently truncates at the newest 500 invoices.** `reports_screen.dart:453` feeds the export from `invoiceListProvider`, which applies `limit: invoiceListPageSize` (500) at `lib/providers/invoice_provider.dart:12,21`. A compliance export that quietly drops documents is a correctness bug, not a perf footnote. Dashboard and reminder center share the same capped stream (acceptable there; label it). | `lib/features/reports/reports_screen.dart:453`, `lib/providers/invoice_provider.dart:12` | Critical |
| F3 | **Latent Drift migration-ordering crash.** `onUpgrade` runs blocks in descending order, but `from < 22` reads `product.stockQuantity` (column added in `from < 7`, which runs later) and `from < 28` writes `round_off_amount` (added in `from < 21`). Any pre-v21 database upgrading to v30 fails. Never fired only because the app is unreleased. | `lib/database/app_database.dart:86-306` | Critical pre-release |
| F4 | **No crash reporting.** `reportNonFatal` (`lib/core/utils/app_diagnostics.dart:10-23`) forwards to `FlutterError.reportError`, which is console-only in release. Six list/settings/provider sites still `catch (_) {}` silently (`customer_list_screen.dart:100`, `invoice_list_screen.dart:136`, `product_list_screen.dart:152`, `quote_list_screen.dart:121`, `settings_screen.dart:55`, `nextcloud_provider.dart:117`). | as listed | High |
| F5 | **App-lock PIN hash is weak**: static salt `'vittix-app-lock'` + single unsalted SHA-256 pass, no wrong-attempt throttling — weaker than the PBKDF2 already implemented for backups. | `lib/services/app_lock_service.dart:14-24` | High |
| F6 | **Platform gaps for flagship features**: iOS has no `GIDClientID`/`CFBundleURLTypes` (google_sign_in 7.x requires one → Drive backup dead on iOS); macOS lacks a Keychain entitlement for `flutter_secure_storage`; Linux `generated_plugins.cmake` lacks `local_auth` + `flutter_local_notifications`; web has no sign-in client and no secure storage. | platform dirs | High for release scope |
| F7 | **Test blind spots in the riskiest code**: `pdf_service.dart` (1,737 lines — only fonts/smoke coverage), `GoogleDriveService` (zero tests), Nextcloud upload/restore/PROPFIND round trip (parse errors are swallowed into a misleading "No cloud backup found", `nextcloud_service.dart:190-222`), `ReminderNotificationService` scheduling math. | `test/` | High |
| F8 | **Monolith files keep growing**: `pdf_service.dart` 1,737; `reports_screen.dart` 1,381; `invoice_preview_screen.dart` 1,169; `settings_screen.dart` 1,158 (grew ~45% since Phase 38 flagged it at 796); `template_manager_screen.dart` 1,104; `test/billing_logic_test.dart` 3,608. | wc -l | Medium |
| F9 | **Services hold a Riverpod `Ref` and read DAO providers back** (e.g. `invoice_service.dart:637` reads `productDaoProvider`), while providers construct services — a service↔provider cycle that blocks plain unit testing. | `lib/services/*`, `lib/providers/*` | Medium |
| F10 | **Localization not started**: 24 EN keys, `supportedLocales=[en]`, only 2 files use `AppLocalizations`; ~344 hardcoded `Text('...')` plus ~650 more literals across features/PDF/notifications (~800-1,000 strings total for hi-IN). | `lib/l10n/` | Strategy decision |
| F11 | **Release hygiene**: no CHANGELOG, version static at `1.0.0+1` with no policy, no iOS/macOS CI jobs, `integration_test/` never runs in CI, crash logs (`flutter_0*.log`, `review_analyze.log`) committed at repo root, commented-out workmanager block in `main.dart:14-38`. | repo root, `.github/workflows/ci.yml` | Medium |

## Priority summary

| Priority | Item | Phase |
|---|---|---|
| Critical | Commit/protect Phases 32-40; release hygiene | R0 |
| Critical | Uncapped, validated GSTR-1 export | P41 |
| Critical | Migration ordering fix + schema migration tests; app-lock PBKDF2 + throttle; crash reporting wired | P42 |
| High | Platform completion for chosen ship targets; CI integration tests | P43 |
| High | Tests for PDF/Drive/Nextcloud/reminder services; split test monolith | P44 |
| Medium | Split screen/service monoliths; break service↔provider cycle | P45 |
| Medium | Margin/profit reporting (`purchasePrice` now exists) | P46 |
| Medium | Composition scheme / Bill of Supply as first-class document | P47 |
| Strategy | hi-IN localization (~800-1,000 strings) | P48 |
| Deferred | E-invoice/e-way bill (blocked on payload shape), backup history UI, bulk import with dedupe, list pagination >500, multi-device sync | backlog |

## Phase dependency map

```
R0 (commit & protect) ──► everything
P41 (compliance exports) ─► P42 (data safety) ─► P43 (platform/CI) ─► first store release candidate
P44 (tests) ─► P45 (splits/refactor)          (can start after P42; before or after release)
P46 (margin) / P47 (composition)               (feature phases, after P45 recommended)
P48 (hi-IN)                                    (any time; decision-gated)
```

---

## R0: Commit And Protect (do first — hours, not days)

**Priority:** Critical · **Effort:** S · **Depends on:** nothing

**Findings addressed:** F1, F11 (hygiene half).

**Tasks**
1. Delete stray log files (`flutter_01-04.log`, `review_analyze.log`); add `*.log` to `.gitignore`.
2. Commit the 199-file working tree. Retroactive logical chunking across 8 phases of interleaved edits is impractical — make one checkpoint commit ("Phases 32-40: integrity, security, compliance, UX"), tag it (e.g. `v0.9.0-checkpoint`), and use clean per-phase commits going forward.
3. Create `CHANGELOG.md` seeded from the phase log; define the version policy (e.g. `0.x.y+build` until first store release).
4. Confirm CI is green on the pushed commit (drift-diff gate, analyze, 137 tests).

**Acceptance criteria:** `git status` clean; tagged checkpoint pushed; CI green; no log files in the repo.

---

## P41: Compliance-Correct GSTR-1 Export

**Priority:** Critical · **Effort:** M · **Depends on:** R0

**Findings addressed:** F2; roadmap item "GST field validation before export" (MISSING_FEATURES Phase 34 remainder).

**Tasks**
1. New DAO query returning **all** invoices in a date range for the business (no `LIMIT`); the export path uses it directly instead of `invoiceListProvider`. Dashboard/reminders/reminder center keep the 500-row window but document the cap in code where the constant is defined.
2. Pre-export validation producing an actionable error list per offending document: GSTIN format + checksum (checksum util already tested), HSN/SAC present on every line, place of supply set for inter-state, non-negative taxable values. Validation offers "fix now" navigation into the document.
3. GSTR-1 completeness: add the EXP/SEZ section and UQC in the HSN summary (both currently missing).
4. Tests: export with >500 invoices includes every document; each validation rule fires on a crafted invalid invoice; export reconciles to DB totals to the paise.

**Acceptance criteria:** an export from a business with 700 invoices in range contains all 700; invalid documents are listed, not silently summarised.

---

## P42: Data-Safety Hardening (pre-release blocker)

**Priority:** Critical · **Effort:** M · **Depends on:** R0

**Findings addressed:** F3, F4, F5.

**Tasks**
1. Rewrite `onUpgrade` in ascending version order (extract each step into a named function called in sequence). Add Drift schema-migration tests (`drift_dev` schema test harness) covering v1→v30 and each jump that previously reordered badly (pre-v7, pre-v21 upgrade paths).
2. App lock: switch the PIN hash to the PBKDF2 parameters already used by `BackupCipher`, generate a random per-install salt, and add wrong-attempt backoff (e.g. exponential delay after 5 misses). Migration: verify old hash on first unlock, re-store with new hash.
3. Wire `reportNonFatal` to a real sink. Recommended: `sentry_flutter` (attach at the single `reportNonFatal` seam; no other call sites change). If no backend is wanted yet, implement a local ring-buffer log with an "export diagnostics" action in Settings — but pick one deliberately.
4. Replace the six silent `catch (_) {}` sites with `reportNonFatal` calls.

**Acceptance criteria:** a v18 database fixture upgrades to v30 in a test without error; 5 wrong PINs trigger visible lockout; a forced backup failure surfaces in the chosen diagnostics sink.

---

## P43: Platform Completion And CI Depth

**Priority:** High · **Effort:** M · **Depends on:** R0 (P42 for lock/biometrics verification)

**Findings addressed:** F6, F11 (CI half). **Requires a ship-target decision** (see Decision points).

**Tasks**
1. Declare ship targets explicitly in the README; for non-shipped platforms, either regenerate plugin registrants (Linux `local_auth`/notifications) or disable the affected features gracefully and mark the platform unsupported.
2. iOS: add `GIDClientID` + reversed-client-ID `CFBundleURLTypes` (google_sign_in 7.x requirement), or gate Drive backup out of iOS until configured; device-verify Face ID + notifications once.
3. macOS: add Keychain access entitlement for `flutter_secure_storage`; verify PIN lock and Nextcloud in a sandboxed release build.
4. CI: run `integration_test/app_flow_test.dart` on every push (Linux desktop is the cheapest host); add an iOS/macOS build job only for targets actually shipping.

**Acceptance criteria:** every platform the app ships on passes its flagship smoke test in CI; unsupported platforms fail gracefully, not silently.

---

## P44: Tests For The Risky Code

**Priority:** High · **Effort:** M · **Depends on:** P42 (diagnostics seam helps fake backends)

**Findings addressed:** F7, F8 (test monolith).

**Tasks**
1. `pdf_service.dart`: extract pure functions first (template-config parsing, color parsing, layout metrics) and unit-test those; add per-template-family render-to-bytes smoke tests (classic, modern, watermark, UPI QR, HSN summary table).
2. `GoogleDriveService` + `NextcloudService` behind a fake `http.Client` / Drive API stub: upload, latest-backup selection, snapshot pruning, restore round trip, and error paths (PROPFIND parse failure must surface, not become "No cloud backup found").
3. `ReminderNotificationService`: scheduling math (cadence offsets, timezone changes), id allocation, exact-alarm permission fallback.
4. Split `test/billing_logic_test.dart` (3,608 lines) by domain into `gst_test.dart`, `numbering_test.dart`, `backup_test.dart`, `stock_test.dart`, `statements_test.dart`, `gstr1_test.dart`, etc. No test logic changes — moves only.

**Acceptance criteria:** zero-coverage list from the audit is empty; `flutter test` stays green with the same assertions reorganized.

---

## P45: Codebase Health — Splits And Decoupling

**Priority:** Medium · **Effort:** M-L · **Depends on:** P44 (safety net first)

**Findings addressed:** F8, F9, dead code.

**Tasks**
1. Split the monoliths (move-only refactors, one PR each): `pdf_service.dart` → template parsing + per-family renderers; `reports_screen.dart` → per-report widgets with a shared export controller; `settings_screen.dart` → section files (it regrew 45% since Phase 38 flagged it — split before it regrows again); `template_manager_screen.dart` → list/detail widgets.
2. Break the service↔provider cycle: services take DAOs via constructor injection instead of reading providers from a stored `Ref`. Providers keep constructing services; services become plain-unit-testable.
3. Remove the commented-out workmanager block in `main.dart`; give the Nextcloud HTTP client timeouts + one retry; make `_syncReminders` incremental (cancelAll+reschedule-all is O(all reminders) on every change).

**Acceptance criteria:** no feature file > ~800 lines; services construct with DAOs only (no `Ref`); behavior-identical per the P44 test suite.

---

## P46: Profit And Margin Reporting

**Priority:** Medium · **Effort:** M · **Depends on:** P45 (reports split) — content from roadmap Phases 35/36.

**Tasks**
1. Margin report over issued invoices: revenue, COGS from `products.purchasePrice` (fallback: sale price with zero margin flagged), gross margin per invoice/customer/product, date + customer + product filters.
2. Uncapped DAO queries per P41's pattern (this report must not truncate either).
3. Tests: margin math, missing purchase price, negative margins, credit notes reduce revenue, cancelled/draft excluded.

**Acceptance criteria:** margin totals reconcile with invoice totals to the paise; the report handles products with no cost basis explicitly.

---

## P47: Composition Scheme And Bill Of Supply

**Priority:** Medium · **Effort:** M · **Depends on:** P45. — roadmap "Next Likely Phases" #2.

**Tasks**
1. Per-business GST registration type: regular / composition / unregistered; composition businesses issue Bills of Supply with scheme rates (no ITC, no tax lines).
2. Promote Bill of Supply from the Phase 39 invoice `type` to a first-class series: own numbering prefix, template label, and GSTR-1 exclusion (composition filings are a separate summary — out of scope, but the export must not mix them in).
3. Tests: series separation, rate behavior per scheme, export exclusion.

**Acceptance criteria:** a composition business can bill end-to-end with correct output documents and never appears in the GSTR-1 B2B/B2CS export.

---

## P48: Localization (hi-IN)

**Priority:** Strategy decision · **Effort:** L · **Depends on:** nothing technical — pipeline is ready (arb, `generate: true`, bundled Devanagari fonts).

**Findings addressed:** F10. **~800-1,000 strings across ~30 screens + PDF labels + notifications + CSV headers.** Only 24 keys exist today.

**Tasks** (if scheduled)
1. Migrate strings domain-by-domain (dashboard → lists → forms → settings → dialogs), keeping machine-read status codes untranslated.
2. Add `app_hi.arb`; set `supportedLocales` to [en, hi]; device-locale detection with a Settings override.
3. PDF templates: template-level language preference per business (labels already come from template config — extend, don't hardcode).
4. Decide CSV header language (keep English for accountant/tooling compatibility — recommended).

**Acceptance criteria:** full app navigable in hi-IN with no clipped/overflowing labels on two breakpoints; PDF renders Hindi names/amounts with the bundled fonts.

**Recommendation:** English-first India launch is viable; schedule this after market feedback unless the target segment demands Hindi at launch.

---

## Backlog / watchlist (unchanged or blocked)

- E-invoice / e-way bill preparation — blocked on finalizing the payload shape (roadmap guidance; do not build speculatively).
- Backup history listing with restore points (roadmap Phase 33 remainder).
- Bulk import + dedupe for customers/products/HSN/UOM (roadmap Phase 35) — pair with onboarding need.
- Invoice list pagination beyond the 500-row window for very large books.
- Multi-device sync/conflict resolution — separate product decision.
- Full authoritative HSN catalogue import (needs an official CBIC source, not hand entry).

## Risk register

| Risk | Mitigation |
|---|---|
| Working-tree loss destroys Phases 32-40 | R0 checkpoint commit (immediate) |
| Silent GSTR-1 truncation for active businesses | P41 uncapped export + test |
| Upgrade crash for any legacy database at first release | P42 ascending migrations + schema tests |
| Undiagnosable release failures (no crash reporting) | P42 diagnostics sink |
| PIN brute-force on a stolen device | P42 PBKDF2 + throttle |
| Feature-dead platforms shipping anyway | P43 explicit ship targets |
| Refactor regressions in PDF/reports | P44 tests before P45 splits |

## Decision points (owner: you)

1. **Ship targets** — DECIDED 2026-10-04: **Android only**. P43 completed for that scope (README policy, master CI trigger fix, per-push Android compile gate, release APK verify). iOS/macOS/Linux/web items below are closed as will-not-fix.
2. **Crash reporting** — decided by default: local diagnostics ring (implemented in P42); `sentry_flutter` can still be attached at the `reportNonFatal` seam without touching call sites if a backend is ever wanted.
3. **hi-IN at launch or after** — recommend after launch unless the segment demands it. Blocks P48 scheduling.
4. **Retroactive commit chunking** — DECIDED 2026-10-04: one checkpoint commit (`89191fe`), tagged `checkpoint-phase-40`; clean history forward.
