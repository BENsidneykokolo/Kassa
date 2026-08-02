import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/database/stock_database.dart';
import '../domain/enums.dart';

/// Service métier central du module Stock. Toute écriture de mouvement passe
/// par ici — jamais d'INSERT direct dans StockMovements depuis l'UI — pour
/// garantir que la logique FEFO / recette / transfert reste cohérente.
class StockService {
  final StockDatabase _db;
  final _uuid = const Uuid();

  StockService(this._db);

  // ---------------------------------------------------------------------
  // ENTRÉE (réception fournisseur)
  // ---------------------------------------------------------------------
  Future<void> receiveStock({
    required String tenantId,
    required String stockItemId,
    required String warehouseId,
    required double quantity,
    required StockUnit unit,
    String? batchNumber,
    DateTime? expirationDate,
    double unitCost = 0,
    String? employeeId,
  }) async {
    await _db.transaction(() async {
      String? batchId;
      final item = await (_db.select(_db.stockItems)
            ..where((t) => t.id.equals(stockItemId)))
          .getSingle();

      if (item.trackByBatch) {
        batchId = _uuid.v4();
        await _db.into(_db.batches).insert(
              BatchesCompanion.insert(
                id: Value(batchId),
                tenantId: tenantId,
                stockItemId: stockItemId,
                warehouseId: warehouseId,
                batchNumber: Value(batchNumber),
                receivedAt: DateTime.now(),
                expirationDate: Value(expirationDate),
                initialQuantity: quantity,
                remainingQuantity: quantity,
                unitCost: Value(unitCost),
              ),
            );
      }

      await _insertMovement(
        tenantId: tenantId,
        stockItemId: stockItemId,
        type: StockMovementType.entree,
        destWarehouseId: warehouseId,
        batchId: batchId,
        quantity: quantity,
        unit: unit,
        createdByEmployeeId: employeeId,
      );
    });
  }

  // ---------------------------------------------------------------------
  // SORTIE directe (vente d'un produit fini tel quel, ex: bouteille de Coca)
  // ---------------------------------------------------------------------
  Future<void> recordSale({
    required String tenantId,
    required String stockItemId,
    required String warehouseId,
    required double quantity,
    required StockUnit unit,
    String? saleExternalRef,
    String? employeeId,
  }) async {
    await _consumeFefo(
      tenantId: tenantId,
      stockItemId: stockItemId,
      warehouseId: warehouseId,
      quantity: quantity,
      unit: unit,
      type: StockMovementType.sortie,
      externalRef: saleExternalRef,
      employeeId: employeeId,
    );
  }

  // ---------------------------------------------------------------------
  // TRANSFERT entre deux magasins/entrepôts
  // Génère un mouvement unique de type `transfert` (source ET destination
  // renseignées) — le niveau de stock par entrepôt est déduit du signe
  // selon la colonne consultée (voir StockItemRepository.watchQuantity).
  // ---------------------------------------------------------------------
  Future<void> transfer({
    required String tenantId,
    required String stockItemId,
    required String sourceWarehouseId,
    required String destWarehouseId,
    required double quantity,
    required StockUnit unit,
    String? employeeId,
  }) async {
    if (sourceWarehouseId == destWarehouseId) {
      throw ArgumentError('Le magasin source et destination doivent différer.');
    }
    final transferRef = _uuid.v4();
    await _insertMovement(
      tenantId: tenantId,
      stockItemId: stockItemId,
      type: StockMovementType.transfert,
      sourceWarehouseId: sourceWarehouseId,
      destWarehouseId: destWarehouseId,
      quantity: quantity,
      unit: unit,
      externalRef: transferRef,
      createdByEmployeeId: employeeId,
    );
    // Note offline : si les deux appareils (boutique source / destination)
    // ne sont pas le même appareil, ce mouvement est répliqué aux deux via
    // YCE/Yabisso Sync — la destination le voit apparaître dès que les
    // appareils sont à portée ou que la sync internet passe.
  }

  // ---------------------------------------------------------------------
  // AJUSTEMENT (inventaire physique par scan) — delta signé
  // ---------------------------------------------------------------------
  Future<void> adjustFromInventory({
    required String tenantId,
    required String stockItemId,
    required String warehouseId,
    required double countedQuantity,
    required double systemQuantity,
    required StockUnit unit,
    String? employeeId,
    String? reason,
  }) async {
    final delta = countedQuantity - systemQuantity;
    if (delta == 0) return;
    await _insertMovement(
      tenantId: tenantId,
      stockItemId: stockItemId,
      type: StockMovementType.ajustement,
      destWarehouseId: delta > 0 ? warehouseId : null,
      sourceWarehouseId: delta < 0 ? warehouseId : null,
      quantity: delta.abs(),
      unit: unit,
      reason: reason ?? 'Écart inventaire physique',
      createdByEmployeeId: employeeId,
    );
  }

  // ---------------------------------------------------------------------
  // CONSOMMATION AUTOMATIQUE VIA RECETTE
  // Ex: vente d'1 "Poulet Braisé" (Kassa Restaurant) -> décrémente
  // automatiquement 300g de poulet, 50g d'oignon, 20ml d'huile, etc.
  // Appelé par le hook de vente Kassa au moment de l'encaissement.
  // ---------------------------------------------------------------------
  Future<void> consumeRecipe({
    required String tenantId,
    required String recipeId,
    required String warehouseId,
    required double portionsSold,
    String? saleExternalRef,
    String? employeeId,
  }) async {
    final recipe =
        await (_db.select(_db.recipes)..where((t) => t.id.equals(recipeId)))
            .getSingle();
    final ingredients = await (_db.select(_db.recipeIngredients)
          ..where((t) => t.recipeId.equals(recipeId)))
        .get();

    final ratio = portionsSold / recipe.yieldQuantity;

    await _db.transaction(() async {
      for (final ing in ingredients) {
        final qtyNeeded = ing.quantity * ratio;
        await _consumeFefo(
          tenantId: tenantId,
          stockItemId: ing.stockItemId,
          warehouseId: warehouseId,
          quantity: qtyNeeded,
          unit: StockUnit.values.byName(ing.unit),
          type: StockMovementType.consommationRecette,
          externalRef: saleExternalRef ?? recipeId,
          employeeId: employeeId,
        );
      }
    });
  }

  // ---------------------------------------------------------------------
  // Cœur FEFO : consomme la quantité demandée en piochant dans les lots
  // les plus proches de la péremption d'abord. Si l'article n'est pas géré
  // par lot, crée simplement un mouvement global sans batchId.
  // ---------------------------------------------------------------------
  Future<void> _consumeFefo({
    required String tenantId,
    required String stockItemId,
    required String warehouseId,
    required double quantity,
    required StockUnit unit,
    required StockMovementType type,
    String? externalRef,
    String? employeeId,
  }) async {
    final item = await (_db.select(_db.stockItems)
          ..where((t) => t.id.equals(stockItemId)))
        .getSingle();

    if (!item.trackByBatch) {
      await _insertMovement(
        tenantId: tenantId,
        stockItemId: stockItemId,
        type: type,
        sourceWarehouseId: warehouseId,
        quantity: quantity,
        unit: unit,
        externalRef: externalRef,
        createdByEmployeeId: employeeId,
      );
      return;
    }

    final batches = await (_db.select(_db.batches)
          ..where((t) =>
              t.stockItemId.equals(stockItemId) &
              t.warehouseId.equals(warehouseId) &
              t.remainingQuantity.isBiggerThanValue(0) &
              t.deletedAt.isNull())
          ..orderBy([
            (t) => OrderingTerm(
                  expression: t.expirationDate,
                  mode: OrderingMode.asc,
                  nulls: NullsOrder.last, // pas de DLC -> consommé en dernier
                )
          ]))
        .get();

    var remaining = quantity;
    await _db.transaction(() async {
      for (final batch in batches) {
        if (remaining <= 0) break;
        final taken = remaining < batch.remainingQuantity
            ? remaining
            : batch.remainingQuantity;

        await (_db.update(_db.batches)..where((t) => t.id.equals(batch.id)))
            .write(BatchesCompanion(
          remainingQuantity: Value(batch.remainingQuantity - taken),
          dirty: const Value(true),
          updatedAt: Value(DateTime.now()),
        ));

        await _insertMovement(
          tenantId: tenantId,
          stockItemId: stockItemId,
          type: type,
          sourceWarehouseId: warehouseId,
          batchId: batch.id,
          quantity: taken,
          unit: unit,
          externalRef: externalRef,
          createdByEmployeeId: employeeId,
        );
        remaining -= taken;
      }

      if (remaining > 0) {
        // Stock insuffisant en lots connus : on consomme quand même pour ne
        // jamais bloquer une vente, mais on trace un mouvement "hors lot" +
        // signal pour que l'écran Alertes remonte l'incohérence à corriger
        // au prochain inventaire physique.
        await _insertMovement(
          tenantId: tenantId,
          stockItemId: stockItemId,
          type: type,
          sourceWarehouseId: warehouseId,
          quantity: remaining,
          unit: unit,
          reason: 'Consommé hors lot connu — vérifier inventaire',
          externalRef: externalRef,
          createdByEmployeeId: employeeId,
        );
      }
    });
  }

  Future<void> _insertMovement({
    required String tenantId,
    required String stockItemId,
    required StockMovementType type,
    String? sourceWarehouseId,
    String? destWarehouseId,
    String? batchId,
    required double quantity,
    required StockUnit unit,
    String? reason,
    String? externalRef,
    String? createdByEmployeeId,
  }) async {
    await _db.into(_db.stockMovements).insert(
          StockMovementsCompanion.insert(
            id: Value(_uuid.v4()),
            tenantId: tenantId,
            stockItemId: stockItemId,
            type: type.name,
            sourceWarehouseId: Value(sourceWarehouseId),
            destWarehouseId: Value(destWarehouseId),
            batchId: Value(batchId),
            quantity: quantity,
            unit: unit.name,
            reason: Value(reason),
            externalRef: Value(externalRef),
            createdByEmployeeId: Value(createdByEmployeeId),
          ),
        );
    // dirty=true par défaut (colonne SyncColumns) -> repris automatiquement
    // par Yabisso Sync au prochain cycle YCE.
  }
}
