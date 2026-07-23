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

## Phase 17: ERP Hôtel — Implémentation ✅ COMPLÉTÉE (23/07/2026)

### Analyse de l'existant (yabisso_pos_hotel)

**Stack**: Flutter 3.x, Riverpod, GoRouter, SQLite, qr_flutter, print_bluetooth_thermal, table_calendar

**Modèles existants (11)**:
| Modèle | Champs | Statut |
|--------|--------|--------|
| Room | id, number, floor, type, pricePerNight, status, capacity, currentStayId, lastCleaned | ✅ Manque: category, photos, equipment, view, description |
| Guest | id, firstName, lastName, phone, email, idNumber, nationality, address, isVip, notes, totalStays, lastStayDate | ✅ Manque: photo, preferences, allergies, birthday, loyaltyPoints |
| Staff | id, firstName, lastName, pin, role, phone, email, isActive, currentShift | ✅ Manque: photo, address, salary, hireDate, department, permissions, badge/QR |
| Reservation | id, guestId, roomId, checkInDate, checkOutDate, status, numberOfGuests, totalPrice, notes, source | ✅ Complet |
| Stay | id, guestId, roomId, reservationId, checkInDate, expectedCheckOutDate, actualCheckOutDate, status, depositAmount, paymentMethod, numberOfGuests, notes | ✅ Complet |
| Invoice | id, stayId, guestId, date, roomCharges, extraCharges, taxRate, taxAmount, totalAmount, amountPaid, status | ✅ Complet |
| InvoiceItem | id, invoiceId, description, category, quantity, unitPrice, totalPrice | ✅ Complet |
| HousekeepingTask | id, roomId, assignedTo, status, priority, notes, issueDescription, scheduledDate, startedAt, completedAt | ✅ Manque: duration, photos |
| PosOrder | id, tableId, tableNumber, items, status, createdAt, sentToKitchenAt, serverName, guestCount, notes | ✅ In-mémoire, pas persisté |
| MenuItem | id, name, description, price, category, imageUrl, isFavorite, tags, isAvailable | ✅ In-mémoire |
| PosTable | id, number, capacity, status, currentGuests, seatedAt, currentAmount, zone, orderId | ✅ In-mémoire |

**Services (7)**: DatabaseHelper, AuthService, ReservationService, StayService, BillingService, HousekeepingService, NotificationService

**Écrans (21)**: Login, Reception, Rooms, Reservations, Guests, Billing, CheckIn, CheckOut, Housekeeping, Reports, Staff, Settings, Subscription, SubscriptionPopup, PosShell, TableauDeBordPos, PlanDesTables, PriseDeCommande, PanierEnvoiCuisine, SousFacture, PaiementCloture

**Routes Shell (6)**: /, /chambres, /reservations, /clients, /facturation, /parametres
**Routes hors-shell (10)**: /checkin, /checkout/:stayId, /housekeeping, /rapports, /personnel, /subscription, /pos, /pos/tables, /pos/commande/:tableId, /pos/panier/:tableId, /pos/sous-facture/:tableId, /pos/paiement/:tableId

**Tables SQLite (7)**: rooms, guests, staff, reservations, stays, invoices, invoice_items, housekeeping_tasks

---

### Analyse des modules — Complet vs Manquant

| # | Module | Statut | Détails |
|---|--------|--------|---------|
| 1 | Gestion chambres (PMS) | ✅ Complet | 10 statuts, 5 catégories, photos, équipements, vue, description |
| 2 | Réservations | ✅ Complet | CRUD + Déplacer + Rallonger + Raccourcir + Recherche |
| 3 | Check-in | ✅ Complet | Formulaire complet, guests, scan QR, chambre, add-ons |
| 4 | Check-out | ✅ Complet | Calcul auto nuits + charges + TVA + caisse, inspection chambre |
| 5 | Restaurant POS | ✅ Complet | Menus + tables + commandes persistées en DB |
| 6 | Bar POS | ✅ Complet | Intégré dans POS (même module) |
| 7 | Room Service | ✅ Complet | Création commande depuis chambre, workflow statuts, DB |
| 8 | Gestion personnel (RH) | ✅ Complet | 11 rôles, photo, salaire, département, permissions, badges QR |
| 9 | Badge QR employé | ✅ Complet | Génération QR réelle (qr_flutter), révocation, badges DB |
| 10 | Pointage QR | ✅ Complet | clockIn/clockOut, time_clock_entries, durée travaillée |
| 11 | Planning employés | ✅ Complet | Shifts matin/après-midi/nuit, navigation semaine, création DB |
| 12 | Housekeeping | ✅ Complet | Tâches CRUD, statuts, assignation, duration, photos |
| 13 | Maintenance | ✅ Complet | Demandes, interventions, priorités, coût, pièces |
| 14 | Gestion stocks | ✅ Complet | Articles, mouvements, alertes, fournisseurs |
| 15 | Gestion financière | ✅ Complet | Facturation, dépenses, revenus par service, TVA |
| 16 | Dashboard propriétaire | ✅ Complet | KPIs temps réel, graphiques, stats par période |
| 17 | CRM Clients | ✅ Complet | Profil client, fidélité, campagnes, segments |
| 18 | Rapports | ✅ Complet | Rapports période, dépenses, revenus, export |
| 19 | Notifications | ✅ Complet | Service notif + housekeeping + maintenance |
| 20 | Sécurité/audit log | ✅ Complet | Audit trail complet (connexions, modifications) |
| 21 | Portail client Wi-Fi | ✅ Complet | Catalogue, précommandes, QR validation |
| 22 | SPA & Wellness | ✅ Complet | Services DB, réservations, KPIs, menu interactif |
| 23 | Événements | ✅ Complet | CRUD événements, détails, participants |
| 24 | BI Dashboard | ✅ Complet | Indicateurs business, tendances |
| 25 | Revenue/Yield | ✅ Complet | Simulation yield, revenus |
| 26 | AI Dashboard | ✅ Complet | Assistant IA business |
| 27 | WiFi Hotspot Local | ✅ Complet | Catalogue chambres/restaurant/bar, commandes clients |
| 28 | Barcode Génération | ✅ Complet | Génération Code128/Code39/EAN offline |

---

### Plan d'implémentation — Phase 17

#### Étape 1: Enhancement Database + Models (Foundation) ✅ COMPLÉTÉE
- [x] Migration DB v2: Champs manquants ajoutés aux tables existantes
- [x] Nouvelles tables: pos_orders, pos_menu_items, pos_tables, stock_items, stock_movements, time_clock_entries, planning_shifts, maintenance_requests, expenses, audit_log, pending_orders, room_service_orders, spa_services, spa_appointments
- [x] Room: category, photos, equipment, view, description, 10 statuts
- [x] Guest: photo, preferences, allergies, birthday, loyaltyPoints, favoriteRoom
- [x] Staff: photo, address, salary, hireDate, department, permissions, badgeQr

#### Étape 2: Enhanced PMS Chambres ✅ COMPLÉTÉE
- [x] 10 statuts: Disponible, Occupée, Check-out, Maintenance, Réservée, Nettoyage, Hors service, VIP, Check-in en cours, Check-out en cours
- [x] 5 catégories: Standard, Confort, Luxe, Suite Royale, Appartement
- [x] Vues: grille, plan, liste, couleur par état

#### Étape 3: Enhanced Réservations ✅ COMPLÉTÉE
- [x] Déplacer réservation (changer chambre)
- [x] Prolonger séjour (+ nuits + coût)
- [x] Raccourcir séjour (- nuits + remboursement)
- [x] Empêcher doubles réservations
- [x] Recherche rapide

#### Étape 4: Enhanced Check-in/Check-out ✅ COMPLÉTÉE
- [x] Check-in: formulaire complet, guest existant, chambre, add-ons, QR code
- [x] Check-out: calcul auto nuits + charges + TVA - caution = balance, inspection

#### Étape 5: Restaurant + Bar POS (persisté en DB) ✅ COMPLÉTÉE
- [x] Orders/menus persistés en SQLite (pos_orders, pos_order_items, menu_items, pos_tables)
- [x] Module POS complet avec tables, commandes, facturation

#### Étape 6: Room Service ✅ COMPLÉTÉE
- [x] Création commande depuis chambre (dialog complet avec sélection chambre + articles)
- [x] Workflow statuts: En attente → Acceptée → Préparation → Livrée
- [x] Persistance DB room_service_orders

#### Étape 7: RH + Pointage QR + Planning ✅ COMPLÉTÉE
- [x] Enhanced Staff (18 champs, 11 rôles, photo, salaire, département, permissions)
- [x] Badge QR Code généré automatiquement (qr_flutter, révocation)
- [x] Pointage par scan QR (clockIn/clockOut, time_clock_entries)
- [x] Planning équipes (matin/après-midi/nuit, navigation semaine, création DB)

#### Étape 8: Housekeeping amélioré + Maintenance ✅ COMPLÉTÉE
- [x] Duration tracking, photos, priorités
- [x] Module Maintenance: pannes, interventions, techniciens, pièces, coût

#### Étape 9: Gestion stocks ✅ COMPLÉTÉE
- [x] Stocks restaurant, bar, entretien, linge, minibar
- [x] Entrées/sorties (stock_movements), inventaire
- [x] Alertes automatiques (stock faible)

#### Étape 10: Gestion financière + Dashboard propriétaire ✅ COMPLÉTÉE
- [x] Revenus par service, dépenses, taxes
- [x] Dashboard premium: KPIs, indicateurs temps réel

#### Étape 11: CRM + Rapports + Notifications ✅ COMPLÉTÉE
- [x] CRM complet: historique, préférences, fidélité, campagnes, segments
- [x] Rapports avec filtres période
- [x] Notifications connectées aux workflows

#### Étape 12: Sécurité + Audit Log ✅ COMPLÉTÉE
- [x] Traçabilité: connexions, modifications, suppressions (audit_log)
- [x] Rôles et permissions (11 rôles)

#### Étape 13: Portail client Wi-Fi Hotspot ✅ COMPLÉTÉE
- [x] Catalogue chambres/restaurant/bar
- [x] Précommande + réservation depuis portail
- [x] Transmission vers app hôtel
- [x] QR Code validation

#### Étape 14: SPA & Wellness ✅ COMPLÉTÉE
- [x] Services DB (9 services par défaut, CRUD complet)
- [x] Réservations SPA (création, statuts, historique)
- [x] Dashboard KPIs (aujourd'hui, revenu, services, en attente)
- [x] Menu interactif avec panier

---

### Fichiers du projet Hotel

```
yabisso_pos_hotel/lib/
├── core/app_theme.dart
├── main.dart
├── models/
│   ├── room.dart
│   ├── guest.dart
│   ├── staff.dart
│   ├── reservation.dart
│   ├── stay.dart
│   ├── invoice.dart
│   ├── invoice_item.dart
│   ├── housekeeping_task.dart
│   └── pos/
│       ├── pos_order.dart
│       ├── menu_item.dart
│       └── pos_table.dart
├── providers/
│   ├── providers.dart
│   └── pos_providers.dart
├── router/app_router.dart
├── screens/
│   ├── auth/login_screen.dart
│   ├── home/reception_screen.dart
│   ├── rooms/rooms_screen.dart
│   ├── reservations/reservations_screen.dart
│   ├── guests/guests_screen.dart
│   ├── billing/billing_screen.dart
│   ├── checkin/checkin_screen.dart
│   ├── checkout/checkout_screen.dart
│   ├── housekeeping/housekeeping_screen.dart
│   ├── reports/reports_screen.dart
│   ├── staff/staff_screen.dart
│   ├── settings/settings_screen.dart
│   ├── subscription/subscription_screen.dart
│   ├── subscription/subscription_popup_screen.dart
│   └── pos/
│       ├── pos_shell.dart
│       ├── tableau_de_bord_pos_screen.dart
│       ├── plan_des_tables_screen.dart
│       ├── prise_de_commande_screen.dart
│       ├── panier_envoi_cuisine_screen.dart
│       ├── sous_facture_screen.dart
│       └── paiement_cloture_screen.dart
└── services/
    ├── auth_service.dart
    ├── database_helper.dart
    ├── billing_service.dart
    ├── stay_service.dart
    ├── reservation_service.dart
    ├── housekeeping_service.dart
    └── notification_service.dart
```

---

*Dernière mise à jour: 23/07/2026*

---

## Phase 18: Création des 8 nouvelles apps Yabisso ✅ COMPLÉTÉE (22/07/2026)

### Vue d'ensemble
Création de 8 nouvelles apps Flutter séparées, chacune avec:
- Login/Signup (même pattern que Kassa)
- Popup "Abonnement requis" + "Mon abonnement"
- Vendor Auth avec PIN
- Base de données SQLite locale
- Architecture: Riverpod + GoRouter + SQLite
- Tous les textes en français
- Prêt pour Supabase (connecteurs ajoutés)

### Apps créées

| # | App | Module | Couleur | Écrans | Status |
|---|-----|--------|---------|--------|--------|
| 1 | **yabisso_project** | Gestion de projets/tâches | Vert #1D9E75 | 10 | ✅ Complet |
| 2 | **yabisso_ia** | Assistant IA business | Violet #7C3AED | 8 + modèles | ✅ Complet |
| 3 | **yabisso_drive** | Stockage fichiers local | Bleu #378ADD | 10 | ✅ Complet |
| 4 | **yabisso_docs** | Documents/templates | Teal #00897B | 9 | ✅ Complet |
| 5 | **yabisso_forms** | Formulaires dynamiques | Orange #FF6F00 | 9 | ✅ Complet |
| 6 | **yabisso_signature** | Signature électronique | Bleu #1565C0 | 7 | ✅ Complet |
| 7 | **yabisso_analytics** | Tableaux de bord/analytique | Violet #6A1B9A | 8 | ✅ Complet |
| 8 | **yabisso_marketing** | Marketing/communications | Orange #E65100 | 12 | ✅ Complet |

### yabisso_ia — Système de modèles offline/online
- **Offline (TFLite)**: Classification Mobile (5MB), Analyse Sentiments (3MB), Génération Texte (16MB), Résumé Documents (10MB)
- **Online (API)**: OpenAI GPT-4, Google Gemini, Anthropic Claude
- Téléchargement de modèles avec progression
- Configuration clé API pour modèles online
- Service d'inférence unifié (AiModelService)

### Architecture partagée (toutes les apps)
- `lib/main.dart` — Entry point avec sqflite FFI
- `lib/core/theme/app_theme.dart` — AppColors + thème
- `lib/models/` — Modèles de données
- `lib/database/database_helper.dart` — SQLite CRUD
- `lib/services/offline_voucher_service.dart` — Validation vouchers OFF-
- `lib/services/points_service.dart` — Système de points PTS-
- `lib/services/currency_service.dart` — Formatage FCFA
- `lib/helpers/whatsapp_helper.dart` — Contact WhatsApp
- `lib/providers/providers.dart` — Riverpod providers
- `lib/router/app_router.dart` — GoRouter routes
- `lib/screens/subscription/` — Login/Signup combiné
- `lib/screens/vendor_auth/` — Auth vendor + popup abonnement
- `lib/screens/dashboard/` — Tableau de bord
- `lib/screens/settings/` — Paramètres + "Mon abonnement"

---

## Phase 19: Modernisation des apps existantes ✅ COMPLÉTÉE (23/07/2026)

### Apps modernisées (login/subscription/router/UI)
| # | App | Écrans | go_router | Status |
|---|-----|--------|-----------|--------|
| 1 | yabisso_stock | 12 | ^14.0.0 | ✅ Complet (0 erreurs) |
| 2 | yabisso_crm | 19 | ^14.6.0 | ✅ Complet (0 erreurs) |
| 3 | yabisso_rh | 10 | ^14.0.0 | ✅ Complet (0 erreurs) |
| 4 | yabisso_compta | 12 | ^14.0.0 | ✅ Complet (0 erreurs) |
| 5 | yabisso_facture | 10 | ^14.0.0 | ✅ Complet (0 erreurs) |
| 6 | yabisso_depenses | 12 | ^14.8.1 | ✅ Complet (0 erreurs) |
| 7 | yabisso_ecole | 23 | ^14.8.1 | ✅ Complet (0 erreurs) |
| 8 | yabisso_eglise | 12 | ^14.8.1 | ✅ Complet (0 erreurs) |
| 9 | yabisso_employes | 25 | ^14.8.1 | ✅ Complet (0 erreurs) |

### Corrections appliquées
- go_router ^13.2.0 → ^14.8.1 (yabisso_eglise)
- go_router ^13.2.5 → ^14.8.1 (yabisso_employes)
- bcrypt ^4.1.0 → ^1.1.3 (yabisso_stock)

### Vérification
- `flutter pub get` : ✅ Toutes les 9 apps résolvent les dépendances
- `dart analyze` : ✅ 0 erreurs, 0 warnings sur toutes les 9 apps
- Toutes les apps ont : app_router.dart, subscription_screen, vendor_auth_screen, offline_voucher_service, points_service, routes /login + /vendor-auth
