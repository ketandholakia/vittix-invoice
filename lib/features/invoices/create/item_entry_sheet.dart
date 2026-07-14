import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../../database/app_database.dart';
import '../../../database/models/hsn_code_lookup.dart';
import '../../../core/utils/gst_calculator.dart';
import '../../hsn_lookup/hsn_search_sheet.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/database_provider.dart';
import '../../../providers/product_provider.dart';
import '../../../providers/shared_preferences_provider.dart';
import '../../../providers/uom_provider.dart';
import '../../../core/utils/form_validators.dart';

class ItemEntrySheet extends ConsumerStatefulWidget {
  final InvoiceItemsCompanion? existingItem;
  final bool isInterState;
  final DateTime? hsnLookupDate;

  const ItemEntrySheet({
    super.key,
    this.existingItem,
    required this.isInterState,
    this.hsnLookupDate,
  });

  @override
  ConsumerState<ItemEntrySheet> createState() => _ItemEntrySheetState();
}

class _ItemEntrySheetState extends ConsumerState<ItemEntrySheet> {
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
      text: widget.existingItem?.name.value ?? '',
    );
    _hsnSacController = TextEditingController(
      text: widget.existingItem?.hsnSac.value ?? '',
    );
    _qtyController = TextEditingController(
      text: widget.existingItem?.quantity.value.toString() ?? '1',
    );
    _rateController = TextEditingController(
      text: widget.existingItem?.rate.value.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.existingItem?.discountPct.value.toString() ?? '0',
    );
    _gstRateController = TextEditingController(
      text: widget.existingItem?.gstRate.value.toString() ?? '',
    );
    _unit = widget.existingItem?.unit.value ?? 'PCS';
    _selectedProductId = widget.existingItem?.productId.value;
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
      if (selected.gstRate != null) {
        _gstRateController.text = selected.gstRate!.toStringAsFixed(1);
      }
    });
  }

  Future<void> _syncGstRateFromHsn() async {
    if (_hsnSacController.text.trim().isEmpty) return;

    final lookup = await ref
        .read(hsnDaoProvider)
        .getHsnCodeByCode(
          _hsnSacController.text.trim(),
          asOf: widget.hsnLookupDate,
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
    final discountAmount = gross * (discount / 100);
    final taxable = gross - discountAmount;

    final breakdown = GstCalculator.calculate(
      taxableAmount: taxable,
      gstRate: gstRate,
      isInterState: widget.isInterState,
    );

    final item = InvoiceItemsCompanion(
      productId: drift.Value(_selectedProductId),
      name: drift.Value(_nameController.text),
      hsnSac: drift.Value(isGstEnabled ? _hsnSacController.text : ''),
      unit: drift.Value(_unit),
      quantity: drift.Value(qty),
      rate: drift.Value(rate),
      discountPct: drift.Value(discount),
      taxableAmount: drift.Value(taxable),
      gstRate: drift.Value(gstRate),
      cgstRate: drift.Value(widget.isInterState ? 0 : gstRate / 2),
      sgstRate: drift.Value(widget.isInterState ? 0 : gstRate / 2),
      igstRate: drift.Value(widget.isInterState ? gstRate : 0),
      cgstAmount: drift.Value(breakdown.cgst),
      sgstAmount: drift.Value(breakdown.sgst),
      igstAmount: drift.Value(breakdown.igst),
      cessAmount: drift.Value(breakdown.cess),
      totalAmount: drift.Value(breakdown.total),
    );

    Navigator.of(context).pop(item);
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
                      decoration: const InputDecoration(
                        labelText: 'Rate *',
                        prefixText: 'Rs. ',
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
