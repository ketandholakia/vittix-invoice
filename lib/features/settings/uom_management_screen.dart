import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/uom_provider.dart';

class UomManagementScreen extends ConsumerStatefulWidget {
  const UomManagementScreen({super.key});

  @override
  ConsumerState<UomManagementScreen> createState() => _UomManagementScreenState();
}

class _UomManagementScreenState extends ConsumerState<UomManagementScreen> {
  Future<void> _editUom({Uom? existing}) async {
    final codeController = TextEditingController(text: existing?.code ?? '');
    final nameController = TextEditingController(text: existing?.name ?? '');
    final familyController = TextEditingController(
      text: existing?.family ?? 'COUNT',
    );
    final baseCodeController = TextEditingController(text: existing?.baseCode ?? '');
    final factorController = TextEditingController(
      text: existing?.conversionFactor.toString() ?? '1.0',
    );
    final sortOrderController = TextEditingController(
      text: existing?.sortOrder.toString() ?? '0',
    );
    bool isActive = existing?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add UOM' : 'Edit UOM'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: codeController,
                  decoration: const InputDecoration(labelText: 'Code'),
                  textCapitalization: TextCapitalization.characters,
                ),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: familyController,
                  decoration: const InputDecoration(labelText: 'Family'),
                ),
                TextField(
                  controller: baseCodeController,
                  decoration: const InputDecoration(labelText: 'Base Code'),
                ),
                TextField(
                  controller: factorController,
                  decoration: const InputDecoration(labelText: 'Conversion Factor'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                TextField(
                  controller: sortOrderController,
                  decoration: const InputDecoration(labelText: 'Sort Order'),
                  keyboardType: TextInputType.number,
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: isActive,
                  onChanged: (value) {
                    setDialogState(() => isActive = value);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final code = codeController.text.trim().toUpperCase();
              final name = nameController.text.trim();
              final family = familyController.text.trim().toUpperCase();
              final factor = double.tryParse(factorController.text.trim()) ?? 1.0;
              final sortOrder = int.tryParse(sortOrderController.text.trim()) ?? 0;
              if (code.isEmpty || name.isEmpty || family.isEmpty) return;

              final dao = ref.read(uomDaoProvider);
              await dao.upsertUom(
                UomsCompanion(
                  id: existing == null ? const drift.Value.absent() : drift.Value(existing.id),
                  code: drift.Value(code),
                  name: drift.Value(name),
                  family: drift.Value(family),
                  baseCode: drift.Value(
                    baseCodeController.text.trim().isEmpty
                        ? null
                        : baseCodeController.text.trim().toUpperCase(),
                  ),
                  conversionFactor: drift.Value(factor),
                  isActive: drift.Value(isActive),
                  sortOrder: drift.Value(sortOrder),
                ),
              );
              if (context.mounted) {
                ref.invalidate(uomCatalogProvider);
                ref.invalidate(uomListProvider);
                Navigator.of(context).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true) {
      setState(() {});
    }

    codeController.dispose();
    nameController.dispose();
    familyController.dispose();
    baseCodeController.dispose();
    factorController.dispose();
    sortOrderController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uomsAsync = ref.watch(uomCatalogProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Units of Measure'),
      ),
      body: uomsAsync.when(
        data: (uoms) {
          if (uoms.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No units configured.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _editUom(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add UOM'),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            itemCount: uoms.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final uom = uoms[index];
              final conversionLabel = uom.baseCode == null || uom.conversionFactor == 1.0
                  ? 'Base unit'
                  : '1 ${uom.code} = ${uom.conversionFactor} ${uom.baseCode}';

              return ListTile(
                title: Text('${uom.name} (${uom.code})'),
                subtitle: Text(
                  '${uom.family} | $conversionLabel | ${uom.isActive ? 'Active' : 'Inactive'}',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _editUom(existing: uom),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading UOMs: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _editUom(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
