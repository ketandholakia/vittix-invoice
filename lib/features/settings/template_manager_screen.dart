import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:printing/printing.dart';

import '../../database/app_database.dart';
import '../../database/tables/template_configs.dart';
import '../../database/tables/businesses.dart';
import '../../models/invoice_template_config.dart';
import '../../providers/business_provider.dart';
import '../../providers/database_provider.dart';
import '../../providers/shared_preferences_provider.dart';
import '../../services/pdf_service.dart';
import 'template_editor_screen.dart';

class TemplateManagerScreen extends ConsumerStatefulWidget {
  const TemplateManagerScreen({super.key});

  @override
  ConsumerState<TemplateManagerScreen> createState() =>
      _TemplateManagerScreenState();
}

class _TemplateManagerScreenState extends ConsumerState<TemplateManagerScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  TemplateScope _scope = TemplateScope.invoice;
  TemplateConfig? _selectedTemplate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeBusinessAsync = ref.watch(activeBusinessProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Template Settings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Settings'), Tab(text: 'Preview')],
        ),
      ),
      body: activeBusinessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Select a business first.'));
          }

          return FutureBuilder<List<TemplateConfig>>(
            future: ref
                .read(templateConfigDaoProvider)
                .getTemplatesForBusiness(business.id, _scope),
            builder: (context, snapshot) {
              final templates = snapshot.data ?? const <TemplateConfig>[];
              _selectedTemplate ??= templates.isNotEmpty ? templates.first : null;
              if (_selectedTemplate != null &&
                  !templates.any((t) => t.id == _selectedTemplate!.id)) {
                _selectedTemplate = templates.isNotEmpty ? templates.first : null;
              }

              return Column(
                children: [
                  Material(
                    color: Theme.of(context).colorScheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: SegmentedButton<TemplateScope>(
                        segments: const [
                          ButtonSegment(
                            value: TemplateScope.invoice,
                            label: Text('Invoice'),
                          ),
                          ButtonSegment(
                            value: TemplateScope.quote,
                            label: Text('Quote'),
                          ),
                        ],
                        selected: {_scope},
                        onSelectionChanged: (selected) {
                          setState(() {
                            _scope = selected.first;
                            _selectedTemplate = null;
                          });
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _SettingsTab(
                          businessId: business.id,
                          scope: _scope,
                          templates: templates,
                          selectedTemplate: _selectedTemplate,
                          onSelectTemplate: (template) {
                            setState(() => _selectedTemplate = template);
                          },
                          onChanged: () {
                            _clearTemplatePreviewCaches();
                            setState(() {});
                          },
                        ),
                        _PreviewTab(
                          businessId: business.id,
                          scope: _scope,
                          templates: templates,
                          selectedTemplate: _selectedTemplate,
                          onSelectTemplate: (template) {
                            setState(() => _selectedTemplate = template);
                          },
                          onChanged: () {
                            _clearTemplatePreviewCaches();
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Failed to load business: $err')),
      ),
    );
  }
}

class _SettingsTab extends ConsumerWidget {
  final int businessId;
  final TemplateScope scope;
  final List<TemplateConfig> templates;
  final TemplateConfig? selectedTemplate;
  final ValueChanged<TemplateConfig> onSelectTemplate;
  final VoidCallback onChanged;

  const _SettingsTab({
    required this.businessId,
    required this.scope,
    required this.templates,
    required this.selectedTemplate,
    required this.onSelectTemplate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Template Actions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => _openEditor(context, businessId, scope, null),
                icon: const Icon(Icons.add),
                label: const Text('Create Template'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: selectedTemplate == null
                    ? null
                    : () => _openEditor(
                          context,
                          businessId,
                          scope,
                          selectedTemplate!.id,
                        ),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Selected'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _ExpandableGroup(
          title: 'Templates',
          children: [
            for (final template in templates)
              ListTile(
                selected: selectedTemplate?.id == template.id,
                leading: Icon(
                  template.isDefault ? Icons.star : Icons.description_outlined,
                ),
                title: Text(template.name),
                subtitle: Text(
                  template.isDefault ? 'Default template' : 'Custom template',
                ),
                onTap: () => onSelectTemplate(template),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: template.isDefault
                          ? 'Default template'
                          : 'Set default',
                      onPressed: template.isDefault
                          ? null
                          : () async {
                              await _setTemplateDefault(
                                ref,
                                businessId,
                                scope,
                                template,
                              );
                              onChanged();
                            },
                      icon: Icon(
                        template.isDefault ? Icons.star : Icons.star_border,
                      ),
                    ),
                    IconButton(
                      tooltip: 'More actions',
                      onPressed: () => _showTemplateActions(
                        context,
                        ref,
                        businessId,
                        scope,
                        template,
                        onChanged,
                      ),
                      icon: const Icon(Icons.more_vert),
                    ),
                  ],
                ),
              ),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Add Template'),
              onTap: () => _openEditor(context, businessId, scope, null),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    int businessId,
    TemplateScope scope,
    int? templateId,
  ) async {
    final result = await context.push<bool>(
      '/template-editor',
      extra: TemplateEditorArgs(
        businessId: businessId,
        scope: scope,
        templateId: templateId,
      ),
    );
    if (result == true) {
      onChanged();
    }
  }

  Future<void> _showTemplateActions(
    BuildContext context,
    WidgetRef ref,
    int businessId,
    TemplateScope scope,
    TemplateConfig template,
    VoidCallback onChanged,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_outlined),
                title: const Text('Edit template'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _openEditor(context, businessId, scope, template.id);
                },
              ),
              ListTile(
                leading: const Icon(Icons.star_border),
                title: const Text('Set default'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await _setTemplateDefault(
                    ref,
                    businessId,
                    scope,
                    template,
                  );
                  onChanged();
                },
              ),
              ListTile(
                leading: const Icon(Icons.copy_outlined),
                title: const Text('Duplicate'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final config = InvoiceTemplateConfig.decode(
                    template.configJson,
                  ).copyWith(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    name: '${template.name} Copy',
                  );
                  await ref.read(templateConfigDaoProvider).insertTemplate(
                        TemplateConfigsCompanion.insert(
                          businessId: businessId,
                          scope: scope,
                          name: config.name,
                          configJson: config.encode(),
                          createdAt: DateTime.now(),
                          updatedAt: DateTime.now(),
                        ),
                      );
                  onChanged();
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('Delete'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  await ref.read(templateConfigDaoProvider).deleteTemplate(
                        template.id,
                      );
                  onChanged();
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _setTemplateDefault(
    WidgetRef ref,
    int businessId,
    TemplateScope scope,
    TemplateConfig template,
  ) async {
    final dao = ref.read(templateConfigDaoProvider);
    await dao.clearDefaultForScope(businessId, scope);
    await dao.updateTemplate(
      template.copyWith(
        isDefault: true,
        updatedAt: DateTime.now(),
      ),
    );

    final businessDao = ref.read(businessDaoProvider);
    final business = await businessDao.getBusinessById(businessId);
    if (business == null) return;

    final updatedBusiness = scope == TemplateScope.invoice
        ? business.copyWith(
            defaultInvoiceTemplateId: drift.Value<int?>(template.id),
          )
        : business.copyWith(
            defaultQuoteTemplateId: drift.Value<int?>(template.id),
          );
    await businessDao.updateBusiness(updatedBusiness);
    ref.invalidate(activeBusinessProvider);
    ref.invalidate(templateConfigDaoProvider);
  }
}

class _PreviewTab extends ConsumerWidget {
  final int businessId;
  final TemplateScope scope;
  final List<TemplateConfig> templates;
  final TemplateConfig? selectedTemplate;
  final ValueChanged<TemplateConfig> onSelectTemplate;
  final VoidCallback onChanged;

  const _PreviewTab({
    required this.businessId,
    required this.scope,
    required this.templates,
    required this.selectedTemplate,
    required this.onSelectTemplate,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final template = selectedTemplate ?? (templates.isNotEmpty ? templates.first : null);
    final config = template == null
        ? InvoiceTemplateConfig.defaults(
            id: 'preview',
            name: 'Preview',
            layoutFamily: 'CLASSIC',
          )
        : InvoiceTemplateConfig.decode(template.configJson);
    final businessAsync = ref.watch(activeBusinessProvider);
    final isGstEnabled = ref.watch(isGstEnabledProvider);
    final showBankDetails = ref.watch(printBankDetailsOnInvoiceProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SizedBox(
          height: 196,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: templates.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final item = templates[index];
              final thumbConfig = InvoiceTemplateConfig.decode(item.configJson);
              return GestureDetector(
                onTap: () => onSelectTemplate(item),
                child: _PreviewThumb(
                  businessId: businessId,
                  scope: scope,
                  label: item.name,
                  active: selectedTemplate?.id == item.id,
                  config: thumbConfig,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 560,
          child: businessAsync.when(
            data: (business) {
              if (business == null) {
                return const Center(child: Text('Select a business first.'));
              }
              return ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    cardColor: const Color(0xFFF8F8FC),
                    dividerColor: Colors.transparent,
                  ),
                  child: PdfPreview(
                    key: ValueKey(
                      '${template?.id}_${config.encode()}_${showBankDetails}_$scope',
                    ),
                    maxPageWidth: 700,
                    allowPrinting: false,
                    allowSharing: false,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    build: (_) => _getCachedTemplatePreviewPdf(
                      business: business,
                      scope: scope,
                      config: config,
                      isGstEnabled: isGstEnabled,
                      showBankDetails: showBankDetails,
                    ),
                  ),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(
              child: Text('Failed to load preview: $err'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (selectedTemplate != null)
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (selectedTemplate!.isDefault)
                Chip(
                  avatar: const Icon(Icons.star, size: 16),
                  label: const Text('Default'),
                )
              else
                FilledButton.icon(
                  onPressed: () async {
                    await _SettingsTab(
                      businessId: businessId,
                      scope: scope,
                      templates: templates,
                      selectedTemplate: selectedTemplate,
                      onSelectTemplate: onSelectTemplate,
                      onChanged: onChanged,
                    )._setTemplateDefault(
                      ref,
                      businessId,
                      scope,
                      selectedTemplate!,
                    );
                    onChanged();
                  },
                  icon: const Icon(Icons.star_border),
                  label: const Text('Set As Default'),
                ),
              OutlinedButton.icon(
                onPressed: () => context.push<bool>(
                  '/template-editor',
                  extra: TemplateEditorArgs(
                    businessId: businessId,
                    scope: scope,
                    templateId: selectedTemplate!.id,
                  ),
                ).then((result) {
                  if (result == true) {
                    onChanged();
                  }
                }),
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit Template'),
              ),
            ],
          ),
        if (selectedTemplate != null) const SizedBox(height: 12),
        if (selectedTemplate != null)
          Row(
            children: [
              const Icon(Icons.description_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  selectedTemplate!.name,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ExpandableGroup extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ExpandableGroup({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(title),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: children,
      ),
    );
  }
}

class _PreviewThumb extends StatelessWidget {
  final int businessId;
  final TemplateScope scope;
  final String label;
  final bool active;
  final InvoiceTemplateConfig config;

  const _PreviewThumb({
    required this.businessId,
    required this.scope,
    required this.label,
    required this.active,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 136,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: active
              ? Theme.of(context).colorScheme.primary
              : Colors.grey.shade300,
          width: active ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                border: Border.all(color: Colors.black12),
              ),
              clipBehavior: Clip.antiAlias,
              child: FutureBuilder<Uint8List>(
                future: _getCachedTemplateThumbnail(
                  businessId: businessId,
                  scope: scope,
                  config: config,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Image.memory(
                      snapshot.data!,
                      fit: BoxFit.cover,
                      alignment: Alignment.topCenter,
                    );
                  }
                  return _FallbackThumb(config: config);
                },
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _FallbackThumb extends StatelessWidget {
  final InvoiceTemplateConfig config;

  const _FallbackThumb({required this.config});

  @override
  Widget build(BuildContext context) {
    final primary = _parseColor(config.primaryColor, Colors.blue);
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            config.titleLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          const SizedBox(height: 6),
          Container(height: 2, color: primary),
          const SizedBox(height: 8),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _parseColor(
                  config.accentColor,
                  Colors.blue.shade50,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<Uint8List> _buildTemplatePreviewPdf({
  required Business business,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
  required bool isGstEnabled,
  required bool showBankDetails,
}) {
  final previewBusiness = business.copyWith(
    invoiceTemplate: config.layoutFamily,
    quoteTemplate: config.layoutFamily,
    brandColor: drift.Value(_previewBrandColor(config.primaryColor)),
    bankName: config.showBankDetails
        ? drift.Value(business.bankName ?? 'Example Bank')
        : const drift.Value(null),
    bankAccount: config.showBankDetails
        ? drift.Value(business.bankAccount ?? '1234567890')
        : const drift.Value(null),
    bankIfsc: config.showBankDetails
        ? drift.Value(business.bankIfsc ?? 'EXAMP001')
        : const drift.Value(null),
  );

  if (scope == TemplateScope.quote) {
    return PdfService.generateQuotePdf(
      business: previewBusiness,
      customer: _previewCustomer(previewBusiness.id),
      quote: _previewQuote(previewBusiness.id),
      items: _previewQuoteItems(),
      isGstEnabled: isGstEnabled && config.showGst,
      showBankDetails: showBankDetails && config.showBankDetails,
      templateConfig: config,
    );
  }

  return PdfService.generateInvoice(
    business: previewBusiness,
    customer: _previewCustomer(previewBusiness.id),
    invoice: _previewInvoice(previewBusiness.id),
    items: _previewInvoiceItems(),
    isGstEnabled: isGstEnabled && config.showGst,
    showBankDetails: showBankDetails && config.showBankDetails,
    templateConfig: config,
  );
}

final Map<String, Future<Uint8List>> _templatePreviewPdfCache =
    <String, Future<Uint8List>>{};

Customer _previewCustomer(int businessId) => Customer(
  id: 1,
  businessId: businessId,
  name: 'Customer Name',
  gstin: '29ABCDE1234F1Z5',
  pan: null,
  address: 'address line 1',
  city: 'Bengaluru',
  stateCode: 29,
  pincode: '560001',
  phone: '9876543210',
  email: 'customer@email.com',
  isActive: true,
  createdAt: DateTime(2026, 6, 30),
);

Invoice _previewInvoice(int businessId) => Invoice(
  id: 1,
  businessId: businessId,
  customerId: 1,
  invoiceNumber: 'INV-2017-17/100',
  currencyCode: 'INR',
  invoiceDate: DateTime(2026, 6, 30),
  dueDate: DateTime(2026, 7, 7),
  invoiceType: 'TAX',
  supplyType: 'GOODS',
  placeOfSupply: 29,
  subtotal: 300,
  discountAmount: 0,
  taxableAmount: 300,
  cgstAmount: 27,
  sgstAmount: 27,
  igstAmount: 0,
  cessAmount: 0,
  totalAmount: 354,
  amountPaid: 0,
  amountInWords: 'Rupees Three Hundred Fifty Four Only',
  notes: 'Preview sample',
  terms: 'Thank you for your business.',
  status: 'UNPAID',
  isIgst: false,
  createdAt: DateTime(2026, 6, 30),
  updatedAt: DateTime(2026, 6, 30),
);

List<InvoiceItem> _previewInvoiceItems() => const [
  InvoiceItem(
    id: 1,
    invoiceId: 1,
    productId: null,
    name: 'Item 1',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 0,
  ),
  InvoiceItem(
    id: 2,
    invoiceId: 1,
    productId: null,
    name: 'Item 2',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 1,
  ),
  InvoiceItem(
    id: 3,
    invoiceId: 1,
    productId: null,
    name: 'Item 3',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 2,
  ),
];

Quote _previewQuote(int businessId) => Quote(
  id: 1,
  businessId: businessId,
  customerId: 1,
  invoiceNumber: 'QUO-2017-17/100',
  currencyCode: 'INR',
  invoiceDate: DateTime(2026, 6, 30),
  dueDate: DateTime(2026, 7, 7),
  invoiceType: 'QUOTE',
  supplyType: 'GOODS',
  placeOfSupply: 29,
  subtotal: 300,
  discountAmount: 0,
  taxableAmount: 300,
  cgstAmount: 27,
  sgstAmount: 27,
  igstAmount: 0,
  cessAmount: 0,
  totalAmount: 354,
  amountInWords: 'Rupees Three Hundred Fifty Four Only',
  notes: 'Preview sample',
  terms: 'Quote valid for 7 days.',
  status: 'DRAFT',
  isIgst: false,
  createdAt: DateTime(2026, 6, 30),
  updatedAt: DateTime(2026, 6, 30),
);

List<QuoteItem> _previewQuoteItems() => const [
  QuoteItem(
    id: 1,
    quoteId: 1,
    productId: null,
    name: 'Item 1',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 0,
  ),
  QuoteItem(
    id: 2,
    quoteId: 1,
    productId: null,
    name: 'Item 2',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 1,
  ),
  QuoteItem(
    id: 3,
    quoteId: 1,
    productId: null,
    name: 'Item 3',
    hsnSac: '1234',
    unit: 'pcs',
    quantity: 1,
    rate: 100,
    discountPct: 0,
    taxableAmount: 100,
    gstRate: 18,
    cgstRate: 9,
    sgstRate: 9,
    igstRate: 0,
    cessRate: 0,
    cgstAmount: 9,
    sgstAmount: 9,
    igstAmount: 0,
    cessAmount: 0,
    totalAmount: 118,
    sortOrder: 2,
  ),
];

int? _previewBrandColor(String colorHex) {
  final hex = colorHex.replaceFirst('#', '');
  if (hex.length != 6) return null;
  return int.tryParse('FF$hex', radix: 16);
}

Color _parseColor(String value, Color fallback) {
  final hex = value.replaceFirst('#', '');
  if (hex.length == 6) {
    return Color(int.parse('FF$hex', radix: 16));
  }
  return fallback;
}

Future<Uint8List> _buildTemplateThumbnail({
  required int businessId,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
}) async {
  final pdf = await _buildTemplatePreviewPdf(
    business: Business(
      id: businessId,
      name: 'Your Organization Name',
      gstin: '29ABCDE1234F1Z5',
      pan: null,
      businessType: BusinessType.gstRegistered,
      address: '23/1 Demo Street',
      city: 'Bengaluru',
      stateCode: 29,
      pincode: '560001',
      phone: '9876543210',
      email: 'hello@example.com',
      logoPath: null,
      bankName: 'Example Bank',
      bankAccount: '1234567890',
      bankIfsc: 'EXAMP001',
      upiId: null,
      currencyCode: 'INR',
      invoiceTemplate: config.layoutFamily,
      quoteTemplate: config.layoutFamily,
      invoiceSeriesFormat: 'INV-{FY}-{SEQ4}',
      quoteSeriesFormat: 'QT-{FY}-{SEQ4}',
      defaultInvoiceTemplateId: null,
      defaultQuoteTemplateId: null,
      brandColor: _previewBrandColor(config.primaryColor),
      isActive: true,
      createdAt: DateTime(2026, 6, 30),
    ),
    scope: scope,
    config: config,
    isGstEnabled: config.showGst,
    showBankDetails: config.showBankDetails,
  );

  await for (final page in Printing.raster(pdf, pages: const [0], dpi: 72)) {
    return page.toPng();
  }
  throw StateError('Unable to rasterize template thumbnail');
}

final Map<String, Future<Uint8List>> _templateThumbnailCache =
    <String, Future<Uint8List>>{};

Future<Uint8List> _getCachedTemplatePreviewPdf({
  required Business business,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
  required bool isGstEnabled,
  required bool showBankDetails,
}) {
  final cacheKey = [
    business.id,
    scope.name,
    config.encode(),
    isGstEnabled,
    showBankDetails,
    business.brandColor,
    business.bankName,
    business.bankAccount,
    business.bankIfsc,
    business.invoiceTemplate,
    business.quoteTemplate,
  ].join('|');

  return _templatePreviewPdfCache.putIfAbsent(
    cacheKey,
    () => _buildTemplatePreviewPdf(
      business: business,
      scope: scope,
      config: config,
      isGstEnabled: isGstEnabled,
      showBankDetails: showBankDetails,
    ),
  );
}

Future<Uint8List> _getCachedTemplateThumbnail({
  required int businessId,
  required TemplateScope scope,
  required InvoiceTemplateConfig config,
}) {
  final cacheKey = '$businessId|${scope.name}|${config.encode()}';
  return _templateThumbnailCache.putIfAbsent(
    cacheKey,
    () => _buildTemplateThumbnail(
      businessId: businessId,
      scope: scope,
      config: config,
    ),
  );
}

void _clearTemplatePreviewCaches() {
  _templatePreviewPdfCache.clear();
  _templateThumbnailCache.clear();
}
