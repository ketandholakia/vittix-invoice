import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' as drift;
import '../../database/app_database.dart';
import '../../providers/customer_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../core/utils/gstin_validator.dart';
import '../../core/constants/gst_states.dart';

class CustomerFormScreen extends ConsumerStatefulWidget {
  final Customer? existingCustomer;

  const CustomerFormScreen({super.key, this.existingCustomer});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _gstinController;
  late TextEditingController _panController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  int? _stateCode;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.existingCustomer?.name ?? '',
    );
    _gstinController = TextEditingController(
      text: widget.existingCustomer?.gstin ?? '',
    );
    _panController = TextEditingController(
      text: widget.existingCustomer?.pan ?? '',
    );
    _addressController = TextEditingController(
      text: widget.existingCustomer?.address ?? '',
    );
    _cityController = TextEditingController(
      text: widget.existingCustomer?.city ?? '',
    );
    _phoneController = TextEditingController(
      text: widget.existingCustomer?.phone ?? '',
    );
    _emailController = TextEditingController(
      text: widget.existingCustomer?.email ?? '',
    );
    _stateCode = widget.existingCustomer?.stateCode;

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
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    final activeBusinessId = ref.read(activeBusinessIdProvider);
    if (activeBusinessId == null) return;

    setState(() => _isLoading = true);

    final isGstEnabled = ref.read(isGstEnabledProvider);

    final companion = CustomersCompanion(
      businessId: drift.Value(activeBusinessId),
      name: drift.Value(_nameController.text.trim()),
      gstin: drift.Value(
        (isGstEnabled && _gstinController.text.trim().isNotEmpty)
            ? _gstinController.text.trim().toUpperCase()
            : null,
      ),
      pan: drift.Value(
        _panController.text.trim().isNotEmpty
            ? _panController.text.trim().toUpperCase()
            : null,
      ),
      address: drift.Value(
        _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
      ),
      city: drift.Value(
        _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
      ),
      phone: drift.Value(
        _phoneController.text.trim().isNotEmpty
            ? _phoneController.text.trim()
            : null,
      ),
      email: drift.Value(
        _emailController.text.trim().isNotEmpty
            ? _emailController.text.trim()
            : null,
      ),
      stateCode: drift.Value(isGstEnabled ? _stateCode : null),
      createdAt: drift.Value(DateTime.now()),
    );

    final notifier = ref.read(customerProvider);

    try {
      if (widget.existingCustomer == null) {
        await notifier.addCustomer(companion);
      } else {
        await notifier.updateCustomer(
          widget.existingCustomer!.copyWith(
            name: _nameController.text.trim(),
            gstin: drift.Value(
              (isGstEnabled && _gstinController.text.trim().isNotEmpty)
                  ? _gstinController.text.trim().toUpperCase()
                  : null,
            ),
            pan: drift.Value(
              _panController.text.trim().isNotEmpty
                  ? _panController.text.trim().toUpperCase()
                  : null,
            ),
            address: drift.Value(
              _addressController.text.trim().isNotEmpty
                  ? _addressController.text.trim()
                  : null,
            ),
            city: drift.Value(
              _cityController.text.trim().isNotEmpty
                  ? _cityController.text.trim()
                  : null,
            ),
            phone: drift.Value(
              _phoneController.text.trim().isNotEmpty
                  ? _phoneController.text.trim()
                  : null,
            ),
            email: drift.Value(
              _emailController.text.trim().isNotEmpty
                  ? _emailController.text.trim()
                  : null,
            ),
            stateCode: drift.Value(isGstEnabled ? _stateCode : null),
          ),
        );
      }

      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/customers');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving customer: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isGstEnabled = ref.watch(isGstEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingCustomer == null ? 'Add Customer' : 'Edit Customer',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              if (isGstEnabled) ...[
                TextFormField(
                  controller: _gstinController,
                  decoration: const InputDecoration(
                    labelText: 'GSTIN (Optional for B2C)',
                    border: OutlineInputBorder(),
                    helperText: 'State code will be auto-detected',
                  ),
                  textCapitalization: TextCapitalization.characters,
                  validator: (val) {
                    if (val != null && val.isNotEmpty) {
                      if (!GstinValidator.isValid(val)) {
                        return 'Invalid GSTIN format';
                      }
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
                controller: _panController,
                decoration: const InputDecoration(
                  labelText: 'PAN Number (Optional)',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.characters,
                maxLength: 10,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  final trimmed = val?.trim() ?? '';
                  if (trimmed.isEmpty) return null;
                  if (!trimmed.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _isLoading ? null : _saveCustomer,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
