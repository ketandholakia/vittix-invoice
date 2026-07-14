import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/widgets/empty_state.dart';
import '../../database/app_database.dart';
import '../../providers/customer_activity_provider.dart';
import '../../providers/customer_detail_provider.dart';

class CustomerDetailScreen extends ConsumerWidget {
  const CustomerDetailScreen({super.key, required this.customerId});

  final int customerId;

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final suffix = date.hour >= 12 ? 'PM' : 'AM';
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute $suffix';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customerAsync = ref.watch(customerDetailProvider(customerId));
    final invoicesAsync = ref.watch(customerInvoicesProvider(customerId));
    final quotesAsync = ref.watch(customerQuotesProvider(customerId));
    final paymentsAsync = ref.watch(
      customerInvoicePaymentsProvider(customerId),
    );
    final activityAsync = ref.watch(customerActivityProvider(customerId));

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Activity')),
      body: customerAsync.when(
        data: (customer) {
          if (customer == null) {
            return const EmptyState(
              icon: Icons.person_off_outlined,
              title: 'Customer not found',
              message:
                  'This customer may have been deleted or is no longer available.',
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customer.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if ((customer.gstin ?? '').isNotEmpty)
                            Chip(label: Text('GSTIN ${customer.gstin}')),
                          if ((customer.phone ?? '').isNotEmpty)
                            Chip(label: Text(customer.phone!)),
                          if ((customer.email ?? '').isNotEmpty)
                            Chip(label: Text(customer.email!)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Quotes',
                      value: quotesAsync.valueOrNull == null
                          ? '-'
                          : quotesAsync.valueOrNull!.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Invoices',
                      value: invoicesAsync.valueOrNull == null
                          ? '-'
                          : invoicesAsync.valueOrNull!.length.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Payments',
                      value: paymentsAsync.valueOrNull == null
                          ? '-'
                          : paymentsAsync.valueOrNull!.length.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Collected',
                          value: _formatMoney(
                            paymentsAsync.valueOrNull?.fold<double>(
                                  0,
                                  (sum, payment) => sum +
                                      (payment.kind == 'REFUND'
                                          ? -payment.amount
                                          : payment.amount),
                                ) ??
                            0,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Converted',
                      value: quotesAsync.valueOrNull == null
                          ? '-'
                          : quotesAsync.valueOrNull!
                                .where((quote) => quote.status == 'CONVERTED')
                                .length
                                .toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: 'Last contact',
                      value: _lastContactLabel(
                        activityAsync.valueOrNull ?? const [],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text('Timeline', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              ..._buildTimeline(
                context,
                customer: customer,
                invoices: invoicesAsync.valueOrNull ?? const [],
                quotes: quotesAsync.valueOrNull ?? const [],
                payments: paymentsAsync.valueOrNull ?? const [],
                activity: activityAsync.valueOrNull ?? const [],
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  List<Widget> _buildTimeline(
    BuildContext context, {
    required Customer customer,
    required List<Invoice> invoices,
    required List<Quote> quotes,
    required List<InvoicePayment> payments,
    required List<CustomerActivityEvent> activity,
  }) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        date: customer.createdAt,
        title: 'Customer created',
        subtitle: customer.address?.trim().isNotEmpty == true
            ? customer.address!.trim()
            : 'Record added to the ledger',
      ),
      ...quotes.map(
        (quote) => _TimelineEvent(
          date: quote.updatedAt,
          title: quote.status == 'CONVERTED'
              ? 'Quote converted'
              : 'Quote updated',
          subtitle:
              '${quote.invoiceNumber}  ${_formatMoney(quote.totalAmount)}',
          actionLabel: 'Open quote',
          onTap: () => context.push('/quote-preview/${quote.id}'),
        ),
      ),
      ...invoices.map(
        (invoice) => _TimelineEvent(
          date: invoice.updatedAt,
          title: invoice.status == 'PAID'
              ? 'Invoice paid'
              : invoice.status == 'PARTIALLY_PAID'
              ? 'Invoice partially paid'
              : 'Invoice issued',
          subtitle:
              '${invoice.invoiceNumber}  ${_formatMoney(invoice.totalAmount)}',
          actionLabel: 'Open invoice',
          onTap: () => context.push('/invoice-preview/${invoice.id}'),
        ),
      ),
      ...payments.map(
        (payment) => _TimelineEvent(
          date: payment.paidAt,
          title: payment.kind == 'REFUND'
              ? 'Refund recorded'
              : payment.kind == 'VOID'
              ? 'Payment voided'
              : 'Payment recorded',
          subtitle:
              '${payment.kind == 'REFUND' ? '-' : ''}${_formatMoney(payment.amount)}',
        ),
      ),
      ...activity.map(
        (entry) => _TimelineEvent(
          date: entry.createdAt,
          title: entry.title,
          subtitle: entry.note ?? entry.eventType,
        ),
      ),
    ]..sort((a, b) => b.date.compareTo(a.date));

    if (events.isEmpty) {
      return const [
        EmptyState(
          icon: Icons.history,
          title: 'No activity yet',
          message:
              'Invoices, quotes, payments, and contact events will appear here.',
        ),
      ];
    }

    return [
      for (final event in events)
        Card(
          child: ListTile(
            leading: const Icon(Icons.schedule),
            title: Text(event.title),
            subtitle: Text('${_formatDate(event.date)}\n${event.subtitle}'),
            isThreeLine: event.actionLabel != null,
            trailing: event.actionLabel == null
                ? null
                : TextButton(
                    onPressed: event.onTap,
                    child: Text(event.actionLabel!),
                  ),
            onTap: event.onTap,
          ),
        ),
      const SizedBox(height: 8),
    ];
  }

  String _formatMoney(double amount) => 'Rs ${amount.toStringAsFixed(2)}';

  String _lastContactLabel(List<CustomerActivityEvent> events) {
    final contactEvents = events
        .where((event) => event.eventType == 'QUOTE_CONTACT')
        .toList();
    if (contactEvents.isEmpty) return 'No contact';

    final latestContact = contactEvents
        .map((event) => event.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
    return _formatDate(latestContact);
  }
}

class _TimelineEvent {
  _TimelineEvent({
    required this.date,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onTap,
  });

  final DateTime date;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onTap;
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
      ),
    );
  }
}
