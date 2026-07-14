import '../../database/app_database.dart';

class CustomerStatementRow {
  final String customerName;
  final String entryType;
  final String documentNumber;
  final DateTime entryDate;
  final double amount;
  final double runningBalance;
  final String note;

  const CustomerStatementRow({
    required this.customerName,
    required this.entryType,
    required this.documentNumber,
    required this.entryDate,
    required this.amount,
    required this.runningBalance,
    required this.note,
  });

  List<String> toCsvRow() => [
        customerName,
        entryDate.toIso8601String().split('T')[0],
        entryType,
        documentNumber,
        amount.toStringAsFixed(2),
        runningBalance.toStringAsFixed(2),
        note,
      ];
}

List<CustomerStatementRow> buildCustomerStatementRows({
  required List<Customer> customers,
  required List<Invoice> invoices,
  required List<InvoicePayment> payments,
}) {
  final customerNameById = {
    for (final customer in customers) customer.id: customer.name,
  };

  final rows = <CustomerStatementRow>[];
  final invoiceById = {for (final invoice in invoices) invoice.id: invoice};
  final customerInvoices = <int, List<Invoice>>{};
  for (final invoice in invoices) {
    customerInvoices.putIfAbsent(invoice.customerId, () => []).add(invoice);
  }

  final customerPayments = <int, List<_CustomerPaymentEntry>>{};
  for (final payment in payments) {
    final invoice = invoiceById[payment.invoiceId];
    if (invoice == null) continue;
    customerPayments
        .putIfAbsent(invoice.customerId, () => [])
        .add(_CustomerPaymentEntry(invoice: invoice, payment: payment));
  }

  final customerIds = <int>{
    ...customerInvoices.keys,
    ...customerPayments.keys,
  }.toList()
    ..sort();

  for (final customerId in customerIds) {
    final customerName = customerNameById[customerId] ?? 'Unknown';
    final entries = <_StatementEntry>[];

    for (final invoice in customerInvoices[customerId] ?? const <Invoice>[]) {
      entries.add(
        _StatementEntry(
          customerName: customerName,
          entryType: 'INVOICE',
          documentNumber: invoice.invoiceNumber,
          entryDate: invoice.invoiceDate,
          amount: invoice.totalAmount,
          note: 'Invoice issued',
          sortKey: invoice.invoiceDate,
          secondarySort: 0,
        ),
      );
    }

    for (final entry in customerPayments[customerId] ?? const <_CustomerPaymentEntry>[]) {
      final payment = entry.payment;
      final double signedAmount = switch (payment.kind) {
        'REFUND' => payment.amount,
        'VOID' => 0.0,
        _ => -payment.amount,
      };
      entries.add(
        _StatementEntry(
          customerName: customerName,
          entryType: payment.kind,
          documentNumber: entry.invoice.invoiceNumber,
          entryDate: payment.paidAt,
          amount: signedAmount,
          note: payment.note ?? _defaultPaymentNote(payment.kind),
          sortKey: payment.paidAt,
          secondarySort: payment.kind == 'VOID' ? 2 : 1,
        ),
      );
    }

    entries.sort((a, b) {
      final dateCompare = a.sortKey.compareTo(b.sortKey);
      if (dateCompare != 0) return dateCompare;
      final secondaryCompare = a.secondarySort.compareTo(b.secondarySort);
      if (secondaryCompare != 0) return secondaryCompare;
      return a.documentNumber.compareTo(b.documentNumber);
    });

    var runningBalance = 0.0;
    for (final entry in entries) {
      runningBalance += entry.amount;
      rows.add(
        CustomerStatementRow(
          customerName: entry.customerName,
          entryType: entry.entryType,
          documentNumber: entry.documentNumber,
          entryDate: entry.entryDate,
          amount: entry.amount,
          runningBalance: runningBalance,
          note: entry.note,
        ),
      );
    }
  }

  return rows;
}

String _defaultPaymentNote(String kind) {
  switch (kind) {
    case 'REFUND':
      return 'Refund recorded';
    case 'VOID':
      return 'Voided payment';
    default:
      return 'Payment recorded';
  }
}

class _CustomerPaymentEntry {
  final Invoice invoice;
  final InvoicePayment payment;

  const _CustomerPaymentEntry({
    required this.invoice,
    required this.payment,
  });
}

class _StatementEntry {
  final String customerName;
  final String entryType;
  final String documentNumber;
  final DateTime entryDate;
  final double amount;
  final String note;
  final DateTime sortKey;
  final int secondarySort;

  const _StatementEntry({
    required this.customerName,
    required this.entryType,
    required this.documentNumber,
    required this.entryDate,
    required this.amount,
    required this.note,
    required this.sortKey,
    required this.secondarySort,
  });
}
