# Roadmap — YABISSO KASSA

## Vue d'ensemble du projet

**Yabisso Kassa** — Application Flutter Cross-Platform Offline-First (POS) pour petits commerçants africains (épiceries, kiosques, boutiques de quartier) en Afrique francophone (Congo, Côte d'Ivoire, Sénégal, Cameroun, etc.)

- **100% offline** — Internet est optionnel
- **Données locales** : SQLite sur l'appareil
- **Backup** : Google Drive (compte utilisateur)
- **Langue** : Français
- **Devise** : FCFA

---

## Plateformes cibles

| Priorité | Plateforme | Version | Notes |
|----------|-----------|---------|-------|
| **P1** | Android | 5.0+ (API 21+) | Priorité absolue |
| **P2** | iOS | 13+ | Priorité #2 |
| **P3** | Windows | 10/11 | Priorité #3 |
| - | iPadOS | - | Plus tard |
| - | macOS | - | Optionnel, plus tard |
| - | Linux | - | Optionnel, plus tard |

---

## Tech Stack

| Composant | Choix |
|-----------|-------|
| Framework | Flutter (dernière stable) |
| State Management | Riverpod |
| Local Database | sqflite |
| Navigation | go_router |
| Backup | Google Drive API |
| Auth | google_sign_in |

### Packages requis (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path: ^1.9.0
  path_provider: ^2.1.3
  flutter_riverpod: ^2.5.1
  go_router: ^13.2.0
  google_sign_in: ^6.2.1
  googleapis: ^12.0.0
  image_picker: ^1.1.0
  connectivity_plus: ^6.0.3
  url_launcher: ^6.3.0
  screenshot: ^2.3.0
  gallery_saver: ^2.3.2
  flutter_local_notifications: ^17.2.0
  google_fonts: ^6.2.1
  intl: ^0.19.0
  flutter_secure_storage: ^9.2.2
  uuid: ^4.4.0
  shared_preferences: ^2.3.2
  bcrypt: ^1.1.3
  blue_thermal_printer: ^1.1.0
  window_manager: ^0.3.8
  hotkey_manager: ^0.2.0
  context_menus: ^1.0.2
```

---

## Configuration par plateforme

### Android (`android/app/build.gradle`)
```groovy
minSdkVersion 21
targetSdkVersion 34
compileSdkVersion 34
```

### Android Permissions (`AndroidManifest.xml`)
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.BLUETOOTH"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT"/>
<uses-permission android:name="android.permission.BLUETOOTH_SCAN"/>
```

### iOS (`Info.plist`)
```xml
<key>NSCameraUsageDescription</key>
<string>Camera pour scanner les produits</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Accès aux photos pour les produits</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Sauvegarder des photos de produits</string>
```

### Windows (`CMakeLists.txt`)
- Activer `window_manager`
- Taille min fenêtre : 900×600
- Icône : logo Yabisso Kassa

---

## Système de couleurs (Yabisso brand)

| Nom | Hex |
|-----|-----|
| Primary Green | `#1D9E75` |
| Primary Blue | `#378ADD` |
| Primary Red | `#E24B4A` |
| Primary Amber | `#F5A623` |
| Text Dark | `#111111` |
| Background | `#F7F8FA` |
| Border | `#E0E0E0` |

---

## Stratégie Responsive (LayoutBuilder + Breakpoints)

```dart
const double mobileBreakpoint = 600;
const double tabletBreakpoint = 900;
const double desktopBreakpoint = 1200;
```

| Layout | Largeur | Navigation | Grille produits | Vue panier |
|--------|---------|------------|-----------------|------------|
| Mobile | < 600px | BottomNavBar (4 icons) | 2 colonnes | Plein écran |
| Tablette | 600-900px | Rail/BottomNav | 3 colonnes | Split view |
| Desktop | > 900px | Sidebar 240px persistant | 4-5 colonnes | Split permanent (60/40) |

---

## Architecture Offline-First

### Principe fondamental
100% offline. Toutes les lectures/écritures → SQLite local uniquement.
Sync Google Drive en arrière-plan quand connecté.

### Détection réseau
`connectivity_plus` surveille la connexion.
Indicateur : 🔴 Hors ligne / 🟢 En ligne

### Sauvegarde Google Drive
- Authentification une seule fois avec compte Google
- Auto-backup toutes les 24h quand connecté
- Export : toutes les tables SQLite → fichier JSON
- Fichier : `yabisso_backup_YYYY-MM-DD.json`
- Garder les 7 derniers backups
- Restauration : téléchargement → réimport vers SQLite

---

## Phase 1 — Fondations (Semaines 1-2)

### 1.1 Setup du projet
- [ ] Créer le projet Flutter multi-plateforme
- [ ] Configurer `pubspec.yaml`
- [ ] Structure de dossiers :
  ```
  lib/
  ├── core/          (theme, constants, utils, device_layout)
  ├── models/        (Product, Sale, SaleItem, Vendor, Supplier, Expense)
  ├── providers/     (Riverpod providers)
  ├── screens/       (products, stock, analysis, settings, payment)
  ├── widgets/       (communs, product_card, cart, numpad)
  ├── database/      (SQLite helpers, DAOs)
  ├── router/        (go_router config)
  └── main.dart
  ```
- [ ] Class `DeviceLayout` helper (détection responsive)

### 1.2 Thème & Design System
- [ ] Appliquer les couleurs Yabisso
- [ ] Typographie adaptative
- [ ] Touch targets minimum par plateforme

### 1.3 Base de données SQLite
- [ ] Schéma complet :

```sql
-- products
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  price REAL NOT NULL,
  cost_price REAL,
  stock INTEGER DEFAULT 0,
  stock_alert INTEGER DEFAULT 10,
  photo_path TEXT,
  supplier_id TEXT,
  created_at TEXT
);

-- sales
CREATE TABLE sales (
  id TEXT PRIMARY KEY,
  vendor_id TEXT,
  total REAL,
  discount REAL DEFAULT 0,
  received REAL,
  change_given REAL,
  created_at TEXT
);

-- sale_items
CREATE TABLE sale_items (
  id TEXT PRIMARY KEY,
  sale_id TEXT,
  product_id TEXT,
  quantity INTEGER,
  unit_price REAL,
  original_price REAL
);

-- suppliers
CREATE TABLE suppliers (
  id TEXT PRIMARY KEY,
  name TEXT,
  phone TEXT,
  address TEXT,
  photo_path TEXT,
  created_at TEXT
);

-- vendors
CREATE TABLE vendors (
  id TEXT PRIMARY KEY,
  name TEXT,
  role TEXT,
  pin_hash TEXT,
  color TEXT,
  initials TEXT,
  created_at TEXT
);

-- expenses
CREATE TABLE expenses (
  id TEXT PRIMARY KEY,
  label TEXT,
  amount REAL,
  created_at TEXT
);
```

---

## Phase 2 — Écrans Core (Semaines 3-5)

### 2.1 Navigation par plateforme

**Mobile** — BottomNavigationBar (4 items) :
- 🏠 Produits
- 📦 Stock
- 📊 Analyse
- ⚙️ Paramètres

**Tablette** — NavigationRail (collapsed) ou BottomNavigationBar en portrait

**Desktop** — NavigationDrawer (240px, toujours visible) :
```
┌─────────────────────┐
│ [LOGO] YABISSO      │
│       Kassa         │
├─────────────────────┤
│ 👤 Fatou (vendeur)  │
│ 🟢 En ligne         │
├─────────────────────┤
│ 🏠 Produits         │
│ 📦 Stock            │
│ 🏪 Achat stock      │
│ 📊 Analyse          │
│ 👥 Vendeurs         │
│ 🚚 Fournisseurs     │
├─────────────────────┤
│ ☁️ Dernière synchro │
│ ⚙️ Paramètres       │
└─────────────────────┘
```

### 2.2 Écran Produits

**Mobile (2 colonnes)**
```
[  Card  ][  Card  ]
[  Card  ][  Card  ]
[Bottom payment bar]
```

**Tablette (3 colonnes)**
```
[Card][Card][Card]
[Card][Card][Card]
[Bottom payment bar]
```

**Desktop (split view)**
```
┌──────────────────┬──────────────────┐
│  Search bar      │  PANIER          │
├──────────────────│  ─────────────   │
│[Card][Card][Card]│  🥤 Coca ×2      │
│[Card][Card][Card]│  💧 Eau  ×1      │
│[Card][Card][Card]│  ─────────────   │
│[Card][Card][Card]│  Total: 1300 F   │
│                  │                  │
│                  │  [  PAYER  ]     │
└──────────────────┴──────────────────┘
```

### 2.3 Écran Paiement

| Plateforme | Layout |
|-----------|--------|
| Mobile | Plein écran avec numpad en bas |
| Tablette | Modale centrée (80% largeur, 90% hauteur) |
| Desktop | Panneau droit (toujours visible dans split view) OU dialogue centré 600px |

---

## Phase 3 — Composants UI Adaptatifs (Semaines 5-7)

### 3.1 Modals & Popups adaptatifs

```dart
void showAdaptiveModal(BuildContext context, Widget child) {
  if (isDesktop(context) || isTablet(context)) {
    showDialog(context: context, builder: (_) => child);
  } else {
    showModalBottomSheet(context: context, builder: (_) => child);
  }
}
```

| Plateforme | Comportement |
|-----------|--------------|
| Mobile | `showModalBottomSheet` (glisse depuis le bas) |
| Tablette | `showDialog` (centré, 70% écran) |
| Desktop | `showDialog` (centré, 500px max) |

### 3.2 Touch Targets

| Élément | Mobile | Tablette | Desktop |
|---------|--------|----------|---------|
| Boutons | 44px min | 52px min | 40px (souris) |
| +/- Produit | 34×34px | 44×44px | 32×32px |
| Nav icons | 48×48px | 56×56px | 48px + hover |

---

## Phase 4 — Fonctionnalités Desktop (Semaines 7-8)

### 4.1 Raccourcis clavier

| Touche | Action |
|--------|--------|
| ENTER / SPACE | Valider/Confirmer |
| ESC | Fermer popup / Annuler |
| CTRL+N | Nouvelle vente (vider panier) |
| CTRL+P | Imprimer reçu |
| CTRL+S | Sauvegarder changements stock |
| F1 | Aide |
| Flèches | Naviguer grille produits |
| +/- | Incrémenter/décrémenter produit sélectionné |

### 4.2 Interactions souris

| Action | Résultat |
|--------|----------|
| Hover produit | Élévation subtile + bordure verte |
| Clic droit produit | Menu contextuel (Ajouter, Détails, Modifier, Stock) |
| Hover nav item | Tooltip avec label |
| Double-clic produit | Ajouter au panier directement |

### 4.3 Gestion fenêtre (Windows)

- Taille min : 900×600px
- Retenir dernière taille/position
- Support fullscreen (F11)
- Icône taskbar : logo Yabisso Kassa

---

## Phase 5 — Fonctionnalités Tablette (Semaines 8-9)

### 5.1 Mode Paysage (principal)
- Split view : produits gauche, panier droite
- Cartes produits plus larges (jusqu'à 200px)
- Boutons numpad plus grands (56px min)
- Rail navigation latéral

### 5.2 Mode Portrait
- Même layout que mobile mais 3 colonnes
- Touch targets plus grands

### 5.3 Clavier externe (iPad/Android tablet)
- Mêmes raccourcis que desktop
- Navigation Tab entre champs

---

## Phase 6 — Sauvegarde & Sync (Semaines 9-10)

- [ ] Backup Google Drive (compte utilisateur)
- [ ] Restauration depuis backup
- [ ] Indicateur de synchro dans sidebar
- [ ] Gestion conflits offline

---

## Phase 7 — Tests & Déploiement (Semaines 10-12)

- [ ] Tests unitaires (models, providers, database)
- [ ] Tests widget (composants UI)
- [ ] Tests intégration (flux de vente complet)
- [ ] Test sur vrais appareils (Android, iOS, Windows)
- [ ] Optimization performances
- [ ] Déploiement Google Play Store
- [ ] Déploiement Microsoft Store
- [ ] (Later) App Store iOS

---

## Ordre de développement

1. DatabaseHelper (SQLite + all CRUD)
2. DeviceLayout helper (breakpoints)
3. Adaptive navigation (mobile/tablet/desktop)
4. Products screen + product cards
5. Payment screen (adaptive modal/split)
6. Receipt screen
7. Stock management screen
8. Stock alert system
9. Vendor login + PIN
10. Suppliers + Add product
11. Analysis screen
12. Google Drive backup
13. Desktop keyboard shortcuts
14. Bluetooth printer (mobile/tablet only)
15. Export to JPEG

---

## Notes importantes

- Toute l'interface en **français**
- Format devise : `1 000 FCFA` (espace comme séparateur de milliers)
- Photos stockées localement via `path_provider`
- Utiliser `Image.file()` pour les photos locales
- Alerte de stock configurable par produit
- Réduction appliquée par prix unitaire
- Chaque vente enregistre : vendeur, produits, prix, réduction, reçu, monnaie rendue, horodatage
- Imprimante Bluetooth : mobile et tablette uniquement (pas desktop)
- Appels téléphoniques : mobile uniquement (`url_launcher` tel: scheme, désactivé sur desktop)
- Caméra : mobile et tablette uniquement (desktop utilise file picker)

---

## Jalons

| Semaine | Jalon | Statut |
|---------|-------|--------|
| 1-2 | Fondations + DB | ✅ |
| 3-5 | Écrans Core | ✅ |
| 5-7 | Composants UI | ✅ |
| 7-8 | Desktop features | ✅ |
| 8-9 | Tablette features | ⏳ |
| 9-10 | Backup & Sync | ✅ |
| 10-12 | Tests & Deploy | ⏳ |

---

## Projets supplémentaires (hors roadmap initial)

### Super Admin Dashboard (React + Express + Capacitor)

**Technos**: React 19 + TypeScript + Tailwind CSS v4 + Vite 8 + Express 5 + Capacitor 8

**Objectif**: Dashboard mobile-first pour gérer boutiques, vendeurs, vouchers et finances.

**Pages**:
- **Accueil**: 4 KPI cards + graphique Revenue + aperçu rapide
- **Boutiques**: Liste avec search/filtres + suspendre/supprimer/réactiver
- **Vouchers**: Génération (4 plans), stats, liste, copie, annulation
- **Alertes**: Filtre par sévérité (urgent/important/info), liens vers boutiques
- **Paramètres**: Profil admin, gestion rapide

**Backend**: Express.js + `db.json` (stockage fichier)
- API REST: `GET/POST/PUT/DELETE /api/shops`, `/api/vendors`, `/api/vouchers`
- Validation voucher: `POST /api/vouchers/validate` (appelé par l'app Flutter)
- Report usage: `POST /api/vouchers/report-usage`
- Statistiques: `GET /api/stats`

**4 Plans voucher** (MICRO=10, BASIC=25, PREMIUM=50, UNLIMITED=∞)

**Points/Vouchers hors-ligne**: Génération OFF-XXXX-XXXX (validation locale, WhatsApp)
**Points System**: PTS-XXXX-XXXX-XXXX, 1pt=1FCFA, payer abonnement avec points
**Plans points**: Micro(1000pts/10prod), Basic(1500pts/25prod), Premium(3000pts/50prod), Illimité(5000pts/∞)

**Déploiement**: Render (config pushée, attente validation user)

**APK**: 4.2 MB via Capacitor Android (v1.0.2)

---

*Dernière mise à jour : 23/06/2026*
