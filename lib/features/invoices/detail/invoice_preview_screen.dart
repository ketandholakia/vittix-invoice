import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/invoice_balance.dart';
import '../../../database/app_database.dart';
import '../../../models/invoice_template_config.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/share_service.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../database/tables/template_configs.dart';

class InvoicePreviewScreen extends ConsumerWidget {
  final int invoiceId;

  const InvoicePreviewScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We ideally should fetch the invoice and its items in a unified provider
    final invoiceFuture = ref.watch(invoiceDetailProvider(invoiceId).future);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: [
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              final canDelete =
                  invoice != null &&
                  invoice.amountPaid <= 0 &&
                  invoice.status != 'PAID';
              if (!canDelete) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete Invoice',
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Delete invoice?'),
                      content: const Text(
                        'This will permanently remove the invoice and its line items.',
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
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invoice deleted.')),
                      );
                      context.go('/invoices');
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete invoice: $e')),
                      );
                    }
                  }
                },
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Invoice',
                onPressed: () => context.push('/edit-invoice', extra: invoice),
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null || invoice.status == 'PAID') {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.payment),
                tooltip: 'Record Payment',
                onPressed: () async {
                  final controller = TextEditingController(
                    text: invoiceBalanceDue(invoice).toStringAsFixed(2),
                  );
                  final amount = await showDialog<double>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Record Payment'),
                      content: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount Paid',
                          prefixText: '',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final val = double.tryParse(controller.text);
                            Navigator.pop(ctx, val);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );

                  if (amount != null && amount > 0) {
                    final notifier = ref.read(invoiceProvider);
                    try {
                      await notifier.recordPayment(invoiceId, amount);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment recorded successfully!'),
                          ),
                        );
                        ref.invalidate(invoiceDetailProvider(invoiceId));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to record payment: $e'),
                          ),
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null || invoice.amountPaid <= 0) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.undo),
                tooltip: 'Record Refund',
                onPressed: () async {
                  final controller = TextEditingController(
                    text: invoice.amountPaid.toStringAsFixed(2),
                  );
                  final amount = await showDialog<double>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Record Refund'),
                      content: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Refund Amount',
                          prefixText: '',
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancel'),
                        ),
                        FilledButton(
                          onPressed: () {
                            final val = double.tryParse(controller.text);
                            Navigator.pop(ctx, val);
                          },
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  );

                  if (amount != null && amount > 0) {
                    try {
                      await ref
                          .read(invoiceProvider)
                          .recordRefund(
                            invoiceId: invoice.id,
                            refundAmount: amount,
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Refund recorded successfully!'),
                          ),
                        );
                        ref.invalidate(invoiceDetailProvider(invoiceId));
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to record refund: $e'),
                          ),
                        );
                      }
                    }
                  }
                },
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Upload Drive Link',
                onPressed: () => _shareInvoiceDriveLink(context, ref, invoice),
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null) {
                return const SizedBox.shrink();
              }
              return IconButton(
                icon: const Icon(Icons.style),
                tooltip: 'Change Template',
                onPressed: () => _showTemplateSelector(context, ref, invoice),
              );
            },
          ),
          FutureBuilder<Invoice?>(
            future: invoiceFuture,
            builder: (context, snapshot) {
              final invoice = snapshot.data;
              if (invoice == null) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (value) async {
                  try {
                    await ref
                        .read(invoiceProvider)
                        .updateInvoiceStatus(invoice.id, value);
                    if (context.mounted) {
                      ref.invalidate(invoiceDetailProvider(invoice.id));
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
                    value: 'CANCELLED',
                    child: Text('Mark Cancelled'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Invoice?>(
        future: invoiceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Failed to load invoice'));
          }

          final invoice = snapshot.data!;
          final activeBusinessId = ref.watch(activeBusinessIdProvider);
          final isGstEnabled = ref.watch(isGstEnabledProvider);
          final showBankDetails = ref.watch(printBankDetailsOnInvoiceProvider);
          final paymentsAsync = ref.watch(invoicePaymentsProvider(invoiceId));

          return FutureBuilder(
            future: Future.wait<dynamic>([
              ref.read(businessDaoProvider).getBusinessById(activeBusinessId!),
              ref.read(customerDaoProvider).getCustomerById(invoice.customerId),
              ref.read(invoiceDaoProvider).getItemsForInvoice(invoice.id),
            ]),
            builder: (context, detailSnapshot) {
              if (detailSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final business = detailSnapshot.data![0] as Business;
              final customer = detailSnapshot.data![1] as Customer;
              final items = detailSnapshot.data![2] as List<InvoiceItem>;
              final reminderText = _buildInvoiceReminder(
                business: business,
                customer: customer,
                invoice: invoice,
              );

              return Column(
                children: [
                  Material(
                    color: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerHighest,
                    child: ListTile(
                      title: Text('Status: ${invoice.status}'),
                      subtitle: Text(
                        'Paid: ${formatMoney(invoice.amountPaid, currencyCode: invoice.currencyCode)}'
                        ' | Balance: ${formatMoney(invoiceBalanceDue(invoice), currencyCode: invoice.currencyCode)}'
                        '${invoiceOverpaidAmount(invoice) > 0 ? ' | Overpaid: ${formatMoney(invoiceOverpaidAmount(invoice), currencyCode: invoice.currencyCode)}' : ''}'
                        '${invoice.dueDate != null ? ' | Due: ${invoice.dueDate!.toLocal().toString().split(' ')[0]}' : ''}',
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) async {
                          switch (value) {
                            case 'copy':
                              await Clipboard.setData(
                                ClipboardData(text: reminderText),
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Reminder copied.'),
                                  ),
                                );
                              }
                              return;
                            case 'share':
                              await ShareService.shareText(
                                reminderText,
                                subject:
                                    'Payment Reminder: ${invoice.invoiceNumber}',
                              );
                              return;
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'copy',
                            child: Text('Copy Reminder'),
                          ),
                          PopupMenuItem(
                            value: 'share',
                            child: Text('Share Reminder'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: PdfPreview(
                      key: ValueKey('${invoice.id}_${invoice.updatedAt.millisecondsSinceEpoch}_${invoice.templateId}'),
                      build: (format) => _buildInvoicePdf(
                        ref: ref,
                        business: business,
                        customer: customer,
                        invoice: invoice,
                        items: items,
                        isGstEnabled: isGstEnabled,
                        showBankDetails: showBankDetails,
                      ),
                      onShared: (context) async {
                        final data = await _buildInvoicePdf(
                          ref: ref,
                          business: business,
                          customer: customer,
                          invoice: invoice,
                          items: items,
                          isGstEnabled: isGstEnabled,
                          showBankDetails: showBankDetails,
                        );
                        await ShareService.sharePdf(
                          data,
                          '${invoice.invoiceNumber}.pdf',
                          subject: 'Invoice: ${invoice.invoiceNumber}',
                          text:
                              'Please find invoice ${invoice.invoiceNumber} attached.',
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: paymentsAsync.when(
                      data: (payments) => payments.isEmpty
                          ? const Center(child: Text('No payments recorded'))
                          : ListView.builder(
                              itemCount: payments.length,
                              itemBuilder: (context, index) {
                                final payment = payments[index];
                                return ListTile(
                                  dense: true,
                                  title: Text(
                                    '${payment.kind == 'REFUND' ? 'Refund ' : ''}${payment.kind == 'VOID' ? 'Voided ' : ''}${formatMoney(payment.amount, currencyCode: invoice.currencyCode)}',
                                  ),
                                  subtitle: Text(
                                    '${payment.kind == 'REFUND'
                                        ? 'Refund'
                                        : payment.kind == 'VOID'
                                        ? 'Voided'
                                        : 'Payment'} | ${payment.paidAt.toLocal().toString().split('.')[0]}',
                                  ),
                                  trailing: const Icon(Icons.edit_outlined),
                                  onTap: () => _editPaymentDialog(
                                    context,
                                    ref,
                                    invoice,
                                    payment,
                                  ),
                                );
                              },
                            ),
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('Payment history error: $err')),
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

  Future<void> _editPaymentDialog(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
    InvoicePayment payment,
  ) async {
    if (payment.kind == 'VOID') {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Voided Payment'),
          content: const Text(
            'Voided payments cannot be edited or voided again.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        ),
      );
      return;
    }

    final amountController = TextEditingController(
      text: payment.amount.toStringAsFixed(2),
    );
    var paidAt = payment.paidAt;

    final result = await showDialog<_PaymentEditAction>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Edit Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Amount Paid',
                  prefixText: '',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Paid On'),
                subtitle: Text(paidAt.toLocal().toString().split(' ')[0]),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: paidAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => paidAt = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(ctx, _PaymentEditAction.voidPayment),
              child: const Text('Void'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _PaymentEditAction.cancel),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text);
                Navigator.pop(
                  ctx,
                  _PaymentEditAction.save(amount: amount, paidAt: paidAt),
                );
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (result == null || result.kind == _PaymentEditActionKind.cancel) {
      return;
    }

    try {
      if (result.kind == _PaymentEditActionKind.voidPayment) {
        await ref
            .read(invoiceProvider)
            .voidPayment(invoiceId: invoice.id, paymentId: payment.id);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Payment voided.')));
          ref.invalidate(invoiceDetailProvider(invoice.id));
        }
        return;
      }

      final amount = result.amount;
      if (amount == null) {
        throw Exception('Enter a valid amount');
      }
      await ref
          .read(invoiceProvider)
          .updatePayment(
            invoiceId: invoice.id,
            paymentId: payment.id,
            amount: amount,
            paidAt: result.paidAt!,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment updated.')));
        ref.invalidate(invoiceDetailProvider(invoice.id));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment update failed: $e')));
      }
    }
  }

  Future<void> _shareInvoiceDriveLink(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) async {
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

      final pdf = await _buildInvoicePdf(
        ref: ref,
        business: business,
        customer: customer,
        invoice: invoice,
        items: items,
        isGstEnabled: isGstEnabled,
        showBankDetails: showBankDetails,
      );
      final result = await GoogleDriveService.instance.uploadShareablePdf(
        pdf,
        '${invoice.invoiceNumber}.pdf',
        description: 'Invoice ${invoice.invoiceNumber}',
      );
      if (result.webViewLink != null) {
        await Clipboard.setData(ClipboardData(text: result.webViewLink!));
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result.webViewLink == null
                  ? 'Invoice uploaded to Drive.'
                  : 'Drive link copied for ${invoice.invoiceNumber}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload invoice to Drive: $e')),
        );
      }
    }
  }

  Future<void> _showTemplateSelector(
    BuildContext context,
    WidgetRef ref,
    Invoice invoice,
  ) async {
    final templates = await ref
        .read(templateConfigDaoProvider)
        .getTemplatesForBusiness(invoice.businessId, TemplateScope.invoice);

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
                trailing: invoice.templateId == null
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => Navigator.pop(ctx, -1),
              ),
              const Divider(height: 1),
              ...templates.map(
                (t) => ListTile(
                  title: Text(t.name),
                  leading: const Icon(Icons.description_outlined),
                  trailing: invoice.templateId == t.id
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
            .read(invoiceProvider)
            .updateInvoiceTemplate(invoice.id, newTemplateId);
        if (context.mounted) {
          ref.invalidate(invoiceDetailProvider(invoice.id));
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

  Future<Uint8List> _buildInvoicePdf({
    required WidgetRef ref,
    required Business business,
    required Customer customer,
    required Invoice invoice,
    required List<InvoiceItem> items,
    required bool isGstEnabled,
    required bool showBankDetails,
  }) async {
    final templateDao = ref.read(templateConfigDaoProvider);
    final template = invoice.templateId != null
        ? await templateDao.getTemplateById(invoice.templateId!)
        : (business.defaultInvoiceTemplateId != null
            ? await templateDao.getTemplateById(business.defaultInvoiceTemplateId!)
            : await templateDao.getDefaultTemplate(
                business.id,
                TemplateScope.invoice,
              ));

    return PdfService.generateInvoice(
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
  }
}

enum _PaymentEditActionKind { save, voidPayment, cancel }

class _PaymentEditAction {
  final _PaymentEditActionKind kind;
  final double? amount;
  final DateTime? paidAt;

  const _PaymentEditAction._(this.kind, {this.amount, this.paidAt});

  const _PaymentEditAction.voidPayment()
    : this._(_PaymentEditActionKind.voidPayment);
  const _PaymentEditAction.cancel() : this._(_PaymentEditActionKind.cancel);
  const _PaymentEditAction.save({double? amount, DateTime? paidAt})
    : this._(_PaymentEditActionKind.save, amount: amount, paidAt: paidAt);
}
