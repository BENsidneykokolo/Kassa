import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../database/stock_database.dart';

/// Niveau de stock agrégé d'un [StockItem] pour un entrepôt donné (ou tous).
class StockLevel {
  final String stockItemId;
  final String? warehouseId;
  final double quantity;
  final DateTime? nearestExpiration;

  const StockLevel({
    required this.stockItemId,
    required this.warehouseId,
    required this.quantity,
    this.nearestExpiration,
  });
}

class StockItemRepository {
  final StockDatabase _db;
  StockItemRepository(this._db);

  Stream<List<StockItem>> watchAll(String tenantId) {
    return (_db.select(_db.stockItems)
          ..where((t) => t.tenantId.equals(tenantId) & t.deletedAt.isNull()))
        .watch();
  }

  Future<String> upsert(StockItemsCompanion item) async {
    final id = item.id.present ? item.id.value : const Uuid().v4();
    await _db.into(_db.stockItems).insertOnConflictUpdate(
          item.copyWith(
            id: Value(id),
            dirty: const Value(true),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return id;
  }

  /// Niveau de stock courant = somme de tous les mouvements signés.
  /// Recalculé à la volée à partir de StockMovements (source de vérité) —
  /// pas de colonne "quantité" dénormalisée qui pourrait diverger.
  Stream<double> watchQuantity(String stockItemId, {String? warehouseId}) {
    final query = _db.customSelect(
      '''
      SELECT COALESCE(SUM(
        CASE
          WHEN type = 'entree' THEN quantity
          WHEN type = 'retour' THEN quantity
          WHEN type = 'sortie' THEN -quantity
          WHEN type = 'consommationRecette' THEN -quantity
          WHEN type = 'perte' THEN -quantity
          WHEN type = 'ajustement' THEN quantity
          WHEN type = 'transfert' THEN
            CASE WHEN dest_warehouse_id = ?2 THEN quantity
                 WHEN source_warehouse_id = ?2 THEN -quantity
                 ELSE 0 END
          ELSE 0
        END
      ), 0) as qty
      FROM stock_movements
      WHERE stock_item_id = ?1
        AND deleted_at IS NULL
        AND (?2 IS NULL OR source_warehouse_id = ?2 OR dest_warehouse_id = ?2)
      ''',
      variables: [Variable(stockItemId), Variable(warehouseId)],
      readsFrom: {_db.stockMovements},
    );
    return query.watchSingle().map((row) => row.read<double>('qty'));
  }

  /// Produits sous leur seuil de réapprovisionnement — alimente l'écran Alertes.
  Future<List<StockItem>> itemsBelowThreshold(String tenantId) async {
    final items = await (_db.select(_db.stockItems)
          ..where((t) => t.tenantId.equals(tenantId) & t.deletedAt.isNull()))
        .get();
    final results = <StockItem>[];
    for (final item in items) {
      final qty = await watchQuantity(item.id).first;
      if (qty <= item.reorderThreshold) results.add(item);
    }
    return results;
  }
}
