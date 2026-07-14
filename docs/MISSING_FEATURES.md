# Development Roadmap

This document tracks gaps and next development plans after reviewing the current codebase and docs. It should be read with `development-reference.md` and `development-phase-log.md`.

## Current Baseline

The app already includes the core offline billing system: businesses, customers, products, invoices, quotes, payments, refunds, voiding, customer activity events, reminders, reports, UOM and HSN catalogs, stock deduction, configurable numbering, editable PDF templates, local JSON backup/restore, Google Drive backup/link sharing, and Nextcloud backup/restore.

Do not re-plan the following as missing work: receivables aging, empty states, reminder center, bulk actions, notification cadence, invoice/quote edit audit events, product stock deduction, currency-aware amounts, UOM catalog, HSN rate versioning, full database backup/restore, refunds, overpayments, payment voiding, templates, Google Drive backup, Nextcloud backup, or document numbering.

## Recommended Next Phases

### Phase 31: Recurring And Subscription Invoices

- Add recurring profile records with business, customer, schedule, next-run date, end condition, and source invoice template data.
- Generate draft invoices from due recurring profiles with clear audit/activity events.
- Add a settings/list screen for active, paused, and ended recurring profiles.
- Add tests for monthly/yearly schedules, skipped runs, end dates, and generated invoice numbering.

### Phase 32: Inventory Operations And Low-Stock Alerts

- Add stock adjustment records for manual corrections, purchases, invoice deductions, invoice edits, invoice deletes, and reversals.
- Surface low-stock warnings in product list, dashboard, and reports when `lowStockWarningsEnabledProvider` is enabled.
- Add product-level reorder thresholds instead of relying only on current stock quantity.
- Add tests for stock ledger balance, invoice edit rollback, and low-stock filtering.

### Phase 33: Backup Hardening And Automation

- Replace plain shared-preference storage for Nextcloud credentials with platform secure storage.
- Add backup history listing for local, Google Drive, and Nextcloud backups.
- Rework automatic backup as a foreground-safe scheduled reminder/action, or use an auth approach that works outside the foreground Google Sign-In flow.
- Add integration-style tests around backup restore schema completeness, especially templates and document template IDs.

### Phase 34: GST Compliance Exports

- Add GSTR-1 style export data for B2B invoices, HSN summary, credit/debit style adjustments if supported later, and document numbering ranges.
- Add e-invoice/e-way bill preparation fields only after the required payload shape is finalized.
- Add validation for required GST fields before export.
- Add CSV/JSON export tests with representative interstate and intrastate invoices.

### Phase 35: Reporting And Data Quality Expansion

- Add profit/margin reports once purchase cost or inventory purchase records exist.
- Add template and backup flows to automated regression coverage.
- Add import/deduplication workflows for customers, products, HSN codes, and UOMs if bulk onboarding becomes a priority.

### Phase 36: Profit And Margin Reporting

- Add margin reporting once purchase cost or inventory purchase records exist.
- Support per-invoice and per-customer profitability breakdowns.
- Add filters for date range, customer, and product/category.
- Add tests for margin math and negative-margin scenarios.

## Known Technical Risks

- Background Google Drive backup is not currently active; the Workmanager path is commented out because Google Sign-In requires foreground authentication.
- Nextcloud credentials are stored in `SharedPreferences`; this should move to secure storage before production use.
- Template configs are JSON blobs, so future template changes need compatibility defaults and migration tests.
- Generated Drift files are checked in; schema changes must update both source tables and generated output.
- Cloud backup and restore paths are mostly UI/service driven and need more automated coverage.

## Documentation Maintenance

- When a phase is implemented, move it from this roadmap into `development-phase-log.md`.
- Keep `development-reference.md` focused on current behavior, not future intent.
- Keep this file limited to unimplemented work, technical risks, and prioritization.
