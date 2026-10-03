# Development Roadmap

This document tracks gaps and next development plans after reviewing the current codebase and docs. It should be read with `development-reference.md` and `development-phase-log.md`.

## Current Baseline

The app already includes the core offline billing system: businesses, customers, products, invoices, quotes, payments, refunds, voiding, customer activity events, reminders, reports, UOM and HSN catalogs, stock deduction, configurable numbering, editable PDF templates, local JSON backup/restore, Google Drive backup/link sharing, and Nextcloud backup/restore. It also now includes credit/debit notes, a stock movement ledger, recurring invoices, tax-at-source (TDS/TCS), reverse charge, ship-to, export/SEZ/LUT declarations, an HSN/SAC summary on invoices, a GSTR-1 style summary export, encrypted backups, and a PIN/biometric app lock.

Do not re-plan the following as missing work: receivables aging, empty states, reminder center, bulk actions, notification cadence, invoice/quote edit audit events, product stock deduction, currency-aware amounts, UOM catalog, HSN rate versioning, full database backup/restore, refunds, overpayments, payment voiding, templates, Google Drive backup, Nextcloud backup, document numbering, credit/debit notes, the stock ledger, recurring invoices, GST compliance fields (reverse charge, ship-to, export/SEZ/LUT, TDS/TCS), the GSTR-1 summary export, backup encryption, the app lock, or low-stock reorder levels and their product-list/dashboard/reports surfacing.

## Recommended Next Phases

### Phase 33: Backup Hardening And Automation (remainder)

- Add backup history listing for local, Google Drive, and Nextcloud backups, with restore points.
- Add integration-style tests around cloud backup/restore paths. (Encryption, secure credential storage, foreground auto-backup, snapshot pruning, and logos/settings coverage are done - see Phase 39.)

### Phase 34: GST Compliance Exports (remainder)

- Add validation for required GST fields (GSTIN, HSN/SAC, place of supply) before a GSTR-1 export, so an invalid document is caught rather than silently summarised.
- Add e-invoice/e-way bill preparation fields only after the required payload shape is finalized. (The GSTR-1 style B2B/B2CS/CDNR/HSN summary export is done - see Phase 39.)

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

- The seeded HSN catalogue is deliberately small and only covers codes whose current rate could be verified against the CBIC schedule; a full catalogue needs an authoritative rate import, not hand-entered guesses.
- LUT zero-rating is applied at the document level (the lines are recomputed at 0% on save), not by the tax engine, so a LUT document cannot show a non-zero rate line.
- Biometric unlock depends on native config (`FlutterFragmentActivity`, `USE_BIOMETRIC`, `NSFaceIDUsageDescription`) that has not been verified on a device build in this environment.
- Template configs are JSON blobs, so future template changes need compatibility defaults and migration tests.
- Generated Drift files are checked in; schema changes must update both source tables and generated output.
- Cloud backup and restore paths are mostly UI/service driven and need more automated coverage.

## Documentation Maintenance

- When a phase is implemented, move it from this roadmap into `development-phase-log.md`.
- Keep `development-reference.md` focused on current behavior, not future intent.
- Keep this file limited to unimplemented work, technical risks, and prioritization.
