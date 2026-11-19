/// The due date for a copy of a document (duplicate or recurring draft).
///
/// Keeps the source's payment term as a whole-day count — a source issued
/// Jan 10 due Jan 25 (15 days) duplicated on Mar 5 becomes due Mar 20 —
/// instead of copying the source's literal due date. Returns null when the
/// source has no due date.
DateTime? dueDateForCopy({
  required DateTime sourceInvoiceDate,
  required DateTime? sourceDueDate,
  required DateTime newInvoiceDate,
}) {
  if (sourceDueDate == null) return null;
  final termDays = sourceDueDate.difference(sourceInvoiceDate).inDays;
  return newInvoiceDate.add(Duration(days: termDays));
}
