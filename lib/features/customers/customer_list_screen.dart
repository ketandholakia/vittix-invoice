import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/widgets/empty_state.dart';
import '../../database/app_database.dart';
import '../../providers/customer_provider.dart';
import '../../services/share_service.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _statusFilter = 'ALL';
  final Set<int> _selectedCustomerIds = {};

  bool get _isSelecting => _selectedCustomerIds.isNotEmpty;

  void _toggleCustomerSelection(int customerId) {
    setState(() {
      if (!_selectedCustomerIds.add(customerId)) {
        _selectedCustomerIds.remove(customerId);
      }
    });
  }

  void _clearSelection() {
    setState(_selectedCustomerIds.clear);
  }

  Future<void> _exportSelectedCustomers(List<Customer> customers) async {
    final selected = customers
        .where((customer) => _selectedCustomerIds.contains(customer.id))
        .toList();
    if (selected.isEmpty) return;

    final rows = <List<String>>[
      ['Customer', 'GSTIN', 'PAN', 'Phone', 'Email', 'City', 'Status'],
      for (final customer in selected)
        [
          customer.name,
          customer.gstin ?? '',
          customer.pan ?? '',
          customer.phone ?? '',
          customer.email ?? '',
          customer.city ?? '',
          customer.isActive ? 'Active' : 'Inactive',
        ],
    ];

    await ShareService.shareCsv(
      rows,
      'selected_customers.csv',
      subject: 'Selected Customers',
      text: 'Selected customer export',
    );
  }

  Future<void> _deleteSelectedCustomers(
    BuildContext context,
    List<Customer> customers,
  ) async {
    final selected = customers
        .where((customer) => _selectedCustomerIds.contains(customer.id))
        .toList();
    if (selected.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete selected customers?'),
        content: Text(
          'This will delete ${selected.length} customer(s). Customers referenced by invoices or quotes may be skipped.',
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
    for (final customer in selected) {
      try {
        await ref.read(customerProvider).deleteCustomer(customer.id);
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
          'Deleted $deleted customer(s).'
          '${failed > 0 ? ' $failed skipped.' : ''}',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    int customerId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete customer?'),
        content: const Text(
          'This will remove the customer and may fail if invoices or quotes still reference it.',
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
      await ref.read(customerProvider).deleteCustomer(customerId);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete customer: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customerListProvider);

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
              ? '${_selectedCustomerIds.length} selected'
              : 'Customers',
        ),
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'Export selected',
                  onPressed: () {
                    final customers = customersAsync.valueOrNull ?? const [];
                    _exportSelectedCustomers(customers);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete selected',
                  onPressed: () {
                    final customers = customersAsync.valueOrNull ?? const [];
                    _deleteSelectedCustomers(context, customers);
                  },
                ),
              ]
            : null,
      ),
      body: customersAsync.when(
        data: (customers) {
          if (customers.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline,
              title: 'No customers yet',
              message:
                  'Add customers to track invoices, quotes, payments, and follow-ups.',
              actionLabel: 'Add Customer',
              onAction: () => context.push('/add-customer'),
            );
          }

          final filteredCustomers = customers.where((customer) {
            final matchesQuery =
                _query.isEmpty ||
                customer.name.toLowerCase().contains(_query) ||
                (customer.gstin ?? '').toLowerCase().contains(_query) ||
                (customer.phone ?? '').toLowerCase().contains(_query) ||
                (customer.email ?? '').toLowerCase().contains(_query);
            final matchesStatus =
                _statusFilter == 'ALL' ||
                (_statusFilter == 'ACTIVE' && customer.isActive) ||
                (_statusFilter == 'INACTIVE' && !customer.isActive);
            return matchesQuery && matchesStatus;
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search customers',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _query.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _query = '');
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                  onChanged: (value) =>
                      setState(() => _query = value.trim().toLowerCase()),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _statusFilter,
                        decoration: const InputDecoration(labelText: 'Status'),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All')),
                          DropdownMenuItem(
                            value: 'ACTIVE',
                            child: Text('Active'),
                          ),
                          DropdownMenuItem(
                            value: 'INACTIVE',
                            child: Text('Inactive'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _statusFilter = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filteredCustomers.isEmpty
                    ? const EmptyState(
                        icon: Icons.search_off,
                        title: 'No matching customers',
                        message:
                            'Adjust the search text or status filter to see more customers.',
                      )
                    : ListView.separated(
                        itemCount: filteredCustomers.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final customer = filteredCustomers[index];

                          return ListTile(
                            selected: _selectedCustomerIds.contains(
                              customer.id,
                            ),
                            leading: _isSelecting
                                ? Checkbox(
                                    value: _selectedCustomerIds.contains(
                                      customer.id,
                                    ),
                                    onChanged: (_) =>
                                        _toggleCustomerSelection(customer.id),
                                  )
                                : const Icon(Icons.person),
                            title: Text(customer.name),
                            subtitle: Text(
                              [
                                if ((customer.gstin ?? '').isNotEmpty)
                                  customer.gstin!,
                                if ((customer.phone ?? '').isNotEmpty)
                                  customer.phone!,
                                if ((customer.email ?? '').isNotEmpty)
                                  customer.email!,
                                customer.isActive ? 'Active' : 'Inactive',
                              ].join(' | '),
                            ),
                            onTap: () {
                              if (_isSelecting) {
                                _toggleCustomerSelection(customer.id);
                                return;
                              }
                              context.push('/customer-detail/${customer.id}');
                            },
                            onLongPress: () =>
                                _toggleCustomerSelection(customer.id),
                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                switch (value) {
                                  case 'edit':
                                    context.push(
                                      '/edit-customer',
                                      extra: customer,
                                    );
                                  case 'delete':
                                    _confirmDelete(context, ref, customer.id);
                                }
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Delete'),
                                ),
                              ],
                              child: const Icon(Icons.more_vert),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-customer'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
