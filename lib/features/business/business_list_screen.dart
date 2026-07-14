import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../providers/business_provider.dart';
import '../../providers/shared_preferences_provider.dart';

class BusinessListScreen extends ConsumerWidget {
  const BusinessListScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int businessId,
    bool isActive,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete business?'),
        content: const Text(
          'This will remove the business and may fail if related records still exist.',
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
      await ref.read(businessProvider).deleteBusiness(businessId);
      if (isActive) {
        ref.read(activeBusinessIdProvider.notifier).clearActiveBusiness();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete business: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final businessesAsync = ref.watch(businessListProvider);
    final activeBusinessId = ref.watch(activeBusinessIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Businesses')),
      body: businessesAsync.when(
        data: (businesses) {
          if (businesses.isEmpty) {
            return EmptyState(
              icon: Icons.business_outlined,
              title: 'No businesses yet',
              message:
                  'Add a business profile before creating invoices, quotes, customers, or products.',
              actionLabel: 'Add Business',
              onAction: () => context.push('/add-business'),
            );
          }
          return ListView.builder(
            itemCount: businesses.length,
            itemBuilder: (context, index) {
              final business = businesses[index];
              final isActive = business.id == activeBusinessId;

              return ListTile(
                leading: Icon(
                  isActive ? Icons.check_circle : Icons.business,
                  color: isActive ? Colors.green : null,
                ),
                title: Text(business.name),
                subtitle: Text('GSTIN: ${business.gstin}'),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'activate':
                        ref
                            .read(activeBusinessIdProvider.notifier)
                            .setActiveBusinessId(business.id);
                      case 'edit':
                        context.push('/edit-business', extra: business);
                      case 'delete':
                        _confirmDelete(context, ref, business.id, isActive);
                    }
                  },
                  itemBuilder: (context) => [
                    if (!isActive)
                      const PopupMenuItem(
                        value: 'activate',
                        child: Text('Set Active'),
                      ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                  child: isActive
                      ? const Text(
                          'Active',
                          style: TextStyle(color: Colors.green),
                        )
                      : const Icon(Icons.more_vert),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-business'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
