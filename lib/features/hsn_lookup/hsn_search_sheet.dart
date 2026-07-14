import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/hsn_provider.dart';

class HsnSearchSheet extends ConsumerStatefulWidget {
  final DateTime? asOf;

  const HsnSearchSheet({super.key, this.asOf});

  @override
  ConsumerState<HsnSearchSheet> createState() => _HsnSearchSheetState();
}

class _HsnSearchSheetState extends ConsumerState<HsnSearchSheet> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hsnListAsync = ref.watch(hsnListProvider(widget.asOf));

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search HSN / SAC or Description',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  ref.read(hsnSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Expanded(
              child: hsnListAsync.when(
                data: (list) {
                  if (list.isEmpty) {
                    return const Center(
                      child: Text('No matching HSN/SAC codes found.'),
                    );
                  }
                  return ListView.builder(
                    controller: scrollController,
                    itemCount: list.length,
                    itemBuilder: (context, index) {
                      final item = list[index];
                      return ListTile(
                        leading: CircleAvatar(child: Text(item.type)),
                        title: Text(item.code),
                        subtitle: Text(
                          item.effectiveFrom != null
                              ? '${item.description} | From ${item.effectiveFrom!.toLocal().toString().split(' ')[0]}'
                              : item.description,
                        ),
                        trailing: item.gstRate != null
                            ? Text('${item.gstRate!.toStringAsFixed(1)}%')
                            : const Text('N/A'),
                        onTap: () {
                          Navigator.of(context).pop(item);
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Error: $err')),
              ),
            ),
          ],
        );
      },
    );
  }
}
