import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/app_database.dart';
import '../../database/models/hsn_code_lookup.dart';
import '../../core/utils/gst_calculator.dart';
import '../hsn_lookup/hsn_search_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/database_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../providers/uom_provider.dart';
import '../../core/utils/form_validators.dart';
import '../../core/utils/money.dart';
import '../../core/utils/money_formatter.dart';

/// Parsed, tax-computed fields of a line item, shared by the invoice and
/// quote item entry sheets.
class ItemEntryData {
  final int? productId;
  final String name;
  final String hsnSac;
  final String unit;
  final double quantity;
  final double rate;
  final double discountPct;
  final double taxableAmount;
  final double gstRate;
  final double cgstRate;
  final double sgstRate;
  final double igstRate;
  final double cessRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalAmount;

  const ItemEntryData({
    this.productId,
    required this.name,
    required this.hsnSac,
    required this.unit,
    required this.quantity,
    required this.rate,
    required this.discountPct,
    required this.taxableAmount,
    required this.gstRate,
    required this.cgstRate,
    required this.sgstRate,
    required this.igstRate,
    required this.cessRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalAmount,
  });

  factory ItemEntryData.fromInvoiceItemCompanion(InvoiceItemsCompanion item) {
    return ItemEntryData(
      productId: item.productId.value,
      name: item.name.value,
      hsnSac: item.hsnSac.value,
      unit: item.unit.value,
      quantity: item.quantity.value,
      rate: item.rate.value,
      discountPct: item.discountPct.value,
      taxableAmount: item.taxableAmount.value,
      gstRate: item.gstRate.value,
      cgstRate: item.cgstRate.value,
      sgstRate: item.sgstRate.value,
      igstRate: item.igstRate.value,
      cessRate: item.cessRate.value,
      cgstAmount: item.cgstAmount.value,
      sgstAmount: item.sgstAmount.value,
      igstAmount: item.igstAmount.value,
      cessAmount: item.cessAmount.value,
      totalAmount: item.totalAmount.value,
    );
  }

  factory ItemEntryData.fromQuoteItemCompanion(QuoteItemsCompanion item) {
    return ItemEntryData(
      productId: item.productId.value,
      name: item.name.value,
      hsnSac: item.hsnSac.value,
      unit: item.unit.value,
      quantity: item.quantity.value,
      rate: item.rate.value,
      discountPct: item.discountPct.value,
      taxableAmount: item.taxableAmount.value,
      gstRate: item.gstRate.value,
      cgstRate: item.cgstRate.value,
      sgstRate: item.sgstRate.value,
      igstRate: item.igstRate.value,
      cessRate: item.cessRate.value,
      cgstAmount: item.cgstAmount.value,
      sgstAmount: item.sgstAmount.value,
      igstAmount: item.igstAmount.value,
      cessAmount: item.cessAmount.value,
      totalAmount: item.totalAmount.value,
    );
  }
}

InvoiceItemsCompanion invoiceItemCompanionFromData(ItemEntryData data) {
  return InvoiceItemsCompanion(
    productId: drift.Value(data.productId),
    name: drift.Value(data.name),
    hsnSac: drift.Value(data.hsnSac),
    unit: drift.Value(data.unit),
    quantity: drift.Value(data.quantity),
    rate: drift.Value(data.rate),
    discountPct: drift.Value(data.discountPct),
    taxableAmount: drift.Value(data.taxableAmount),
    gstRate: drift.Value(data.gstRate),
    cgstRate: drift.Value(data.cgstRate),
    sgstRate: drift.Value(data.sgstRate),
    igstRate: drift.Value(data.igstRate),
    cessRate: drift.Value(data.cessRate),
    cgstAmount: drift.Value(data.cgstAmount),
    sgstAmount: drift.Value(data.sgstAmount),
    igstAmount: drift.Value(data.igstAmount),
    cessAmount: drift.Value(data.cessAmount),
    totalAmount: drift.Value(data.totalAmount),
  );
}

QuoteItemsCompanion quoteItemCompanionFromData(ItemEntryData data) {
  return QuoteItemsCompanion(
    productId: drift.Value(data.productId),
    name: drift.Value(data.name),
    hsnSac: drift.Value(data.hsnSac),
    unit: drift.Value(data.unit),
    quantity: drift.Value(data.quantity),
    rate: drift.Value(data.rate),
    discountPct: drift.Value(data.discountPct),
    taxableAmount: drift.Value(data.taxableAmount),
    gstRate: drift.Value(data.gstRate),
    cgstRate: drift.Value(data.cgstRate),
    sgstRate: drift.Value(data.sgstRate),
    igstRate: drift.Value(data.igstRate),
    cessRate: drift.Value(data.cessRate),
    cgstAmount: drift.Value(data.cgstAmount),
    sgstAmount: drift.Value(data.sgstAmount),
    igstAmount: drift.Value(data.igstAmount),
    cessAmount: drift.Value(data.cessAmount),
    totalAmount: drift.Value(data.totalAmount),
  );
}

/// Bottom-sheet form for adding/editing a line item. Shared by the invoice
/// and quote create/edit forms; [buildCompanion] maps the parsed fields to
/// the document-specific item companion type.
class ItemEntrySheet<C> extends ConsumerStatefulWidget {
  final ItemEntryData? existingItem;
  final bool isInterState;
  final DateTime? hsnLookupDate;
  final String currencyCode;
  final C Function(ItemEntryData data) buildCompanion;

  const ItemEntrySheet({
    super.key,
    this.existingItem,
    required this.isInterState,
    this.hsnLookupDate,
    this.currencyCode = 'INR',
    required this.buildCompanion,
  });

  @override
  ConsumerState<ItemEntrySheet<C>> createState() => _ItemEntrySheetState<C>();
}

class _ItemEntrySheetState<C> extends ConsumerState<ItemEntrySheet<C>> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _hsnSacController;
  late TextEditingController _qtyController;
  late TextEditingController _rateController;
  late TextEditingController _discountController;
  late TextEditingController _gstRateController;
  String _unit = 'PCS';
  int? _selectedProductId;
  Product? _selectedProduct;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingItem?.name ?? '',
    );
    _hsnSacController = TextEditingController(
      text: widget.existingItem?.hsnSac ?? '',
    );
    _qtyController = TextEditingController(
      text: widget.existingItem?.quantity.toString() ?? '1',
    );
    _rateController = TextEditingController(
      text: widget.existingItem?.rate.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.existingItem?.discountPct.toString() ?? '0',
    );
    _gstRateController = TextEditingController(
      text: widget.existingItem?.gstRate.toString() ?? '',
    );
    _unit = widget.existingItem?.unit ?? 'PCS';
    _selectedProductId = widget.existingItem?.productId;
  }

  void _applyProduct(Product product) {
    setState(() {
      _selectedProduct = product;
      _selectedProductId = product.id;
      _nameController.text = product.name;
      _hsnSacController.text = product.hsnSac;
      _rateController.text = product.salePrice.toString();
      _gstRateController.text = product.gstRate.toString();
      _unit = product.unit;
    });
  }

  Future<void> _showHsnLookup() async {
    final selected = await showModalBottomSheet<HsnCodeLookup>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => HsnSearchSheet(asOf: widget.hsnLookupDate),
    );

    if (selected == null) return;

    setState(() {
      _hsnSacController.text = selected.code;
    });
    // Resolve through the price-aware sync so a price-banded rule (such as the
    // Rs.2,500 garment threshold) selects the band matching this line.
    await _syncGstRateFromHsn();
  }

  Future<void> _syncGstRateFromHsn() async {
    if (_hsnSacController.text.trim().isEmpty) return;

    final unitPrice = double.tryParse(_rateController.text.trim());
    final lookup = await ref
        .read(hsnDaoProvider)
        .getHsnCodeByCode(
          _hsnSacController.text.trim(),
          asOf: widget.hsnLookupDate,
          unitPrice: unitPrice,
        );
    final rate = lookup?.gstRate;
    if (rate != null) {
      _gstRateController.text = rate.toStringAsFixed(1);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final qty = double.parse(_qtyController.text);
    final rate = double.parse(_rateController.text);
    final discount = double.parse(_discountController.text);
    final isGstEnabled = ref.read(isGstEnabledProvider);
    if (isGstEnabled) {
      await _syncGstRateFromHsn();
    }
    if (!mounted) return;
    final gstRate = isGstEnabled
        ? double.tryParse(_gstRateController.text.trim()) ?? 0.0
        : 0.0;

    final gross = qty * rate;
    final discountAmount = round2(gross * (discount / 100));
    final taxable = round2(gross - discountAmount);

    final cessRate =
        _selectedProduct?.cessRate ?? widget.existingItem?.cessRate ?? 0;
    final breakdown = GstCalculator.calculate(
      taxableAmount: taxable,
      gstRate: gstRate,
      isInterState: widget.isInterState,
      cessRate: cessRate,
    );

    final data = ItemEntryData(
      productId: _selectedProductId,
      name: _nameController.text,
      hsnSac: isGstEnabled ? _hsnSacController.text : '',
      unit: _unit,
      quantity: qty,
      rate: rate,
      discountPct: discount,
      taxableAmount: taxable,
      gstRate: gstRate,
      cgstRate: widget.isInterState ? 0 : gstRate / 2,
      sgstRate: widget.isInterState ? 0 : gstRate / 2,
      igstRate: widget.isInterState ? gstRate : 0,
      cessRate: cessRate,
      cgstAmount: breakdown.cgst,
      sgstAmount: breakdown.sgst,
      igstAmount: breakdown.igst,
      cessAmount: breakdown.cess,
      totalAmount: breakdown.total,
    );

    Navigator.of(context).pop(widget.buildCompanion(data));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnSacController.dispose();
    _qtyController.dispose();
    _rateController.dispose();
    _discountController.dispose();
    _gstRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isGstEnabled = ref.watch(isGstEnabledProvider);
    final productsAsync = ref.watch(productListProvider);
    final uoms = ref.watch(uomListProvider).valueOrNull ?? const <Uom>[];
    final unitItems = <DropdownMenuItem<String>>[
      if (uoms.every((uom) => uom.code != _unit))
        DropdownMenuItem(value: _unit, child: Text(_unit)),
      ...uoms.map(
        (uom) => DropdownMenuItem(
          value: uom.code,
          child: Text(
            uom.conversionFactor == 1.0 || uom.baseCode == null
                ? '${uom.name} (${uom.code})'
                : '${uom.name} (${uom.code}) = ${uom.conversionFactor} ${uom.baseCode}',
          ),
        ),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.existingItem == null
                    ? 'Add Line Item'
                    : 'Edit Line Item',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              productsAsync.when(
                data: (products) => DropdownButtonFormField<int?>(
                  initialValue: _selectedProductId,
                  decoration: const InputDecoration(labelText: 'Saved Product'),
                  items: [
                    const DropdownMenuItem<int?>(
                      value: null,
                      child: Text('Custom item'),
                    ),
                    ...products
                        .where((product) => product.isActive)
                        .map(
                          (product) => DropdownMenuItem<int?>(
                            value: product.id,
                            child: Text(product.name),
                          ),
                        ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      setState(() {
                        _selectedProductId = null;
                        _selectedProduct = null;
                      });
                      return;
                    }
                    final product = products.firstWhere(
                      (entry) => entry.id == value,
                    );
                    _applyProduct(product);
                  },
                ),
                loading: () => const SizedBox.shrink(),
                error: (err, stack) => const SizedBox.shrink(),
              ),
              if (ref.watch(lowStockWarningsEnabledProvider) &&
                  _selectedProduct != null &&
                  _selectedProduct!.stockQuantity <= 0 &&
                  !_selectedProduct!.isService)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'Warning: this product currently has zero stock.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Item Name *'),
                validator: (val) => val!.isEmpty ? 'Required' : null,
              ),
              if (isGstEnabled) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hsnSacController,
                        decoration: const InputDecoration(
                          labelText: 'HSN/SAC *',
                        ),
                        validator: (val) => val!.isEmpty ? 'Required' : null,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _showHsnLookup,
                    ),
                  ],
                ),
              ],
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _qtyController,
                      decoration: const InputDecoration(
                        labelText: 'Quantity *',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) =>
                          FormValidators.requiredPositiveNumber(val, 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: unitItems,
                      onChanged: (val) => setState(() => _unit = val!),
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _rateController,
                      decoration: InputDecoration(
                        labelText: 'Rate *',
                        prefixText: currencySymbol(widget.currencyCode),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) => FormValidators.requiredPositiveNumber(val, 'Rate'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) =>
                          FormValidators.optionalPercentageValidator(val, 'Discount'),
                    ),
                  ),
                ],
              ),
              if (isGstEnabled) ...[
                TextFormField(
                  controller: _gstRateController,
                  decoration: const InputDecoration(labelText: 'GST Rate % *'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: (val) => FormValidators.percentageValidator(val, 'GST rate'),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _save,
                child: Text(
                  widget.existingItem == null ? 'Add Item' : 'Save Item',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
