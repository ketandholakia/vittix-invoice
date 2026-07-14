import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../database/app_database.dart';
import '../../database/tables/template_configs.dart';
import '../../models/invoice_template_config.dart';
import '../../providers/database_provider.dart';

class TemplateEditorArgs {
  final int businessId;
  final TemplateScope scope;
  final int? templateId;

  const TemplateEditorArgs({
    required this.businessId,
    required this.scope,
    this.templateId,
  });
}

class TemplateEditorScreen extends ConsumerStatefulWidget {
  final TemplateEditorArgs args;
  const TemplateEditorScreen({super.key, required this.args});

  @override
  ConsumerState<TemplateEditorScreen> createState() =>
      _TemplateEditorScreenState();
}

class _TemplateEditorScreenState extends ConsumerState<TemplateEditorScreen> {
  TemplateConfig? _template;
  bool _loading = true;
  late InvoiceTemplateConfig _config;

  // Text controllers
  late final TextEditingController _name = TextEditingController();
  late final TextEditingController _title = TextEditingController();
  late final TextEditingController _invoiceNo = TextEditingController();
  late final TextEditingController _date = TextEditingController();
  late final TextEditingController _billTo = TextEditingController();
  late final TextEditingController _terms = TextEditingController();
  late final TextEditingController _watermark = TextEditingController();
  late final TextEditingController _footerNote = TextEditingController();

  // Layout
  late String _paperSize;
  late String _layoutFamily;
  String? _fontFamily;
  late String _headerDensity;
  late double _layoutSpacing;
  late double _borderThickness;

  // Colors
  Color _primaryColor = const Color(0xFF1E88E5);
  Color _accentColor = const Color(0xFFE3F2FD);

  // Visibility toggles
  late bool _showLogo;
  late bool _showGst;
  late bool _showHsn;
  late bool _showBankDetails;
  late bool _showSignature;
  late bool _showQrCode;
  late bool _showDueDate;
  late bool _showPlaceOfSupply;
  late bool _showAmountInWords;

  // Table
  late List<String> _columns;
  late String _tableBorderStyle;

  // All possible item columns
  static const _allColumns = ['item', 'hsn', 'qty', 'rate', 'discount', 'gst', 'amount'];
  static const _columnLabels = {
    'item': 'Item',
    'hsn': 'HSN/SAC',
    'qty': 'Qty',
    'rate': 'Rate',
    'discount': 'Discount',
    'gst': 'GST',
    'amount': 'Amount',
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dao = ref.read(templateConfigDaoProvider);
    final template = widget.args.templateId == null
        ? null
        : await dao.getTemplateById(widget.args.templateId!);
    _template = template;
    _config = template == null
        ? InvoiceTemplateConfig.defaults(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            name: 'New Template',
            layoutFamily: 'CLASSIC',
          )
        : InvoiceTemplateConfig.decode(template.configJson);

    _name.text = _config.name;
    _title.text = _config.titleLabel;
    _invoiceNo.text = _config.invoiceNoLabel;
    _date.text = _config.dateLabel;
    _billTo.text = _config.billToLabel;
    _terms.text = _config.termsText;
    _watermark.text = _config.watermarkText ?? '';
    _footerNote.text = _config.footerText ?? '';

    _paperSize = _config.paperSize;
    _layoutFamily = _config.layoutFamily;
    _fontFamily = _config.fontFamily;
    _headerDensity = _config.headerDensity;
    _layoutSpacing = _config.layoutSpacing;
    _borderThickness = _config.borderThickness;

    _primaryColor = _parseColor(_config.primaryColor, const Color(0xFF1E88E5));
    _accentColor = _parseColor(_config.accentColor, const Color(0xFFE3F2FD));

    _showLogo = _config.showLogo;
    _showGst = _config.showGst;
    _showHsn = _config.showHsn;
    _showBankDetails = _config.showBankDetails;
    _showSignature = _config.showSignature;
    _showQrCode = _config.showQrCode;
    _showDueDate = _config.showDueDate;
    _showPlaceOfSupply = _config.showPlaceOfSupply;
    _showAmountInWords = _config.showAmountInWords;

    _columns = [..._config.itemColumns];
    _tableBorderStyle = _config.tableBorderStyle;

    setState(() => _loading = false);
  }

  Color _parseColor(String value, Color fallback) {
    final hex = value.replaceFirst('#', '');
    if (hex.length == 6) return Color(int.parse('FF$hex', radix: 16));
    return fallback;
  }

  String _hex(Color color) =>
      '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

  InvoiceTemplateConfig _currentConfig() => InvoiceTemplateConfig(
        id: _config.id,
        name: _name.text.trim(),
        paperSize: _paperSize,
        primaryColor: _hex(_primaryColor),
        accentColor: _hex(_accentColor),
        showLogo: _showLogo,
        showGst: _showGst,
        showHsn: _showHsn,
        showBankDetails: _showBankDetails,
        showSignature: _showSignature,
        showQrCode: _showQrCode,
        itemColumns: _columns,
        titleLabel: _title.text.trim(),
        invoiceNoLabel: _invoiceNo.text.trim(),
        dateLabel: _date.text.trim(),
        billToLabel: _billTo.text.trim(),
        termsText: _terms.text.trim(),
        watermarkText:
            _watermark.text.trim().isEmpty ? null : _watermark.text.trim(),
        layoutFamily: _layoutFamily,
        fontFamily: _fontFamily,
        layoutSpacing: _layoutSpacing,
        borderThickness: _borderThickness,
        headerDensity: _headerDensity,
        showDueDate: _showDueDate,
        showPlaceOfSupply: _showPlaceOfSupply,
        showAmountInWords: _showAmountInWords,
        tableBorderStyle: _tableBorderStyle,
        footerText:
            _footerNote.text.trim().isEmpty ? null : _footerNote.text.trim(),
      );

  Future<void> _save() async {
    final dao = ref.read(templateConfigDaoProvider);
    final config = _currentConfig();
    if (_template == null) {
      final id = await dao.insertTemplate(
        TemplateConfigsCompanion.insert(
          businessId: widget.args.businessId,
          scope: widget.args.scope,
          name: config.name,
          configJson: config.encode(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await _setBusinessDefault(id);
    } else {
      await dao.updateTemplate(
        _template!.copyWith(
          name: config.name,
          configJson: config.encode(),
          updatedAt: DateTime.now(),
        ),
      );
    }
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _setBusinessDefault(int templateId) async {
    final businessDao = ref.read(businessDaoProvider);
    final business = await businessDao.getBusinessById(widget.args.businessId);
    if (business == null) return;
    final updated = widget.args.scope == TemplateScope.invoice
        ? business.copyWith(defaultInvoiceTemplateId: drift.Value(templateId))
        : business.copyWith(defaultQuoteTemplateId: drift.Value(templateId));
    await businessDao.updateBusiness(updated);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Template Editor'),
        actions: [
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // ── Identity ─────────────────────────────────────────────────────
          _Section(
            title: 'Identity',
            icon: Icons.badge_outlined,
            initiallyExpanded: true,
            children: [
              _field(_name, 'Template Name', Icons.label_outline),
              const SizedBox(height: 12),
              _field(_title, 'Document Title (e.g. TAX INVOICE)', Icons.title),
            ],
          ),
          // ── Labels ───────────────────────────────────────────────────────
          _Section(
            title: 'Labels',
            icon: Icons.text_fields,
            children: [
              _field(_invoiceNo, 'Invoice No Label', Icons.tag),
              const SizedBox(height: 12),
              _field(_date, 'Date Label', Icons.calendar_today_outlined),
              const SizedBox(height: 12),
              _field(_billTo, 'Bill To Label', Icons.person_outline),
            ],
          ),
          // ── Layout ───────────────────────────────────────────────────────
          _Section(
            title: 'Layout',
            icon: Icons.dashboard_customize_outlined,
            children: [
              _dropdown<String>(
                label: 'Paper Size',
                value: _paperSize,
                items: const {
                  'a4': 'A4',
                  'a5': 'A5',
                  'thermal': 'Thermal (80 mm)',
                },
                onChanged: (v) => setState(() => _paperSize = v!),
              ),
              const SizedBox(height: 12),
              _dropdown<String>(
                label: 'Layout Family',
                value: _layoutFamily,
                items: const {
                  'CLASSIC': 'Classic',
                  'MODERN': 'Modern',
                  'ELEGANT': 'Elegant',
                  'COMPACT': 'Compact',
                  'THERMAL': 'Thermal',
                  'LETTERHEAD': 'Letterhead',
                },
                onChanged: (v) => setState(() => _layoutFamily = v!),
              ),
              const SizedBox(height: 12),
              _dropdown<String>(
                label: 'Header Density',
                value: _headerDensity,
                items: const {
                  'COMFORTABLE': 'Comfortable',
                  'COMPACT': 'Compact',
                  'SPACIOUS': 'Spacious',
                },
                onChanged: (v) => setState(() => _headerDensity = v!),
              ),
              const SizedBox(height: 16),
              _sliderTile(
                label: 'Spacing',
                value: _layoutSpacing,
                min: 4,
                max: 28,
                divisions: 6,
                unit: 'pt',
                onChanged: (v) => setState(() => _layoutSpacing = v),
              ),
              _sliderTile(
                label: 'Border Thickness',
                value: _borderThickness,
                min: 0.5,
                max: 3,
                divisions: 5,
                unit: 'pt',
                onChanged: (v) => setState(() => _borderThickness = v),
              ),
            ],
          ),
          // ── Typography ───────────────────────────────────────────────────
          _Section(
            title: 'Typography',
            icon: Icons.font_download_outlined,
            children: [
              _dropdown<String?>(
                label: 'Font Family',
                value: _fontFamily,
                items: const {
                  null: 'Default (Roboto)',
                  'Open Sans': 'Open Sans',
                  'Lato': 'Lato',
                  'Montserrat': 'Montserrat',
                },
                onChanged: (v) => setState(() => _fontFamily = v),
              ),
            ],
          ),
          // ── Colours ──────────────────────────────────────────────────────
          _Section(
            title: 'Colours',
            icon: Icons.palette_outlined,
            children: [
              _colorRow(
                'Primary Color',
                _primaryColor,
                (c) => setState(() => _primaryColor = c),
              ),
              const Divider(height: 1),
              _colorRow(
                'Accent / Header Background Color',
                _accentColor,
                (c) => setState(() => _accentColor = c),
              ),
            ],
          ),
          // ── Visibility ───────────────────────────────────────────────────
          _Section(
            title: 'Visibility',
            icon: Icons.visibility_outlined,
            children: [
              _toggle('Show Logo', _showLogo,
                  (v) => setState(() => _showLogo = v)),
              _toggle('Show GST / Tax Columns', _showGst,
                  (v) => setState(() => _showGst = v)),
              _toggle('Show HSN/SAC Code', _showHsn,
                  (v) => setState(() => _showHsn = v)),
              _toggle('Show Bank Details', _showBankDetails,
                  (v) => setState(() => _showBankDetails = v)),
              _toggle('Show Signature Line', _showSignature,
                  (v) => setState(() => _showSignature = v)),
              _toggle('Show UPI QR Code', _showQrCode,
                  (v) => setState(() => _showQrCode = v)),
              const Divider(height: 1),
              _toggle('Show Due Date', _showDueDate,
                  (v) => setState(() => _showDueDate = v)),
              _toggle('Show Place of Supply', _showPlaceOfSupply,
                  (v) => setState(() => _showPlaceOfSupply = v)),
              _toggle('Show Amount in Words', _showAmountInWords,
                  (v) => setState(() => _showAmountInWords = v)),
            ],
          ),
          // ── Table ────────────────────────────────────────────────────────
          _Section(
            title: 'Table',
            icon: Icons.table_chart_outlined,
            children: [
              _dropdown<String>(
                label: 'Table Border Style',
                value: _tableBorderStyle,
                items: const {
                  'FULL': 'Full (all borders)',
                  'ROWS_ONLY': 'Rows only (horizontal lines)',
                  'NONE': 'None (plain rows)',
                },
                onChanged: (v) => setState(() => _tableBorderStyle = v!),
              ),
              const SizedBox(height: 16),
              Text(
                'Item Columns',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _allColumns.map((col) {
                  final selected = _columns.contains(col);
                  return FilterChip(
                    label: Text(_columnLabels[col] ?? col),
                    selected: selected,
                    onSelected: col == 'item' || col == 'amount'
                        ? null // always required
                        : (on) {
                            setState(() {
                              if (on) {
                                _columns.add(col);
                              } else {
                                _columns.remove(col);
                              }
                            });
                          },
                    selectedColor: cs.primaryContainer,
                    checkmarkColor: cs.onPrimaryContainer,
                  );
                }).toList(),
              ),
              const SizedBox(height: 4),
              Text(
                '"Item" and "Amount" columns are always included.',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: cs.outline),
              ),
            ],
          ),
          // ── Text / Footer ────────────────────────────────────────────────
          _Section(
            title: 'Text & Footer',
            icon: Icons.notes_outlined,
            children: [
              _field(
                _terms,
                'Declaration / Terms Header',
                Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              _field(
                _footerNote,
                'Footer Note (small text at bottom)',
                Icons.info_outline,
                hintText: 'e.g. Generated by Vittix',
              ),
              const SizedBox(height: 12),
              _field(
                _watermark,
                'Watermark Text',
                Icons.water_outlined,
                hintText: 'e.g. DRAFT or PAID',
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Helper widgets
  // ---------------------------------------------------------------------------

  Widget _field(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    String? hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: Icon(icon, size: 20),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }

  Widget _dropdown<T>({
    required String label,
    required T value,
    required Map<T, String> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      items: items.entries
          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _sliderTile({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String unit,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 130,
          child: Text(
            '$label: ${value.toStringAsFixed(value == value.roundToDouble() ? 0 : 1)} $unit',
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) {
    return SwitchListTile.adaptive(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      dense: true,
    );
  }

  Widget _colorRow(
    String label,
    Color color,
    ValueChanged<Color> onSelected,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.black12),
        ),
      ),
      onTap: () async {
        Color temp = color;
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(label),
            content: ColorPicker(
              pickerColor: color,
              onColorChanged: (c) => temp = c,
              enableAlpha: false,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  onSelected(temp);
                  Navigator.pop(ctx);
                },
                child: const Text('Use This'),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// _Section — collapsible card with icon + title
// ---------------------------------------------------------------------------

class _Section extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool initiallyExpanded;

  const _Section({
    required this.title,
    required this.icon,
    required this.children,
    this.initiallyExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ExpansionTile(
        initiallyExpanded: initiallyExpanded,
        leading: Icon(icon, color: cs.primary),
        title: Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        childrenPadding:
            const EdgeInsets.fromLTRB(16, 4, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}
