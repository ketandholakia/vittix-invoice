part of 'reports_screen.dart';

// Private row/data widgets and dialogs used by the reports screen.

class _ReportTile extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const _ReportTile({required this.title, required this.value, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      trailing: Text(
        value,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _OperationalReportData {
  final List<_CustomerReportRow> customerRows;
  final List<CustomerStatementRow> customerStatementRows;
  final List<_ReceivablesAgingRow> receivablesAgingRows;
  final List<_HsnReportRow> hsnRows;
  final List<_QuoteConversionRow> quoteConversionRows;
  final List<_QuoteQueueRow> quoteQueueRows;

  const _OperationalReportData({
    this.customerRows = const [],
    this.customerStatementRows = const [],
    this.receivablesAgingRows = const [],
    this.hsnRows = const [],
    this.quoteConversionRows = const [],
    this.quoteQueueRows = const [],
  });
}

class _CustomerAccumulator {
  final String customerName;
  int invoiceCount = 0;
  double sales = 0;
  double collected = 0;
  double pending = 0;

  _CustomerAccumulator({required this.customerName});
}

class _CustomerReportRow {
  final String customerName;
  final int invoiceCount;
  final double sales;
  final double collected;
  final double pending;

  const _CustomerReportRow({
    required this.customerName,
    required this.invoiceCount,
    required this.sales,
    required this.collected,
    required this.pending,
  });
}

class _ReceivablesAgingAccumulator {
  final String customerName;
  int invoiceCount = 0;
  double current = 0;
  double days1To30 = 0;
  double days31To60 = 0;
  double days61To90 = 0;
  double daysOver90 = 0;

  _ReceivablesAgingAccumulator({required this.customerName});

  void addBalance({required double balanceDue, required int daysOverdue}) {
    if (daysOverdue <= 0) {
      current += balanceDue;
    } else if (daysOverdue <= 30) {
      days1To30 += balanceDue;
    } else if (daysOverdue <= 60) {
      days31To60 += balanceDue;
    } else if (daysOverdue <= 90) {
      days61To90 += balanceDue;
    } else {
      daysOver90 += balanceDue;
    }
  }
}

class _ReceivablesAgingRow {
  final String customerName;
  final int invoiceCount;
  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double daysOver90;

  double get totalDue =>
      current + days1To30 + days31To60 + days61To90 + daysOver90;

  const _ReceivablesAgingRow({
    required this.customerName,
    required this.invoiceCount,
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
  });
}

class _ReceivablesAgingSummary {
  final double current;
  final double days1To30;
  final double days31To60;
  final double days61To90;
  final double daysOver90;

  const _ReceivablesAgingSummary({
    required this.current,
    required this.days1To30,
    required this.days31To60,
    required this.days61To90,
    required this.daysOver90,
  });

  factory _ReceivablesAgingSummary.fromRows(List<_ReceivablesAgingRow> rows) {
    return _ReceivablesAgingSummary(
      current: rows.fold<double>(0, (sum, row) => sum + row.current),
      days1To30: rows.fold<double>(0, (sum, row) => sum + row.days1To30),
      days31To60: rows.fold<double>(0, (sum, row) => sum + row.days31To60),
      days61To90: rows.fold<double>(0, (sum, row) => sum + row.days61To90),
      daysOver90: rows.fold<double>(0, (sum, row) => sum + row.daysOver90),
    );
  }
}

class _HsnAccumulator {
  final String hsnSac;
  int itemCount = 0;
  double taxable = 0;
  double cgst = 0;
  double sgst = 0;
  double igst = 0;
  double cess = 0;

  _HsnAccumulator({required this.hsnSac});
}

class _HsnReportRow {
  final String hsnSac;
  final int itemCount;
  final double taxable;
  final double cgst;
  final double sgst;
  final double igst;
  final double cess;

  const _HsnReportRow({
    required this.hsnSac,
    required this.itemCount,
    required this.taxable,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.cess,
  });
}

class _QuoteConversionAccumulator {
  final String customerName;
  int quoteCount = 0;
  int convertedCount = 0;
  int rejectedCount = 0;

  _QuoteConversionAccumulator({required this.customerName});
}

class _QuoteConversionRow {
  final String customerName;
  final int quoteCount;
  final int convertedCount;
  final int rejectedCount;
  final double conversionRate;

  const _QuoteConversionRow({
    required this.customerName,
    required this.quoteCount,
    required this.convertedCount,
    required this.rejectedCount,
    required this.conversionRate,
  });
}

class _QuoteQueueRow {
  final String customerName;
  final String quoteNumber;
  final String status;
  final String quoteDate;
  final String lastContact;
  final int ageDays;

  const _QuoteQueueRow({
    required this.customerName,
    required this.quoteNumber,
    required this.status,
    required this.quoteDate,
    required this.lastContact,
    required this.ageDays,
  });
}

/// Lists pre-export GST field problems and lets the user fix them (tap a row
/// to open the invoice), export anyway, or cancel.
class _Gstr1ValidationDialog extends StatelessWidget {
  const _Gstr1ValidationDialog({required this.issues});

  final List<Gstr1Issue> issues;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Check GST details before export'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${issues.length} problem${issues.length == 1 ? '' : 's'} found '
              'in the selected period. These documents may be summarised '
              'wrong in the GSTR-1 export.',
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: issues.length,
                itemBuilder: (context, index) {
                  final issue = issues[index];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      '${issue.invoiceNumber} — ${issue.field}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    subtitle: Text(issue.message),
                    trailing: const Icon(Icons.open_in_new, size: 16),
                    onTap: () {
                      Navigator.of(context).pop(false);
                      context.push('/invoice-preview/${issue.invoiceId}');
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Export anyway'),
        ),
      ],
    );
  }
}
