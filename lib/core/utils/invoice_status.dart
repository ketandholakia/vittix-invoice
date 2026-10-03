/// Invoice statuses that are not yet issued or are voided, and therefore must
/// not contribute to revenue, tax or receivables totals.
///
/// A DRAFT invoice has not been issued to the customer, and a CANCELLED
/// invoice no longer bears tax or a receivable.
const Set<String> excludedFromInvoiceTotals = {'DRAFT', 'CANCELLED'};

/// Whether an invoice in [status] should be counted in financial totals
/// (revenue, taxable and tax sums, and receivables).
///
/// Centralised so the dashboard and the reports screen agree on which
/// documents count. Drafts and cancelled invoices are excluded.
bool isInvoiceCountedInTotals(String status) =>
    !excludedFromInvoiceTotals.contains(status);

/// True for credit and debit notes, which adjust an existing invoice rather
/// than being an independent sale.
bool isAdjustmentNote(String invoiceType) =>
    invoiceType == 'CREDIT_NOTE' || invoiceType == 'DEBIT_NOTE';

/// Signed contribution of a document to revenue and tax totals: a credit note
/// reduces what was billed, everything else adds.
double signedInvoiceTotal(double totalAmount, String invoiceType) =>
    invoiceType == 'CREDIT_NOTE' ? -totalAmount : totalAmount;
