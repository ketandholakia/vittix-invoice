# Missing Features

This document tracks known gaps between the current VittixInvoice implementation and likely future requirements. Use it alongside `DEVELOPMENT_REFERENCE.md` and `PHASE_LOG.md` to plan upcoming work.

## Explicitly Flagged Next Phases

## Inferred Gaps

### Billing & Payments

- No recurring/subscription invoice support.

### Operations

- No audit trail for invoice/quote edits themselves (who changed what, when) - only customer contact tracking is implemented.

## Suggested Prioritization

1. Recurring/subscription invoice support
2. Any future payment adjustments that need scheduled recurrence logic

## Notes

- This list is derived from reading `DEVELOPMENT_REFERENCE.md` and `PHASE_LOG.md`; verify against actual code before scoping, since some gaps may already be partially addressed in-progress.
- Update this file as features are implemented or reprioritized, mirroring the phase-log style used elsewhere.
- Receivables aging reports were implemented in Phase 9.
- Detail and empty-state UX polish was implemented in Phase 10.
- Due-date driven reminder center was implemented in Phase 11.
- Bulk invoice and quote export/delete was implemented in Phase 12.yes
- Bulk customer and product export/delete was implemented in Phase 13.
- Bulk Reminder Center copy/share/export was implemented in Phase 14.
- Reminder cadence controls and device notifications were implemented in Phase 15.
- Audit trail for invoice and quote edits was implemented in Phase 16.
- Inventory linkage through product stock deduction was implemented in Phase 17.
- Currency-aware business, invoice, and quote amounts were implemented in Phase 18.
- HSN tax-rate versioning with effective-from dates was implemented in Phase 19.
- Full database backup/restore via JSON export/import was implemented in Phase 20.
- Payment refunds were implemented in Phase 22.
- Overpayment handling was implemented in Phase 23.
- Payment reversal and voiding were implemented in Phase 24.
- Document templates were implemented in Phase 25.
- Google Drive cloud backup and Drive PDF links were implemented in Phase 26.
