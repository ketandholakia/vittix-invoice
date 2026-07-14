import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/app_database.dart';
import '../../database/models/hsn_code_lookup.dart';
import '../../providers/business_provider.dart';
import '../../core/utils/money_formatter.dart';
import '../../providers/database_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../providers/uom_provider.dart';
import '../hsn_lookup/hsn_search_sheet.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  final Product? existingProduct;

  const ProductFormScreen({super.key, this.existingProduct});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _hsnSacController;
  late TextEditingController _salePriceController;
  late TextEditingController _gstRateController;
  late TextEditingController _stockQuantityController;

  bool _isService = false;
  String _unit = 'PCS';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingProduct?.name ?? '',
    );
    _hsnSacController = TextEditingController(
      text: widget.existingProduct?.hsnSac ?? '',
    );
    _salePriceController = TextEditingController(
      text: widget.existingProduct?.salePrice.toString() ?? '',
    );
    _gstRateController = TextEditingController(
      text: widget.existingProduct?.gstRate.toString() ?? '',
    );
    _stockQuantityController = TextEditingController(
      text: widget.existingProduct?.stockQuantity.toString() ?? '0',
    );
    _isService = widget.existingProduct?.isService ?? false;
    _unit = widget.existingProduct?.unit ?? 'PCS';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _hsnSacController.dispose();
    _salePriceController.dispose();
    _gstRateController.dispose();
    _stockQuantityController.dispose();
    super.dispose();
  }

  Future<void> _showHsnLookup() async {
    final HsnCodeLookup? selected = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => HsnSearchSheet(asOf: DateTime.now()),
    );

    if (selected != null) {
      setState(() {
        _hsnSacController.text = selected.code;
        if (selected.gstRate != null) {
          _gstRateController.text = selected.gstRate!.toStringAsFixed(1);
        }
        _isService = selected.type == 'SAC';
      });
    }
  }

  Future<void> _syncGstRateFromHsn() async {
    final hsnCode = _hsnSacController.text.trim();
    if (hsnCode.isEmpty) return;

    final lookup = await ref.read(hsnDaoProvider).getHsnCodeByCode(
      hsnCode,
      asOf: DateTime.now(),
    );
    final rate = lookup?.gstRate;
    if (rate != null) {
      _gstRateController.text = rate.toStringAsFixed(1);
    }
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    final activeBusinessId = ref.read(activeBusinessIdProvider);
    if (activeBusinessId == null) return;

    setState(() => _isLoading = true);

    final isGstEnabled = ref.read(isGstEnabledProvider);
    if (isGstEnabled) {
      await _syncGstRateFromHsn();
    }
    final parsedGstRate = isGstEnabled
        ? double.tryParse(_gstRateController.text.trim()) ?? 0.0
        : 0.0;

    final companion = ProductsCompanion(
      businessId: drift.Value(activeBusinessId),
      name: drift.Value(_nameController.text.trim()),
      hsnSac: drift.Value(isGstEnabled ? _hsnSacController.text.trim() : ''),
      unit: drift.Value(_unit),
      salePrice: drift.Value(double.parse(_salePriceController.text.trim())),
      gstRate: drift.Value(parsedGstRate),
      stockQuantity: drift.Value(
        double.parse(_stockQuantityController.text.trim()),
      ),
      isService: drift.Value(_isService),
      createdAt: drift.Value(DateTime.now()),
    );

    final notifier = ref.read(productProvider);

    try {
      if (widget.existingProduct == null) {
        await notifier.addProduct(companion);
      } else {
        await notifier.updateProduct(
          widget.existingProduct!.copyWith(
            name: _nameController.text.trim(),
            hsnSac: isGstEnabled ? _hsnSacController.text.trim() : '',
            unit: _unit,
            salePrice: double.parse(_salePriceController.text.trim()),
            gstRate: parsedGstRate,
            stockQuantity: double.parse(_stockQuantityController.text.trim()),
            isService: _isService,
          ),
        );
      }

      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/products');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving product: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGstEnabled = ref.watch(isGstEnabledProvider);
    final currencyCode =
        ref.watch(activeBusinessProvider).valueOrNull?.currencyCode ?? 'INR';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingProduct == null
              ? 'Add Product/Service'
              : 'Edit Product',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: const Text('Is this a Service?'),
                value: _isService,
                onChanged: (val) => setState(() => _isService = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _isService ? 'Service Name *' : 'Product Name *',
                  border: const OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (isGstEnabled) ...[
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _hsnSacController,
                        decoration: const InputDecoration(
                          labelText: 'HSN/SAC *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) =>
                            val == null || val.isEmpty ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      onPressed: _showHsnLookup,
                      icon: const Icon(Icons.search),
                      tooltip: 'Lookup HSN/SAC',
                    ),
                    const SizedBox(width: 8),
                    IconButton.filledTonal(
                      onPressed: () => context.push(
                        '/hsn-rates?code=${Uri.encodeComponent(_hsnSacController.text.trim())}',
                      ),
                      icon: const Icon(Icons.history),
                      tooltip: 'Rate history',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
              DropdownButtonFormField<String>(
                initialValue: _unit,
                decoration: const InputDecoration(
                  labelText: 'Unit *',
                  border: OutlineInputBorder(),
                ),
                items: unitItems,
                onChanged: (val) {
                  if (val != null) setState(() => _unit = val);
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Required';
                  if (double.tryParse(val) == null) {
                    return 'Invalid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: InputDecoration(
                        labelText: 'Sale Price *',
                        border: const OutlineInputBorder(),
                        prefixText: '${currencySymbol(currencyCode)} ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Required';
                        if (double.tryParse(val) == null) {
                          return 'Invalid number';
                        }
                        return null;
                      },
                    ),
                  ),
                  if (isGstEnabled) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _gstRateController,
                        decoration: const InputDecoration(
                          labelText: 'GST Rate % *',
                          border: OutlineInputBorder(),
                          suffixText: '%',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Required';
                          if (double.tryParse(val) == null) {
                            return 'Invalid rate';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _saveProduct,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
