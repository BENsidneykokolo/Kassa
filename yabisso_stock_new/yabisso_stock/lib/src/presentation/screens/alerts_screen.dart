import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../providers/stock_providers.dart';
import '../widgets/stock_badges.dart';
import 'product_detail_screen.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(stockDatabaseProvider);
    final lowStock = ref.watch(lowStockItemsProvider);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Alertes'),
          bottom: const TabBar(tabs: [
            Tab(text: 'Ruptures'),
            Tab(text: 'Péremption proche'),
          ]),
        ),
        body: TabBarView(
          children: [
            lowStock.when(
              data: (items) => items.isEmpty
                  ? const Center(child: Text('Aucune rupture en cours.'))
                  : ListView(
                      children: items
                          .map((item) => ListTile(
                                leading: const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                                title: Text(item.catalogProductId),
                                subtitle: Text('Seuil de réappro : ${item.reorderThreshold} ${item.unit}'),
                                trailing: TextButton(
                                  child: const Text('Commander'),
                                  onPressed: () {
                                    // TODO: brancher sur un futur bon de commande fournisseur
                                    // (ou lien direct vers Yabisso Facture côté achats).
                                  },
                                ),
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ProductDetailScreen(stockItemId: item.id),
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
            ),
            StreamBuilder<List<Batch>>(
              stream: (db.select(db.batches)
                    ..where((t) =>
                        t.remainingQuantity.isBiggerThanValue(0) &
                        t.expirationDate.isNotNull())
                    ..orderBy([(t) => drift.OrderingTerm(expression: t.expirationDate)])
                    ..limit(50))
                  .watch(),
              builder: (context, snap) {
                final batches = (snap.data ?? [])
                    .where((b) =>
                        b.expirationDate != null &&
                        b.expirationDate!.difference(DateTime.now()).inDays <= 7)
                    .toList();
                if (batches.isEmpty) {
                  return const Center(child: Text('Aucun lot proche de la péremption.'));
                }
                return ListView(
                  children: batches
                      .map((b) => ListTile(
                            leading: const Icon(Icons.hourglass_bottom, color: Colors.red),
                            title: Text(b.batchNumber ?? 'Lot ${b.id.substring(0, 6)}'),
                            subtitle: Text('${b.remainingQuantity} restant(s)'),
                            trailing: ExpirationBadge(expirationDate: b.expirationDate),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ProductDetailScreen(stockItemId: b.stockItemId),
                              ),
                            ),
                          ))
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
