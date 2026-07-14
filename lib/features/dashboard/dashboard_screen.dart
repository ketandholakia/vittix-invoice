import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/utils/invoice_balance.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/invoice_provider.dart';
import '../../providers/quote_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeBusinessId = ref.watch(activeBusinessIdProvider);
    final businessAsync = activeBusinessId != null
        ? ref.watch(businessDaoProvider).getBusinessById(activeBusinessId)
        : Future.value(null);

    final invoicesAsync = ref.watch(invoiceListProvider);
    final quotesAsync = ref.watch(quoteListProvider);

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder(
          future: businessAsync,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Text(snapshot.data!.name);
            }
            return const Text('Dashboard');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.indigo),
              child: Text(
                'VittixInvoice',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.business),
              title: const Text('Manage Businesses'),
              onTap: () {
                context.pop();
                context.push('/businesses');
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Customers'),
              onTap: () {
                context.pop();
                context.push('/customers');
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text('Products & Services'),
              onTap: () {
                context.pop();
                context.push('/products');
              },
            ),
            ListTile(
              leading: const Icon(Icons.request_quote),
              title: const Text('Quotes'),
              onTap: () {
                context.pop();
                context.push('/quotes');
              },
            ),
            ListTile(
              leading: const Icon(Icons.receipt),
              title: const Text('Invoices'),
              onTap: () {
                context.pop();
                context.push('/invoices');
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications_active),
              title: const Text('Reminders'),
              onTap: () {
                context.pop();
                context.push('/reminders');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text('Reports'),
              onTap: () {
                context.pop();
                context.push('/reports');
              },
            ),
          ],
        ),
      ),
      body: invoicesAsync.when(
        data: (invoices) {
          final quotes = quotesAsync.valueOrNull ?? const [];
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);
          final totalRevenue = invoices.fold<double>(
            0,
            (sum, inv) => sum + inv.totalAmount,
          );
          final thisMonth = invoices.where(
            (i) =>
                i.invoiceDate.month == DateTime.now().month &&
                i.invoiceDate.year == DateTime.now().year,
          );
          final monthRevenue = thisMonth.fold<double>(
            0,
            (sum, inv) => sum + inv.totalAmount,
          );
          final unpaidTotal = invoices.fold<double>(
            0,
            (sum, inv) => sum + invoiceBalanceDue(inv),
          );
          final activeQuotes = quotes.where(
            (quote) => quote.status != 'CONVERTED',
          );
          final staleQuotes = activeQuotes.where((quote) {
            if (quote.status == 'REJECTED') {
              return false;
            }
            return now.difference(quote.updatedAt).inDays >= 3;
          }).toList();
          final totalQuotes = quotes.length;
          final convertedQuotes = quotes
              .where((quote) => quote.status == 'CONVERTED')
              .length;
          final conversionRate = totalQuotes == 0
              ? 0.0
              : (convertedQuotes / totalQuotes) * 100;
          final expiringQuotes = activeQuotes.where((quote) {
            if (quote.dueDate == null || quote.status == 'REJECTED') {
              return false;
            }
            final due = DateTime(
              quote.dueDate!.year,
              quote.dueDate!.month,
              quote.dueDate!.day,
            );
            final daysRemaining = due.difference(today).inDays;
            return daysRemaining >= 0 && daysRemaining <= 7;
          }).toList();
          final expiredQuotes = activeQuotes.where((quote) {
            if (quote.dueDate == null || quote.status == 'REJECTED') {
              return false;
            }
            final due = DateTime(
              quote.dueDate!.year,
              quote.dueDate!.month,
              quote.dueDate!.day,
            );
            return due.isBefore(today);
          }).toList();
          final recentInvoices = invoices.take(5).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Total Revenue',
                        value: 'Rs. ${totalRevenue.toStringAsFixed(0)}',
                        icon: Icons.account_balance_wallet,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'This Month',
                        value: 'Rs. ${monthRevenue.toStringAsFixed(0)}',
                        icon: Icons.trending_up,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Unpaid',
                        value: 'Rs. ${unpaidTotal.toStringAsFixed(0)}',
                        icon: Icons.pending_actions,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        title: 'Quote Conversion',
                        value:
                            '$convertedQuotes/$totalQuotes (${conversionRate.toStringAsFixed(0)}%)',
                        icon: Icons.swap_horiz,
                        color: Colors.purple,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // --- CHARTS SECTION ---
                Text('Revenue vs Unpaid', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              value: totalRevenue - unpaidTotal > 0 ? totalRevenue - unpaidTotal : 1,
                              title: 'Paid',
                              color: Colors.green,
                              radius: 50,
                            ),
                            PieChartSectionData(
                              value: unpaidTotal > 0 ? unpaidTotal : 1,
                              title: 'Unpaid',
                              color: Colors.orange,
                              radius: 50,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                
                if (staleQuotes.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Quote Follow-up Queue',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${staleQuotes.length} stale | ${expiredQuotes.length} expired | ${expiringQuotes.length} expiring',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 156,
                    child: ListView.builder(
                      itemCount: staleQuotes.take(3).length,
                      itemBuilder: (context, index) {
                        final quote = staleQuotes[index];
                        final isExpired = expiredQuotes.any(
                          (entry) => entry.id == quote.id,
                        );
                        final dueDate = quote.dueDate
                            ?.toLocal()
                            .toString()
                            .split(' ')[0];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isExpired
                                  ? Colors.red
                                  : Colors.deepOrange,
                              child: const Icon(
                                Icons.request_quote,
                                color: Colors.white,
                              ),
                            ),
                            title: Text(quote.invoiceNumber),
                            subtitle: Text(
                              '${isExpired ? 'Expired' : 'Needs follow-up'}'
                              '${dueDate != null ? ' | Valid until $dueDate' : ''}',
                            ),
                            trailing: Text(
                              'Rs. ${quote.totalAmount.toStringAsFixed(0)}',
                            ),
                            onTap: () =>
                                context.push('/quote-preview/${quote.id}'),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Invoices',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${activeQuotes.length} active quotes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                invoices.isEmpty
                    ? const Center(
                        child: Text('No invoices yet. Create one!'),
                      )
                    : ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: recentInvoices.length,
                        itemBuilder: (context, index) {
                          final invoice = recentInvoices[index];
                          final balance = invoiceBalanceDue(invoice);
                          final isOverdue =
                              invoice.dueDate != null &&
                              balance > 0 &&
                              invoice.dueDate!.isBefore(DateTime.now());

                          return Card(
                            elevation: 2,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Icon(
                                  Icons.receipt,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                invoice.invoiceNumber,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isThreeLine: balance > 0,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              dense: true,
                              minVerticalPadding: 8,
                              subtitleTextStyle: Theme.of(
                                context,
                              ).textTheme.bodySmall?.copyWith(height: 1.3),
                              titleTextStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                              horizontalTitleGap: 12,
                              visualDensity: VisualDensity.compact,
                              titleAlignment: ListTileTitleAlignment.center,
                              enabled: true,
                              selected: false,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              subtitle: Text(
                                '${invoice.invoiceDate.toString().split(' ')[0]}'
                                '${invoice.dueDate != null ? ' | Due ${invoice.dueDate!.toString().split(' ')[0]}' : ''}'
                                '${balance > 0 ? '\nBalance Rs. ${balance.toStringAsFixed(2)}' : ''}',
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Rs. ${invoice.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
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
                              onTap: () => context.push(
                                '/invoice-preview/${invoice.id}',
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
