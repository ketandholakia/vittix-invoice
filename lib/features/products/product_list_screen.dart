import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/money_formatter.dart';
import '../../database/app_database.dart';
import '../../providers/business_provider.dart';
import '../../providers/product_provider.dart';
import '../../services/share_service.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  final Set<int> _selectedProductIds = {};

  bool get _isSelecting => _selectedProductIds.isNotEmpty;

  void _toggleProductSelection(int productId) {
    setState(() {
      if (!_selectedProductIds.add(productId)) {
        _selectedProductIds.remove(productId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedProductIds.clear);
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int productId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete product?'),
        content: const Text(
          'This will remove the product and may fail if existing line items still reference it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    try {
      await ref.read(productProvider).deleteProduct(productId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete product: $e')));
      }
    }
  }

  Future<void> _exportSelectedProducts(
    List<Product> products,
    String currencyCode,
  ) async {
    final selected = products
        .where((product) => _selectedProductIds.contains(product.id))
        .toList();
    if (selected.isEmpty) return;

    final rows = <List<String>>[
      [
        'Name',
        'Type',
        'HSN/SAC',
        'Unit',
        'Sale Price',
        'Currency',
        'GST Rate',
        'Stock Qty',
      ],
      for (final product in selected)
        [
          product.name,
          product.isService ? 'Service' : 'Product',
          product.hsnSac,
          product.unit,
          formatMoney(product.salePrice, currencyCode: currencyCode),
          currencyCode,
          product.gstRate.toStringAsFixed(2),
          product.stockQuantity.toStringAsFixed(2),
        ],
    ];

    await ShareService.shareCsv(
      rows,
      'selected_products.csv',
      subject: 'Selected Products',
      text: 'Selected product export',
    );
  }

  Future<void> _deleteSelectedProducts(
    BuildContext context,
    List<Product> products,
  ) async {
    final selected = products
        .where((product) => _selectedProductIds.contains(product.id))
        .toList();
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected products?'),
        content: Text(
          'This will delete ${selected.length} product(s). Products referenced by invoice or quote line items may be skipped.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    var deleted = 0;
    var failed = 0;
    for (final product in selected) {
      try {
        await ref.read(productProvider).deleteProduct(product.id);
        deleted += 1;
      } catch (_) {
        failed += 1;
      }
    }
    if (!context.mounted) return;
    _clearSelection();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Deleted $deleted product(s).'
          '${failed > 0 ? ' $failed skipped.' : ''}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productListProvider);
    final currencyCode =
        ref.watch(activeBusinessProvider).valueOrNull?.currencyCode ?? 'INR';

    return Scaffold(
      appBar: AppBar(
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Clear selection',
                onPressed: _clearSelection,
              )
            : null,
        title: Text(
          _isSelecting
              ? '${_selectedProductIds.length} selected'
              : 'Products & Services',
        ),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  onPressed: () {
                    final products = productsAsync.valueOrNull ?? const [];
                    _exportSelectedProducts(products, currencyCode);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete selected',
                  onPressed: () {
                    final products = productsAsync.valueOrNull ?? const [];
                    _deleteSelectedProducts(context, products);
                  },
                ),
              ]
            : null,
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'No products yet',
              message:
                  'Add products or services to reuse them in invoices and quotes.',
              actionLabel: 'Add Product',
              onAction: () => context.push('/add-product'),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return ListTile(
                selected: _selectedProductIds.contains(product.id),
                leading: _isSelecting
                    ? Checkbox(
                        value: _selectedProductIds.contains(product.id),
                        onChanged: (_) => _toggleProductSelection(product.id),
                      )
                    : Icon(
                        product.isService
                            ? Icons.design_services
                            : Icons.inventory_2,
                      ),
                title: Text(product.name),
                subtitle: Text(
                  '${product.isService ? 'Service' : 'Product'} | HSN/SAC: ${product.hsnSac} | Rate: ${formatMoney(product.salePrice, currencyCode: currencyCode)} | Stock: ${product.stockQuantity.toStringAsFixed(2)}',
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        context.push('/edit-product', extra: product);
                        break;
                      case 'delete':
                        _confirmDelete(context, ref, product.id);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Text(
                        product.isService ? 'Edit Service' : 'Edit Product',
                      ),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${product.gstRate}% GST'),
                      const SizedBox(width: 4),
                      const Icon(Icons.more_vert, size: 18),
                    ],
                  ),
                ),
                onTap: _isSelecting
                    ? () => _toggleProductSelection(product.id)
                    : () => context.push('/edit-product', extra: product),
                onLongPress: () => _toggleProductSelection(product.id),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-product'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
