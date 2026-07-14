import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/app_database.dart';
import '../../../providers/business_provider.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/invoice_provider.dart';
import '../../../providers/quote_provider.dart';
import '../../../providers/customer_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../core/utils/amount_in_words.dart';
import '../../../core/utils/money_formatter.dart';
import 'quote_item_entry_sheet.dart';

class QuoteFormScreen extends ConsumerStatefulWidget {
  final Quote? existingQuote;

  const QuoteFormScreen({super.key, this.existingQuote});

  @override
  ConsumerState<QuoteFormScreen> createState() => _QuoteFormScreenState();
}

class _QuoteFormScreenState extends ConsumerState<QuoteFormScreen> {
  Customer? _selectedCustomer;
  final List<QuoteItemsCompanion> _items = [];
  late final TextEditingController _notesController;
  late final TextEditingController _termsController;
  bool _isInterState = false;
  bool _isLoading = false;
  DateTime _quoteDate = DateTime.now();
  DateTime? _validUntilDate;
  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(
      text: widget.existingQuote?.notes ?? '',
    );
    _termsController = TextEditingController(
      text: widget.existingQuote?.terms ?? '',
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isValidUntil}) async {
    final initialDate = isValidUntil
        ? (_validUntilDate ?? _quoteDate.add(const Duration(days: 7)))
        : _quoteDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isValidUntil) {
        _validUntilDate = picked;
      } else {
        _quoteDate = picked;
        if (_validUntilDate != null && _validUntilDate!.isBefore(_quoteDate)) {
          _validUntilDate = _quoteDate;
        }
      }
    });
  }

  void _addItem() async {
    final newItem = await showModalBottomSheet<QuoteItemsCompanion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => QuoteItemEntrySheet(
        isInterState: _isInterState,
        hsnLookupDate: _quoteDate,
      ),
    );

    if (newItem != null) {
      setState(() {
        _items.add(newItem);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final updatedItem = await showModalBottomSheet<QuoteItemsCompanion>(
      context: context,
      isScrollControlled: true,
      builder: (context) => QuoteItemEntrySheet(
        isInterState: _isInterState,
        existingItem: _items[index],
        hsnLookupDate: _quoteDate,
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

  void _saveQuote() async {
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
    _updateSupplyType(activeBusiness, _selectedCustomer, isGstEnabled);
    final activeBusinessId = ref.read(activeBusinessIdProvider)!;
    final currencyCode = activeBusiness.currencyCode;
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

    final quote = QuotesCompanion.insert(
      businessId: activeBusinessId,
      customerId: _selectedCustomer!.id,
      invoiceNumber: 'PENDING',
      invoiceDate: _quoteDate,
      dueDate: drift.Value(_validUntilDate),
      invoiceType: 'QUOTE', // Hardcoded as QUOTE
      supplyType: 'B2B',
      placeOfSupply: _selectedCustomer!.stateCode ?? 0,
      subtotal: taxable,
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
      if (widget.existingQuote == null) {
        await ref.read(quoteProvider).createQuoteWithItems(quote, _items);
      } else {
        await ref
            .read(quoteProvider)
            .updateQuoteWithItems(widget.existingQuote!, quote, _items);
      }
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/quotes');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to save quote: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final activeBusinessAsync = ref.watch(activeBusinessProvider);
    final existingQuote = widget.existingQuote;

    return Scaffold(
      appBar: AppBar(
        title: Text(existingQuote == null ? 'Create Quote' : 'Edit Quote'),
      ),
      body: customersAsync.when(
        data: (customers) {
          final activeBusiness = activeBusinessAsync.valueOrNull;
          final currencyCode = activeBusiness?.currencyCode ?? 'INR';
          final isGstEnabled = ref.watch(isGstEnabledProvider);
          if (!_hasInitialized && existingQuote != null) {
            _hasInitialized = true;
            _quoteDate = existingQuote.invoiceDate;
            _validUntilDate = existingQuote.dueDate;
            _selectedCustomer = customers.cast<Customer?>().firstWhere(
              (customer) => customer?.id == existingQuote.customerId,
              orElse: () => null,
            );
            _isInterState = existingQuote.isIgst;
            Future.microtask(() async {
              final existingItems = await ref
                  .read(quoteDaoProvider)
                  .getItemsForQuote(existingQuote.id);
              if (!mounted) return;
              setState(() {
                _items
                  ..clear()
                  ..addAll(
                    existingItems.map(
                      (item) => QuoteItemsCompanion(
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
                          final quotes = ref
                              .watch(quoteListProvider)
                              .valueOrNull;
                          final invoices = ref
                              .watch(invoiceListProvider)
                              .valueOrNull;
                          if (quotes == null || invoices == null) {
                            return const SizedBox.shrink();
                          }

                          final customerQuotes = quotes
                              .where(
                                (quote) =>
                                    quote.customerId == _selectedCustomer!.id,
                              )
                              .toList();
                          final customerInvoices = invoices
                              .where(
                                (invoice) =>
                                    invoice.customerId == _selectedCustomer!.id,
                              )
                              .toList();
                          final convertedCount = customerQuotes
                              .where((quote) => quote.status == 'CONVERTED')
                              .length;
                          final lastQuote = customerQuotes.isEmpty
                              ? null
                              : (customerQuotes.toList()..sort(
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
                                'Quotes: ${customerQuotes.length} | Converted: $convertedCount'
                                '${lastQuote != null ? ' | Last: ${lastQuote.invoiceNumber}' : ''}',
                              ),
                              trailing: Text(
                                'Invoices ${customerInvoices.length}',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                    const SizedBox(height: 12),
                    if (existingQuote != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Quote No: ${existingQuote.invoiceNumber}'),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Quote Date'),
                            subtitle: Text(
                              _quoteDate.toLocal().toString().split(' ')[0],
                            ),
                            onTap: () => _pickDate(isValidUntil: false),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Valid Until'),
                            subtitle: Text(
                              _validUntilDate?.toLocal().toString().split(
                                    ' ',
                                  )[0] ??
                                  'Not set',
                            ),
                            onTap: () => _pickDate(isValidUntil: true),
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
                        onPressed: _isLoading ? null : _saveQuote,
                        icon: const Icon(Icons.save),
                        label: Text(
                          _isLoading
                              ? 'Saving...'
                              : (existingQuote == null
                                    ? 'Save Quote'
                                    : 'Update Quote'),
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
