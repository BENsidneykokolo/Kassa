/// Unité de mesure d'un produit. Chaque produit du catalogue a UNE unité de
/// référence (celle dans laquelle son stock est compté). Les recettes et les
/// mouvements peuvent utiliser une unité différente tant qu'une conversion
/// existe (ex: recette exprimée en grammes pour un produit stocké en kg).
enum StockUnit {
  piece, // ex: bouteille de Coca, unité vendable telle quelle
  kg,
  g,
  l,
  ml,
  carton,
  sac,
}

extension StockUnitX on StockUnit {
  /// Facteur de conversion vers l'unité "de base" du même type
  /// (g pour les unités de masse, ml pour les unités de volume).
  double get baseFactor {
    switch (this) {
      case StockUnit.kg:
        return 1000;
      case StockUnit.g:
        return 1;
      case StockUnit.l:
        return 1000;
      case StockUnit.ml:
        return 1;
      case StockUnit.piece:
      case StockUnit.carton:
      case StockUnit.sac:
        return 1; // unités "comptables", pas de conversion physique
    }
  }

  String get label {
    switch (this) {
      case StockUnit.piece:
        return 'unité';
      case StockUnit.kg:
        return 'kg';
      case StockUnit.g:
        return 'g';
      case StockUnit.l:
        return 'L';
      case StockUnit.ml:
        return 'mL';
      case StockUnit.carton:
        return 'carton';
      case StockUnit.sac:
        return 'sac';
    }
  }
}

/// Type de mouvement de stock — chaque ligne de StockMovements en porte un.
enum StockMovementType {
  entree, // réception fournisseur
  sortie, // vente directe (produit fini vendu tel quel, ex: bouteille de Coca)
  consommationRecette, // décrément automatique d'un ingrédient via une recette
  transfert, // entre deux entrepôts/magasins de la même entreprise
  ajustement, // correction manuelle (inventaire physique)
  perte, // casse, vol, péremption constatée
  retour, // retour client / retour fournisseur
}

/// Stratégie de sortie de lot lors d'une consommation.
enum LotStrategy {
  fefo, // First Expired, First Out — par défaut pour le périssable
  fifo, // First In, First Out — pour le non périssable sans DLC
}

/// Niveau de sévérité d'une alerte stock.
enum StockAlertLevel { info, attention, critique }
