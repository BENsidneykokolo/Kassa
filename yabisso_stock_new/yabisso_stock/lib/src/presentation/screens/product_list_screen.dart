import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums.dart';
import '../providers/stock_providers.dart';
import '../widgets/stock_badges.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allStockItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Articles en stock'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Rechercher un produit…',
                prefixIcon: Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
              ),
              onChanged: (v) => setState(() => _query = v.toLowerCase()),
            ),
          ),
        ),
      ),
      body: itemsAsync.when(
        data: (items) {
          final filtered = items
              .where((i) => i.catalogProductId.toLowerCase().contains(_query))
              .toList();
          if (filtered.isEmpty) {
            return const Center(child: Text('Aucun article trouvé.'));
          }
          return ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = filtered[index];
              final qtyAsync = ref.watch(
                stockQuantityProvider((stockItemId: item.id, warehouseId: null)),
              );
              return ListTile(
                title: Text(item.catalogProductId),
                subtitle: Text(item.isRawMaterial ? 'Matière première' : 'Produit fini'),
                trailing: qtyAsync.when(
                  data: (qty) => StockLevelBadge(
                    quantity: qty,
                    threshold: item.reorderThreshold,
                    unit: StockUnit.values.byName(item.unit),
                  ),
                  loading: () => const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Icon(Icons.error_outline, size: 16),
                ),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductDetailScreen(stockItemId: item.id)),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur : $e')),
      ),
    );
  }
}
