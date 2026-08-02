import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/database/stock_database.dart';
import '../../data/repositories/stock_item_repository.dart';
import '../../application/stock_service.dart';

/// À surcharger (override) au démarrage de l'app avec l'instance réelle,
/// partagée avec les autres modules du monorepo si une seule connexion
/// SQLite est utilisée, ou dédiée si le module Stock a sa propre base.
final stockDatabaseProvider = Provider<StockDatabase>((ref) {
  throw UnimplementedError(
    'stockDatabaseProvider doit être surchargé au démarrage de l\'app '
    '(voir main.dart) avec la connexion Drift réelle.',
  );
});

final stockItemRepositoryProvider = Provider<StockItemRepository>((ref) {
  return StockItemRepository(ref.watch(stockDatabaseProvider));
});

final stockServiceProvider = Provider<StockService>((ref) {
  return StockService(ref.watch(stockDatabaseProvider));
});

/// Entreprise / tenant courant — à alimenter depuis la session utilisateur
/// (module RH / Auth partagé).
final currentTenantIdProvider = Provider<String>((ref) {
  throw UnimplementedError('currentTenantIdProvider doit être surchargé.');
});

final allStockItemsProvider = StreamProvider<List<StockItem>>((ref) {
  final repo = ref.watch(stockItemRepositoryProvider);
  final tenantId = ref.watch(currentTenantIdProvider);
  return repo.watchAll(tenantId);
});

final lowStockItemsProvider = FutureProvider<List<StockItem>>((ref) async {
  final repo = ref.watch(stockItemRepositoryProvider);
  final tenantId = ref.watch(currentTenantIdProvider);
  return repo.itemsBelowThreshold(tenantId);
});

/// Niveau de stock d'un article, optionnellement filtré par entrepôt.
final stockQuantityProvider =
    StreamProvider.family<double, ({String stockItemId, String? warehouseId})>(
  (ref, args) {
    final repo = ref.watch(stockItemRepositoryProvider);
    return repo.watchQuantity(args.stockItemId, warehouseId: args.warehouseId);
  },
);
