part of 'reports_screen.dart';

// Report data loading for the operational report section.

extension _ReportsData on _ReportsScreenState {
  Future<_OperationalReportData> _loadOperationalReportData({
    required int? businessId,
    required List<Invoice> invoices,
  }) async {
    if (businessId == null || invoices.isEmpty) {
      return const _OperationalReportData();
    }

    final customerDao = ref.read(customerDaoProvider);
    final invoiceDao = ref.read(invoiceDaoProvider);
    final customers = await customerDao.getCustomersForBusiness(businessId);
    final items = await invoiceDao.getItemsForInvoices(
      invoices.map((invoice) => invoice.id).toList(),
    );
    final payments = await invoiceDao.getPaymentsForInvoices(
      invoices.map((invoice) => invoice.id).toList(),
    );

    final customerNameById = {
      for (final customer in customers) customer.id: customer.name,
    };
    final customerAggregates = <int, _CustomerAccumulator>{};
    final receivablesAgingAggregates = <int, _ReceivablesAgingAccumulator>{};
    final quoteAggregates = <int, _QuoteConversionAccumulator>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    for (final invoice in invoices) {
      final balanceDue = invoiceBalanceDue(invoice);
      final isNote = isAdjustmentNote(invoice.invoiceType);
      final accumulator = customerAggregates.putIfAbsent(
        invoice.customerId,
        () => _CustomerAccumulator(
          customerName: customerNameById[invoice.customerId] ?? 'Unknown',
        ),
      );
      // Notes adjust an existing invoice rather than being one themselves, and
      // a credit note reduces the customer's sales.
      if (!isNote) accumulator.invoiceCount += 1;
      accumulator.sales +=
          signedInvoiceTotal(invoice.totalAmount, invoice.invoiceType);
      accumulator.collected += invoice.amountPaid;
      if (!isNote) accumulator.pending += balanceDue;

      if (!isNote && balanceDue > 0) {
        final agingAccumulator = receivablesAgingAggregates.putIfAbsent(
          invoice.customerId,
          () => _ReceivablesAgingAccumulator(
            customerName: customerNameById[invoice.customerId] ?? 'Unknown',
          ),
        );
        agingAccumulator.invoiceCount += 1;

        final dueDate = invoice.dueDate;
        final daysOverdue = dueDate == null
            ? 0
            : today
                  .difference(
                    DateTime(dueDate.year, dueDate.month, dueDate.day),
                  )
                  .inDays;
        agingAccumulator.addBalance(
          balanceDue: balanceDue,
          daysOverdue: daysOverdue,
        );
      }
    }

    final quotes = await ref
        .read(quoteDaoProvider)
        .getQuotesForBusiness(businessId);
    final selectedRange = _selectedRange;
    for (final quote in quotes) {
      if (selectedRange != null &&
          (quote.invoiceDate.isBefore(selectedRange.start) ||
              quote.invoiceDate.isAfter(selectedRange.end))) {
        continue;
      }
      final accumulator = quoteAggregates.putIfAbsent(
        quote.customerId,
        () => _QuoteConversionAccumulator(
          customerName: customerNameById[quote.customerId] ?? 'Unknown',
        ),
      );
      accumulator.quoteCount += 1;
      if (quote.status == 'CONVERTED') {
        accumulator.convertedCount += 1;
      } else if (quote.status == 'REJECTED') {
        accumulator.rejectedCount += 1;
      }
    }

    final hsnAggregates = <String, _HsnAccumulator>{};
    for (final item in items) {
      final hsnKey = item.hsnSac.isEmpty ? 'UNSPECIFIED' : item.hsnSac;
      final accumulator = hsnAggregates.putIfAbsent(
        hsnKey,
        () => _HsnAccumulator(hsnSac: hsnKey),
      );
      accumulator.itemCount += 1;
      accumulator.taxable += item.taxableAmount;
      accumulator.cgst += item.cgstAmount;
      accumulator.sgst += item.sgstAmount;
      accumulator.igst += item.igstAmount;
      accumulator.cess += item.cessAmount;
    }

    final customerRows =
        customerAggregates.values
            .map(
              (value) => _CustomerReportRow(
                customerName: value.customerName,
                invoiceCount: value.invoiceCount,
                sales: value.sales,
                collected: value.collected,
                pending: value.pending,
              ),
            )
            .toList()
          ..sort((a, b) => b.sales.compareTo(a.sales));

    final customerStatementRows = buildCustomerStatementRows(
      customers: customers,
      invoices: invoices,
      payments: payments,
    );

    final hsnRows =
        hsnAggregates.values
            .map(
              (value) => _HsnReportRow(
                hsnSac: value.hsnSac,
                itemCount: value.itemCount,
                taxable: value.taxable,
                cgst: value.cgst,
                sgst: value.sgst,
                igst: value.igst,
                cess: value.cess,
              ),
            )
            .toList()
          ..sort((a, b) => b.taxable.compareTo(a.taxable));

    final receivablesAgingRows =
        receivablesAgingAggregates.values
            .map(
              (value) => _ReceivablesAgingRow(
                customerName: value.customerName,
                invoiceCount: value.invoiceCount,
                current: value.current,
                days1To30: value.days1To30,
                days31To60: value.days31To60,
                days61To90: value.days61To90,
                daysOver90: value.daysOver90,
              ),
            )
            .toList()
          ..sort((a, b) => b.totalDue.compareTo(a.totalDue));

    final quoteConversionRows =
        quoteAggregates.values
            .map(
              (value) => _QuoteConversionRow(
                customerName: value.customerName,
                quoteCount: value.quoteCount,
                convertedCount: value.convertedCount,
                rejectedCount: value.rejectedCount,
                conversionRate: value.quoteCount == 0
                    ? 0
                    : (value.convertedCount / value.quoteCount) * 100,
              ),
            )
            .toList()
          ..sort((a, b) => b.conversionRate.compareTo(a.conversionRate));

    final quoteQueueRows =
        quotes
            .where(
              (quote) =>
                  quote.status != 'CONVERTED' && quote.status != 'REJECTED',
            )
            .where(
              (quote) => DateTime.now().difference(quote.updatedAt).inDays >= 3,
            )
            .map(
              (quote) => _QuoteQueueRow(
                customerName: customerNameById[quote.customerId] ?? 'Unknown',
                quoteNumber: quote.invoiceNumber,
                status: quote.status,
                quoteDate: quote.invoiceDate.toIso8601String().split('T')[0],
                lastContact: quote.updatedAt.toIso8601String().split('T')[0],
                ageDays: DateTime.now().difference(quote.updatedAt).inDays,
              ),
            )
            .toList()
          ..sort((a, b) => b.ageDays.compareTo(a.ageDays));

    return _OperationalReportData(
      customerRows: customerRows,
      customerStatementRows: customerStatementRows,
      receivablesAgingRows: receivablesAgingRows,
      hsnRows: hsnRows,
      quoteConversionRows: quoteConversionRows,
      quoteQueueRows: quoteQueueRows,
    );
  }
}
