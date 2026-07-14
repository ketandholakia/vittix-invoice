import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../database/app_database.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/quote_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../database/tables/template_configs.dart';
import '../../../models/invoice_template_config.dart';
import '../../../services/pdf_service.dart';
import '../../../services/share_service.dart';

class QuoteListScreen extends ConsumerStatefulWidget {
  const QuoteListScreen({super.key});

  @override
  ConsumerState<QuoteListScreen> createState() => _QuoteListScreenState();
}

class _QuoteListScreenState extends ConsumerState<QuoteListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'ALL';
  bool _showExpiringSoonOnly = false;
  bool _showExpiredOnly = false;
  final Set<int> _selectedQuoteIds = {};

  bool get _isSelecting => _selectedQuoteIds.isNotEmpty;

  void _toggleQuoteSelection(int quoteId) {
    setState(() {
      if (!_selectedQuoteIds.add(quoteId)) {
        _selectedQuoteIds.remove(quoteId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedQuoteIds.clear);
  }

  Future<void> _exportSelectedQuotes(List<Quote> quotes) async {
    final selected = quotes
        .where((quote) => _selectedQuoteIds.contains(quote.id))
        .toList();
    if (selected.isEmpty) return;

    final rows = <List<String>>[
      ['Quote Number', 'Date', 'Valid Until', 'Status', 'Total Amount'],
      for (final quote in selected)
        [
          quote.invoiceNumber,
          quote.invoiceDate.toIso8601String().split('T')[0],
          quote.dueDate?.toIso8601String().split('T')[0] ?? '',
          quote.status,
          quote.totalAmount.toStringAsFixed(2),
        ],
    ];

    await ShareService.shareCsv(
      rows,
      'selected_quotes.csv',
      subject: 'Selected Quotes',
      text: 'Selected quote export',
    );
  }

  Future<void> _deleteSelectedQuotes(
    BuildContext context,
    List<Quote> quotes,
  ) async {
    final selected = quotes
        .where((quote) => _selectedQuoteIds.contains(quote.id))
        .toList();
    final deletable = selected
        .where((quote) => quote.status != 'CONVERTED')
        .toList();
    if (deletable.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No selected quotes can be deleted.')),
      );
      return;
    }

    final skipped = selected.length - deletable.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete selected quotes?'),
        content: Text(
          'This will delete ${deletable.length} quote(s).'
          '${skipped > 0 ? ' $skipped converted quote(s) will be skipped.' : ''}',
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
    for (final quote in deletable) {
      try {
        await ref.read(quoteProvider).deleteQuote(quote.id);
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
          'Deleted $deleted quote(s).'
          '${failed > 0 ? ' $failed failed.' : ''}',
        ),
      ),
    );
  }

  bool _isExpiringSoon(Quote quote) {
    if (quote.dueDate == null || quote.status == 'CONVERTED') {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final validUntil = DateTime(
      quote.dueDate!.year,
      quote.dueDate!.month,
      quote.dueDate!.day,
    );
    final daysRemaining = validUntil.difference(today).inDays;
    return daysRemaining >= 0 && daysRemaining <= 7;
  }

  bool _isExpired(Quote quote) {
    if (quote.dueDate == null || quote.status == 'CONVERTED') {
      return false;
    }
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final validUntil = DateTime(
      quote.dueDate!.year,
      quote.dueDate!.month,
      quote.dueDate!.day,
    );
    return validUntil.isBefore(today);
  }

  Future<void> _shareQuote(BuildContext context, Quote quote) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(quote.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(quote.customerId);
      final items = await ref.read(quoteDaoProvider).getItemsForQuote(quote.id);
      final isGstEnabled = ref.read(isGstEnabledProvider);
      final showBankDetails = ref.read(printBankDetailsOnInvoiceProvider);

      if (business == null || customer == null) {
        throw Exception('Quote data is incomplete');
      }

      final template = business.defaultQuoteTemplateId != null
          ? await ref
              .read(templateConfigDaoProvider)
              .getTemplateById(business.defaultQuoteTemplateId!)
          : await ref
              .read(templateConfigDaoProvider)
              .getDefaultTemplate(business.id, TemplateScope.quote);

      final pdf = await PdfService.generateQuotePdf(
        business: business,
        customer: customer,
        quote: quote,
        items: items,
        isGstEnabled: isGstEnabled,
        showBankDetails: showBankDetails,
        templateConfig: template == null
            ? null
            : InvoiceTemplateConfig.decode(template.configJson),
      );

      await ShareService.sharePdf(
        pdf,
        '${quote.invoiceNumber}.pdf',
        subject: 'Quote: ${quote.invoiceNumber}',
        text: 'Please find quote ${quote.invoiceNumber} attached.',
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share quote: $e')));
    }
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
        : DateTime(
            quote.dueDate!.year,
            quote.dueDate!.month,
            quote.dueDate!.day,
          );
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
    return '$opening ${quote.invoiceNumber} for ${formatMoney(quote.totalAmount, currencyCode: quote.currencyCode)}.'
        '${validUntil != null ? ' The quote is valid until $validUntil.' : ''}'
        '${isExpired ? ' This quote has expired.' : ''}'
        '${isExpiringSoon ? ' This quote will expire soon.' : ''}'
        '${contact.isNotEmpty ? ' $contact' : ''}'
        ' Please let us know if you would like us to proceed.';
  }

  Future<void> _copyFollowUp(BuildContext context, Quote quote) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(quote.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(quote.customerId);
      if (business == null || customer == null) {
        throw Exception('Quote data is incomplete');
      }
      await Clipboard.setData(
        ClipboardData(
          text: _buildQuoteFollowUp(
            business: business,
            customer: customer,
            quote: quote,
          ),
        ),
      );
      await ref.read(quoteProvider).markQuoteContacted(quote.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Follow-up copied.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to copy follow-up: $e')));
    }
  }

  Future<void> _shareFollowUp(BuildContext context, Quote quote) async {
    try {
      final business = await ref
          .read(businessDaoProvider)
          .getBusinessById(quote.businessId);
      final customer = await ref
          .read(customerDaoProvider)
          .getCustomerById(quote.customerId);
      if (business == null || customer == null) {
        throw Exception('Quote data is incomplete');
      }
      await ShareService.shareText(
        _buildQuoteFollowUp(
          business: business,
          customer: customer,
          quote: quote,
        ),
        subject: 'Quote Follow-up: ${quote.invoiceNumber}',
      );
      await ref.read(quoteProvider).markQuoteContacted(quote.id);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to share follow-up: $e')));
    }
  }

  Future<void> _deleteQuote(BuildContext context, Quote quote) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete quote?'),
        content: Text('Delete ${quote.invoiceNumber}? This cannot be undone.'),
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
      await ref.read(quoteProvider).deleteQuote(quote.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Quote deleted.')));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete quote: $e')));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quotesAsync = ref.watch(quoteListProvider);

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
          _isSelecting ? '${_selectedQuoteIds.length} selected' : 'Quotes',
        ),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  onPressed: () {
                    final quotes = quotesAsync.valueOrNull ?? const [];
                    _exportSelectedQuotes(quotes);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete selected',
                  onPressed: () {
                    final quotes = quotesAsync.valueOrNull ?? const [];
                    _deleteSelectedQuotes(context, quotes);
                  },
                ),
              ]
            : null,
      ),
      body: quotesAsync.when(
        data: (quotes) {
          final filteredQuotes = quotes.where((quote) {
            final matchesQuery =
                _query.isEmpty ||
                quote.invoiceNumber.toLowerCase().contains(_query) ||
                quote.status.toLowerCase().contains(_query);
            final matchesStatus =
                _statusFilter == 'ALL' || quote.status == _statusFilter;
            final matchesExpiringSoon =
                !_showExpiringSoonOnly || _isExpiringSoon(quote);
            final matchesExpired = !_showExpiredOnly || _isExpired(quote);
            return matchesQuery &&
                matchesStatus &&
                matchesExpiringSoon &&
                matchesExpired;
          }).toList();

          final followUpQuotes =
              quotes.where((quote) {
                if (quote.status == 'CONVERTED' || quote.status == 'REJECTED') {
                  return false;
                }
                return _isExpired(quote) || _isExpiringSoon(quote);
              }).toList()..sort((a, b) {
                final aDate = a.dueDate ?? DateTime(9999);
                final bDate = b.dueDate ?? DateTime(9999);
                return aDate.compareTo(bDate);
              });

          if (quotes.isEmpty) {
            return EmptyState(
              icon: Icons.request_quote_outlined,
              title: 'No quotes yet',
              message:
                  'Create quotes to follow up with customers and convert accepted work into invoices.',
              actionLabel: 'New Quote',
              onAction: () => context.push('/create-quote'),
            );
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search quotes',
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
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _statusFilter,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'ALL', child: Text('All')),
                        DropdownMenuItem(value: 'DRAFT', child: Text('Draft')),
                        DropdownMenuItem(value: 'SENT', child: Text('Sent')),
                        DropdownMenuItem(
                          value: 'ACCEPTED',
                          child: Text('Accepted'),
                        ),
                        DropdownMenuItem(
                          value: 'REJECTED',
                          child: Text('Rejected'),
                        ),
                        DropdownMenuItem(
                          value: 'CONVERTED',
                          child: Text('Converted'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _statusFilter = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Expiring 7d'),
                          selected: _showExpiringSoonOnly,
                          onSelected: (selected) {
                            setState(() => _showExpiringSoonOnly = selected);
                          },
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Expired'),
                          selected: _showExpiredOnly,
                          onSelected: (selected) {
                            setState(() => _showExpiredOnly = selected);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              if (followUpQuotes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('Needs Follow-up'),
                          subtitle: Text(
                            '${followUpQuotes.length} quotes are expired or expiring within 7 days',
                          ),
                        ),
                        ...followUpQuotes.take(3).map((quote) {
                          final expired = _isExpired(quote);
                          final expiringSoon = _isExpiringSoon(quote);
                          final dueLabel = quote.dueDate == null
                              ? 'No validity date'
                              : quote.dueDate!.toLocal().toString().split(
                                  ' ',
                                )[0];
                          return ListTile(
                            dense: true,
                            title: Text(quote.invoiceNumber),
                            subtitle: Text(
                              '${expired ? 'Expired' : (expiringSoon ? 'Expiring soon' : quote.status)} | Valid until $dueLabel',
                            ),
                            trailing: TextButton(
                              onPressed: () =>
                                  context.push('/quote-preview/${quote.id}'),
                              child: const Text('Review'),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              Expanded(
                child: filteredQuotes.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No matching quotes',
                        message:
                            'Adjust the search text, status filter, or expiry filters.',
                      )
                    : ListView.builder(
                        itemCount: filteredQuotes.length,
                        itemBuilder: (context, index) {
                          final quote = filteredQuotes[index];
                          final expired = _isExpired(quote);
                          final expiringSoon = _isExpiringSoon(quote);

                          return ListTile(
                            selected: _selectedQuoteIds.contains(quote.id),
                            leading: _isSelecting
                                ? Checkbox(
                                    value: _selectedQuoteIds.contains(quote.id),
                                    onChanged: (_) =>
                                        _toggleQuoteSelection(quote.id),
                                  )
                                : const Icon(Icons.request_quote),
                            title: Text(quote.invoiceNumber),
                            subtitle: Text(
                              'Date: ${quote.invoiceDate.toLocal().toString().split(' ')[0]}'
                              '${quote.dueDate != null ? ' | Valid Until: ${quote.dueDate!.toLocal().toString().split(' ')[0]}' : ''}',
                            ),
                            onTap: () {
                              if (_isSelecting) {
                                _toggleQuoteSelection(quote.id);
                                return;
                              }
                              context.push('/quote-preview/${quote.id}');
                            },
                            onLongPress: () => _toggleQuoteSelection(quote.id),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      formatMoney(
                                        quote.totalAmount,
                                        currencyCode: quote.currencyCode,
                                      ),
                                    ),
                                    Text(
                                      quote.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: quote.status == 'CONVERTED'
                                            ? Colors.green
                                            : (expired
                                                  ? Colors.red
                                                  : (expiringSoon
                                                        ? Colors.deepOrange
                                                        : (quote.status ==
                                                                  'REJECTED'
                                                              ? Colors.red
                                                              : Colors
                                                                    .orange))),
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
                                          '/quote-preview/${quote.id}',
                                        );
                                        return;
                                      case 'share':
                                        await _shareQuote(context, quote);
                                        return;
                                      case 'copy_followup':
                                        await _copyFollowUp(context, quote);
                                        return;
                                      case 'share_followup':
                                        await _shareFollowUp(context, quote);
                                        return;
                                      case 'duplicate':
                                        final duplicatedId = await ref
                                            .read(quoteProvider)
                                            .duplicateQuote(quote.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Quote duplicated as draft.',
                                            ),
                                          ),
                                        );
                                        context.push(
                                          '/quote-preview/$duplicatedId',
                                        );
                                        return;
                                      case 'delete':
                                        await _deleteQuote(context, quote);
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
                                      value: 'copy_followup',
                                      child: Text('Copy Follow-up'),
                                    ),
                                    PopupMenuItem(
                                      value: 'share_followup',
                                      child: Text('Share Follow-up'),
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
        onPressed: () => context.push('/create-quote'),
        icon: const Icon(Icons.add),
        label: const Text('New Quote'),
      ),
    );
  }
}
