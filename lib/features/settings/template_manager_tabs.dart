part of 'template_manager_screen.dart';

// The Settings and Preview tabs of the template manager.

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
                const Chip(
                  avatar: Icon(Icons.star, size: 16),
                  label: Text('Default'),
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
