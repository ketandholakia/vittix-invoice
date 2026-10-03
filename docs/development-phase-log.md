# Development Phase Log

This log records the implemented milestones so future development can build on the existing work instead of rediscovering it.

## Phase 1: Billing Foundation

- Added transactional invoice creation.
- Added per-business, per-financial-year numbering for invoices.
- Stabilized invoice status and payment state handling.
- Added invoice editing, duplication, and deletion rules.
- Added invoice payment history.
- Added quote creation and quote numbering.

## Phase 2: Quote Lifecycle

- Added quote editing, duplication, deletion, and status transitions.
- Added quote conversion into invoices.
- Added quote conversion tracking for reporting.
- Added stalled quote follow-up queueing.

## Phase 3: Output And Sharing

- Added PDF sharing.
- Added CSV exports.
- Added reusable share/message text for invoices and quotes.

## Phase 4: Customer Management

- Added customer CRUD.
- Added phone and email fields to customer records.
- Added customer-aware reminder and follow-up actions.
- Added contact-aware dispatch for invoice reminders and quote follow-ups.

## Phase 5: Reporting And Dashboard

- Improved dashboard summaries for invoices and quotes.
- Added quote conversion metrics.
- Added follow-up queue visibility.
- Expanded reports with quote conversion and reminder activity.

## Phase 6: Customer Activity Timeline

- Added customer detail routing.
- Added customer invoice, quote, and payment lookup helpers.
- Added a customer activity screen with merged timeline events.
- Added summary stats for invoices, quotes, payments, collected amount, converted quotes, and last contact.

## Phase 7: Customer Contact Audit Trail

- Added an explicit customer activity event table.
- Added a DAO and provider for customer activity entries.
- Recorded quote follow-up contact events when follow-ups are dispatched.
- Switched the customer detail screen to use explicit contact events for last-contact display.

## Phase 8: Search And Filtering

- Added search across customer, invoice, and quote list screens.
- Added status and activity filters for customer, invoice, and quote lists.
- Added overdue and expiry-focused list filters for invoices and quotes.

## Phase 9: Receivables Aging Reports

- Added receivables aging buckets to reports for current, 1-30, 31-60, 61-90, and 90+ day balances.
- Added per-customer outstanding aging rows.
- Added CSV export for receivables aging.

## Phase 10: UX Polish And Empty States

- Added a shared empty-state widget for list and detail screens.
- Replaced plain empty-list text with clearer empty states and relevant actions for businesses, customers, products, invoices, and quotes.
- Added clearer filtered-result empty states for customer, invoice, and quote lists.
- Polished customer detail missing-record and no-activity states.
- Removed a duplicated invoice preview edit/delete action.

## Phase 11: Reminder Center

- Added a Reminder Center screen for due and overdue invoice reminders.
- Added quote follow-up reminders for quotes expiring within seven days or already expired.
- Added copy/share reminder actions from the reminder queue.
- Recorded invoice reminder contacts in the customer activity timeline.
- Added a provider-level test for due invoice reminder queueing.

## Phase 12: Bulk Invoice And Quote Actions

- Added long-press selection mode to invoice and quote list screens.
- Added bulk CSV export for selected invoices and quotes.
- Added guarded bulk delete for selected invoices and quotes.
- Skips invoices and quotes that cannot be deleted under existing business rules.

## Phase 13: Bulk Customer And Product Actions

- Added long-press selection mode to customer and product list screens.
- Added bulk CSV export for selected customers and products.
- Added guarded bulk delete for selected customers and products.
- Reports skipped records when database references prevent deletion.

## Phase 14: Bulk Reminder Actions

- Added long-press selection mode to Reminder Center.
- Added bulk copy and share for selected invoice reminders and quote follow-ups.
- Added CSV export for selected reminders.
- Marks selected invoices and quotes as contacted when bulk copy/share is used.

## Phase 15: Reminder Cadence And Device Notifications

- Added reminder notification preferences for enable/disable and cadence offsets.
- Added local device notifications for due invoices and expiring quotes.
- Added automatic reminder resync on app startup and when reminder data changes.
- Added a settings screen control path for initializing and tuning reminder notifications.
- Added persistence tests for reminder notification settings.

## Phase 16: Audit Trail For Document Edits

- Added invoice edit audit events to the customer activity timeline.
- Added quote edit audit events to the customer activity timeline.
- Recorded change summaries for customer, total, due-date, and item-count edits.
- Added provider tests covering invoice and quote edit audit event creation.

## Phase 17: Inventory Linkage

- Added stock quantity to products.
- Added product stock display to the product list and export.
- Deducted stock for linked product items when invoices are created or duplicated.
- Restored and re-applied stock when invoices are edited or deleted.
- Added provider coverage for product stock adjustment flows.

## Phase 18: Currency-Aware Document Amounts

- Added currency codes to businesses, invoices, and quotes.
- Added a business currency selector to the business form.
- Formatted product, invoice, and quote monetary displays from stored currency codes.
- Updated PDF and reminder messaging to use document currency values.
- Preserved document currency across create, edit, duplicate, and convert flows.

## Phase 19: Unit Of Measure Lookup Table

- Added a database-backed unit-of-measure catalog.
- Seeded the default unit list through the app startup provider path.
- Replaced hardcoded unit dropdown options on product, invoice, and quote entry screens with database-driven choices.
- Added provider coverage for seeded UOM values.

## Phase 20: HSN Tax-Rate Versioning

- Added HSN tax-rate history rows with effective-from dates.
- Updated HSN lookup to resolve the applicable rate for a document date.
- Added an HSN rate history screen for maintaining dated GST rate versions.
- Wired product and item entry flows to resolve GST from HSN at save time.
- Added provider and DAO coverage for rate history lookup and inserts.

## Phase 21: Full Database Backup And Restore

- Added JSON export of the full database state across business, customer, product, invoice, quote, HSN, UOM, payment, and activity tables.
- Added JSON restore support that rebuilds the database from a backup snapshot.
- Exposed backup export and restore actions from the Settings screen.
- Added roundtrip test coverage for exporting and restoring a full snapshot.

## Phase 22: Payment Refunds

- Added refund entries to invoice payment history with signed balance impact.
- Added refund recording from the invoice preview screen.
- Updated customer timelines and invoice payment summaries to display refund activity.
- Added provider and test coverage for refund balance recalculation.

## Phase 23: Overpayment Handling

- Allowed invoice payments to exceed the remaining balance when needed.
- Standardized balance-due calculations so overpaid invoices clamp to zero pending balance.
- Updated dashboard, reports, reminders, PDFs, and invoice list/detail views to use the shared balance helper.
- Added test coverage for overpayment storage and PAID status handling.

## Phase 24: Payment Reversal And Voiding

- Added voided payment state for invoice payment history.
- Replaced hard payment deletion in the invoice detail flow with voiding.
- Preserved payment records for audit history while removing their balance impact.
- Added test coverage for voided payment status recalculation.

## Phase 25: Document Templates

- Added business-level invoice and quote template selection.
- Added classic and modern PDF layouts for invoices and quotes.
- Exposed template selection from the Settings screen for the active business.
- Kept generated documents routed through the selected template without changing invoice or quote data capture.

## Phase 26: Google Drive Cloud Backup And Links

- Added Google account connection for Drive access.
- Added Drive backup upload and latest-backup restore from the Settings screen.
- Added shareable Drive link upload for invoice and quote PDFs.
- Reused the same PDF generation pipeline for local share, Drive share, and cloud backup flows.

## Phase 27: Custom Document Numbering

- Added business-level invoice and quote numbering format fields.
- Added a Document Numbering settings screen with token previews.
- Supported `{FY}`, calendar year/month tokens, and variable-width sequence tokens.
- Routed invoice, quote, duplicate, and quote-conversion numbering through the configured formats.

## Phase 28: Editable PDF Templates

- Added database-backed template configuration records for invoice and quote scopes.
- Added a template manager with preview thumbnails, clone, edit, delete, and default-selection actions.
- Added a template editor for layout family, colors, labels, columns, visibility toggles, watermark, footer, and UPI QR display.
- Added per-document template override selection on invoice and quote preview screens.

## Phase 29: Nextcloud Backup And Restore

- Added Nextcloud WebDAV configuration persistence.
- Added backup upload and latest-backup restore through Nextcloud from Settings.
- Created the `VittixInvoiceBackups` WebDAV folder when missing.
- Reused the full database JSON backup and restore pipeline used by local and Google Drive backup flows.

## Phase 30: Payment And Print Configuration Polish

- Added business-level UPI ID storage.
- Added optional UPI QR rendering in configured PDF templates.
- Added print-bank-details and low-stock warning preferences.
- Added an auto-backup preference flag, while background Drive backup execution remains disabled because Google Sign-In requires foreground authentication.

## Phase 31: Customer Statement Reporting

- Added a customer statement report path under Reports.
- Added statement rows that combine invoices, payments, refunds, and voided payments into a running balance.
- Added CSV export for customer statements.
- Added provider-backed test coverage for signed statement row ordering and balance math.

## Phase 32: Core Data Integrity Fixes

- Added `round2` money rounding and applied it at every computation boundary in GST breakdowns, item entry, invoice/quote totals, and payment/refund bookkeeping.
- Rewrote the amount-in-words converter to derive rupees and paise from a single rounded paise value (fixing binary floating-point drift and "One Rupees" wording).
- Replaced O(N) invoice/quote numbering scans with per-business, per-document-type, per-financial-year, per-format counters in a `document_sequences` table (schema v19 with counter backfill).
- Added unique-constraint-aware allocation that resyncs counters from scanned maxima for legacy numbers, deleted numbers, and mid-year format changes.
- Added foreign-key indexes across invoices, quotes, items, payments, customers, products, activity events, and template configs to remove full-table scans on joins and cascade deletes.
- Hardened backup restore with an exact schema-version gate and required-table validation so a failed restore can no longer wipe existing data.
- Fixed template configs and sequence counters missing from backup export/restore.
- Added regression tests for words, rounding, backup restore safety, and sequence counters (46 tests total, analyzer clean).

## Phase 33: Security Hardening

- Moved Nextcloud credentials out of plaintext SharedPreferences into platform secure storage (Keychain/Keystore) with a one-time migration that clears the legacy plaintext keys.
- Added a `SecureKeyValueStore` abstraction with a provider seam so credential persistence is unit-testable with mocked storage.
- Enforced HTTPS for Nextcloud WebDAV: plain `http://` URLs are rejected with an actionable settings error; schemeless URLs are normalized to `https://`.
- Replaced debug-key release signing with a dedicated release keystore (`android/app/release-keystore.jks`) configured via gitignored `android/key.properties`; release builds never fall back to debug keys.
- Verified `flutter build apk --release` output with `apksigner` (signed by the release certificate, not the debug cert).
- Added 9 tests covering credential migration, secure persistence, clearing, and URL enforcement (55 tests total, analyzer clean).

## Phase 34: Quality Gates And Test Expansion

- Tightened `analysis_options.yaml`: strict casts/inference/raw-types, `avoid_print`, `prefer_const_constructors`, `unnecessary_lambdas`, `unawaited_futures` (plus `discarded_futures` under `test/`), making `flutter analyze --fatal-infos` the quality bar (0 issues).
- Added unit coverage for the full `InvoiceNumberGenerator` token matrix (`{FY}`, `{YYYY}/{YY}/{MM}/{M}/{DD}/{MON}/{MONTH}`, `{SEQ2..6}`, backdated financial years) and currency-agnostic balance/overpayment math.
- Fixed a real century bug in `financialYear` that dropped the leading zero for years ending in `00` (e.g., 2000 produced `990` instead of `9900`).
- Added widget tests for invoice form validation (customer + items required), invoice list empty/filtered-empty states, and a working retry action on the list error state (previously plain text with no recovery).
- Added an end-to-end document pipeline test (business → customer → product → invoice → payment → PDF bytes → backup → restore) that runs both in the VM and on-device via `integration_test/`.
- Fixed a latent crash exposed by the e2e test: `pdf` 3.13 forbids combining `pageTheme` with `pageFormat`/`margin`/`theme` in `MultiPage`, so PDF generation would have asserted at runtime; layout settings moved inside `PageTheme`.
- Fixed a dashboard `Row` overflow on narrow screens ("Recent Invoices" header) and hardened reminder listener calls against plugin failures.
- Removed dead code (`models/invoice_summary.dart` was unused and non-type-safe).
- 73 tests total (22 new), analyzer clean; on-device integration run was attempted but this environment's emulator could not stay stable, so the same flow is verified by the VM run.

## Phase 35: DevOps And Release Readiness

- Added `.github/workflows/ci.yml`: PR/push CI runs `build_runner` + `git diff --exit-code` (fails on stale generated drift code), `flutter analyze --fatal-infos`, and `flutter test`; a tag-triggered (`v*`) release job builds the Play AAB + sideload APK, injects `key.properties`/`release-keystore.jks` from repo secrets when configured, and uploads artifacts.
- Android: app label now "Vittix Invoice"; applicationId aligned to `com.vittix.invoice` (namespace kept, TODO removed); `flutter_launcher_icons` (indigo `V` adaptive icon, generated for Android/iOS/web) and `flutter_native_splash` (#3730A3, API 31 splash) wired; R8 enabled for release (`isMinifyEnabled` + `isShrinkResources` with `proguard-rules.pro` keeps for `com.dexterous` (notifications), `com.it_nomads` (secure storage), `com.google.android.gms` (drive/sign-in models)).
- iOS: bundle ID aligned to `com.vittix.invoice` (prod + test targets); added `NSCameraUsageDescription`, `NSMicrophoneUsageDescription`, `NSPhotoLibraryUsageDescription`.
- macOS: added `com.apple.security.network.client` to Debug + Release entitlements so Nextcloud/Drive work in the sandboxed release build.
- Web: PWA manifest renamed to "Vittix Invoice" with proper description and brand colors; `index.html` title/meta/theme-color updated.
- Pruned dead deps: removed `cupertino_icons`, `uuid`, `mobile_scanner`, `riverpod_annotation`; updated package description.
- Verification: `flutter analyze --fatal-infos` clean; 73/73 tests pass; `flutter build apk --release` succeeds with R8 (72.2 MB, down from 85.1 MB) and apksigner confirms the release certificate (`CN=Vittix Invoice`) on package `com.vittix.invoice`.
- Deliberately skipped (documented in plan): ABI splits (app bundles handle this), `google-services.json` injection (no GMS Firebase config in this app), and on-device PDF/notification smoke-test of the R8 build (no stable emulator in this environment — first store-candidate build should be smoke-tested on a physical device).

## Phase 36: State Management And Performance Refactor (P5)

- Added Drift `watch*` stream methods to every DAO (invoices, items, payments, quotes, customers, products, businesses, activity events) — the first stream surface in the app.
- Converted all data providers to `StreamProvider.autoDispose` (lists, details, payments, activity) backed by those streams; added `businessDetailProvider`, `invoiceItemsProvider` families. Services/notifiers no longer invalidate for list/detail refresh — every mutation propagates through the DB stream (including stock deltas from invoice create/edit/delete, which previously never refreshed the product list).
- Removed ~25 mutation-time `ref.invalidate(...)` calls across `InvoiceService`, `QuoteNotifier`, and the CRUD notifiers; kept invalidation only where no watched table changes (reminder center after `markInvoiceReminderSent` — an activity-event-only write) and for retry affordances.
- Rewrote `invoice_preview_screen.dart`: the 7 AppBar `FutureBuilder`s plus the body `Future.wait` cluster (3 raw DAO reads re-created on every rebuild) are gone; the screen now renders from a single `ref.watch(invoiceDetailProvider(invoiceId))` with a `.when(loading/error/data)` body, a Retry button on error, and business/customer/items served by stream families. `updateInvoiceStatus`/`updateInvoiceTemplate`/payment actions refresh the open preview automatically via the streams.
- Moved the invoice/quote edit forms' initialization out of `build` (the `_hasInitialized` + `Future.microtask` anti-pattern): dates, customer and line items now load in `initState` via a post-frame callback.
- Memoized list filtering: new `filteredInvoiceListProvider`/`filteredQuoteListProvider` (`StreamProvider.autoDispose.family` over filter records) replace in-build `.where` recomputation; quote expiry helpers consolidated into `isQuoteExpiringSoon`/`isQuoteExpired` (semantics unchanged: CONVERTED excluded, non-negative window).
- Documented scale limit: `invoiceListPageSize = 500` — the invoice list stream loads the newest 500 invoices; search narrows within that window (same operating set for dashboard and reminder center).
- Dashboard app bar no longer creates a fresh DAO future in `build` (now `businessDetailProvider`); form screens untouched elsewhere.
- Dead code: deleted `core/constants/app_colors.dart` (zero references) and `FormValidators.requiredString` (unused). The `setState(() {})` occurrences were reviewed and kept — they are legitimate rebuild triggers for derived preview text/list re-reads, not dead code.
- Tests: 3 new stream-refresh tests (customer detail reflects edits with no manual invalidation; invoice detail/payments emit after `recordPayment`; active business emits after row change). Widget tests now flush drift's stream-close timer at teardown (`settleDriftStreams`).
- Verified: `flutter analyze --fatal-infos` clean; 76/76 tests pass.

## Phase 37: Invoice/Quote Unification (P6)

- New `DocumentServiceBase<D, IR, C, IC>` (`lib/services/document_service.dart`): the shared write core — transactional create-with-items, duplicate, update-with-items (delete-reinsert + stock reversal + edit-audit event), status/template updates, delete, and contacted events. Sequence allocation (`insertXWithGeneratedNumber` DAO seams), stock deltas, and the `INVOICE_EDIT`/`QUOTE_EDIT` audit summaries all run once here. Subclasses supply typed seams (dao ops, companion copyWith mapping, labels); `InvoiceService` and the new `QuoteService` (`lib/services/quote_service.dart`) are now thin subclasses (~2/3 of the old per-service logic moved into the base; service files shrank from ~400/480 lines to ~240/270).
- One mutation convention: `QuoteNotifier` (plain-class provider) deleted; `quoteProvider` is now `Provider<QuoteService>` mirroring `invoiceProvider`/`invoiceServiceProvider`. All 15 quote call sites and all existing tests keep their exact method names — the billing suite passed untouched (equivalence proof), including the quote delete/converted guards and the `QUOTE_EDIT` audit wording.
- Diff-summary helper: `_describeInvoiceEdit`/`_describeQuoteEdit` collapsed into `buildDocumentEditSummary` (`lib/core/utils/document_edit_summary.dart`) — output strings byte-identical ('due date'/'valid until', 'Invoice/Quote edited/refreshed').
- Item entry sheets unified: one generic `ItemEntrySheet<C>` in `lib/features/shared/item_entry_sheet.dart` (with `ItemEntryData` + `invoiceItemCompanionFromData`/`quoteItemCompanionFromData` mappers); both per-feature sheets deleted, including the private validator copies in `quote_item_entry_sheet.dart` (now `FormValidators`). Sheet title normalized to 'Add/Edit Line Item' on both sides.
- Create/edit forms unified: `lib/features/shared/document_form_screen.dart` holds the shared `DocumentFormScreenState<W, D, C, IC>` base (notes/terms seeding, date pickers, item add/edit/remove, supply-type logic, tax summing + save flow, and the whole build tree); `invoice_form.dart` and `quote_form.dart` now only keep labels, companion construction, save dispatch and their distinct customer summary cards (~480 → ~200 lines each, ~64% byte-identical build collapsed).
- Behavior fix (deliberate, covered by a differential test): `convertToInvoice` now routes through `InvoiceService.createInvoiceWithItems` (the shared core) instead of re-implementing the insert loop inline — and therefore now deducts product stock like any invoice create (previously conversion never touched stock; quotes still never touch stock). Conversion stays atomic (outer transaction wraps core create + `CONVERTED` status write).
- New differential tests (`test/document_service_test.dart`): quote create leaves stock untouched while invoice create deducts it (same payload → same totals/items); duplicate produces fresh-numbered DRAFT copies on both sides (stock re-deducted only for invoices); convert-to-invoice deducts stock via the shared core; edit-audit notes carry the document-specific labels.
- Verified: `flutter analyze --fatal-infos` clean; 80/80 tests pass (76 pre-existing untouched + 4 new).

## Phase 38: UX, Responsiveness, Currency And Localization (P7)

- Currency correctness — one helper, zero literals: new `formatMoneyForBusiness` (`lib/core/utils/formatting.dart`) plus the existing `formatMoney`/`currencySymbol` in `lib/core/utils/money_formatter.dart` replaced every `'Rs. '` literal across dashboard, item entry sheet (currency-aware `prefixText` via a new `currencyCode` param), reminder center, reports, and both preview/list screens (~30 sites). Amounts now render with the business's `currencyCode`.
- Dates — no more string split parsing: new `formatDate` and `formatDateTime` helpers replaced ~35 `toIso8601String().split('T')[0]` / `.toString().split(' ')` usages in `lib/features/**` and `lib/services/pdf_service.dart`. Audit strings in `buildDocumentEditSummary` (`lib/core/utils/document_edit_summary.dart`) switched to `formatDate`; differential tests in `test/document_service_test.dart` updated to the `'Jul 7, 2026 -> Jul 10, 2026'` format. CSV export rows intentionally keep ISO `toIso8601String().split('T')[0]` (machine-readable output, not date parsing).
- Navigation hardening — deep links no longer crash: added `lib/features/shared/not_found_screen.dart` and hardened `lib/app.dart` — 5 `state.extra! as X` casts guarded via `_extraOrNull<T>` (fall back to not-found), 3 unguarded `int.parse(path id)` replaced with `int.tryParse` fallback, and a new `GoRouter.errorBuilder` → `NotFoundScreen`. No route-shape (id-based push) conversion was done — guards preserve the existing UX and tests.
- Theme + dark mode: new `lib/core/theme/app_theme.dart` with `buildAppTheme(Brightness)` (light/dark from the same indigo seed, M3, centered `AppBarTheme`) plus a `StatusPalette`/`invoiceStatusColor`/`quoteStatusColor` helper that replaces the 4 duplicated status-color ternaries (dashboard stat cards, invoice list, quote list). `ThemeMode` persistence via a `ThemeModeNotifier` (`lib/providers/shared_preferences_provider.dart`, `themeModeProvider`, key `theme_mode`) wired into `MaterialApp.router` in `app.dart`; a dark-mode selector (System/Light/Dark) was added to Settings (`lib/features/settings/settings_screen.dart`).
- Responsive: new `lib/core/widgets/responsive_layout.dart` (`ScreenSize` compact/medium/expanded at <600/600-1000/>1000, plus a `ResponsiveLayout` widget). Dashboard stat cards now stack to a single column on <600 and lay out two-per-row on >=600; the follow-up header collapsed from a space-between `Row` to a `Wrap` to avoid overflow; other Rows already use `Expanded`/`Flexible` so list and form screens stay compact-safe.
- Localization scaffold (incremental): added `flutter_localizations` (sdk) and bumped `intl` to `^0.20.2` (conflict with the SDK-pinned `flutter_localizations`); new `l10n.yaml` (`arb-dir: lib/l10n/arb`, output to `lib/l10n/generated`), `lib/l10n/arb/app_en.arb`, and `generate: true` in `pubspec.yaml`; `MaterialApp.router` now wires `AppLocalizations.localizationsDelegates`/`supportedLocales`. Migrated a representative shared widget (Settings > Appearance dropdown → `loc.appearance`/`loc.system`/`loc.light`/`loc.dark`) to prove the pipeline end-to-end; the rest of the inline strings are left for the planned hi-IN translation pass per P7 scope.
- Out of scope / deferred: splitting the giant `reports_screen.dart` (1,196), `settings_screen.dart` (796), and `template_manager_screen.dart` (1,039). These have no failing tests and the interactions are not localized enough to split cleanly yet — left as explicit follow-ups rather than rushed edits (see "Next Likely Phases"). `AppColors` still exists untouched (no dead-file deletion attempted this phase).
- Audit result: `flutter analyze --fatal-infos` clean; 80/80 tests pass. Acceptance gates — zero `'Rs. '` literals, zero `toString().split()` date parsing in `lib/`, deep links fail gracefully, dark toggle persists — all satisfied.

## Phase 39: Correctness, Compliance And Backup Hardening

A review-driven pass over the whole app. Schema moved v19  v29.

- Tax and money correctness: each line's CGST/SGST/IGST split is recomputed from its own taxable amount and GST rate against the document's supply type at save (a customer change no longer leaves lines disagreeing with `isIgst`); component sums are rounded per document; `subtotal`/`discountAmount`/`taxableAmount` are now modelled separately and the PDF prints Subtotal  Discount  Taxable; whole-rupee round off is applied to the payable and is switchable (`roundOffEnabledProvider`). New pure `computeDocumentTotals` (`lib/core/utils/document_totals.dart`).
- Document lifecycle: only DRAFT invoices are editable (issued documents are corrected with a note); deleting is limited to drafts so GST series never gap; payments cannot be recorded on a cancelled invoice and cancelled invoices cannot be reopened; credit/debit notes (`createCreditNote`/`createDebitNote`) copy an issued invoice into its own `CN-`/`DN-` series, and a credit note returns stock.
- Totals scope: cancelled/draft documents are excluded from dashboard, reports, statements and exports; credit notes subtract (`signedInvoiceTotal`), and notes are not receivables.
- GST compliance: supply type and place of supply are derived (B2B/B2C, customer state  GSTIN state  business state) and can be overridden (incl. EXPORT/SEZ); HSN rates updated for the 22 Sep 2025 revision with price bands (garments 5% up to Rs.2,500 / 18% above); non-GST invoices are typed `BILL_OF_SUPPLY`; reverse charge, ship-to, HSN/SAC summary on the PDF, export/SEZ/LUT declaration (LUT supplies auto zero-rate), TDS/TCS, and a GSTR-1 style summary export (B2B/B2CS/CDNR/HSN).
- Stock: new append-only `stock_movements` ledger replaces the clamp-at-zero counter; the product balance is the ledger sum and over-sales stay visible as negative.
- Backup: passphrase encryption (PBKDF2-HMAC-SHA256 + AES-256-GCM, self-describing envelope, wrong passphrase leaves the DB untouched) for local and cloud paths; pre-restore snapshots pruned to the newest 5; logos and selected preferences included in the backup; `allowBackup` disabled on Android.
- Output and platform: bundled Noto Sans + Devanagari/Gujarati fonts so the rupee sign and Indic names render offline; dd-MM-yyyy on printed documents; state codes printed as "Gujarat (24)"; app lock with PIN and biometrics (local_auth, `FlutterFragmentActivity`, `USE_BIOMETRIC`, `NSFaceIDUsageDescription`); Drive share link warns before creating public access and offers revoke; Nextcloud reuses one HTTP client.
- Recurring invoices (was Phase 31): `recurring_invoices` schedules repeat an issued invoice into a fresh draft on launch, with month-end clamping and catch-up so a date can never generate twice.
- Robustness: payment state refresh re-reads inside its transaction (no stale-row writes); non-fatal failures are reported through `reportNonFatal` instead of being swallowed; a one-shot migration repairs pre-existing lines whose tax split disagreed with their document.
- Verified: `flutter analyze` clean; 134/134 tests pass.

## Phase 40: Low-Stock Reorder Thresholds And Surfacing

- Added `products.reorderLevel` (schema v30) with a **Reorder Level** field on the product form (0 = no threshold configured).
- New `isProductLowStock` / `lowStockLabel` helpers (`lib/core/utils/stock_status.dart`): a configured reorder level wins; with none set the product only counts as low once it is out of stock. Services never hold stock and are never flagged.
- Surfaced in three places, all gated by the existing `lowStockWarningsEnabledProvider`: a badge on the product list row, a dashboard banner counting low-stock products with a shortcut into the product list, and a **Low Stock** section in Reports that lists products with their stock against the reorder level.
- Completes the former Phase 32 (its stock-movement-ledger half landed in Phase 39).
- Verified: `flutter analyze` clean; 137/137 tests pass (`LowStock` group covers the threshold rule, the out-of-stock fallback, and the service exemption).
- Deliberately not automated: a widget test for the Reports screen. Its charts animate continuously, so `pumpAndSettle` never settles and the screen has no widget-test coverage elsewhere; the section is exercised through the pure helper instead.

## Phase 41: Compliance-Correct GSTR-1 Export

- The GSTR-1 summary export reads the full book through a new uncapped `InvoiceDao.getInvoicesForBusinessBetween` (plus the uncapped all-time query) instead of the 500-row-capped `invoiceListProvider`, which silently truncated exports for larger businesses. Dashboard and reminder center intentionally keep the windowed stream.
- Added pre-export validation (`lib/core/utils/gstr1_validation.dart`): GSTIN format + checksum, B2B invoices whose customer has no GSTIN, impossible places of supply (state codes), lines with a missing or too-short HSN/SAC, and negative taxable amounts. The Reports screen lists every issue in a dialog with tap-to-open invoice navigation, "Export anyway", and cancel.
- Added an EXP/SEZ section (EXP/SEZ-WPAY/WOPAY derived from the LUT flag); export supplies no longer leak into the domestic B2B/B2CS sections. The HSN summary now carries a UQC column, mapping app UOM codes to the official UQC set (KG→KGS, GRM→GMS, CM→CMS, ML→MLT; unknown → OTH).
- Tests: 501-invoice range export completeness (bucket total proves no truncation), UQC mapping, EXP/SEZ routing, and seven validation rules (147 total at close).

## Phase 42: Data-Safety Hardening

- Rewrote the Drift `onUpgrade` ladder in strict ascending version order. The previous descending order crashed any database upgrading across step boundaries (v6 databases died in the v22 stock backfill reading the v7 `stock_quantity` column; v20 databases died in the v28 tax-split repair writing the v21 `round_off_amount` column; pre-v17 databases died in the v19 sequence backfill reading the v17 series-format columns).
- Added `_addColumnIfMissing` and routed every `addColumn` through it: `Migrator.createTable` builds tables from the *current* Dart schema, so tables created mid-migration already contain later-added columns and a plain `addColumn` fails with "duplicate column name" (uoms at v10/v11, invoice_payments at v5/v12/v23). The v19 and v22 backfills now select explicit columns instead of full rows for the same reason.
- Added `test/migration_test.dart`: hand-built v6 and v20 database fixtures (raw SQL at historical shapes, `PRAGMA user_version` set) upgrade to v30 and assert the stock-ledger opening backfill, sequence-counter backfill, tax-split repair, and every added column land correctly.
- Hardened the app lock: the PIN is now stretched with PBKDF2-HMAC-SHA256 (100k iterations, random per-install salt — the same parameters as backup encryption) with constant-time comparison; legacy single-SHA-256 digests are verified once and transparently upgraded on the next successful unlock. Wrong attempts now trigger a persisted lockout (5 attempts → 30 s, doubling per extra failure up to 15 min) that survives app restarts; the lock screen shows a live countdown and disables PIN entry while locked out.
- Added a diagnostics ring buffer (200 records) behind `reportNonFatal` with a Settings → Export diagnostics share action, and replaced the six remaining silent `catch (_) {}` sites (four bulk-delete loops, the pre-restore safety snapshot, the Nextcloud secure-storage write queue) with reported failures.
- Verified: `flutter analyze --fatal-infos` clean; 154/154 tests pass.

## Next Likely Phases

1. Platform completion for chosen ship targets (iOS Google Sign-In config, macOS keychain entitlement, Linux plugin registrants) and integration tests in CI.
2. Bill of Supply as a first-class document type; per-business GST toggle; composition-scheme handling.
3. Margin/profit reporting now that `products.purchasePrice` provides a per-product cost basis.
4. Invoice list/dashboard performance beyond the current 500-row window.
5. E-invoice/e-way bill preparation once the payload shape is settled.
