# Yabisso Stock

Module de gestion d'inventaire de l'écosystème Yabisso — base de code générée,
**à poursuivre dans Antigravity**, sur le même principe que Yabisso Hôtel.

## Ce qui est livré

- **Schéma Drift complet** (`lib/src/data/database/stock_database.dart`) :
  `Warehouses`, `StockItems`, `Batches`, `StockMovements`, `Recipes`,
  `RecipeIngredients` — toutes avec les colonnes de synchro offline-first
  (`dirty`, `updatedAt`, `syncedAt`, `deletedAt`, `tenantId`) alignées sur le
  pattern déjà utilisé côté Kassa.
- **Logique métier centrale** (`stock_service.dart`) :
  - réception fournisseur (avec ou sans lot / DLC),
  - sortie FEFO (First Expired, First Out) automatique par lot,
  - transfert inter-magasins (un seul mouvement, source + destination),
  - ajustement d'inventaire (delta signé),
  - **consommation automatique via recette** — le cas restaurant demandé :
    une vente de "Poulet Braisé" décrémente automatiquement poulet, oignon,
    huile, etc. selon la nomenclature définie dans `Recipes`/`RecipeIngredients`.
- **Unités hétérogènes** (`domain/enums.dart`) : pièce, kg, g, L, mL, carton,
  sac — avec facteurs de conversion, pour couvrir "1 bouteille de Coca" vs
  "riz en kg" vs "viande en g" dans le même système.
- **8 écrans fonctionnels** : Dashboard, Liste articles, Fiche produit
  (lots + historique), Formulaire de mouvement, Transfert, Inventaire par
  scan (code-barres), Alertes (rupture + péremption), Recettes.
- **Registrar de synchro** (`stock_sync_registrar.dart`) : déclare au SDK
  `yabisso_sync` comment chaque table doit être répliquée via YCE, avec la
  bonne stratégie de conflit par table (append-only pour les mouvements,
  merge additif pour les quantités de lot, last-write-wins pour les fiches).

## Dépendances externes supposées (à créer/brancher dans le monorepo)

Le `pubspec.yaml` référence trois packages internes qui n'existent pas
encore en tant que tels dans ce livrable — ils sont supposés faire partie
du monorepo Flutter en cours de consolidation :

- `yabisso_ui` — kit de composants partagés (déjà en discussion avec Kassa/LOBA).
- `yabisso_catalog` — le produit "canonique" (nom, code-barres, prix, image)
  partagé avec Kassa. `StockItem.catalogProductId` y fait référence en FK
  logique. **Étape à faire dans Antigravity** : brancher la vraie résolution
  code-barres → `catalogProductId` (actuellement simulée dans
  `inventory_scan_screen.dart`).
- `yabisso_sync` — SDK générique de synchro décrit dans le document de
  spécification de la suite (`yabisso-suite-specs.md`). S'il n'existe pas
  encore, `stock_sync_registrar.dart` peut être mis de côté (`// TODO`)
  jusqu'à ce que le SDK soit prêt, sans bloquer le reste du module.

## Prochaines étapes suggérées dans Antigravity

1. `flutter pub get` puis `dart run build_runner build --delete-conflicting-outputs`
   pour générer `stock_database.g.dart` (le fichier `part` référencé n'est
   pas généré ici — c'est le rôle de `drift_dev`).
2. Brancher `stockDatabaseProvider` et `currentTenantIdProvider` sur la
   session réelle (auth + module RH pour le tenant courant).
3. Remplacer la matérialisation "carte" des matières premières : à ce
   stade, `StockItems.catalogProductId` est un `String` libre — le lier au
   vrai package catalogue pour afficher noms/photos au lieu de l'ID brut
   dans l'UI (actuellement affiché tel quel dans les listes, volontairement
   simplifié).
4. Ajouter le hook côté Kassa : à chaque ligne de vente encaissée, appeler
   soit `StockService.recordSale` (produit fini vendu tel quel, ex: Coca),
   soit `StockService.consumeRecipe` (plat préparé, ex: restaurant) selon
   que le produit vendu a une recette associée ou non.
5. Écran "Bon de commande fournisseur" (bouton "Commander" dans
   `alerts_screen.dart` est un stub) — probablement à construire en même
   temps que Yabisso Facture côté achats.
6. Différencier proprement le mouvement `perte` de `sortie` dans
   `StockService` (actuellement simplifié dans le formulaire de mouvement —
   voir commentaire dans `stock_movement_form_screen.dart`).

## Pourquoi ces choix d'architecture

- **Mouvements en append-only** : aucune table de "stock actuel" n'est
  stockée directement — tout est recalculé depuis `StockMovements`. C'est
  plus lent à la lecture mais élimine toute divergence possible entre deux
  appareils qui se synchronisent après plusieurs jours hors-ligne : il n'y a
  qu'une seule source de vérité (le journal des faits), jamais un total à
  réconcilier.
- **FEFO automatique** : le gérant n'a jamais à choisir manuellement quel
  lot consommer — critique pour un utilisateur peu technique en boutique ou
  en cuisine.
- **Recettes comme nomenclature indépendante du POS** : `Recipes` ne connaît
  que des `stockItemId`, jamais directement le panier Kassa — ça permet de
  réutiliser Yabisso Stock pour n'importe quel module vendeur futur (Hôtel
  room-service, Delivery, etc.) sans dépendance croisée.
