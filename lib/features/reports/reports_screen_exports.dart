// The export helpers call setState to toggle per-export progress flags; as
// same-library extensions on the state class they are instance members in
// every meaningful sense, but the analyzer cannot see that, so the protected
// member lint is disabled for this file only.
//
// ignore_for_file: invalid_use_of_protected_member
part of 'reports_screen.dart';

// Export and range-filter helpers for the reports screen.

extension _ReportsExports on _ReportsScreenState {
  Future<void> _pickCustomRange() async {
    final now = DateTime.now();
    final initialRange =
        _selectedRange ??
        DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: initialRange,
    );
    if (picked == null) return;

    setState(() {
      _customStartDate = picked.start;
      _customEndDate = picked.end;
      _range = ReportRange.custom;
    });
  }

  List<Invoice> _filterInvoices(List<Invoice> invoices) {
    // Drafts are not issued and cancelled invoices are void, so neither may
    // contribute to any report total.
    final counted = invoices.where(
      (invoice) => isInvoiceCountedInTotals(invoice.status),
    );
    final selectedRange = _selectedRange;
    if (selectedRange == null) {
      return counted.toList();
    }

    return counted
        .where(
          (invoice) =>
              !invoice.invoiceDate.isBefore(selectedRange.start) &&
              !invoice.invoiceDate.isAfter(selectedRange.end),
        )
        .toList();
  }

  List<Quote> _filterQuotes(List<Quote> quotes) {
    final selectedRange = _selectedRange;
    if (selectedRange == null) {
      return quotes;
    }

    return quotes
        .where(
          (quote) =>
              !quote.invoiceDate.isBefore(selectedRange.start) &&
              !quote.invoiceDate.isAfter(selectedRange.end),
        )
        .toList();
  }

  Future<void> _exportInvoices(List<Invoice> invoices) async {
    setState(() => _isExportingInvoices = true);
    try {
      final rows = <List<String>>[
        [
          'Invoice Number',
          'Date',
          'Due Date',
          'Status',
          'Subtotal',
          'Taxable Amount',
          'CGST',
          'SGST',
          'IGST',
          'Cess',
          'Total Amount',
          'Amount Paid',
          'Balance Due',
        ],
        for (final invoice in invoices)
          [
            invoice.invoiceNumber,
            invoice.invoiceDate.toIso8601String().split('T')[0],
            invoice.dueDate?.toIso8601String().split('T')[0] ?? '',
            invoice.status,
            invoice.subtotal.toStringAsFixed(2),
            invoice.taxableAmount.toStringAsFixed(2),
            invoice.cgstAmount.toStringAsFixed(2),
            invoice.sgstAmount.toStringAsFixed(2),
            invoice.igstAmount.toStringAsFixed(2),
            invoice.cessAmount.toStringAsFixed(2),
            invoice.totalAmount.toStringAsFixed(2),
            invoice.amountPaid.toStringAsFixed(2),
            invoiceBalanceDue(invoice).toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'invoice_report.csv',
        subject: 'Invoice Report',
        text: 'Invoice report export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingInvoices = false);
      }
    }
  }

  Future<void> _exportGstr1() async {
    setState(() => _isExportingGstr1 = true);
    try {
      final businessId = ref.read(activeBusinessIdProvider);
      if (businessId == null) return;
      final invoiceDao = ref.read(invoiceDaoProvider);

      // Read the full book from the DAO, never the watched list providers —
      // those cap at invoiceListPageSize (500) for UI performance and a
      // capped compliance export would silently drop documents.
      final range = _selectedRange;
      final invoices = range == null
          ? await invoiceDao.getInvoicesForBusiness(businessId)
          : await invoiceDao.getInvoicesForBusinessBetween(
              businessId,
              range.start,
              range.end,
            );
      final customers = await ref
          .read(customerDaoProvider)
          .getCustomersForBusiness(businessId);
      final items = await invoiceDao.getItemsForInvoices(
        invoices.map((invoice) => invoice.id).toList(),
      );

      final issues = validateInvoicesForGstr1(
        customers: customers,
        invoices: invoices,
        items: items,
      );
      if (issues.isNotEmpty && mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => _Gstr1ValidationDialog(issues: issues),
        );
        if (proceed != true) return;
      }

      final rows = buildGstr1Rows(
        customers: customers,
        invoices: invoices,
        items: items,
      );

      await ShareService.shareCsv(
        rows,
        'gstr1_summary.csv',
        subject: 'GSTR-1 Summary',
        text: 'GSTR-1 style summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingGstr1 = false);
      }
    }
  }

  Future<void> _exportQuotes(List<Quote> quotes) async {
    setState(() => _isExportingQuotes = true);
    try {
      final rows = <List<String>>[
        [
          'Quote Number',
          'Date',
          'Valid Until',
          'Status',
          'Subtotal',
          'Taxable Amount',
          'CGST',
          'SGST',
          'IGST',
          'Cess',
          'Total Amount',
        ],
        for (final quote in quotes)
          [
            quote.invoiceNumber,
            quote.invoiceDate.toIso8601String().split('T')[0],
            quote.dueDate?.toIso8601String().split('T')[0] ?? '',
            quote.status,
            quote.subtotal.toStringAsFixed(2),
            quote.taxableAmount.toStringAsFixed(2),
            quote.cgstAmount.toStringAsFixed(2),
            quote.sgstAmount.toStringAsFixed(2),
            quote.igstAmount.toStringAsFixed(2),
            quote.cessAmount.toStringAsFixed(2),
            quote.totalAmount.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'quote_report.csv',
        subject: 'Quote Report',
        text: 'Quote report export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuotes = false);
      }
    }
  }

  Future<void> _exportCustomerSummary(
    List<_CustomerReportRow> customerRows,
  ) async {
    setState(() => _isExportingCustomerSummary = true);
    try {
      final rows = <List<String>>[
        ['Customer', 'Invoices', 'Sales', 'Collected', 'Pending'],
        for (final row in customerRows)
          [
            row.customerName,
            row.invoiceCount.toString(),
            row.sales.toStringAsFixed(2),
            row.collected.toStringAsFixed(2),
            row.pending.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'customer_sales_summary.csv',
        subject: 'Customer Sales Summary',
        text: 'Customer sales summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCustomerSummary = false);
      }
    }
  }

  Future<void> _exportCustomerStatement(
    List<CustomerStatementRow> rows,
  ) async {
    setState(() => _isExportingCustomerStatement = true);
    try {
      final csvRows = <List<String>>[
        [
          'Customer',
          'Date',
          'Entry Type',
          'Document',
          'Amount',
          'Running Balance',
          'Note',
        ],
        for (final row in rows) row.toCsvRow(),
      ];

      await ShareService.shareCsv(
        csvRows,
        'customer_statement.csv',
        subject: 'Customer Statement',
        text: 'Customer statement export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingCustomerStatement = false);
      }
    }
  }

  Future<void> _exportReceivablesAging(
    List<_ReceivablesAgingRow> agingRows,
  ) async {
    setState(() => _isExportingReceivablesAging = true);
    try {
      final rows = <List<String>>[
        [
          'Customer',
          'Open Invoices',
          'Current',
          '1-30 Days',
          '31-60 Days',
          '61-90 Days',
          '90+ Days',
          'Total Due',
        ],
        for (final row in agingRows)
          [
            row.customerName,
            row.invoiceCount.toString(),
            row.current.toStringAsFixed(2),
            row.days1To30.toStringAsFixed(2),
            row.days31To60.toStringAsFixed(2),
            row.days61To90.toStringAsFixed(2),
            row.daysOver90.toStringAsFixed(2),
            row.totalDue.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'receivables_aging.csv',
        subject: 'Receivables Aging',
        text: 'Receivables aging export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingReceivablesAging = false);
      }
    }
  }

  Future<void> _exportHsnSummary(List<_HsnReportRow> hsnRows) async {
    setState(() => _isExportingHsnSummary = true);
    try {
      final rows = <List<String>>[
        ['HSN/SAC', 'Item Count', 'Taxable', 'CGST', 'SGST', 'IGST', 'Cess'],
        for (final row in hsnRows)
          [
            row.hsnSac,
            row.itemCount.toString(),
            row.taxable.toStringAsFixed(2),
            row.cgst.toStringAsFixed(2),
            row.sgst.toStringAsFixed(2),
            row.igst.toStringAsFixed(2),
            row.cess.toStringAsFixed(2),
          ],
      ];

      await ShareService.shareCsv(
        rows,
        'hsn_tax_summary.csv',
        subject: 'HSN Tax Summary',
        text: 'HSN and tax summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingHsnSummary = false);
      }
    }
  }

  Future<void> _exportQuoteConversionSummary(
    List<_QuoteConversionRow> rows,
  ) async {
    setState(() => _isExportingQuoteConversion = true);
    try {
      final csvRows = <List<String>>[
        ['Customer', 'Quotes', 'Converted', 'Conversion Rate', 'Rejected'],
        for (final row in rows)
          [
            row.customerName,
            row.quoteCount.toString(),
            row.convertedCount.toString(),
            '${row.conversionRate.toStringAsFixed(2)}%',
            row.rejectedCount.toString(),
          ],
      ];

      await ShareService.shareCsv(
        csvRows,
        'quote_conversion_summary.csv',
        subject: 'Quote Conversion Summary',
        text: 'Quote conversion summary export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuoteConversion = false);
      }
    }
  }

  Future<void> _exportQuoteQueue(List<_QuoteQueueRow> rows) async {
    setState(() => _isExportingQuoteQueue = true);
    try {
      final csvRows = <List<String>>[
        [
          'Customer',
          'Quote',
          'Status',
          'Quote Date',
          'Last Contact',
          'Age Days',
        ],
        for (final row in rows)
          [
            row.customerName,
            row.quoteNumber,
            row.status,
            row.quoteDate,
            row.lastContact,
            row.ageDays.toString(),
          ],
      ];

      await ShareService.shareCsv(
        csvRows,
        'quote_queue.csv',
        subject: 'Quote Follow-up Queue',
        text: 'Quote follow-up queue export',
      );
    } finally {
      if (mounted) {
        setState(() => _isExportingQuoteQueue = false);
      }
    }
  }
}
