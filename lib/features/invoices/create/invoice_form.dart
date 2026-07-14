import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../core/utils/invoice_balance.dart';
import '../../../database/app_database.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/quote_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../core/utils/amount_in_words.dart';
import '../../../core/utils/money_formatter.dart';
import 'item_entry_sheet.dart';

class InvoiceFormScreen extends ConsumerStatefulWidget {
  final Invoice? existingInvoice;

  const InvoiceFormScreen({super.key, this.existingInvoice});

  @override
  ConsumerState<InvoiceFormScreen> createState() => _InvoiceFormScreenState();
}

class _InvoiceFormScreenState extends ConsumerState<InvoiceFormScreen> {
  Customer? _selectedCustomer;
  final List<InvoiceItemsCompanion> _items = [];
  late final TextEditingController _notesController;
  late final TextEditingController _termsController;
  bool _isInterState = false;
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  bool _isLoading = false;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.existingInvoice?.notes ?? '',
    );
    _termsController = TextEditingController(
      text: widget.existingInvoice?.terms ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isDueDate}) async {
    final initialDate = isDueDate
        ? (_dueDate ?? _invoiceDate.add(const Duration(days: 7)))
        : _invoiceDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isDueDate) {
        _dueDate = picked;
      } else {
        _invoiceDate = picked;
        if (_dueDate != null && _dueDate!.isBefore(_invoiceDate)) {
          _dueDate = _invoiceDate;
        }
      }
    });
  }

  void _addItem() async {
    final newItem = await showModalBottomSheet<InvoiceItemsCompanion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemEntrySheet(
        isInterState: _isInterState,
        hsnLookupDate: _invoiceDate,
      ),
    );

    if (newItem != null) {
      setState(() {
        _items.add(newItem);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final updatedItem = await showModalBottomSheet<InvoiceItemsCompanion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ItemEntrySheet(
        isInterState: _isInterState,
        existingItem: _items[index],
        hsnLookupDate: _invoiceDate,
      ),
    );

    if (updatedItem != null) {
      setState(() {
        _items[index] = updatedItem;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  void _updateSupplyType(Business? business, Customer? customer, bool isGst) {
    if (!isGst || business == null || customer?.stateCode == null) {
      _isInterState = false;
      return;
    }

    _isInterState = business.stateCode != customer!.stateCode;
  }

  void _saveInvoice() async {
    if (_selectedCustomer == null || _items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select customer and add items')),
      );
      return;
    }

    final activeBusiness = await ref.read(activeBusinessProvider.future);
    if (activeBusiness == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select an active business first')),
        );
      }
      return;
    }

    final isGstEnabled = ref.read(isGstEnabledProvider);
    final currencyCode = activeBusiness.currencyCode;
    _updateSupplyType(activeBusiness, _selectedCustomer, isGstEnabled);
    final activeBusinessId = ref.read(activeBusinessIdProvider)!;
    setState(() => _isLoading = true);

    double taxable = 0;
    double cgst = 0;
    double sgst = 0;
    double igst = 0;
    double cess = 0;

    for (final item in _items) {
      taxable += item.taxableAmount.value;
      cgst += item.cgstAmount.value;
      sgst += item.sgstAmount.value;
      igst += item.igstAmount.value;
      cess += item.cessAmount.value;
    }

    final grandTotal = taxable + cgst + sgst + igst + cess;

    final invoice = InvoicesCompanion.insert(
      businessId: activeBusinessId,
      customerId: _selectedCustomer!.id,
      invoiceNumber: 'PENDING',
      invoiceDate: _invoiceDate,
      dueDate: drift.Value(_dueDate),
      invoiceType: isGstEnabled ? 'TAX_INVOICE' : 'INVOICE',
      supplyType: 'B2B',
      placeOfSupply: _selectedCustomer!.stateCode ?? 0,
      subtotal: taxable, // Simplified
      taxableAmount: taxable,
      totalAmount: grandTotal,
      cgstAmount: drift.Value(cgst),
      sgstAmount: drift.Value(sgst),
      igstAmount: drift.Value(igst),
      cessAmount: drift.Value(cess),
      amountInWords: drift.Value(AmountInWords.convert(grandTotal)),
      notes: drift.Value(
        _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      ),
      terms: drift.Value(
        _termsController.text.trim().isEmpty
            ? null
            : _termsController.text.trim(),
      ),
      isIgst: drift.Value(_isInterState),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).copyWith(currencyCode: drift.Value(currencyCode));

    try {
      if (widget.existingInvoice == null) {
        await ref.read(invoiceProvider).createInvoiceWithItems(invoice, _items);
      } else {
        await ref
            .read(invoiceProvider)
            .updateInvoiceWithItems(widget.existingInvoice!, invoice, _items);
      }
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/invoices');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save invoice: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final activeBusinessAsync = ref.watch(activeBusinessProvider);
    final existingInvoice = widget.existingInvoice;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          existingInvoice == null ? 'Create Invoice' : 'Edit Invoice',
        ),
      ),
      body: customersAsync.when(
        data: (customers) {
          final activeBusiness = activeBusinessAsync.valueOrNull;
          final currencyCode = activeBusiness?.currencyCode ?? 'INR';
          final isGstEnabled = ref.watch(isGstEnabledProvider);
          if (!_hasInitialized && existingInvoice != null) {
            _hasInitialized = true;
            _invoiceDate = existingInvoice.invoiceDate;
            _dueDate = existingInvoice.dueDate;
            _selectedCustomer = customers.cast<Customer?>().firstWhere(
              (customer) => customer?.id == existingInvoice.customerId,
              orElse: () => null,
            );
            _isInterState = existingInvoice.isIgst;
            Future.microtask(() async {
              final existingItems = await ref
                  .read(invoiceDaoProvider)
                  .getItemsForInvoice(existingInvoice.id);
              if (!mounted) return;
              setState(() {
                _items
                  ..clear()
                  ..addAll(
                    existingItems.map(
                      (item) => InvoiceItemsCompanion(
                        productId: drift.Value(item.productId),
                        name: drift.Value(item.name),
                        hsnSac: drift.Value(item.hsnSac),
                        unit: drift.Value(item.unit),
                        quantity: drift.Value(item.quantity),
                        rate: drift.Value(item.rate),
                        discountPct: drift.Value(item.discountPct),
                        taxableAmount: drift.Value(item.taxableAmount),
                        gstRate: drift.Value(item.gstRate),
                        cgstRate: drift.Value(item.cgstRate),
                        sgstRate: drift.Value(item.sgstRate),
                        igstRate: drift.Value(item.igstRate),
                        cessRate: drift.Value(item.cessRate),
                        cgstAmount: drift.Value(item.cgstAmount),
                        sgstAmount: drift.Value(item.sgstAmount),
                        igstAmount: drift.Value(item.igstAmount),
                        cessAmount: drift.Value(item.cessAmount),
                        totalAmount: drift.Value(item.totalAmount),
                        sortOrder: drift.Value(item.sortOrder),
                      ),
                    ),
                  );
              });
            });
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(
                        labelText: 'Select Customer',
                      ),
                      initialValue: _selectedCustomer,
                      items: customers
                          .map(
                            (c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCustomer = val;
                          _updateSupplyType(activeBusiness, val, isGstEnabled);
                        });
                      },
                    ),
                    if (_selectedCustomer != null) ...[
                      const SizedBox(height: 12),
                      Builder(
                        builder: (context) {
                          final invoices = ref
                              .watch(invoiceListProvider)
                              .valueOrNull;
                          final quotes = ref
                              .watch(quoteListProvider)
                              .valueOrNull;
                          if (invoices == null || quotes == null) {
                            return const SizedBox.shrink();
                          }

                          final customerInvoices = invoices
                              .where(
                                (invoice) =>
                                    invoice.customerId == _selectedCustomer!.id,
                              )
                              .toList();
                          final customerQuotes = quotes
                              .where(
                                (quote) =>
                                    quote.customerId == _selectedCustomer!.id,
                              )
                              .toList();
                          final outstanding = customerInvoices.fold<double>(
                            0,
                            (sum, invoice) => sum + invoiceBalanceDue(invoice),
                          );
                          final lastInvoice = customerInvoices.isEmpty
                              ? null
                              : (customerInvoices.toList()..sort(
                                      (a, b) => b.invoiceDate.compareTo(
                                        a.invoiceDate,
                                      ),
                                    ))
                                    .first;

                          return Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              title: Text(_selectedCustomer!.name),
                              subtitle: Text(
                                'Invoices: ${customerInvoices.length} | Quotes: ${customerQuotes.length}'
                                '${lastInvoice != null ? ' | Last: ${lastInvoice.invoiceNumber}' : ''}',
                              ),
                              trailing: Text(
                                formatMoney(outstanding, currencyCode: currencyCode),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (existingInvoice != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Invoice No: ${existingInvoice.invoiceNumber}',
                        ),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Invoice Date'),
                            subtitle: Text(
                              _invoiceDate.toLocal().toString().split(' ')[0],
                            ),
                            onTap: () => _pickDate(isDueDate: false),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Due Date'),
                            subtitle: Text(
                              _dueDate?.toLocal().toString().split(' ')[0] ??
                                  'Not set',
                            ),
                            onTap: () => _pickDate(isDueDate: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _termsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Terms',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, i) {
                    final item = _items[i];
                    return ListTile(
                      title: Text(item.name.value),
                      subtitle: Text(
                        'Qty: ${item.quantity.value} | Total: ${formatMoney(item.totalAmount.value, currencyCode: currencyCode)}',
                      ),
                      onTap: () => _editItem(i),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _removeItem(i),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add Item'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _isLoading ? null : _saveInvoice,
                        icon: const Icon(Icons.save),
                        label: Text(
                          _isLoading
                              ? 'Saving...'
                              : (existingInvoice == null
                                    ? 'Save Invoice'
                                    : 'Update Invoice'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
