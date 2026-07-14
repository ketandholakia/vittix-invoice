# Development Reference

This document tracks the implemented structure of VittixInvoice so future work can stay aligned with the current codebase.

## Architecture

- UI layer: Flutter screens under `lib/features/**`
- State layer: Riverpod providers under `lib/providers/**`
- Data layer: Drift database, DAOs, and generated table classes under `lib/database/**`
- Sharing and output: PDF and share services under `lib/services/**`

## Core Data Model

- Businesses own customers, products, invoices, and quotes.
- Businesses store a default currency code that flows into new invoices and quotes.
- Customers store contact and tax details.
- Invoices and quotes store the commercial document header plus item rows in separate item tables.
- Invoice payments are stored separately and rolled into invoice status and balance state.
- Invoice payments now support refund entries alongside standard receipt entries.
- Overpaid invoices keep the collected amount intact while clamping pending balance to zero in reports and reminders.
- Payment history also supports voided entries, which preserve audit history but no longer affect invoice balances.
- Businesses store invoice and quote PDF template choices that drive classic or modern document layouts.
- Google Drive sign-in now supports cloud backup upload/restore and shareable invoice or quote PDF links.
- Products now track on-hand stock quantity for linked invoice items.
- Units of measure are stored in a database-backed catalog with family, base-unit, and conversion-factor metadata.

## Implemented Billing Flows

- Invoice creation is transactional and assigns per-business, per-financial-year numbering.
- Quote creation is transactional and uses the same numbering rules with a `QT` prefix.
- Quote conversion creates a fresh invoice and marks the quote as converted.
- Invoice editing, duplication, deletion, and payment updates are supported.
- Quote editing, duplication, deletion, and status updates are supported.
- Invoice and quote edits now write audit events into the customer activity timeline.
- Invoice create, duplicate, edit, and delete flows adjust linked product stock automatically.
- Invoice and quote PDFs, reminders, and key list/detail screens format amounts from the stored currency code.
- PDF sharing and CSV export are available for the main document flows.
- Invoice and quote list screens support long-press selection for bulk CSV export and guarded bulk delete.
- Customer and product list screens support long-press selection for bulk CSV export and guarded bulk delete.
- The Settings screen exposes backup/restore actions and UOM catalog management.
- Invoice preview includes payment and refund entry actions.
- Invoice preview also supports voiding a recorded payment.
- Settings exposes document template selection for the active business.
- Settings exposes Google Drive backup connect/upload/restore actions for the active business.

## Customer Workflows

- Customer CRUD is available from the customer list and form screens.
- Customer records now include phone and email fields.
- Customer list rows open a dedicated customer detail screen.
- Customer detail shows:
  - customer identity and contact summary
  - quote count
  - invoice count
  - payment count
  - collected amount
  - converted quote count
  - last contact time derived from the newest quote update
  - merged activity timeline for quotes, invoices, and payments

## Reporting And Dashboard

- Dashboard includes billing and quote activity summaries.
- Reports include invoice metrics, quote conversion metrics, and follow-up queue visibility.
- Reports include receivables aging buckets for current, 1-30, 31-60, 61-90, and 90+ day outstanding balances.
- Reminder and follow-up copy/share actions use customer phone/email when available.
- The Reminder Center queues unpaid invoices due within seven days or overdue, plus active quotes expiring within seven days or expired.
- The Reminder Center supports long-press selection for bulk copy, share, and CSV export of reminder messages.
- Reminder notifications can be enabled or disabled, and cadence offsets are configurable from settings.

## Providers

- `customerListProvider`: active-business customer list
- `customerDetailProvider`: single customer lookup for detail view
- `customerInvoicesProvider`: invoices for a customer
- `customerQuotesProvider`: quotes for a customer
- `customerInvoicePaymentsProvider`: payment history for all invoices belonging to a customer
- `invoiceListProvider`: active-business invoice list
- `invoicePaymentsProvider(invoiceId)`: payments for a specific invoice
- `quoteListProvider`: active-business quote list
- `productListProvider`: active-business product list
- `uomListProvider`: active-business UOM list
- `uomCatalogProvider`: full UOM catalog for management screens

## DAO Helpers Added For Customer Views

- `InvoiceDao.getInvoicesForCustomer(int customerId)`
- `InvoiceDao.getPaymentsForInvoices(List<int> invoiceIds)`
- `QuoteDao.getQuotesForCustomer(int customerId)`

These helpers keep the customer timeline screen simple and avoid pushing business logic into widgets.

## Important Screens

- `lib/features/dashboard/dashboard_screen.dart`
- `lib/features/customers/customer_list_screen.dart`
- `lib/features/customers/customer_form_screen.dart`
- `lib/features/settings/uom_management_screen.dart`
- `lib/features/customers/customer_detail_screen.dart`
- `lib/features/invoices/list/invoice_list_screen.dart`
- `lib/features/invoices/detail/invoice_preview_screen.dart`
- `lib/features/quotes/list/quote_list_screen.dart`
- `lib/features/quotes/detail/quote_preview_screen.dart`
- `lib/features/reports/reports_screen.dart`
- `lib/features/reminders/reminder_center_screen.dart`

## Shared UI

- `lib/core/widgets/empty_state.dart` provides the standard empty-state layout for list and detail screens.

## Operational Notes

- Re-run `flutter analyze` and `flutter test` after data model or provider changes.
- Rebuild generated files after Drift schema changes or annotated provider changes.
- If timeline detail needs to become more accurate later, add explicit contact/event fields rather than inferring from `updatedAt`.
