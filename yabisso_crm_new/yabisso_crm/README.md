# Yabisso CRM

Module de gestion de la relation client de l'écosystème Yabisso — base de
code générée, **à poursuivre dans Antigravity**, même principe que Yabisso
Hôtel et Yabisso Stock.

## Ce qui est livré

- **Schéma Drift complet** : `Contacts`, `Tags`/`ContactTags`,
  `Opportunities`, `Interactions`, `FollowUpReminders` — mêmes colonnes de
  synchro offline-first (`dirty`, `updatedAt`, `syncedAt`, `deletedAt`,
  `tenantId`) que Stock/Kassa.
- **Fiche 360° du contact** : coordonnées, opportunités liées, et un fil
  chronologique unique mêlant interactions manuelles (appel, visite,
  réunion, note) et interactions **remontées automatiquement** par les
  autres modules.
- **Pipeline commercial en kanban** glisser-déposer, implémenté avec les
  widgets natifs Flutter (`Draggable`/`DragTarget`) — pas de dépendance
  tierce risquée. Défilable horizontalement pour rester utilisable sur
  téléphone.
- **Rappels de suivi** avec bandeau d'alerte sur l'écran d'accueil dès
  qu'un rappel arrive à échéance.
- **Recherche locale** (nom, entreprise, téléphone) sur SQLite, 100%
  fonctionnelle hors-ligne.
- **Adaptateurs cross-module** dans `crm_service.dart` — c'est le point le
  plus important pour la cohérence de la suite :
  - `logPurchase()` — à appeler depuis Kassa/Facture après une vente.
  - `logReservation()` — à appeler depuis Booking après une réservation.
  - `logMessage()` — à appeler depuis WhatsApp/SMS à chaque message.
  Ces trois méthodes retrouvent (ou créent à la volée) le contact CRM
  correspondant via `linkedCustomerId`, puis journalisent l'événement —
  aucune ressaisie manuelle nécessaire pour que la fiche 360° reste à jour.
- **Registrar de synchro** (`crm_sync_registrar.dart`) : Interactions en
  append-only (insertOnly), Contacts/Opportunities en last-write-wins.

## Dépendances externes supposées

- `yabisso_ui` — kit de composants partagés.
- `yabisso_sync` — SDK générique de synchro (voir `yabisso-suite-specs.md`).
  Si pas encore prêt, `crm_sync_registrar.dart` peut être mis de côté sans
  bloquer le reste.

Contrairement à Yabisso Stock, le CRM **n'a pas besoin** du package
`yabisso_catalog` — son seul point d'ancrage externe est `linkedCustomerId`,
un simple identifiant texte que n'importe quel module vendeur peut fournir.

## Prochaines étapes suggérées dans Antigravity

1. `flutter pub get` puis `dart run build_runner build --delete-conflicting-outputs`
   pour générer `crm_database.g.dart`.
2. Brancher `crmDatabaseProvider` et `currentTenantIdProvider` sur la
   session réelle (module RH/Auth).
3. Câbler les 3 adaptateurs (`logPurchase`, `logReservation`, `logMessage`)
   depuis Kassa/Facture, Booking, et WhatsApp/SMS au fur et à mesure que ces
   modules avancent — c'est ce qui transforme le CRM en un vrai historique
   automatique plutôt qu'un carnet d'adresses de plus.
4. Étape non couverte ici : les **segments dynamiques** pour Yabisso
   Marketing (ex. "clients n'ayant pas acheté depuis 30 jours"). La table
   `Tags` posée ici gère les segments manuels ; les segments calculés
   demanderont une vue agrégée côté Analytics/Marketing plutôt qu'une table
   du CRM lui-même.
5. Les étapes du pipeline (`OpportunityStage`) sont fixes en V1. Si
   certaines entreprises veulent personnaliser leurs colonnes, prévoir une
   table `PipelineStages` par tenant plutôt que l'enum actuel.

## Pourquoi ces choix d'architecture

- **Interactions en append-only** : comme les mouvements de stock, le
  journal d'un contact ne doit jamais pouvoir être réécrit — c'est la
  mémoire de la relation client, potentiellement consultée en cas de litige
  ou pour comprendre pourquoi une affaire a été perdue.
- **`linkedCustomerId` plutôt qu'une vraie FK base de données** : le CRM
  doit pouvoir fonctionner même si Facture ou Booking ne sont pas encore
  installés chez un client Yabisso donné — le lien reste possible sans
  dépendance dure entre les packages.
- **Kanban en widgets natifs** : évite d'introduire une dépendance externe
  dont la maintenance et la compatibilité avec les futures versions de
  Flutter ne sont pas garanties, pour un composant qui reste simple à
  reproduire soi-même.
