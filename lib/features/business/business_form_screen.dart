import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:drift/drift.dart' as drift;

import '../../core/utils/gstin_validator.dart';
import '../../database/app_database.dart';
import '../../providers/business_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../core/constants/gst_states.dart';
import '../../database/tables/businesses.dart';

class BusinessFormScreen extends ConsumerStatefulWidget {
  final Business? existingBusiness;

  const BusinessFormScreen({super.key, this.existingBusiness});

  @override
  ConsumerState<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends ConsumerState<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _bankNameController;
  late TextEditingController _bankAccountController;
  late TextEditingController _bankIfscController;
  late TextEditingController _upiIdController;

  int? _stateCode;
  bool _isLoading = false;
  String? _logoPath;
  int? _brandColor;
  String _currencyCode = 'INR';
  late BusinessType _businessType;

  static const List<String> _currencyCodes = [
    'INR',
    'USD',
    'EUR',
    'GBP',
    'AED',
    'SGD',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingBusiness?.name ?? '',
    );
    _gstinController = TextEditingController(
      text: widget.existingBusiness?.gstin ?? '',
    );
    _panController = TextEditingController(
      text: widget.existingBusiness?.pan ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingBusiness?.address ?? '',
    );
    _cityController = TextEditingController(
      text: widget.existingBusiness?.city ?? '',
    );
    _bankNameController = TextEditingController(
      text: widget.existingBusiness?.bankName ?? '',
    );
    _bankAccountController = TextEditingController(
      text: widget.existingBusiness?.bankAccount ?? '',
    );
    _bankIfscController = TextEditingController(
      text: widget.existingBusiness?.bankIfsc ?? '',
    );
    _upiIdController = TextEditingController(
      text: widget.existingBusiness?.upiId ?? '',
    );
    _stateCode = widget.existingBusiness?.stateCode;
    _logoPath = widget.existingBusiness?.logoPath;
    _brandColor = widget.existingBusiness?.brandColor;
    _currencyCode = widget.existingBusiness?.currencyCode ?? 'INR';
    _businessType =
        widget.existingBusiness?.businessType ?? BusinessType.gstRegistered;

    _gstinController.addListener(_onGstinChanged);
  }

  void _onGstinChanged() {
    final gstin = _gstinController.text.trim().toUpperCase();
    if (gstin.length >= 2) {
      final code = GstinValidator.extractStateCode(gstin);
      if (code != null && GstStates.states.containsKey(code)) {
        setState(() {
          _stateCode = code;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _gstinController.dispose();
    _panController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _bankNameController.dispose();
    _bankAccountController.dispose();
    _bankIfscController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _logoPath = image.path);
    }
  }

  void _pickColor() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a brand color'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: _brandColor != null
                  ? Color(_brandColor!)
                  : Theme.of(context).primaryColor,
              onColorChanged: (Color color) {
                setState(() => _brandColor = color.toARGB32());
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveBusiness() async {
    if (!_formKey.currentState!.validate()) return;

    if (_businessType != BusinessType.unregistered && _stateCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid State Code from GSTIN')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final companion =
        BusinessesCompanion.insert(
          name: _nameController.text.trim(),
          gstin: _businessType != BusinessType.unregistered
              ? _gstinController.text.trim().toUpperCase()
              : '',
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          stateCode: _businessType != BusinessType.unregistered
              ? (_stateCode ?? 0)
              : 0,
          createdAt: DateTime.now(),
        ).copyWith(
          name: drift.Value(_nameController.text.trim()),
          pan: drift.Value(_panController.text.trim().toUpperCase()),
          address: drift.Value(_addressController.text.trim()),
          city: drift.Value(_cityController.text.trim()),
          stateCode: drift.Value(
            _businessType != BusinessType.unregistered ? (_stateCode ?? 0) : 0,
          ),
          logoPath: drift.Value(_logoPath),
          brandColor: drift.Value(_brandColor),
          businessType: drift.Value(_businessType),
          currencyCode: drift.Value(_currencyCode),
          bankName: drift.Value(
            _bankNameController.text.trim().isEmpty
                ? null
                : _bankNameController.text.trim(),
          ),
          bankAccount: drift.Value(
            _bankAccountController.text.trim().isEmpty
                ? null
                : _bankAccountController.text.trim(),
          ),
          bankIfsc: drift.Value(
            _bankIfscController.text.trim().isEmpty
                ? null
                : _bankIfscController.text.trim().toUpperCase(),
          ),
          upiId: drift.Value(
            _upiIdController.text.trim().isEmpty
                ? null
                : _upiIdController.text.trim(),
          ),
        );

    final notifier = ref.read(businessProvider);
    try {
      if (widget.existingBusiness == null) {
        final id = await notifier.addBusiness(companion);

        final activeId = ref.read(activeBusinessIdProvider);
        if (activeId == null) {
          ref.read(activeBusinessIdProvider.notifier).setActiveBusinessId(id);
          if (mounted) context.go('/dashboard');
        } else {
          if (mounted) context.pop();
        }
      } else {
        final updatedBusiness = widget.existingBusiness!.copyWith(
          name: _nameController.text.trim(),
          gstin: _businessType != BusinessType.unregistered
              ? _gstinController.text.trim().toUpperCase()
              : '',
          pan: drift.Value(_panController.text.trim().toUpperCase()),
          businessType: _businessType,
          address: _addressController.text.trim(),
          city: _cityController.text.trim(),
          stateCode: _businessType != BusinessType.unregistered
              ? (_stateCode ?? 0)
              : 0,
          logoPath: drift.Value(_logoPath),
          brandColor: drift.Value(_brandColor),
          currencyCode: _currencyCode,
          bankName: drift.Value(
            _bankNameController.text.trim().isEmpty
                ? null
                : _bankNameController.text.trim(),
          ),
          bankAccount: drift.Value(
            _bankAccountController.text.trim().isEmpty
                ? null
                : _bankAccountController.text.trim(),
          ),
          bankIfsc: drift.Value(
            _bankIfscController.text.trim().isEmpty
                ? null
                : _bankIfscController.text.trim().toUpperCase(),
          ),
          upiId: drift.Value(
            _upiIdController.text.trim().isEmpty
                ? null
                : _upiIdController.text.trim(),
          ),
          invoiceSeriesFormat: widget.existingBusiness!.invoiceSeriesFormat,
          quoteSeriesFormat: widget.existingBusiness!.quoteSeriesFormat,
        );
        await notifier.updateBusiness(updatedBusiness);
        if (mounted) context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving business: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingBusiness == null ? 'Add Business' : 'Edit Business',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: _pickLogo,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: _logoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(_logoPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Icon(
                                Icons.add_a_photo,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Brand Color'),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _pickColor,
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: _brandColor != null
                                  ? Color(_brandColor!)
                                  : Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<BusinessType>(
                initialValue: _businessType,
                decoration: const InputDecoration(
                  labelText: 'Business Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: BusinessType.gstRegistered,
                    child: Text('GST Registered'),
                  ),
                  DropdownMenuItem(
                    value: BusinessType.unregistered,
                    child: Text('Unregistered'),
                  ),
                  DropdownMenuItem(
                    value: BusinessType.compositionScheme,
                    child: Text('Composition Scheme'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _businessType = val;
                      if (val == BusinessType.unregistered) {
                        _gstinController.clear();
                        _stateCode = null;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              if (_businessType != BusinessType.unregistered) ...[
                TextFormField(
                  controller: _gstinController,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN *',
                    border: OutlineInputBorder(),
                    helperText: 'State code will be auto-detected',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Required';
                    if (!GstinValidator.isValid(val)) {
                      return 'Invalid GSTIN format';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                if (_stateCode != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Text(
                      'Detected State: ${GstStates.getStateName(_stateCode!)} ($_stateCode)',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
              ],
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Business Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _currencyCode,
                decoration: const InputDecoration(
                  labelText: 'Currency',
                  border: OutlineInputBorder(),
                ),
                items: _currencyCodes
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _currencyCode = val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _panController,
                decoration: InputDecoration(
                  labelText: _businessType == BusinessType.unregistered
                      ? 'PAN Number *'
                      : 'PAN Number (Optional)',
                  border: const OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
                validator: (val) {
                  if (_businessType == BusinessType.unregistered) {
                    if (val == null || val.isEmpty) {
                      return 'Required for Unregistered business';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankNameController,
                decoration: const InputDecoration(
                  labelText: 'Bank Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankAccountController,
                decoration: const InputDecoration(
                  labelText: 'Bank Account Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bankIfscController,
                decoration: const InputDecoration(
                  labelText: 'Bank IFSC',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  labelText: 'UPI ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _saveBusiness,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Business'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
