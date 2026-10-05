import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';
import '../../../core/utils/formatting.dart';
import '../../../core/utils/money_formatter.dart';
import '../../../core/utils/invoice_balance.dart';
import '../../../core/utils/billing_mode.dart';
import '../../../core/utils/invoice_status.dart';
import '../../../core/utils/recurrence.dart';
import '../../../database/app_database.dart';
import '../../../models/invoice_template_config.dart';
import '../../../services/google_drive_service.dart';
import '../../../services/invoice_service.dart';
import '../../../services/pdf_service.dart';
import '../../../services/share_service.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/customer_detail_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../database/tables/template_configs.dart';

class InvoicePreviewScreen extends ConsumerWidget {
  final int invoiceId;

  const InvoicePreviewScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final invoiceAsync = ref.watch(invoiceDetailProvider(invoiceId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Preview'),
        actions: invoiceAsync.maybeWhen(
          data: (invoice) => invoice == null
              ? const []
              : [
                  _DeleteInvoiceAction(invoice: invoice),
                  _EditInvoiceAction(invoice: invoice),
                  _RecordPaymentAction(invoice: invoice, invoiceId: invoiceId),
                  _RecordRefundAction(invoice: invoice),
                  _ShareDriveLinkAction(invoice: invoice),
                  _ChangeTemplateAction(invoice: invoice),
                  _StatusMenuAction(invoice: invoice),
                  _CreateNoteAction(invoice: invoice),
                  _RecurringAction(invoice: invoice),
                ],
          orElse: () => const [],
        ),
      ),
      body: invoiceAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _ErrorRetry(
          onRetry: () => ref.invalidate(invoiceDetailProvider(invoiceId)),
        ),
        data: (invoice) {
          if (invoice == null) {
            return const Center(child: Text('Invoice not found'));
          }
          return _InvoicePreviewBody(invoiceId: invoiceId, invoice: invoice);
        },
      ),
    );
  }
}

class _ErrorRetry extends StatelessWidget {
  final VoidCallback onRetry;

  const _ErrorRetry({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48),
          const SizedBox(height: 12),
          const Text('Failed to load invoice'),
          const SizedBox(height: 12),
          FilledButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _DeleteInvoiceAction extends ConsumerWidget {
  final Invoice invoice;

  const _DeleteInvoiceAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canDelete = invoice.status == 'DRAFT';
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
  }
}

class _EditInvoiceAction extends ConsumerWidget {
  final Invoice invoice;

  const _EditInvoiceAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.status != 'DRAFT') {
      return const SizedBox.shrink();
    }
    return IconButton(
      icon: const Icon(Icons.edit),
      tooltip: 'Edit Invoice',
      onPressed: () => context.push('/edit-invoice', extra: invoice),
    );
  }
}

class _RecordPaymentAction extends ConsumerWidget {
  final Invoice invoice;
  final int invoiceId;

  const _RecordPaymentAction({required this.invoice, required this.invoiceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.status == 'PAID' || invoice.status == 'CANCELLED') {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.payment),
      tooltip: 'Record Payment',
      onPressed: () async {
        final draft = await _showRecordPaymentDialog(
          context,
          initialAmount: invoiceBalanceDue(invoice),
        );
        if (draft == null) return;

        final notifier = ref.read(invoiceProvider);
        try {
          await notifier.recordPayment(
            invoiceId,
            draft.amount,
            paidAt: draft.paidAt,
            mode: draft.mode,
            reference: draft.reference,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment recorded successfully!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to record payment: $e')),
            );
          }
        }
      },
    );
  }
}

class _RecordRefundAction extends ConsumerWidget {
  final Invoice invoice;

  const _RecordRefundAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.amountPaid <= 0 || invoice.status == 'CANCELLED') {
      return const SizedBox.shrink();
    }

    return IconButton(
      icon: const Icon(Icons.undo),
      tooltip: 'Record Refund',
      onPressed: () async {
        final draft = await _showRefundDialog(
          context,
          initialAmount: invoice.amountPaid,
        );
        if (draft == null) return;

        try {
          await ref.read(invoiceProvider).recordRefund(
            invoiceId: invoice.id,
            refundAmount: draft.amount,
            paidAt: draft.paidAt,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refund recorded successfully!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to record refund: $e')),
            );
          }
        }
      },
    );
  }
}

class _ShareDriveLinkAction extends ConsumerWidget {
  final Invoice invoice;

  const _ShareDriveLinkAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.link),
      tooltip: 'Upload Drive Link',
      onPressed: () => _shareInvoiceDriveLink(context, ref, invoice),
    );
  }
}

class _ChangeTemplateAction extends ConsumerWidget {
  final Invoice invoice;

  const _ChangeTemplateAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.style),
      tooltip: 'Change Template',
      onPressed: () => _showTemplateSelector(context, ref, invoice),
    );
  }
}

class _StatusMenuAction extends ConsumerWidget {
  final Invoice invoice;

  const _StatusMenuAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.status == 'PAID' || invoice.status == 'CANCELLED') {
      return const SizedBox.shrink();
    }
    return PopupMenuButton<String>(
      onSelected: (value) async {
        try {
          await ref.read(invoiceProvider).updateInvoiceStatus(invoice.id, value);
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
        PopupMenuItem(value: 'CANCELLED', child: Text('Mark Cancelled')),
      ],
    );
  }
}

class _CreateNoteAction extends ConsumerWidget {
  final Invoice invoice;

  const _CreateNoteAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canAdjust =
        invoice.status != 'DRAFT' &&
        invoice.status != 'CANCELLED' &&
        !isAdjustmentNote(invoice.invoiceType);
    if (!canAdjust) return const SizedBox.shrink();

    return PopupMenuButton<String>(
      icon: const Icon(Icons.note_add_outlined),
      tooltip: 'Raise credit / debit note',
      onSelected: (value) async {
        try {
          final service = ref.read(invoiceProvider);
          final noteId = value == InvoiceService.creditNoteType
              ? await service.createCreditNote(invoice.id)
              : await service.createDebitNote(invoice.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value == InvoiceService.creditNoteType
                      ? 'Credit note created as a draft.'
                      : 'Debit note created as a draft.',
                ),
              ),
            );
            await context.push('/invoice-preview/$noteId');
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to create note: $e')),
            );
          }
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: InvoiceService.creditNoteType,
          child: Text('Credit note'),
        ),
        PopupMenuItem(
          value: InvoiceService.debitNoteType,
          child: Text('Debit note'),
        ),
      ],
    );
  }
}

class _RecurringAction extends ConsumerWidget {
  final Invoice invoice;

  const _RecurringAction({required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (invoice.status == 'DRAFT' || isAdjustmentNote(invoice.invoiceType)) {
      return const SizedBox.shrink();
    }

    final recurrence = ref.watch(invoiceRecurrenceProvider(invoice.id));
    return recurrence.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (active) => active == null
          ? IconButton(
              icon: const Icon(Icons.repeat),
              tooltip: 'Make recurring',
              onPressed: () => _start(context, ref),
            )
          : IconButton(
              icon: const Icon(Icons.stop_circle_outlined),
              tooltip:
                  'Repeats ${recurrenceFrequencyFromCode(active.frequency).label.toLowerCase()} — tap to stop',
              onPressed: () async {
                await ref
                    .read(recurringInvoiceProvider)
                    .stopRecurrence(active.id);
                ref.invalidate(invoiceRecurrenceProvider(invoice.id));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Recurring stopped.')),
                  );
                }
              },
            ),
    );
  }

  Future<void> _start(BuildContext context, WidgetRef ref) async {
    final frequency = await showDialog<RecurrenceFrequency>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Repeat this invoice'),
        children: [
          for (final value in RecurrenceFrequency.values)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, value),
              child: Text(value.label),
            ),
        ],
      ),
    );
    if (frequency == null) return;

    try {
      await ref
          .read(recurringInvoiceProvider)
          .startRecurrence(invoiceId: invoice.id, frequency: frequency);
      ref.invalidate(invoiceRecurrenceProvider(invoice.id));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'This invoice now repeats ${frequency.label.toLowerCase()}.',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to make it recurring: $e')),
        );
      }
    }
  }
}

class _InvoicePreviewBody extends ConsumerWidget {
  final int invoiceId;
  final Invoice invoice;

  const _InvoicePreviewBody({required this.invoiceId, required this.invoice});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showBankDetails = ref.watch(printBankDetailsOnInvoiceProvider);
    final businessAsync = ref.watch(businessDetailProvider(invoice.businessId));
    final isGstEnabled = chargesGstForBusiness(
      businessAsync.valueOrNull?.businessType,
      gstFeaturesEnabled: ref.watch(isGstEnabledProvider),
    );
    final customerAsync = ref.watch(customerDetailProvider(invoice.customerId));
    final itemsAsync = ref.watch(invoiceItemsProvider(invoice.id));
    final paymentsAsync = ref.watch(invoicePaymentsProvider(invoiceId));

    if (businessAsync.hasError || customerAsync.hasError || itemsAsync.hasError) {
      return _ErrorRetry(
        onRetry: () {
          ref.invalidate(businessDetailProvider(invoice.businessId));
          ref.invalidate(customerDetailProvider(invoice.customerId));
          ref.invalidate(invoiceItemsProvider(invoice.id));
        },
      );
    }

    final business = businessAsync.valueOrNull;
    final customer = customerAsync.valueOrNull;
    final items = itemsAsync.valueOrNull;
    if (business == null || customer == null || items == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final reminderText = _buildInvoiceReminder(
      business: business,
      customer: customer,
      invoice: invoice,
    );

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: ListTile(
            title: Text(
              isAdjustmentNote(invoice.invoiceType)
                  ? '${invoice.invoiceType == InvoiceService.creditNoteType ? 'Credit note' : 'Debit note'} | Status: ${invoice.status}'
                  : 'Status: ${invoice.status}',
            ),
            subtitle: Text(
              'Paid: ${formatMoney(invoice.amountPaid, currencyCode: invoice.currencyCode)}'
              ' | Balance: ${formatMoney(invoiceBalanceDue(invoice), currencyCode: invoice.currencyCode)}'
              '${invoiceOverpaidAmount(invoice) > 0 ? ' | Overpaid: ${formatMoney(invoiceOverpaidAmount(invoice), currencyCode: invoice.currencyCode)}' : ''}'
              '${invoice.dueDate != null ? ' | Due: ${formatDate(invoice.dueDate!)}' : ''}',
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                switch (value) {
                  case 'copy':
                    await Clipboard.setData(ClipboardData(text: reminderText));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reminder copied.')),
                      );
                    }
                    return;
                  case 'share':
                    await ShareService.shareText(
                      reminderText,
                      subject: 'Payment Reminder: ${invoice.invoiceNumber}',
                    );
                    return;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'copy', child: Text('Copy Reminder')),
                PopupMenuItem(value: 'share', child: Text('Share Reminder')),
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
                text: 'Please find invoice ${invoice.invoiceNumber} attached.',
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
                          [
                            payment.kind == 'REFUND'
                                ? 'Refund'
                                : payment.kind == 'VOID'
                                    ? 'Voided'
                                    : 'Payment',
                            formatDateTime(payment.paidAt),
                            if (payment.mode != null) payment.mode!,
                            if (payment.reference != null) payment.reference!,
                          ].join(' | '),
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) =>
                Center(child: Text('Payment history error: $err')),
          ),
        ),
      ],
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
      '${invoice.dueDate != null ? ' The due date is ${formatDate(invoice.dueDate!)}.' : ''}'
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
        content: const Text('Voided payments cannot be edited or voided again.'),
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

  final amountController = TextEditingController(text: payment.amount.toStringAsFixed(2));
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
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount Paid'),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Paid On'),
              subtitle: Text(formatDate(paidAt)),
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
            onPressed: () => Navigator.pop(ctx, _PaymentEditAction.voidPayment),
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
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Share a public Drive link?'),
      content: const Text(
        'The invoice PDF will be uploaded to Google Drive with an "anyone '
        'with the link" permission. It contains your GSTIN, address and any '
        'bank or UPI details printed on the invoice. Only continue if you '
        'intend to share it.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Upload & share'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

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
    final isGstEnabled = chargesGstForBusiness(
      business?.businessType,
      gstFeaturesEnabled: ref.read(isGstEnabledProvider),
    );
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
          action: result.webViewLink == null
              ? null
              : SnackBarAction(
                  label: 'Revoke link',
                  onPressed: () async {
                    try {
                      await GoogleDriveService.instance.revokePublicAccess(
                        fileId: result.fileId,
                        permissionId: result.publicPermissionId,
                      );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Public link revoked.'),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to revoke link: $e'),
                          ),
                        );
                      }
                    }
                  },
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

/// Values collected by the payment/refund dialogs.
class _PaymentDraft {
  final double amount;
  final DateTime paidAt;
  final String? mode;
  final String? reference;

  const _PaymentDraft({
    required this.amount,
    required this.paidAt,
    this.mode,
    this.reference,
  });
}

const _paymentModes = ['CASH', 'UPI', 'BANK', 'CARD', 'OTHER'];

Future<_PaymentDraft?> _showRecordPaymentDialog(
  BuildContext context, {
  required double initialAmount,
}) async {
  final amountController =
      TextEditingController(text: initialAmount.toStringAsFixed(2));
  final referenceController = TextEditingController();
  var paidAt = DateTime.now();
  var mode = _paymentModes.first;
  String? error;

  final result = await showDialog<_PaymentDraft>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Record Payment'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount Paid',
                  errorText: error,
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: const InputDecoration(labelText: 'Mode'),
                items: [
                  for (final m in _paymentModes)
                    DropdownMenuItem(value: m, child: Text(m)),
                ],
                onChanged: (value) => setState(() => mode = value ?? mode),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference (UPI / cheque no.)',
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Paid On'),
                subtitle: Text(formatDate(paidAt)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: paidAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => paidAt = picked);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                setState(() => error = 'Enter a valid amount');
                return;
              }
              final reference = referenceController.text.trim();
              Navigator.pop(
                ctx,
                _PaymentDraft(
                  amount: amount,
                  paidAt: paidAt,
                  mode: mode,
                  reference: reference.isEmpty ? null : reference,
                ),
              );
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  amountController.dispose();
  referenceController.dispose();
  return result;
}

Future<_PaymentDraft?> _showRefundDialog(
  BuildContext context, {
  required double initialAmount,
}) async {
  final amountController =
      TextEditingController(text: initialAmount.toStringAsFixed(2));
  var paidAt = DateTime.now();
  String? error;

  final result = await showDialog<_PaymentDraft>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: const Text('Record Refund'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Refund Amount',
                  errorText: error,
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Refunded On'),
                subtitle: Text(formatDate(paidAt)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: paidAt,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => paidAt = picked);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text.trim());
              if (amount == null || amount <= 0) {
                setState(() => error = 'Enter a valid amount');
                return;
              }
              Navigator.pop(ctx, _PaymentDraft(amount: amount, paidAt: paidAt));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  amountController.dispose();
  return result;
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