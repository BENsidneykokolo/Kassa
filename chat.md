# Notes projet Kassa

## Build
- **NE JAMAIS lancer `flutter clean`** — le build Gradle est trop long (~30 min+)
- Flutter SDK : `C:\Users\Utilisateur\Downloads\flutter\bin\flutter.bat`
- Pour builder : `flutter build apk --release` (ou `--debug` pour tester)
- APK de sortie : `yabisso_kassa\build\app\outputs\flutter-apk\`
- Toujours utiliser le script PowerShell existant (`flutter_build2.ps1`) plutôt que `flutter clean` + build

## Session du 04/07/2026 — Vérification fichiers .md + reprise

### 00:00 — Vérification complète du contexte
- **User**: Vérifier tous les fichiers .md dans `fichiers/` pour le contexte + enregistrer automatiquement les échanges dans chat.md en temps réel + "think deeper" avant de répondre + vérifier/tester chaque implémentation
- **Opencode**: 
  - ✅ **5 fichiers .md principaux lus** : role.md, roadmap.md, task.md, implementation.md, probleme.md
  - ✅ **chat.md (fichiers/) lu** : historique complet des sessions (957 lignes)
  - ✅ **Contexte complet** : Kassa — App Flutter POS offline-first pour commerçants africains
    - **14 phases complétées** (Fondations → Devise/Langue/Excel)
    - **Phase 15 en cours** : Wiring CurrencyService, LanguageService, déploiement Render, Bluetooth, tests, Play Store
    - **Dashboard React** : Mobile-first, Points/Vouchers, Render config pushée
    - **Dernier build** : v1.4.6 (111.4 MB), flutter analyze 0 erreurs
    - **GitHub** : `BENsidneykokolo/Kassa`
  - ✅ **Règles actives** : auto-enregistrement chat ✓, think deeper ✓, vérifier/tester chaque implémentation ✓

---

## Session du 11/07/2026 (17:00) — Vérification fichiers .md + enregistrement automatique

### 17:00 — Vérification complète du contexte

- **User**: Vérifier tous les fichiers .md dans `fichiers/` pour le contexte, enregistrer automatiquement les échanges dans chat.md en temps réel, "think deeper" avant de répondre, et vérifier/tester chaque implémentation. Rôles : Developer IA, QA/Test Engineer IA, Code Reviewer IA.
- **Opencode**: 
  - ✅ **6 fichiers .md principaux lus** : role.md, roadmap.md, task.md, implementation.md, probleme.md, chat.md (2210 lignes)
  - ✅ **Contexte complet** : Kassa — Écosystème Flutter POS offline-first pour commerçants africains
    - **Kassa (POS)** : Phases 1-14 complétées, v1.4.11, APK 115.1 MB, Windows kassa.exe 22.4 MB, GitHub pushé
    - **Dashboard React** : Mobile-first, Points/Vouchers/Offline, Render config pushée
    - **7+ autres apps** : Restaurant, Hotel, Employés, Admin, Compta, CRM, Dépenses, École, Facture, RH, Stock
    - **Derniers correctifs** (11/07) : Fix DB bugs critiques (shops prestataire_id, check_out_time Admin, vendors employee_id)
    - **6 APKs** dans `apk/` : Kassa, Employés, Admin, Dashboard, Restaurant, Hotel
  - ✅ **Règles actives** : auto-enregistrement chat ✓, think deeper ✓, vérifier/tester chaque implémentation ✓

### Résumé de l'état actuel (11/07/2026)

| Composant | Statut | Détails |
|-----------|--------|---------|
| Flutter App (Kassa) | ✅ Pushé | v1.4.11, APK 115.1 MB, GitHub `BENsidneykokolo/Kassa` |
| Dashboard React | ✅ Pushé | GitHub `BENsidneykokolo/yabisso-admin-dashboard` |
| 7+ autres apps | ✅ Pushés | Restaurant, Hotel, Employés, Admin, Compta, CRM, Dépenses |
| Phases 1-14 | ✅ Complétées | Fondations → Devise/Langue/Excel |
| Phase 15 | ⏳ En attente | Wiring CurrencyService/LanguageService, Render deploy, tests, Play Store |
| Windows | ✅ Buildé | kassa.exe 22.4 MB |
| iOS/macOS | 🔄 | GitHub Actions configurés |

### Tâches en attente (task.md + implementation.md Phase 15)
| Priorité | Tâche | Statut |
|----------|-------|--------|
| P1 | Wiring CurrencyService.formatPrice() partout | À faire |
| P1 | Wiring LanguageService.translate() UI | À faire |
| P1 | Déploiement Render | En attente validation user |
| P1 | Mise à jour API URL Flutter après Render | En attente |
| P2 | Bluetooth printer (thermal printing) | À faire |
| P2 | Tests unitaires (Flutter) | À faire |
| P2 | Déploiement Play Store | À faire |

*En attente des instructions de Ben...*

### 17:30 — Exploration complète du code source yabisso_kassa

**Résultat de l'exploration** :
- **50+ fichiers Dart** dans lib/ (core/, database/, helpers/, models/, providers/, router/, screens/, services/, widgets/)
- **9 tables SQLite** (products, sales, sale_items, suppliers, vendors, expenses, categories, settings, inventory_history)
- **12 services** (currency, language, csv, excel, pdf, pack, points, offline_voucher, sync, hotspot_sync, image_labeler, product_exporter)
- **26 routes** GoRouter configurées
- **8 providers** Riverpod
- **DB version 9** avec migrations v1→v9

**Bug mineur trouvé** :
- `/suppliers/add` route pointe vers `AddProductScreen` au lieu d'un écran dédié
- `app_constants.dart` version `1.0.0` vs `pubspec.yaml` `1.4.3+13` (désynchronisé)
- `blue_thermal_printer` commenté dans pubspec.yaml

**Phase 15 — Tâches en attente** :
1. Wiring CurrencyService.formatPrice() partout dans l'app
2. Wiring LanguageService.translate() pour toutes les chaînes UI
3. Déploiement Render (validation user requise)
4. Mise à jour API URL Flutter après Render
5. Bluetooth printer (thermal printing)
6. Tests unitaires Flutter
7. Déploiement Play Store

*En attente des instructions de Ben...*

### 17:40 — Ajout bouton "Profil" dans bottom nav Dashboard Admin

**Demande** : Ajouter un accès "Paramètres" ou "Profil" dans la bottom nav du Dashboard Admin.

**Diagnostic** :
- Route `/profile` existante dans `main.dart:83` → `ProfileScreen`
- `ProfileScreen` a un bouton "Paramètres" qui navigue vers `/settings`
- `/settings` a le tile "Import / Export Pack" dans la section "Données"
- **Bug** : Aucun lien depuis le Dashboard vers `/profile` — la route était orpheline

**Fix** :
- Ajouté `_buildNavItem(Icons.person_outline, 'Profil', false, () => context.push('/profile'))` dans `_buildBottomNav()`
- Bottom nav : Dashboard → Employés → Ventes → Analyse → IA → **Profil** (nouveau)

**Fichier modifié** : `yabisso_admin/lib/screens/home/dashboard_screen.dart:547`

**Parcours corrigé** :
```
Dashboard → [Profil] → [Paramètres] → [Import / Export Pack]
```

**Vérification** :
- `Icons.person_outline` disponible via `material.dart` ✅
- Route `/profile` enregistrée dans GoRouter ✅
- Vérifié manuellement ✅

### 17:50 — Build APK Admin

- `flutter pub get` : dépendances OK
- `flutter build apk --release` : **72.5 MB**
- APK copié vers `apk/yabisso_admin.apk`
- Build : 11/07/2026

*En attente des instructions de Ben...*
