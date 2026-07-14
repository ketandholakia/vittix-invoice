import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/invoice_balance.dart';
import '../../core/widgets/empty_state.dart';
import '../../database/app_database.dart';
import '../../providers/reminder_provider.dart';
import '../../services/share_service.dart';

class ReminderCenterScreen extends ConsumerStatefulWidget {
  const ReminderCenterScreen({super.key});

  @override
  ConsumerState<ReminderCenterScreen> createState() =>
      _ReminderCenterScreenState();
}

class _ReminderCenterScreenState extends ConsumerState<ReminderCenterScreen> {
  final Set<String> _selectedReminderKeys = {};

  bool get _isSelecting => _selectedReminderKeys.isNotEmpty;

  void _toggleReminderSelection(String key) {
    setState(() {
      if (!_selectedReminderKeys.add(key)) {
        _selectedReminderKeys.remove(key);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedReminderKeys.clear);
  }

  Future<void> _copySelectedReminders(ReminderCenterData data) async {
    final messages = _selectedReminderMessages(data);
    if (messages.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: messages.join('\n\n')));
    await _markSelectedContacted(data);
    if (!mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied ${messages.length} reminder(s).')),
    );
  }

  Future<void> _shareSelectedReminders(ReminderCenterData data) async {
    final messages = _selectedReminderMessages(data);
    if (messages.isEmpty) return;
    await ShareService.shareText(
      messages.join('\n\n'),
      subject: 'Payment and quote reminders',
    );
    await _markSelectedContacted(data);
    if (!mounted) return;
    _clearSelection();
  }

  Future<void> _exportSelectedReminders(ReminderCenterData data) async {
    final rows = <List<String>>[
      ['Type', 'Customer', 'Document', 'Status', 'Amount', 'Message'],
      ...data.invoiceReminders
          .where((item) => _selectedReminderKeys.contains(_invoiceKey(item)))
          .map(
            (item) => [
              'Invoice',
              item.customer!.name,
              item.invoice.invoiceNumber,
              item.isOverdue
                  ? '${item.daysUntilDue.abs()}d overdue'
                  : (item.daysUntilDue == 0
                        ? 'Due today'
                        : 'Due in ${item.daysUntilDue}d'),
              item.balanceDue.toStringAsFixed(2),
              _buildInvoiceReminder(
                business: item.business,
                customer: item.customer!,
                invoice: item.invoice,
              ),
            ],
          ),
      ...data.quoteReminders
          .where((item) => _selectedReminderKeys.contains(_quoteKey(item)))
          .map(
            (item) => [
              'Quote',
              item.customer!.name,
              item.quote.invoiceNumber,
              item.isExpired
                  ? '${item.daysUntilExpiry.abs()}d expired'
                  : (item.daysUntilExpiry == 0
                        ? 'Expires today'
                        : 'Expires in ${item.daysUntilExpiry}d'),
              item.quote.totalAmount.toStringAsFixed(2),
              _buildQuoteFollowUp(
                business: item.business,
                customer: item.customer!,
                quote: item.quote,
              ),
            ],
          ),
    ];
    if (rows.length == 1) return;
    await ShareService.shareCsv(
      rows,
      'selected_reminders.csv',
      subject: 'Selected Reminders',
      text: 'Selected reminders export',
    );
  }

  List<String> _selectedReminderMessages(ReminderCenterData data) {
    return [
      ...data.invoiceReminders
          .where((item) => _selectedReminderKeys.contains(_invoiceKey(item)))
          .map(
            (item) => _buildInvoiceReminder(
              business: item.business,
              customer: item.customer!,
              invoice: item.invoice,
            ),
          ),
      ...data.quoteReminders
          .where((item) => _selectedReminderKeys.contains(_quoteKey(item)))
          .map(
            (item) => _buildQuoteFollowUp(
              business: item.business,
              customer: item.customer!,
              quote: item.quote,
            ),
          ),
    ];
  }

  Future<void> _markSelectedContacted(ReminderCenterData data) async {
    final actions = ref.read(reminderActionsProvider);
    for (final item in data.invoiceReminders.where(
      (item) => _selectedReminderKeys.contains(_invoiceKey(item)),
    )) {
      await actions.markInvoiceContacted(item.invoice.id);
    }
    for (final item in data.quoteReminders.where(
      (item) => _selectedReminderKeys.contains(_quoteKey(item)),
    )) {
      await actions.markQuoteContacted(item.quote.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remindersAsync = ref.watch(reminderCenterProvider);
    final currentData = remindersAsync.valueOrNull;

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
          _isSelecting
              ? '${_selectedReminderKeys.length} selected'
              : 'Reminders',
        ),
        actions: _isSelecting && currentData != null
            ? [
                IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: 'Copy selected',
                  onPressed: () => _copySelectedReminders(currentData),
                ),
                IconButton(
                  icon: const Icon(Icons.share),
                  tooltip: 'Share selected',
                  onPressed: () => _shareSelectedReminders(currentData),
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  onPressed: () => _exportSelectedReminders(currentData),
                ),
              ]
            : null,
      ),
      body: remindersAsync.when(
        data: (data) {
          if (data.totalCount == 0) {
            return const EmptyState(
              icon: Icons.notifications_none,
              title: 'No reminders due',
              message:
                  'Invoices due within 7 days and quotes expiring within 7 days will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(reminderCenterProvider.future),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _ReminderSummary(data: data),
                const SizedBox(height: 16),
                Text(
                  'Invoice Reminders',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (data.invoiceReminders.isEmpty)
                  const Text('No invoice reminders due.')
                else
                  ...data.invoiceReminders.map(
                    (item) => _InvoiceReminderTile(
                      item: item,
                      isSelecting: _isSelecting,
                      isSelected: _selectedReminderKeys.contains(
                        _invoiceKey(item),
                      ),
                      onToggleSelected: () =>
                          _toggleReminderSelection(_invoiceKey(item)),
                    ),
                  ),
                const SizedBox(height: 16),
                Text(
                  'Quote Follow-ups',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (data.quoteReminders.isEmpty)
                  const Text('No quote follow-ups due.')
                else
                  ...data.quoteReminders.map(
                    (item) => _QuoteReminderTile(
                      item: item,
                      isSelecting: _isSelecting,
                      isSelected: _selectedReminderKeys.contains(
                        _quoteKey(item),
                      ),
                      onToggleSelected: () =>
                          _toggleReminderSelection(_quoteKey(item)),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

String _invoiceKey(InvoiceReminderItem item) => 'invoice:${item.invoice.id}';

String _quoteKey(QuoteReminderItem item) => 'quote:${item.quote.id}';

class _ReminderSummary extends StatelessWidget {
  const _ReminderSummary({required this.data});

  final ReminderCenterData data;

  @override
  Widget build(BuildContext context) {
    final overdueInvoices = data.invoiceReminders
        .where((item) => item.isOverdue)
        .length;
    final expiredQuotes = data.quoteReminders
        .where((item) => item.isExpired)
        .length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _SummaryMetric(
                label: 'Due',
                value: data.totalCount.toString(),
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: 'Overdue',
                value: overdueInvoices.toString(),
              ),
            ),
            Expanded(
              child: _SummaryMetric(
                label: 'Expired quotes',
                value: expiredQuotes.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.headlineSmall),
      ],
    );
  }
}

class _InvoiceReminderTile extends ConsumerWidget {
  const _InvoiceReminderTile({
    required this.item,
    required this.isSelecting,
    required this.isSelected,
    required this.onToggleSelected,
  });

  final InvoiceReminderItem item;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = item.customer!;
    final invoice = item.invoice;
    final label = item.isOverdue
        ? '${item.daysUntilDue.abs()}d overdue'
        : (item.daysUntilDue == 0
              ? 'Due today'
              : 'Due in ${item.daysUntilDue}d');
    final reminderText = _buildInvoiceReminder(
      business: item.business,
      customer: customer,
      invoice: invoice,
    );

    return Card(
      child: ListTile(
        selected: isSelected,
        leading: isSelecting
            ? Checkbox(value: isSelected, onChanged: (_) => onToggleSelected())
            : Icon(
                item.isOverdue
                    ? Icons.warning_amber
                    : Icons.notifications_active,
                color: item.isOverdue ? Colors.red : null,
              ),
        title: Text('${customer.name} - ${invoice.invoiceNumber}'),
        subtitle: Text(
          '$label | Balance Rs. ${item.balanceDue.toStringAsFixed(2)}',
        ),
        onTap: () {
          if (isSelecting) {
            onToggleSelected();
            return;
          }
          context.push('/invoice-preview/${invoice.id}');
        },
        onLongPress: onToggleSelected,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'copy':
                await Clipboard.setData(ClipboardData(text: reminderText));
                await ref
                    .read(reminderActionsProvider)
                    .markInvoiceContacted(invoice.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Reminder copied.')),
                );
                return;
              case 'share':
                await ShareService.shareText(
                  reminderText,
                  subject: 'Payment Reminder: ${invoice.invoiceNumber}',
                );
                await ref
                    .read(reminderActionsProvider)
                    .markInvoiceContacted(invoice.id);
                return;
              case 'open':
                if (!context.mounted) return;
                context.push('/invoice-preview/${invoice.id}');
                return;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'copy', child: Text('Copy Reminder')),
            PopupMenuItem(value: 'share', child: Text('Share Reminder')),
            PopupMenuItem(value: 'open', child: Text('Open Invoice')),
          ],
        ),
      ),
    );
  }
}

class _QuoteReminderTile extends ConsumerWidget {
  const _QuoteReminderTile({
    required this.item,
    required this.isSelecting,
    required this.isSelected,
    required this.onToggleSelected,
  });

  final QuoteReminderItem item;
  final bool isSelecting;
  final bool isSelected;
  final VoidCallback onToggleSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customer = item.customer!;
    final quote = item.quote;
    final label = item.isExpired
        ? '${item.daysUntilExpiry.abs()}d expired'
        : (item.daysUntilExpiry == 0
              ? 'Expires today'
              : 'Expires in ${item.daysUntilExpiry}d');
    final followUpText = _buildQuoteFollowUp(
      business: item.business,
      customer: customer,
      quote: quote,
    );

    return Card(
      child: ListTile(
        selected: isSelected,
        leading: isSelecting
            ? Checkbox(value: isSelected, onChanged: (_) => onToggleSelected())
            : Icon(
                item.isExpired ? Icons.error_outline : Icons.schedule_send,
                color: item.isExpired ? Colors.red : null,
              ),
        title: Text('${customer.name} - ${quote.invoiceNumber}'),
        subtitle: Text('$label | Rs. ${quote.totalAmount.toStringAsFixed(2)}'),
        onTap: () {
          if (isSelecting) {
            onToggleSelected();
            return;
          }
          context.push('/quote-preview/${quote.id}');
        },
        onLongPress: onToggleSelected,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'copy':
                await Clipboard.setData(ClipboardData(text: followUpText));
                await ref
                    .read(reminderActionsProvider)
                    .markQuoteContacted(quote.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Follow-up copied.')),
                );
                return;
              case 'share':
                await ShareService.shareText(
                  followUpText,
                  subject: 'Quote Follow-up: ${quote.invoiceNumber}',
                );
                await ref
                    .read(reminderActionsProvider)
                    .markQuoteContacted(quote.id);
                return;
              case 'open':
                if (!context.mounted) return;
                context.push('/quote-preview/${quote.id}');
                return;
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'copy', child: Text('Copy Follow-up')),
            PopupMenuItem(value: 'share', child: Text('Share Follow-up')),
            PopupMenuItem(value: 'open', child: Text('Open Quote')),
          ],
        ),
      ),
    );
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
      'Rs. ${balance.toStringAsFixed(2)}.'
      '${dueDate != null ? ' The due date is $dueDate.' : ''}'
      '${isOverdue ? ' This invoice is now overdue.' : ''}'
      '${contact.isNotEmpty ? ' $contact' : ''}'
      ' Please let us know once payment is completed.';
}

String _buildQuoteFollowUp({
  required Business business,
  required Customer customer,
  required Quote quote,
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final validUntil = quote.dueDate?.toLocal().toString().split(' ')[0];
  final dueDateValue = quote.dueDate == null
      ? null
      : DateTime(quote.dueDate!.year, quote.dueDate!.month, quote.dueDate!.day);
  final isExpired = dueDateValue != null && dueDateValue.isBefore(today);
  final isExpiringSoon =
      dueDateValue != null &&
      !isExpired &&
      dueDateValue.difference(today).inDays <= 7;
  final opening = isExpired
      ? 'Hello ${customer.name}, following up from ${business.name} on expired quote'
      : (isExpiringSoon
            ? 'Hello ${customer.name}, a quick follow-up from ${business.name} on quote nearing expiry'
            : 'Hello ${customer.name}, sharing a follow-up from ${business.name} regarding quote');
  final contact = customer.phone?.isNotEmpty == true
      ? 'You can reach us on ${customer.phone}.'
      : (customer.email?.isNotEmpty == true
            ? 'You can reply to ${customer.email}.'
            : '');
  return '$opening ${quote.invoiceNumber} for Rs. ${quote.totalAmount.toStringAsFixed(2)}.'
      '${validUntil != null ? ' The quote is valid until $validUntil.' : ''}'
      '${isExpired ? ' This quote has expired.' : ''}'
      '${isExpiringSoon ? ' This quote will expire soon.' : ''}'
      '${contact.isNotEmpty ? ' $contact' : ''}'
      ' Please let us know if you would like us to proceed.';
}
