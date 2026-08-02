import 'package:yabisso_sync/yabisso_sync.dart';
import '../../data/database/stock_database.dart';

/// Déclare au SDK Yabisso Sync comment synchroniser les tables du module
/// Stock via YCE (Internet -> WiFi Direct -> Nearby -> BLE Mesh -> SMS).
///
/// Stratégies de résolution de conflit :
/// - StockMovements : append-only, jamais de conflit (chaque ligne est un
///   fait immuable une fois créée) -> stratégie `insertOnly`.
/// - Batches.remainingQuantity : deux appareils peuvent décrémenter le même
///   lot hors-ligne en parallèle -> `mergeAdditive` (on rejoue les deltas
///   plutôt que d'écraser une valeur absolue).
/// - StockItems / Warehouses / Recipes / RecipeIngredients : édition de
///   fiche par un seul gérant en général -> `lastWriteWins`.
class StockSyncRegistrar {
  static void register(YabissoSync sync, StockDatabase db) {
    sync.registerTable(
      table: db.warehouses,
      priority: SyncPriority.high, // petite table, peu d'octets, utile partout
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.stockItems,
      priority: SyncPriority.high,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.batches,
      priority: SyncPriority.medium,
      conflictStrategy: ConflictStrategy.mergeAdditive,
      mergeField: 'remainingQuantity',
    );

    sync.registerTable(
      table: db.stockMovements,
      priority: SyncPriority.critical, // source de vérité, à répliquer en premier
      conflictStrategy: ConflictStrategy.insertOnly,
    );

    sync.registerTable(
      table: db.recipes,
      priority: SyncPriority.low,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.recipeIngredients,
      priority: SyncPriority.low,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );
  }
}
