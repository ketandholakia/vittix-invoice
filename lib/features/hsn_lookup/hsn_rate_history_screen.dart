import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hsn_provider.dart';
import '../../providers/database_provider.dart';

class HsnRateHistoryScreen extends ConsumerStatefulWidget {
  final String? initialCode;

  const HsnRateHistoryScreen({super.key, this.initialCode});

  @override
  ConsumerState<HsnRateHistoryScreen> createState() =>
      _HsnRateHistoryScreenState();
}

class _HsnRateHistoryScreenState extends ConsumerState<HsnRateHistoryScreen> {
  late final TextEditingController _codeController;
  late final TextEditingController _rateController;
  DateTime _effectiveFrom = DateTime.now();
  String? _selectedCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedCode = widget.initialCode?.trim().isEmpty == true
        ? null
        : widget.initialCode?.trim();
    _codeController = TextEditingController(text: _selectedCode ?? '');
    _rateController = TextEditingController();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _pickEffectiveDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _effectiveFrom,
      firstDate: DateTime(2017, 7, 1),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() => _effectiveFrom = picked);
  }

  Future<void> _loadCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;
    setState(() => _selectedCode = code);
  }

  Future<void> _saveRate() async {
    final code = _codeController.text.trim().toUpperCase();
    final rate = double.tryParse(_rateController.text.trim());
    if (code.isEmpty || rate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an HSN code and GST rate')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      await ref.read(hsnDaoProvider).addHsnCodeRate(
            code: code,
            gstRate: rate,
            effectiveFrom: _effectiveFrom,
          );
      ref.invalidate(hsnRateVersionsProvider(code));
      setState(() => _selectedCode = code);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rate version saved')),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save rate version: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCode = _selectedCode;
    final versionsAsync = selectedCode == null
        ? null
        : ref.watch(hsnRateVersionsProvider(selectedCode));

    return Scaffold(
      appBar: AppBar(
        title: const Text('HSN Rate Versions'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      labelText: 'HSN / SAC Code',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.characters,
                    onSubmitted: (_) => _loadCode(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _loadCode,
                  icon: const Icon(Icons.search),
                  label: const Text('Load'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _rateController,
                    decoration: const InputDecoration(
                      labelText: 'GST Rate %',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _pickEffectiveDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Effective From',
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        _effectiveFrom.toIso8601String().split('T')[0],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _isSaving ? null : _saveRate,
                  icon: const Icon(Icons.save),
                  label: const Text('Save'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: selectedCode == null
                  ? const Center(
                      child: Text('Load an HSN code to view its rate history.'),
                    )
                  : versionsAsync!.when(
                      data: (versions) {
                        if (versions.isEmpty) {
                          return const Center(
                            child: Text('No rate versions found for this code.'),
                          );
                        }
                        return ListView.separated(
                          itemCount: versions.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final version = versions[index];
                            return ListTile(
                              leading: const Icon(Icons.timeline),
                              title: Text('${version.gstRate ?? 0}%'),
                              subtitle: Text(
                                'Effective ${version.effectiveFrom.toIso8601String().split('T')[0]}',
                              ),
                            );
                          },
                        );
                      },
                      loading: () =>
                          const Center(child: CircularProgressIndicator()),
                      error: (err, stack) =>
                          Center(child: Text('Error loading rates: $err')),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
