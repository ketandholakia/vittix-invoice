import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/invoice_balance.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../database/app_database.dart';
import '../../../database/tables/template_configs.dart';
import '../../../models/invoice_template_config.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../services/pdf_service.dart';
import '../../../services/share_service.dart';

class InvoiceListScreen extends ConsumerStatefulWidget {
  const InvoiceListScreen({super.key});

  @override
  ConsumerState<InvoiceListScreen> createState() => _InvoiceListScreenState();
}

class _InvoiceListScreenState extends ConsumerState<InvoiceListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'ALL';
  bool _showOverdueOnly = false;
  final Set<int> _selectedInvoiceIds = {};

  bool get _isSelecting => _selectedInvoiceIds.isNotEmpty;

  void _toggleInvoiceSelection(int invoiceId) {
    setState(() {
      if (!_selectedInvoiceIds.add(invoiceId)) {
        _selectedInvoiceIds.remove(invoiceId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedInvoiceIds.clear);
  }

  Future<void> _exportSelectedInvoices(List<Invoice> invoices) async {
    final selected = invoices
        .where((invoice) => _selectedInvoiceIds.contains(invoice.id))
        .toList();
    if (selected.isEmpty) return;

    final rows = <List<String>>[
      [
        'Invoice Number',
        'Date',
        'Due Date',
        'Status',
        'Total Amount',
        'Currency',
        'Amount Paid',
        'Balance Due',
      ],
      for (final invoice in selected)
        [
          invoice.invoiceNumber,
          invoice.invoiceDate.toIso8601String().split('T')[0],
          invoice.dueDate?.toIso8601String().split('T')[0] ?? '',
          invoice.status,
          formatMoney(invoice.totalAmount, currencyCode: invoice.currencyCode),
          invoice.currencyCode,
          formatMoney(invoice.amountPaid, currencyCode: invoice.currencyCode),
          formatMoney(
            invoiceBalanceDue(invoice),
            currencyCode: invoice.currencyCode,
          ),
        ],
    ];

    await ShareService.shareCsv(
      rows,
      'selected_invoices.csv',
      subject: 'Selected Invoices',
      text: 'Selected invoice export',
    );
  }

  Future<void> _deleteSelectedInvoices(
    BuildContext context,
    List<Invoice> invoices,
  ) async {
    final selected = invoices
        .where((invoice) => _selectedInvoiceIds.contains(invoice.id))
        .toList();
    final deletable = selected
        .where((invoice) => invoice.amountPaid <= 0 && invoice.status != 'PAID')
        .toList();
    if (deletable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No selected invoices can be deleted.')),
      );
      return;
    }

    final skipped = selected.length - deletable.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected invoices?'),
        content: Text(
          'This will delete ${deletable.length} invoice(s).'
          '${skipped > 0 ? ' $skipped paid invoice(s) will be skipped.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    var deleted = 0;
    var failed = 0;
    for (final invoice in deletable) {
      try {
        await ref.read(invoiceProvider).deleteInvoice(invoice.id);
        deleted += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (!context.mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted $deleted invoice(s).'
          '${failed > 0 ? ' $failed failed.' : ''}',
        ),
      ),
    );
  }

  Future<void> _shareInvoice(BuildContext context, Invoice invoice) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(invoice.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(invoice.customerId);
      final items = await ref
          .read(invoiceDaoProvider)
          .getItemsForInvoice(invoice.id);
      final isGstEnabled = ref.read(isGstEnabledProvider);
      final showBankDetails = ref.read(printBankDetailsOnInvoiceProvider);

      if (business == null || customer == null) {
        throw Exception('Invoice data is incomplete');
      }

      final template = business.defaultInvoiceTemplateId != null
          ? await ref
              .read(templateConfigDaoProvider)
              .getTemplateById(business.defaultInvoiceTemplateId!)
          : await ref
              .read(templateConfigDaoProvider)
              .getDefaultTemplate(business.id, TemplateScope.invoice);

      final pdf = await PdfService.generateInvoice(
        business: business,
        customer: customer,
        invoice: invoice,
        items: items,
        isGstEnabled: isGstEnabled,
        showBankDetails: showBankDetails,
        templateConfig: template == null
            ? null
            : InvoiceTemplateConfig.decode(template.configJson),
      );

      await ShareService.sharePdf(
        pdf,
        '${invoice.invoiceNumber}.pdf',
        subject: 'Invoice: ${invoice.invoiceNumber}',
        text: 'Please find invoice ${invoice.invoiceNumber} attached.',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share invoice: $e')));
    }
  }

  String _buildInvoiceReminder({
    required Business business,
    required Customer customer,
    required Invoice invoice,
  }) {
    final balance = invoiceBalanceDue(invoice);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dueDate = invoice.dueDate?.toLocal().toString().split(' ')[0];
    final isOverdue =
        invoice.dueDate != null &&
        DateTime(
          invoice.dueDate!.year,
          invoice.dueDate!.month,
          invoice.dueDate!.day,
        ).isBefore(today);
    final opening = isOverdue
        ? 'Hello ${customer.name}, this is an overdue payment reminder from ${business.name}'
        : 'Hello ${customer.name}, this is a payment reminder from ${business.name}';
    final contact = customer.phone?.isNotEmpty == true
        ? 'You can reply on ${customer.phone}.'
        : (customer.email?.isNotEmpty == true
              ? 'You can reply to ${customer.email}.'
              : '');
    return '$opening for invoice ${invoice.invoiceNumber} with pending balance '
        '${formatMoney(balance, currencyCode: invoice.currencyCode)}.'
        '${dueDate != null ? ' The due date is $dueDate.' : ''}'
        '${isOverdue ? ' This invoice is now overdue.' : ''}'
        '${contact.isNotEmpty ? ' $contact' : ''}'
        ' Please let us know once payment is completed.';
  }

  Future<void> _copyReminder(BuildContext context, Invoice invoice) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(invoice.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(invoice.customerId);
      if (business == null || customer == null) {
        throw Exception('Invoice data is incomplete');
      }
      await Clipboard.setData(
        ClipboardData(
          text: _buildInvoiceReminder(
            business: business,
            customer: customer,
            invoice: invoice,
          ),
        ),
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reminder copied.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to copy reminder: $e')));
    }
  }

  Future<void> _shareReminder(BuildContext context, Invoice invoice) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(invoice.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(invoice.customerId);
      if (business == null || customer == null) {
        throw Exception('Invoice data is incomplete');
      }
      await ShareService.shareText(
        _buildInvoiceReminder(
          business: business,
          customer: customer,
          invoice: invoice,
        ),
        subject: 'Payment Reminder: ${invoice.invoiceNumber}',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share reminder: $e')));
    }
  }

  Future<void> _deleteInvoice(BuildContext context, Invoice invoice) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete invoice?'),
        content: Text(
          'Delete ${invoice.invoiceNumber}? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await ref.read(invoiceProvider).deleteInvoice(invoice.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invoice deleted.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete invoice: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoicesAsync = ref.watch(invoiceListProvider);

    return Scaffold(
      appBar: AppBar(
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear selection',
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _isSelecting ? '${_selectedInvoiceIds.length} selected' : 'Invoices',
        ),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  onPressed: () {
                    final invoices = invoicesAsync.valueOrNull ?? const [];
                    _exportSelectedInvoices(invoices);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete selected',
                  onPressed: () {
                    final invoices = invoicesAsync.valueOrNull ?? const [];
                    _deleteSelectedInvoices(context, invoices);
                  },
                ),
              ]
            : null,
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          final filteredInvoices = invoices.where((invoice) {
            final matchesQuery =
                _query.isEmpty ||
                invoice.invoiceNumber.toLowerCase().contains(_query) ||
                invoice.status.toLowerCase().contains(_query);
            final matchesStatus =
                _statusFilter == 'ALL' || invoice.status == _statusFilter;
            final isOverdue =
                invoice.dueDate != null &&
                invoiceBalanceDue(invoice) > 0 &&
                invoice.dueDate!.isBefore(DateTime.now());
            final matchesOverdue = !_showOverdueOnly || isOverdue;
            return matchesQuery && matchesStatus && matchesOverdue;
          }).toList();

          if (invoices.isEmpty) {
            return EmptyState(
              icon: Icons.receipt_long_outlined,
              title: 'No invoices yet',
              message:
                  'Create your first invoice to start tracking sales and payments.',
              actionLabel: 'New Invoice',
              onAction: () => context.push('/create-invoice'),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search invoices',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All')),
                          DropdownMenuItem(
                            value: 'DRAFT',
                            child: Text('Draft'),
                          ),
                          DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                          DropdownMenuItem(
                            value: 'PARTIALLY_PAID',
                            child: Text('Partially Paid'),
                          ),
                          DropdownMenuItem(value: 'PAID', child: Text('Paid')),
                          DropdownMenuItem(
                            value: 'CANCELLED',
                            child: Text('Cancelled'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _statusFilter = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Overdue'),
                      selected: _showOverdueOnly,
                      onSelected: (selected) {
                        setState(() => _showOverdueOnly = selected);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredInvoices.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No matching invoices',
                        message:
                            'Adjust the search text, status filter, or overdue filter.',
                      )
                    : ListView.builder(
                        itemCount: filteredInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = filteredInvoices[index];
                          final isOverdue =
                              invoice.dueDate != null &&
                              invoiceBalanceDue(invoice) > 0 &&
                              invoice.dueDate!.isBefore(DateTime.now());

                          return ListTile(
                            selected: _selectedInvoiceIds.contains(invoice.id),
                            leading: _isSelecting
                                ? Checkbox(
                                    value: _selectedInvoiceIds.contains(
                                      invoice.id,
                                    ),
                                    onChanged: (_) =>
                                        _toggleInvoiceSelection(invoice.id),
                                  )
                                : const Icon(Icons.receipt),
                            title: Text(invoice.invoiceNumber),
                            subtitle: Text(
                              'Date: ${invoice.invoiceDate.toLocal().toString().split(' ')[0]}'
                              '${invoice.dueDate != null ? ' | Due: ${invoice.dueDate!.toLocal().toString().split(' ')[0]}' : ''}',
                            ),
                            onTap: () {
                              if (_isSelecting) {
                                _toggleInvoiceSelection(invoice.id);
                                return;
                              }
                              context.push('/invoice-preview/${invoice.id}');
                            },
                            onLongPress: () =>
                                _toggleInvoiceSelection(invoice.id),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(
                                        invoice.totalAmount,
                                        currencyCode: invoice.currencyCode,
                                      ),
                                    ),
                                    Text(
                                      invoice.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: invoice.status == 'PAID'
                                            ? Colors.green
                                            : (isOverdue
                                                  ? Colors.red
                                                  : Colors.orange),
                                      ),
                                    ),
                                  ],
                                ),
                                PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    switch (value) {
                                      case 'open':
                                        if (!context.mounted) return;
                                        context.push(
                                          '/invoice-preview/${invoice.id}',
                                        );
                                        return;
                                      case 'share':
                                        await _shareInvoice(context, invoice);
                                        return;
                                      case 'copy_reminder':
                                        await _copyReminder(context, invoice);
                                        return;
                                      case 'share_reminder':
                                        await _shareReminder(context, invoice);
                                        return;
                                      case 'duplicate':
                                        final duplicatedId = await ref
                                            .read(invoiceProvider)
                                            .duplicateInvoice(invoice.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Invoice duplicated as draft.',
                                            ),
                                          ),
                                        );
                                        context.push(
                                          '/invoice-preview/$duplicatedId',
                                        );
                                        return;
                                      case 'delete':
                                        await _deleteInvoice(context, invoice);
                                        return;
                                    }
                                  },
                                  itemBuilder: (context) => const [
                                    PopupMenuItem(
                                      value: 'open',
                                      child: Text('Open'),
                                    ),
                                    PopupMenuItem(
                                      value: 'share',
                                      child: Text('Share PDF'),
                                    ),
                                    PopupMenuItem(
                                      value: 'copy_reminder',
                                      child: Text('Copy Reminder'),
                                    ),
                                    PopupMenuItem(
                                      value: 'share_reminder',
                                      child: Text('Share Reminder'),
                                    ),
                                    PopupMenuItem(
                                      value: 'duplicate',
                                      child: Text('Duplicate'),
                                    ),
                                    PopupMenuItem(
                                      value: 'delete',
                                      child: Text('Delete'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/create-invoice'),
        icon: const Icon(Icons.add),
        label: const Text('New Invoice'),
      ),
    );
  }
}
