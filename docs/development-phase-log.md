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

## Next Likely Phases

1. No new phase is committed yet.
