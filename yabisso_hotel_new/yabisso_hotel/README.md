# Yabisso Hôtel — Base Flutter

Base de l'application mobile **Yabisso Hôtel**, module ERP hôtelier de
l'écosystème Yabisso Business, construite à partir des deux prompts
UI/UX (Stitch AI) que tu as fournis.

## ⚠️ Étape obligatoire avant de lancer l'app

Ce projet a été généré à la main (pas de Flutter SDK disponible ici), donc
il ne contient que `lib/`, `pubspec.yaml` et `analysis_options.yaml` — il
manque les dossiers de plateforme (`android/`, `ios/`, `web/`, etc.).

Dans Antigravity ou un terminal, à la racine du projet :

```bash
flutter create . --project-name yabisso_hotel --org com.yabisso
flutter pub get
flutter run
```

`flutter create .` complète un dossier existant : il ajoute les dossiers
de plateforme manquants **sans toucher** à `lib/` ni `pubspec.yaml`.

## Structure

```
lib/
  core/
    theme/        → Design system (couleurs, typographie, ThemeData clair/sombre)
    router/        → go_router : toutes les routes de l'app
    constants/     → Enums partagés (rôles, statuts chambre/commande/réservation)
    services/      → Connectivity, Sync (offline-first), Session (rôle connecté)
    widgets/       → Composants réutilisables (StatCard, StatusBadge, SyncIndicator,
                      états vide/erreur/chargement, ModuleScaffold, AppShell)
  data/
    models/        → Room, Guest, Reservation, Employee, HotelOrder, HotelProfile
    mock/          → Données de démo pour développer l'UI sans backend
  features/
    auth/          → Splash, Onboarding (4 écrans), Login, Sélection de rôle
    dashboard/      → Dashboard Propriétaire (stats, graphique, activité, alertes, conseil IA)
    rooms/          → Gestion des chambres (grille filtrable, statuts colorés)
    reservations/   → Liste des réservations
    <18 autres modules> → écran fonctionnel "ModuleScaffold" prêt à être rempli
                          (Réception, Check-in, Check-out, Caisse Restaurant/Bar,
                          Room Service, Employés, Pointage, Housekeeping, Maintenance,
                          Stocks, Finances, CRM, Marketing, Analytics, AI Hotel Manager,
                          Portail Client, Notifications, Paramètres)
```

## Ce qui est déjà fonctionnel

- Navigation complète (go_router) : Splash → Onboarding → Login → Sélection
  de rôle → Dashboard, avec bottom navigation (Accueil / Chambres /
  Réservations / Plus) et un menu "Plus" qui donne accès aux 18 autres modules.
- Design system cohérent (palette bleu Yabisso + accents, police Inter,
  cartes/boutons/champs harmonisés, mode clair et sombre).
- Dashboard Propriétaire complet avec cartes statistiques, graphique de
  revenus (fl_chart), activité en temps réel, alertes et un bloc "Conseil IA".
- Écran Chambres avec grille de cartes colorées par statut, recherche et
  filtres par étage.
- Écran Réservations avec badges de statut.
- Écran Employés avec statut de présence.
- Squelette du moteur offline-first : `ConnectivityService` (détecte
  online/offline) + `SyncService` (état offline / syncing / synced, avec
  un `TODO` clair pour brancher l'envoi réel des données non synchronisées).
- Modèles de données prêts à être connectés à SQLite / au backend :
  `Room`, `Guest`, `Reservation`, `Employee`, `HotelOrder`, `HotelProfile`.

## Ce qu'il reste à faire (dans Antigravity)

1. **Intégrer tes écrans déjà générés.** Tu as mentionné un dossier
   d'écrans (`...\Kassa\fichiers\ecrans\hotel`) — envoie-les-moi ou
   importe-les directement dans les dossiers `features/<module>/`
   correspondants pour remplacer les `ModuleScaffold` (placeholders) par
   les vrais écrans.
2. Brancher une vraie base SQLite (via `sqflite`, déjà dans `pubspec.yaml`)
   pour stocker chambres/réservations/employés/commandes en local, avec la
   colonne `synced` pour le moteur offline-first.
3. Brancher `SyncService._runSync()` sur le backend réel une fois prêt.
4. Remplacer les données de `data/mock/mock_data.dart` par les vraies
   requêtes locales (Riverpod providers déjà en place pour t'y accrocher).
5. Reprendre les composants visuels de **Yabisso Kassa** pour la caisse
   Restaurant/Bar, le panier et les commandes, comme demandé dans ton
   prompt, afin de garder la cohérence UX entre Kassa et Hôtel.

## Design system — points clés

- Couleur principale : bleu `#1B4B8F` (identité Yabisso), accent or
  `#C9A24B` pour la touche "5 étoiles".
- Statuts chambre : disponible (vert), occupée (bleu), réservée (violet),
  nettoyage (ambre), inspection (cyan), maintenance (gris), hors service (rouge).
- Rayons de bord, espacements et typographie centralisés dans
  `core/theme/app_theme.dart` (`AppRadius`, `AppSpacing`) pour rester
  cohérent partout, y compris dans les écrans que tu ajouteras.
