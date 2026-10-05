part of 'template_manager_screen.dart';

// Group headers and preview/thumbnail widgets.

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
