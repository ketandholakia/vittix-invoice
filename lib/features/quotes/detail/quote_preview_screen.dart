import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../database/app_database.dart';
import '../../../database/tables/template_configs.dart';
import '../../../models/invoice_template_config.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/share_service.dart';
import '../../../providers/quote_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/shared_preferences_provider.dart';

class QuotePreviewScreen extends ConsumerWidget {
  final int quoteId;

  const QuotePreviewScreen({super.key, required this.quoteId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quoteFuture = ref.watch(quoteDetailProvider(quoteId).future);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quote Preview'),
        actions: [
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Quote',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete quote?'),
                      content: const Text(
                        'This will permanently remove the quote and its line items.',
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
                    await ref.read(quoteProvider).deleteQuote(quote.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Quote deleted.')),
                      );
                      context.go('/quotes');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete quote: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Quote',
                onPressed: () => context.push('/edit-quote', extra: quote),
              );
            },
          ),
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null || quote.status == 'CONVERTED') {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.check_circle_outline),
                tooltip: 'Convert to Invoice',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Convert to Invoice?'),
                      content: const Text(
                        'This will create a new invoice from this quote.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Convert'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    final notifier = ref.read(quoteProvider);
                    try {
                      final invoiceId = await notifier.convertToInvoice(
                        quoteId,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Quote converted successfully!'),
                          ),
                        );
                        context.pushReplacement('/invoice-preview/$invoiceId');
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Conversion failed: $e')),
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Upload Drive Link',
                onPressed: () => _shareQuoteDriveLink(context, ref, quote),
              );
            },
          ),
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.style),
                tooltip: 'Change Template',
                onPressed: () => _showTemplateSelector(context, ref, quote),
              );
            },
          ),
          FutureBuilder<Quote?>(
            future: quoteFuture,
            builder: (context, snapshot) {
              final quote = snapshot.data;
              if (quote == null || quote.status == 'CONVERTED') {
                return const SizedBox.shrink();
              }
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  try {
                    await ref
                        .read(quoteProvider)
                        .updateQuoteStatus(quote.id, value);
                    if (context.mounted) {
                      ref.invalidate(quoteDetailProvider(quote.id));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to update status: $e')),
                      );
                    }
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'SENT', child: Text('Mark Sent')),
                  PopupMenuItem(
                    value: 'ACCEPTED',
                    child: Text('Mark Accepted'),
                  ),
                  PopupMenuItem(
                    value: 'REJECTED',
                    child: Text('Mark Rejected'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Quote?>(
        future: quoteFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load quote'));
          }

          final quote = snapshot.data!;
          final activeBusinessId = ref.watch(activeBusinessIdProvider);
          final isGstEnabled = ref.watch(isGstEnabledProvider);
          final showBankDetails = ref.watch(printBankDetailsOnInvoiceProvider);

          return FutureBuilder(
            future: Future.wait<dynamic>([
              ref.read(businessDaoProvider).getBusinessById(activeBusinessId!),
              ref.read(customerDaoProvider).getCustomerById(quote.customerId),
              ref.read(quoteDaoProvider).getItemsForQuote(quote.id),
            ]),
            builder: (context, detailSnapshot) {
              if (detailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final business = detailSnapshot.data![0] as Business;
              final customer = detailSnapshot.data![1] as Customer;
              final items = detailSnapshot.data![2] as List<QuoteItem>;
              final followUpText = _buildQuoteFollowUp(
                business: business,
                customer: customer,
                quote: quote,
              );

              return Column(
                children: [
                  Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      title: Text('Status: ${quote.status}'),
                      subtitle: Text(
                        quote.dueDate != null
                            ? 'Valid until ${quote.dueDate!.toLocal().toString().split(' ')[0]}'
                            : 'No validity date set',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'copy':
                              await Clipboard.setData(
                                ClipboardData(text: followUpText),
                              );
                              await ref
                                  .read(quoteProvider)
                                  .markQuoteContacted(quote.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Follow-up copied.'),
                                  ),
                                );
                              }
                              return;
                            case 'share':
                              await ShareService.shareText(
                                followUpText,
                                subject:
                                    'Quote Follow-up: ${quote.invoiceNumber}',
                              );
                              await ref
                                  .read(quoteProvider)
                                  .markQuoteContacted(quote.id);
                              return;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'copy',
                            child: Text('Copy Follow-up'),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Text('Share Follow-up'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: PdfPreview(
                      key: ValueKey('${quote.id}_${quote.updatedAt.millisecondsSinceEpoch}_${quote.templateId}'),
                      build: (format) => _buildQuotePdf(
                        ref: ref,
                        business: business,
                        customer: customer,
                        quote: quote,
                        items: items,
                        isGstEnabled: isGstEnabled,
                        showBankDetails: showBankDetails,
                      ),
                      onShared: (context) async {
                        final data = await _buildQuotePdf(
                          ref: ref,
                          business: business,
                          customer: customer,
                          quote: quote,
                          items: items,
                          isGstEnabled: isGstEnabled,
                          showBankDetails: showBankDetails,
                        );
                        await ShareService.sharePdf(
                          data,
                          '${quote.invoiceNumber}.pdf',
                          subject: 'Quote: ${quote.invoiceNumber}',
                          text:
                              'Please find quote ${quote.invoiceNumber} attached.',
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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

  Future<void> _shareQuoteDriveLink(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
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

      final pdf = await _buildQuotePdf(
        ref: ref,
        business: business,
        customer: customer,
        quote: quote,
        items: items,
        isGstEnabled: isGstEnabled,
        showBankDetails: showBankDetails,
      );
      final result = await GoogleDriveService.instance.uploadShareablePdf(
        pdf,
        '${quote.invoiceNumber}.pdf',
        description: 'Quote ${quote.invoiceNumber}',
      );
      if (result.webViewLink != null) {
        await Clipboard.setData(ClipboardData(text: result.webViewLink!));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.webViewLink == null
                  ? 'Quote uploaded to Drive.'
                  : 'Drive link copied for ${quote.invoiceNumber}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload quote to Drive: $e')),
        );
      }
    }
  }

  Future<void> _showTemplateSelector(
    BuildContext context,
    WidgetRef ref,
    Quote quote,
  ) async {
    final templates = await ref
        .read(templateConfigDaoProvider)
        .getTemplatesForBusiness(quote.businessId, TemplateScope.quote);

    if (!context.mounted) return;

    final selectedId = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(
                title: Text(
                  'Select Template',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                title: const Text('Business Default'),
                leading: const Icon(Icons.star),
                trailing: quote.templateId == null
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => Navigator.pop(ctx, -1),
              ),
              const Divider(height: 1),
              ...templates.map(
                (t) => ListTile(
                  title: Text(t.name),
                  leading: const Icon(Icons.description_outlined),
                  trailing: quote.templateId == t.id
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
                  onTap: () => Navigator.pop(ctx, t.id),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedId != null) {
      final newTemplateId = selectedId == -1 ? null : selectedId;
      try {
        await ref
            .read(quoteProvider)
            .updateQuoteTemplate(quote.id, newTemplateId);
        if (context.mounted) {
          ref.invalidate(quoteDetailProvider(quote.id));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Failed to change template: $e')));
        }
      }
    }
  }

  Future<Uint8List> _buildQuotePdf({
    required WidgetRef ref,
    required Business business,
    required Customer customer,
    required Quote quote,
    required List<QuoteItem> items,
    required bool isGstEnabled,
    required bool showBankDetails,
  }) async {
    final templateDao = ref.read(templateConfigDaoProvider);
    final template = quote.templateId != null
        ? await templateDao.getTemplateById(quote.templateId!)
        : (business.defaultQuoteTemplateId != null
            ? await templateDao.getTemplateById(business.defaultQuoteTemplateId!)
            : await templateDao.getDefaultTemplate(business.id, TemplateScope.quote));

    return PdfService.generateQuotePdf(
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
  }
}
