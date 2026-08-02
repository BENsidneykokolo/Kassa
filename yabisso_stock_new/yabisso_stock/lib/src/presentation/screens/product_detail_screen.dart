import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../domain/enums.dart';
import '../../data/database/stock_database.dart';
import '../providers/stock_providers.dart';
import '../widgets/stock_badges.dart';
import 'stock_movement_form_screen.dart';

/// Fiche détaillée d'un article : niveau global, répartition par lot (si
/// suivi par lot), et historique des mouvements les plus récents.
class ProductDetailScreen extends ConsumerWidget {
  final String stockItemId;
  const ProductDetailScreen({super.key, required this.stockItemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(stockDatabaseProvider);
    final qtyAsync = ref.watch(
      stockQuantityProvider((stockItemId: stockItemId, warehouseId: null)),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Fiche article')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Mouvement'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => StockMovementFormScreen(stockItemId: stockItemId),
          ),
        ),
      ),
      body: FutureBuilder<StockItem>(
        future: (db.select(db.stockItems)..where((t) => t.id.equals(stockItemId)))
            .getSingle(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final item = snapshot.data!;
          final unit = StockUnit.values.byName(item.unit);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.catalogProductId,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Unité de suivi : ${unit.label}'),
                        ],
                      ),
                      qtyAsync.when(
                        data: (qty) => StockLevelBadge(
                          quantity: qty,
                          threshold: item.reorderThreshold,
                          unit: unit,
                        ),
                        loading: () => const CircularProgressIndicator(strokeWidth: 2),
                        error: (_, __) => const Icon(Icons.error_outline),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (item.trackByBatch) ...[
                const Text('Lots en stock', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                StreamBuilder<List<Batch>>(
                  stream: (db.select(db.batches)
                        ..where((t) =>
                            t.stockItemId.equals(stockItemId) &
                            t.remainingQuantity.isBiggerThanValue(0))
                        ..orderBy([(t) => drift.OrderingTerm(expression: t.expirationDate)]))
                      .watch(),
                  builder: (context, snap) {
                    final batches = snap.data ?? [];
                    if (batches.isEmpty) {
                      return const Text('Aucun lot actif.');
                    }
                    return Column(
                      children: batches
                          .map((b) => ListTile(
                                dense: true,
                                title: Text(b.batchNumber ?? 'Lot ${b.id.substring(0, 6)}'),
                                subtitle: Text('${b.remainingQuantity} ${unit.label} restants'),
                                trailing: ExpirationBadge(expirationDate: b.expirationDate),
                              ))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
              const Text('Historique des mouvements', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              StreamBuilder<List<StockMovement>>(
                stream: (db.select(db.stockMovements)
                      ..where((t) => t.stockItemId.equals(stockItemId))
                      ..orderBy([(t) => drift.OrderingTerm.desc(t.updatedAt)])
                      ..limit(30))
                    .watch(),
                builder: (context, snap) {
                  final movements = snap.data ?? [];
                  if (movements.isEmpty) {
                    return const Text('Aucun mouvement enregistré.');
                  }
                  return Column(
                    children: movements
                        .map((m) => ListTile(
                              dense: true,
                              leading: _iconForType(m.type),
                              title: Text('${_labelForType(m.type)} — ${m.quantity} ${m.unit}'),
                              subtitle: Text(m.reason ?? m.externalRef ?? ''),
                              trailing: m.dirty
                                  ? const Icon(Icons.sync, size: 16, color: Colors.grey)
                                  : const Icon(Icons.cloud_done, size: 16, color: Colors.green),
                            ))
                        .toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Icon _iconForType(String type) {
    switch (StockMovementType.values.byName(type)) {
      case StockMovementType.entree:
        return const Icon(Icons.call_received, color: Colors.green);
      case StockMovementType.sortie:
        return const Icon(Icons.call_made, color: Colors.blue);
      case StockMovementType.consommationRecette:
        return const Icon(Icons.restaurant, color: Colors.deepOrange);
      case StockMovementType.transfert:
        return const Icon(Icons.swap_horiz, color: Colors.purple);
      case StockMovementType.ajustement:
        return const Icon(Icons.tune, color: Colors.grey);
      case StockMovementType.perte:
        return const Icon(Icons.delete_outline, color: Colors.red);
      case StockMovementType.retour:
        return const Icon(Icons.undo, color: Colors.teal);
    }
  }

  String _labelForType(String type) {
    switch (StockMovementType.values.byName(type)) {
      case StockMovementType.entree:
        return 'Entrée';
      case StockMovementType.sortie:
        return 'Sortie';
      case StockMovementType.consommationRecette:
        return 'Conso. recette';
      case StockMovementType.transfert:
        return 'Transfert';
      case StockMovementType.ajustement:
        return 'Ajustement';
      case StockMovementType.perte:
        return 'Perte';
      case StockMovementType.retour:
        return 'Retour';
    }
  }
}
