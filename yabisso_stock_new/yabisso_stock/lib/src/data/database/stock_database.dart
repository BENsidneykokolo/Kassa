import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

part 'stock_database.g.dart';

/// Colonnes communes à TOUTES les tables synchronisables du module,
/// pour rester cohérent avec le pattern déjà validé sur Kassa :
/// - [dirty]      : true tant que la ligne n'a pas été confirmée par le serveur
/// - [updatedAt]  : horodatage de la dernière modification locale
/// - [syncedAt]   : dernière synchro réussie (null si jamais synchronisé)
/// - [deletedAt]  : soft delete (jamais de DELETE physique en offline-first)
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()(); // entreprise propriétaire
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ---------------------------------------------------------------------------
// ENTREPÔTS / MAGASINS
// ---------------------------------------------------------------------------
class Warehouses extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get type =>
      text().withDefault(const Constant('boutique'))(); // boutique, entrepot central, cuisine...
  TextColumn get address => text().nullable()();
  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// FICHE STOCK D'UN PRODUIT (extension des données catalogue partagées avec
// Kassa/LOBA — le produit lui-même vit dans le package `yabisso_catalog`,
// ici on ne stocke QUE ce qui est spécifique au suivi de stock)
// ---------------------------------------------------------------------------
class StockItems extends Table with SyncColumns {
  TextColumn get catalogProductId => text()(); // FK logique -> yabisso_catalog.Product.id
  TextColumn get unit => text()(); // StockUnit.name — unité de référence du stock
  BoolColumn get trackByBatch =>
      boolean().withDefault(const Constant(false))(); // ex: viande, produits laitiers
  BoolColumn get trackExpiration =>
      boolean().withDefault(const Constant(false))();
  RealColumn get reorderThreshold =>
      real().withDefault(const Constant(0))(); // seuil d'alerte rupture (unité de référence)
  RealColumn get reorderQuantity =>
      real().withDefault(const Constant(0))(); // quantité suggérée à recommander
  BoolColumn get isRawMaterial =>
      boolean().withDefault(const Constant(false))(); // matière première (ex: riz, viande) vs produit fini vendable

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// LOTS (obligatoire uniquement si StockItem.trackByBatch == true)
// ---------------------------------------------------------------------------
class Batches extends Table with SyncColumns {
  TextColumn get stockItemId =>
      text().references(StockItems, #id)();
  TextColumn get warehouseId =>
      text().references(Warehouses, #id)();
  TextColumn get batchNumber => text().nullable()();
  DateTimeColumn get receivedAt => dateTime()();
  DateTimeColumn get expirationDate => dateTime().nullable()();
  RealColumn get initialQuantity => real()();
  RealColumn get remainingQuantity => real()();
  RealColumn get unitCost => real().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// MOUVEMENTS DE STOCK — source de vérité, tout le reste (niveaux de stock)
// est recalculé à partir de cette table (append-only, jamais modifiée).
// ---------------------------------------------------------------------------
class StockMovements extends Table with SyncColumns {
  TextColumn get stockItemId => text().references(StockItems, #id)();
  TextColumn get type => text()(); // StockMovementType.name
  TextColumn get sourceWarehouseId =>
      text().nullable().references(Warehouses, #id)();
  TextColumn get destWarehouseId =>
      text().nullable().references(Warehouses, #id)();
  TextColumn get batchId => text().nullable().references(Batches, #id)();
  RealColumn get quantity => real()(); // toujours positive, le [type] donne le sens
  TextColumn get unit => text()();
  TextColumn get reason => text().nullable()();
  // Référence externe : id de vente Kassa, id d'exécution de recette,
  // id de transfert (pour lier les 2 mouvements sortie+entrée), etc.
  TextColumn get externalRef => text().nullable()();
  TextColumn get createdByEmployeeId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// RECETTES (nomenclature) — ex: "Poulet Braisé" consomme 300g de poulet,
// 50g d'oignon, 20ml d'huile à chaque vente d'un menu Kassa lié.
// ---------------------------------------------------------------------------
class Recipes extends Table with SyncColumns {
  TextColumn get name => text()();
  // Produit fini du catalogue que cette recette permet de préparer
  // (ex: l'item de menu "Poulet Braisé" côté Kassa Restaurant).
  TextColumn get catalogProductId => text()();
  RealColumn get yieldQuantity =>
      real().withDefault(const Constant(1))(); // nombre de portions produites par exécution
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecipeIngredients extends Table with SyncColumns {
  TextColumn get recipeId => text().references(Recipes, #id)();
  TextColumn get stockItemId =>
      text().references(StockItems, #id)(); // la matière première consommée
  RealColumn get quantity => real()(); // pour 1x `yieldQuantity` de la recette
  TextColumn get unit => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Warehouses,
    StockItems,
    Batches,
    StockMovements,
    Recipes,
    RecipeIngredients,
  ],
)
class StockDatabase extends _$StockDatabase {
  StockDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
