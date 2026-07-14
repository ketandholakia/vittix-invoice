import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/invoice_number.dart';
import '../../database/app_database.dart';
import '../../providers/business_provider.dart';

class DocumentNumberingScreen extends ConsumerStatefulWidget {
  const DocumentNumberingScreen({super.key});

  @override
  ConsumerState<DocumentNumberingScreen> createState() =>
      _DocumentNumberingScreenState();
}

class _DocumentNumberingScreenState
    extends ConsumerState<DocumentNumberingScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _invoiceController;
  late final TextEditingController _quoteController;
  bool _initialized = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _invoiceController = TextEditingController();
    _quoteController = TextEditingController();
  }

  @override
  void dispose() {
    _invoiceController.dispose();
    _quoteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessAsync = ref.watch(activeBusinessProvider);
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Document Numbering')),
      body: businessAsync.when(
        data: (business) {
          if (business == null) {
            return const Center(child: Text('Select a business first.'));
          }

          if (!_initialized) {
            _invoiceController.text = business.invoiceSeriesFormat;
            _quoteController.text = business.quoteSeriesFormat;
            _initialized = true;
          }

          final invoiceFormat = InvoiceNumberGenerator.normalizeFormat(
            _invoiceController.text,
            fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
          );
          final quoteFormat = InvoiceNumberGenerator.normalizeFormat(
            _quoteController.text,
            fallback: InvoiceNumberGenerator.defaultQuoteFormat,
          );

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Configure how invoice and quote numbers are generated.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _TokenHelpCard(now: now),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _invoiceController,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Series Format',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: _validateFormat,
                ),
                const SizedBox(height: 8),
                Text(
                  'Example: ${InvoiceNumberGenerator.samplePreview(invoiceFormat, now)}',
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quoteController,
                  decoration: const InputDecoration(
                    labelText: 'Quote Series Format',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: _validateFormat,
                ),
                const SizedBox(height: 8),
                Text(
                  'Example: ${InvoiceNumberGenerator.samplePreview(quoteFormat, now)}',
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _saving
                      ? null
                      : () => _save(
                            business.copyWith(
                              invoiceSeriesFormat: invoiceFormat,
                              quoteSeriesFormat: quoteFormat,
                            ),
                          ),
                  child: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Numbering'),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('Failed to load active business: $err'),
        ),
      ),
    );
  }

  String? _validateFormat(String? value) {
    final normalized = InvoiceNumberGenerator.normalizeFormat(
      value,
      fallback: InvoiceNumberGenerator.defaultInvoiceFormat,
    );
    if (!normalized.contains('{SEQ')) {
      return 'Format must include a sequence token like {SEQ4}.';
    }
    return null;
  }

  Future<void> _save(Business updatedBusiness) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await ref.read(businessProvider).updateBusiness(updatedBusiness);
      ref.invalidate(activeBusinessProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document numbering updated.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save numbering: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}

class _TokenHelpCard extends StatelessWidget {
  final DateTime now;

  const _TokenHelpCard({required this.now});

  @override
  Widget build(BuildContext context) {
    final examples = [
      '{FY} = ${InvoiceNumberGenerator.financialYear(now)}',
      '{YYYY} = ${now.year}',
      '{YY} = ${(now.year % 100).toString().padLeft(2, '0')}',
      '{MM} = ${now.month.toString().padLeft(2, '0')}',
      '{MON} = ${InvoiceNumberGenerator.samplePreview('{MON}', now)}',
      '{MONTH} = ${InvoiceNumberGenerator.samplePreview('{MONTH}', now)}',
      '{SEQ4} = 0001',
      '{SEQ6} = 000001',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Tokens',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            for (final example in examples) Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(example),
            ),
            const SizedBox(height: 8),
            const Text('Example formats:'),
            const Text('INV-{FY}-{SEQ4}'),
            const Text('INV/{YYYY}/{MM}/{SEQ4}'),
            const Text('QT-{MON}-{YY}-{SEQ3}'),
            const Text('SALE-{YYYY}-{MM}-A-{SEQ4}-X'),
          ],
        ),
      ),
    );
  }
}
