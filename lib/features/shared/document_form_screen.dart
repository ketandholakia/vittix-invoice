import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../database/app_database.dart';
import '../../providers/business_provider.dart';
import '../../providers/customer_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../core/utils/document_totals.dart';
import '../../core/utils/formatting.dart';
import '../../core/utils/gst_supply.dart';
import '../../core/utils/money.dart';

String? _trimmedOrNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String _rateText(double? rate) =>
    (rate == null || rate == 0) ? '' : rate.toString();

double _parseRate(String value) {
  final parsed = double.tryParse(value.trim());
  return (parsed == null || parsed < 0) ? 0 : parsed;
}

/// Per-item tax component sums used when building the document companion.
typedef ItemTotals = LineTotals;

/// Shared create/edit form scaffolding for invoice and quote documents.
/// Subclasses supply the document-specific seams: labels, companion
/// construction, save dispatch and the customer summary card.
abstract class DocumentFormScreenState<W extends ConsumerStatefulWidget, D, C, IC>
    extends ConsumerState<W> {  Customer? selectedCustomer;
  final List<IC> items = [];
  late final TextEditingController notesController;
  late final TextEditingController termsController;
  late final TextEditingController shipToNameController;
  late final TextEditingController shipToAddressController;
  late final TextEditingController shipToCityController;
  bool isInterState = false;
  bool isLoading = false;
  bool reverseCharge = false;

  /// AUTO derives the supply type from the customer; the others pin it.
  String supplyCategory = 'AUTO';
  bool exportWithLut = false;

  late final TextEditingController tdsSectionController;
  late final TextEditingController tdsRateController;
  late final TextEditingController tcsSectionController;
  late final TextEditingController tcsRateController;
  DateTime documentDate = DateTime.now();
  DateTime? endDate;

  // ---- seams ----

  D? get existingDocument;

  String get documentNoun;

  String get dateLabel;

  String get endDateLabel;

  String get listRoute;

  String get saveErrorPrefix;

  void seedFromExisting(D document);

  ({String? notes, String? terms}) notesAndTermsOf(D document);

  /// Ship-to details carried by [document] (blank when there are none).
  ({String? name, String? address, String? city}) shippingOf(D document);

  /// Whether [document] is marked as a reverse-charge supply.
  bool reverseChargeOf(D document);

  /// Supply category and export/LUT declaration carried by [document].
  ({String supplyType, bool exportWithLut}) supplyDeclarationOf(D document);

  /// TDS/TCS sections and rates carried by [document].
  ({String? tdsSection, double tdsRate, String? tcsSection, double tcsRate})
  taxesAtSourceOf(D document);

  Future<Customer?> loadCustomer(D document);

  Future<List<IC>> loadItemCompanions(D document);

  Future<IC?> showItemSheet({IC? existing});

  ItemTotals totalsOf(IC item);

  /// Rebuilds [item] with its tax split recomputed from its taxable amount and
  /// GST rate for the current supply type. Invoked on save so the stored
  /// per-line CGST/SGST/IGST always agrees with the document's `isIgst` flag.
  ///
  /// [zeroRate] drops the tax entirely (an export/SEZ supply under LUT).
  IC recomputeItemTax(
    IC item, {
    required bool isInterState,
    bool zeroRate = false,
  });

  String itemListTitle(IC item);

  String itemListSubtitle(IC item, String currencyCode);

  String documentNumberLabel(D document);

  C buildCompanion({
    required int businessId,
    required Customer customer,
    required String currencyCode,
    required bool isGstEnabled,
    required String supplyType,
    required int placeOfSupply,
    required double subtotal,
    required double discount,
    required double taxable,
    required double cgst,
    required double sgst,
    required double igst,
    required double cess,
    required double roundOff,
    required double grandTotal,
    required bool reverseCharge,
    required String? shipToName,
    required String? shipToAddress,
    required String? shipToCity,
    required bool exportWithLut,
    required String? tdsSection,
    required double tdsRate,
    required double tdsAmount,
    required String? tcsSection,
    required double tcsRate,
    required double tcsAmount,
  });

  Future<void> saveDocument({
    required C companion,
    required List<IC> items,
    required D? existing,
  });

  Widget buildCustomerSummaryCard(Customer customer, String currencyCode);

  // ---- shared flow ----

  @override
  void initState() {
    super.initState();
    final document = existingDocument;
    final seed = document == null ? null : notesAndTermsOf(document);
    notesController = TextEditingController(text: seed?.notes ?? '');
    termsController = TextEditingController(text: seed?.terms ?? '');
    final shipping = document == null ? null : shippingOf(document);
    shipToNameController = TextEditingController(text: shipping?.name ?? '');
    shipToAddressController = TextEditingController(
      text: shipping?.address ?? '',
    );
    shipToCityController = TextEditingController(text: shipping?.city ?? '');
    reverseCharge = document != null && reverseChargeOf(document);
    final declaration = document == null
        ? null
        : supplyDeclarationOf(document);
    supplyCategory = declaration?.supplyType ?? 'AUTO';
    exportWithLut = declaration?.exportWithLut ?? false;
    final atSource = document == null ? null : taxesAtSourceOf(document);
    tdsSectionController = TextEditingController(
      text: atSource?.tdsSection ?? '',
    );
    tdsRateController = TextEditingController(
      text: _rateText(atSource?.tdsRate),
    );
    tcsSectionController = TextEditingController(
      text: atSource?.tcsSection ?? '',
    );
    tcsRateController = TextEditingController(
      text: _rateText(atSource?.tcsRate),
    );
    if (document != null) {
      seedFromExisting(document);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingData(document);
      });
    }
  }

  Future<void> _loadExistingData(D document) async {
    final loadedItems = await loadItemCompanions(document);
    final customer = await loadCustomer(document);
    if (!mounted) return;
    setState(() {
      if (customer != null) {
        selectedCustomer = customer;
      }
      items
        ..clear()
        ..addAll(loadedItems);
    });
  }

  @override
  void dispose() {
    notesController.dispose();
    termsController.dispose();
    shipToNameController.dispose();
    shipToAddressController.dispose();
    shipToCityController.dispose();
    tdsSectionController.dispose();
    tdsRateController.dispose();
    tcsSectionController.dispose();
    tcsRateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isEndDate}) async {
    final initialDate = isEndDate
        ? (endDate ?? documentDate.add(const Duration(days: 7)))
        : documentDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;

    setState(() {
      if (isEndDate) {
        endDate = picked;
      } else {
        documentDate = picked;
        if (endDate != null && endDate!.isBefore(documentDate)) {
          endDate = documentDate;
        }
      }
    });
  }

  Future<void> _addItem() async {
    final newItem = await showItemSheet();
    if (newItem != null) {
      setState(() {
        items.add(newItem);
      });
    }
  }

  Future<void> _editItem(int index) async {
    final updatedItem = await showItemSheet(existing: items[index]);
    if (updatedItem != null) {
      setState(() {
        items[index] = updatedItem;
      });
    }
  }

  void _removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void _updateSupplyType(Business? business, Customer? customer, bool isGst) {
    if (!isGst || business == null || customer == null) {
      isInterState = false;
      return;
    }

    final state = customerStateCode(customer);
    if (state == null) {
      isInterState = false;
      return;
    }

    isInterState = business.stateCode != state;
  }

  Future<void> _save() async {
    if (isLoading) return;

    if (selectedCustomer == null || items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select customer and add items')),
      );
      return;
    }

    // Disable the button before the first await so a double tap cannot create
    // two documents.
    setState(() => isLoading = true);

    final activeBusiness = await ref.read(activeBusinessProvider.future);
    if (activeBusiness == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Select an active business first')),
        );
        setState(() => isLoading = false);
      }
      return;
    }

    final isGstEnabled = ref.read(isGstEnabledProvider);
    final currencyCode = activeBusiness.currencyCode;
    _updateSupplyType(activeBusiness, selectedCustomer, isGstEnabled);

    final effectiveSupplyType = supplyCategory == 'AUTO'
        ? deriveSupplyType(selectedCustomer!)
        : supplyCategory;
    // An export/SEZ supply declared under LUT is zero-rated: no IGST is charged.
    final zeroRated =
        exportWithLut &&
        (effectiveSupplyType == 'EXPORT' || effectiveSupplyType == 'SEZ');

    // Lines capture their tax split when they are added, so if the customer is
    // changed afterwards the stored CGST/SGST/IGST would disagree with the
    // document's isIgst flag. Rebuild every line against the current supply
    // type before totalling so the document and its lines always agree.
    final normalizedItems = [
      for (final item in items)
        recomputeItemTax(
          item,
          isInterState: isInterState,
          zeroRate: zeroRated,
        ),
    ];

    final activeBusinessId = ref.read(activeBusinessIdProvider)!;

    final lineTotals = [for (final item in normalizedItems) totalsOf(item)];
    final tdsRate = _parseRate(tdsRateController.text);
    final tcsRate = _parseRate(tcsRateController.text);
    final baseTotals = computeDocumentTotals(lineTotals);
    final totals = computeDocumentTotals(
      lineTotals,
      tdsAmount: round2(baseTotals.taxable * tdsRate / 100),
      tcsAmount: round2(baseTotals.taxable * tcsRate / 100),
      applyRoundOff: ref.read(roundOffEnabledProvider),
    );

    final companion = buildCompanion(
      businessId: activeBusinessId,
      customer: selectedCustomer!,
      currencyCode: currencyCode,
      isGstEnabled: isGstEnabled,
      supplyType: effectiveSupplyType,
      exportWithLut: exportWithLut,
      placeOfSupply: derivePlaceOfSupply(selectedCustomer!, activeBusiness),
      subtotal: totals.subtotal,
      discount: totals.discount,
      taxable: totals.taxable,
      cgst: totals.cgst,
      sgst: totals.sgst,
      igst: totals.igst,
      cess: totals.cess,
      roundOff: totals.roundOff,
      grandTotal: totals.grandTotal,
      reverseCharge: reverseCharge,
      shipToName: _trimmedOrNull(shipToNameController.text),
      shipToAddress: _trimmedOrNull(shipToAddressController.text),
      shipToCity: _trimmedOrNull(shipToCityController.text),
      tdsSection: _trimmedOrNull(tdsSectionController.text),
      tdsRate: tdsRate,
      tdsAmount: totals.tdsAmount,
      tcsSection: _trimmedOrNull(tcsSectionController.text),
      tcsRate: tcsRate,
      tcsAmount: totals.tcsAmount,
    );

    try {
      await saveDocument(
        companion: companion,
        items: normalizedItems,
        existing: existingDocument,
      );
      if (!mounted) return;
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(listRoute);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save $saveErrorPrefix: $e')),
        );
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);
    final activeBusinessAsync = ref.watch(activeBusinessProvider);
    final document = existingDocument;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          document == null ? 'Create $documentNoun' : 'Edit $documentNoun',
        ),
      ),
      body: customersAsync.when(
        data: (customers) {
          final activeBusiness = activeBusinessAsync.valueOrNull;
          final currencyCode = activeBusiness?.currencyCode ?? 'INR';
          final isGstEnabled = ref.watch(isGstEnabledProvider);

          return Column(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                    DropdownButtonFormField<Customer>(
                      decoration: const InputDecoration(
                        labelText: 'Select Customer',
                      ),
                      initialValue: selectedCustomer,
                      items: customers
                          .map(
                            (c) =>
                                DropdownMenuItem(value: c, child: Text(c.name)),
                          )
                          .toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedCustomer = val;
                          _updateSupplyType(activeBusiness, val, isGstEnabled);
                        });
                      },
                    ),
                    if (selectedCustomer != null) ...[
                      const SizedBox(height: 12),
                      buildCustomerSummaryCard(selectedCustomer!, currencyCode),
                    ],
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: supplyCategory,
                      decoration: const InputDecoration(
                        labelText: 'Supply type',
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'AUTO',
                          child: Text('Automatic'),
                        ),
                        DropdownMenuItem(value: 'B2B', child: Text('B2B')),
                        DropdownMenuItem(value: 'B2C', child: Text('B2C')),
                        DropdownMenuItem(
                          value: 'EXPORT',
                          child: Text('Export'),
                        ),
                        DropdownMenuItem(value: 'SEZ', child: Text('SEZ unit')),
                      ],
                      onChanged: (value) =>
                          setState(() => supplyCategory = value ?? 'AUTO'),
                    ),
                    if (supplyCategory == 'EXPORT' || supplyCategory == 'SEZ')
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Under LUT'),
                        subtitle: const Text(
                          'Supply without payment of IGST (Letter of Undertaking)',
                        ),
                        value: exportWithLut,
                        onChanged: (value) =>
                            setState(() => exportWithLut = value),
                      ),
                    const SizedBox(height: 12),
                    if (document != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(documentNumberLabel(document)),
                      ),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(dateLabel),
                            subtitle: Text(
                              formatDate(documentDate),
                            ),
                            onTap: () => _pickDate(isEndDate: false),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(endDateLabel),
                            subtitle: Text(
                              endDate == null
                                  ? 'Not set'
                                  : formatDate(endDate!),
                            ),
                            onTap: () => _pickDate(isEndDate: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: termsController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Terms',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Reverse charge'),
                      subtitle: const Text(
                        'Tax payable by the recipient (RCM)',
                      ),
                      value: reverseCharge,
                      onChanged: (value) =>
                          setState(() => reverseCharge = value),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Ship to (optional)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: shipToNameController,
                      decoration: const InputDecoration(
                        labelText: 'Ship-to name',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: shipToAddressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Ship-to address',
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: shipToCityController,
                      decoration: const InputDecoration(
                        labelText: 'Ship-to city',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'TDS / TCS (optional)',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tdsSectionController,
                            decoration: const InputDecoration(
                              labelText: 'TDS section',
                              hintText: '194J',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: tdsRateController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            decoration: const InputDecoration(
                              labelText: 'TDS %',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: tcsSectionController,
                            decoration: const InputDecoration(
                              labelText: 'TCS section',
                              hintText: '206C(1H)',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: tcsRateController,
                            keyboardType:
                                const TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                            decoration: const InputDecoration(
                              labelText: 'TCS %',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return ListTile(
                      title: Text(itemListTitle(item)),
                      subtitle: Text(
                        itemListSubtitle(item, currencyCode),
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
                        onPressed: isLoading ? null : _save,
                        icon: const Icon(Icons.save),
                        label: Text(
                          isLoading
                              ? 'Saving...'
                              : (document == null
                                    ? 'Save $documentNoun'
                                    : 'Update $documentNoun'),
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
