# Plan d'Implémentation - Kassa

## Vue d'ensemble du projet

Yabisso Kassa — Application Flutter Cross-Platform Offline-First (POS) pour petits commerçants africains.

## Phase 1: Fondations ✅ COMPLÉTÉE
- [x] Créer le projet Flutter multi-plateforme
- [x] Configurer pubspec.yaml (26+ packages)
- [x] Structure de dossiers (core/, models/, providers/, screens/, widgets/, database/, router/, services/)
- [x] DeviceLayout helper responsive
- [x] Thème Yabisso (couleurs, typographie)
- [x] Base de données SQLite (6 tables, CRUD complet, v5 migrations)
- [x] 6 modèles de données (Product, Sale, SaleItem, Vendor, Supplier, Expense)
- [x] Migration DB v1→v2 (catégories) + v2→v3 (audio) + v4 (settings) + v5 (discount_amount)

## Phase 2: Écrans Core ✅ COMPLÉTÉE
- [x] Navigation par plateforme (BottomNav mobile, Sidebar desktop)
- [x] MainScreen avec BottomNav persistante
- [x] ProductsScreen (POS Principal) avec stock validation
- [x] AddProductScreen (ajout avec images + audio)
- [x] PaymentScreen (numpad, remises, billets rapides, stock check)
- [x] ReceiptScreen (réçu avec données réelles)
- [x] StockAlertScreen
- [x] StockPurchaseScreen (design complet, call/WhatsApp)
- [x] SuppliersScreen (popup détails, call, WhatsApp)
- [x] InventoryScreen (images, prix cliquable, marge, success modal)
- [x] AnalysisScreen (rapports jour/semaine/mois/année, bénéfice, meilleur produit, détail vente)
- [x] SettingsScreen (Bluetooth search, sync Google Drive)
- [x] CategoriesScreen (gestion catégories/sous-catégories)
- [x] VendorsScreen (gestion vendeurs avec PIN)
- [x] VendorAuthScreen (sélection profil + PIN creation/verification)
- [x] SubscriptionScreen (login/inscription)
- [x] SyncSettingsScreen (QR code, Google Drive, scan connexion)

## Phase 3: Widgets ✅ COMPLÉTÉE
- [x] ProductCard (responsive, stock validation, out of stock)
- [x] CartPanel (barre panier avec "Payer")
- [x] AppNumpad (réutilisable)
- [x] Audio recording widget (fournisseurs)

## Phase 4: Fonctionnalités Avancées ✅ COMPLÉTÉE
- [x] Stock validation (ne pas vendre plus que dispo)
- [x] Notification stock faible après vente
- [x] Remises visibles avec modification/suppression
- [x] Bénéfice tracking (ventes - coût)
- [x] Meilleur produit par période
- [x] Détail des ventes (image, nom, quantité, prix)
- [x] Gestion de stock améliorée (images, prix, marge)
- [x] Fournisseurs: call, WhatsApp, popup détails
- [x] Imprimante Bluetooth search
- [x] Vendeurs avec PIN creation/verification

## Phase 5: Synchronisation ✅ COMPLÉTÉE
- [x] Architecture offline-first
- [x] Google Drive backup (sales.json, products.json, vendors.json, sale_items.json)
- [x] Synchronisation automatique toutes les 5 minutes
- [x] QR code pairing (boutique → propriétaire)
- [x] Download/Import données depuis Google Drive
- [x] Connectivity check (offline → retry automatique)

## Phase 6: Dashboard Super Admin ✅ COMPLÉTÉE
- [x] Dashboard React (React 19 + TypeScript + Tailwind v4 + Vite 8)
- [x] Backend API Express (5 routes REST + voucher validation + stats)
- [x] 4 plans voucher (MICRO=10, BASIC=25, PREMIUM=50, UNLIMITED=∞)
- [x] Génération vouchers (code YAB-XXXX-XXXX, CSV, print, copie)
- [x] Validation voucher depuis Flutter (POST /api/vouchers/validate)
- [x] Gestion boutiques (créer, suspendre, réactiver, supprimer)
- [x] Gestion vendeurs (créer, filtrer par rôle, supprimer)
- [x] Alertes automatiques (suspendues, expirations)
- [x] Finances (KPIs, graphiques, paiements)
- [x] Dashboard mobile-first (Bottom Nav 5 items, design cartes, charts)
- [x] APK Capacitor (4.5 MB)
- [x] Déploiement Render configuré (render.yaml + Procfile)

## Phase 7: Voucher Validation (Flutter) ✅ COMPLÉTÉE
- [x] Bouton "Activer avec un voucher" dans SubscriptionScreen
- [x] Dialogue de saisie de code voucher
- [x] Appel API POST /api/vouchers/validate
- [x] Sauvegarde max_products + plan + expires_at dans SharedPreferences
- [x] Vérification limite produits avant ajout (AddProductScreen)
- [x] Bannière limite produits avec progress bar (ProductsContent)

## Phase 8: Offline Vouchers ✅ COMPLÉTÉE
- [x] OfflineVoucherService (génération boutique ID, hash, validation)
- [x] Code voucher OFF-XXXX-XXXX (validation locale, pas d'Internet)
- [x] WhatsApp avec ID boutique intégré
- [x] Anti-reuse codes (SharedPreferences)
- [x] Vérification appartenance boutique (hash comparison)
- [x] Dashboard: endpoint POST /api/vouchers/generate-offline

## Phase 9: Points System ✅ COMPLÉTÉE
- [x] PointsService (gestion solde, validation PTS-XXXX-XXXX-XXXX)
- [x] PointsScreen (solde, code PTS, WhatsApp, validation)
- [x] Settings: entrée Points dans section Abonnement
- [x] Subscription: "Payer avec points" avec 4 plans
- [x] Plans: Micro(1000pts/10prod), Basic(1500pts/25prod), Premium(3000pts/50prod), Illimité(5000pts/∞)
- [x] Dashboard: endpoint POST /api/vouchers/generate-points
- [x] Dashboard: formulaire points + badge PTS dans liste

## Phase 10: App Icons ✅ COMPLÉTÉE
- [x] Flutter: icône caisse (yabissokassa_icon_caisse.png) dans tous les mipmap Android
- [x] Dashboard: icône dashboard (yabissokassa_icon_dashbord.png) comme favicon

## Phase 11: Renommage Kassa ✅ COMPLÉTÉE
- [x] "Yabisso Kassa" → "Kassa" dans tous les fichiers d'affichage utilisateur
- [x] Nom installation "Kassa" sur Android, iOS, macOS, Windows
- [x] Build Windows .exe (kassa.exe)
- [x] Build Android APK (app-release.apk)
- [x] Backup GitHub repo `BENsidneykokolo/Kassa`

## Phase 12: Améliorations inventaire + scanner ✅ COMPLÉTÉE
- [x] Cliquer sur image produit → EditProductScreen avec bouton supprimer
- [x] Flash fonctionnel sur `ScannerScreen` (bouton torche)
- [x] Flash fonctionnel sur scanner code-barres dans `AddProductScreen`
- [x] Build Windows + Android après modifications

## Phase 13: UI Fixes + Import/Export complet ✅ COMPLÉTÉE
- [x] Header Ventes simplifié (remove 3 dots, Online badge, font size 20→16, même ligne)
- [x] Boutons +/- scanner vérifiés (scanner_screen.dart)
- [x] Fix suppression sous-catégorie (long-press menu contextuel + boutons restructurés)
- [x] Import/Export JSON v2 avec images base64 + catégories/fournisseurs par nom
- [x] CSV Import/Export avec category_name, supplier_name, photo_path
- [x] Fix path.basename dans product_exporter.dart

## Phase 14: Devise, Langue, Excel ✅ COMPLÉTÉE
- [x] Système multi-devises (10 devises africaines + internationales)
- [x] CurrencyService avec formatage et persistence SharedPreferences
- [x] Dialog sélection devise dans Paramètres
- [x] Système multi-langues (FR, EN, SW, PT)
- [x] LanguageService avec traductions UI complètes
- [x] Dialog sélection langue dans Paramètres
- [x] Import/Export Excel (.xlsx) remplace CSV
- [x] ExcelService avec détection colonnes auto par en-tête
- [x] Support types CellValue (IntCellValue, DoubleCellValue, TextCellValue)
- [x] Fix scroll scanner (bottom padding 2 écrans)
- [x] Fix 6 erreurs excel_service.dart (maxRow, nullable)
- [x] flutter analyze 0 erreurs

## Phase 15: En attente (prochaines étapes)
- [x] Wiring CurrencyService.formatPrice() partout dans l'app (19 fichiers, 38 occurrences FCFA → fmtPrice/symbol) ✅ 17/07/2026
- [x] Wiring LanguageService.translate() navigation + cart panel (80+ clés, t() function) ✅ 17/07/2026
- [x] Fix bouton Payer cassé (cart_panel → /payment) ✅ 17/07/2026
- [x] Fix bouton Appeler fournisseur cassé (stock_alert → url_launcher) ✅ 17/07/2026
- [x] Wiring LanguageService.translate() pour toutes les chaînes UI
- [ ] Déploiement Render (attente validation user)
- [ ] Mise à jour _apiBaseUrl dans subscription_screen.dart après Render
- [ ] Bluetooth printer (thermal printing)
- [ ] Tests unitaires (Flutter)
- [ ] Déploiement Play Store

## Phase 16: Corrections Marketing + WiFi Hotspot ✅ COMPLÉTÉE (18/07/2026)

### WiFi Hotspot Local — Corrections critiques
- [x] **validateOrder()** crée une vraie vente (Sale + SaleItems) + déduit le stock atomiquement ✅
- [x] **Bouton Refuser** ajouté dans OrderQueueScreen (avec dialog confirmation) ✅
- [x] **Service images produits** : endpoint HTTP `/api/products/{id}/photo` pour servir les images du catalogue ✅
- [x] **Catalog HTML** : images produits utilisent l'endpoint API au lieu des chemins locaux ✅

### Marketing — Corrections + Nouveaux écrans
- [x] **getCouponDiscountFromMap()** : retourne le vrai montant de réduction (% ou fixe) ✅
- [x] **applyCoupon()** retourne le montant de réduction (pas juste bool) ✅
- [x] **_isInactive()** : utilise maintenant le paramètre `days` + vérifie `updatedAt` ✅
- [x] **Promotions** : ajout suppression + édition + fix clavier (viewInsets) ✅
- [x] **Coupons** : ajout toggle actif/inactif + suppression + édition + fix clavier ✅
- [x] **Poster Studio** : fix clavier + option "Choisir un produit" (catalogue local) ✅
- [x] **Poster Studio** : génération PDF réelle (promo + coupon) + partage fichier ✅
- [x] **Nouveau : Campagnes Screen** — CRUD complet (créer, modifier, supprimer, envoyer) ✅
- [x] **Nouveau : Stats Marketing Screen** — Ventes (jour/semaine/mois) + Marketing + Clients ✅
- [x] **Dashboard Marketing** : boutons Campagnes, Stats, VIP, Points branchés ✅
- [x] **AI Marketing** : panneau fonctionnel avec vrais suggestions + slogans + ad text ✅
- [x] **deleteCampaign()** ajouté dans DatabaseHelper ✅
- [x] Routes `/marketing/campaigns` et `/marketing/stats` ajoutées ✅

### Raccourci Commandes
- [x] **Bouton "Commandes"** ajouté dans l'en-tête de l'écran Vente (products_content.dart) ✅

### Fichiers modifiés
| Fichier | Action |
|---------|--------|
| `lib/services/wifi_commerce/order_queue_service.dart` | Réécrit — validateOrder crée une vraie Sale + déduit stock |
| `lib/screens/wifi_commerce/order_queue_screen.dart` | Ajout bouton Refuser + _rejectOrder() |
| `lib/services/wifi_commerce/local_server_service.dart` | Ajout endpoint /api/products/{id}/photo |
| `lib/services/wifi_commerce/catalog_html.dart` | Images utilisent endpoint API |
| `lib/services/marketing/marketing_service.dart` | Fix getCouponDiscountFromMap, _isInactive, applyCoupon retourne discount |
| `lib/services/marketing/poster_service.dart` | Ajout generateCouponPDF, shareFile |
| `lib/screens/marketing/promotions_screen.dart` | Ajout delete/edit + fix clavier |
| `lib/screens/marketing/coupons_screen.dart` | Ajout toggle/delete/edit + fix clavier |
| `lib/screens/marketing/poster_studio_screen.dart` | Ajout "Choisir un produit" + fix clavier + PDF réel |
| `lib/screens/marketing/marketing_dashboard_screen.dart` | 4 boutons branchés + AI Marketing fonctionnel |
| `lib/screens/marketing/campaigns_screen.dart` | **Nouveau** — CRUD campagnes complet |
| `lib/screens/marketing/marketing_stats_screen.dart` | **Nouveau** — Stats marketing temps réel |
| `lib/router/app_router.dart` | Routes /marketing/campaigns + /marketing/stats |
| `lib/database/database_helper.dart` | Ajout deleteCampaign() |
| `lib/screens/products/products_content.dart` | Bouton "Commandes" ajouté |

---

*Dernière mise à jour: 18/07/2026*
