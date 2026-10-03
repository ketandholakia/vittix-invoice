/// Document type codes stored in `invoices.invoiceType`.
///
/// The stored set is `TAX_INVOICE`, `BILL_OF_SUPPLY`, `CREDIT_NOTE`,
/// `DEBIT_NOTE` (quotes use `QUOTE`). A GST-disabled invoice used to be stored
/// as `'INVOICE'`, which was not one of these.
const String taxInvoiceType = 'TAX_INVOICE';
const String billOfSupplyType = 'BILL_OF_SUPPLY';

/// A tax invoice when GST is charged, otherwise a bill of supply (unregistered
/// or composition-scheme suppliers, and exempt supplies).
String invoiceTypeForGst({required bool isGstEnabled}) =>
    isGstEnabled ? taxInvoiceType : billOfSupplyType;
