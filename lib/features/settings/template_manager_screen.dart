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

part 'template_manager_tabs.dart';
part 'template_manager_thumbs.dart';
part 'template_manager_previews.dart';

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
