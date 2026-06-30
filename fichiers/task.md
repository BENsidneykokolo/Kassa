# Tâches - Kassa

## Tâches en cours

| Priorité | Tâche | Assigné | Statut | Date |
|----------|-------|---------|--------|------|
| P1 | Déploiement Render | User | En attente | 15/06/2026 |

## Tâches à faire

| Priorité | Tâche | Assigné | Date prévue |
|----------|-------|---------|-------------|
| P1 | Mise à jour API URL Flutter après Render | Opencode | 15/06/2026 |
| P2 | Tests unitaires (Flutter) | Opencode | - |
| P2 | Déploiement Play Store | Opencode | - |


## Tâches terminées

| Tâche | Complétée le | Notes |
|-------|--------------|-------|
| Section Aide dans Paramètres (Appel/WhatsApp/SMS/Chatbot) | 27/06/2026 | settings_screen.dart: +242050332359, message auto avec ID boutique |
| Fix scanner noir écran Paiement | 27/06/2026 | Copié code scanner_screen.dart (ventes) → payment_screen.dart |
| GitHub Actions iOS + macOS | 26/06/2026 | build.yml: macos-15, IPA + DMG, cache Flutter + CocoaPods |
| Entitlements macOS (network.client) | 26/06/2026 | DebugProfile + Release: network.client + files.user-selected |
| Build APK v1.4.6 | 27/06/2026 | 111.4 MB, scanner fix + help section |

| Tâche | Complétée le | Notes |
|-------|--------------|-------|
| Header Ventes simplifié (remove 3 dots, Online badge, font size) | 24/06/2026 | products_content.dart: icône + nom + Scanner sur 1 ligne |
| Fix suppression sous-catégorie | 24/06/2026 | Long-press menu contextuel + boutons restructurés dans categories_screen.dart |
| Import/Export JSON complet avec images | 24/06/2026 | product_exporter.dart v2: base64 images, cat/fournisseur par nom |
| CSV Import/Export avec catégories/fournisseurs par nom | 24/06/2026 | csv_service.dart: nouveaux champs category_name, supplier_name, photo_path |
| Fix path.basename dans product_exporter | 24/06/2026 | `p.basename` → `path.basename` |
| Système multi-devises (10 devises) | 26/06/2026 | currency_service.dart: XAF, XOF, CDF, NGN, GHS, KES, ZAR, USD, EUR, GBP |
| Système multi-langues (4 langues) | 26/06/2026 | language_service.dart: FR, EN, SW, PT + traductions UI |
| Import/Export Excel (.xlsx) remplace CSV | 26/06/2026 | excel_service.dart: export/import avec tous champs, détection colonnes auto |
| Fix scroll scanner (2 écrans) | 26/06/2026 | Bottom padding pour éviter chevauchement barre paiement |
| Fix 6 erreurs excel_service.dart | 26/06/2026 | maxRow→rows.length, CellValue type matching, imports nettoyés |
| flutter analyze 0 erreurs | 26/06/2026 | 0 erreurs après tous les fixes |

| Tâche | Complétée le | Notes |
|-------|--------------|-------|
| Écran gestion produits dans paramètres (AddProductScreen mode édition) | 23/06/2026 | ProductManagementScreen liste produits → AddProductScreen(product:) + bouton supprimer |
| Accès edit/supprimé retiré de l'inventaire et écran produits | 23/06/2026 | Uniquement accessible depuis Paramètres > Produits |
| Renommage "Yabisso Kassa" → "Kassa" (écran vente + install) | 23/06/2026 | desktop_pos_screen, configs Android/iOS/macOS/Windows |
| Cliquer image inventaire → EditProductScreen + supprimer | 23/06/2026 | inventory_screen + products_content (EditProductScreen) |
| Flash fonctionnel écrans scanner (2 écrans) | 23/06/2026 | MobileScannerController.toggleTorch() |
| Build Windows .exe (kassa.exe) | 23/06/2026 | flutter build windows --release |
| Build Android APK (app-release.apk) | 23/06/2026 | flutter build apk --release |
| Backup GitHub repo + push | 23/06/2026 | github.com/BENsidneykokolo/Kassa |
| Fix écran Historique Reçus (crash NULL Sale fields) | 17/06/2026 | sale.dart fromMap null-safe, error handling receipt_history_screen |
| DB Migration v6 (is_modified, modified_at) | 17/06/2026 | Version 5→6, colonnes is_modified + modified_at dans sales |
| Catégories récursives infinies | 17/06/2026 | _RecursiveCategoryTile, getAllSubcategoryIdsRecursive |
| Fix UNLIMITED product limit | 17/06/2026 | Vérifie subscription_plan avant limite max_products |
| Badge "Modifié" sur reçus | 17/06/2026 | Orange badge + mention dans détail |
| IDs boutique sur Dashboard | 17/06/2026 | Boutiques.tsx + Dashboard.tsx affichent IDs |
| Build Flutter APK v1.2.1 | 17/06/2026 | 67.6 MB, commit 39d0e1d, pushé GitHub |
| **Fix stock edit facture (CRITIQUE)** | **18/06/2026** | **`applySaleEditAtomic()` : transaction atomique avec delta direct au lieu de restore+deduct séquentiel** |
| **Fix remise non appliquée dans Aujourd'hui** | **18/06/2026** | **`getTodayItemsTotal()` → SUM(sales.total) au lieu de SUM(unit_price*quantity)** |
| **Fix bénéfice carton non affiché** | **18/06/2026** | **`_updateProfitCalculations()` → ajout `setState()` pour rafraîchissement UI** |
| Build Flutter APK v1.2.4 | 18/06/2026 | 71 MB, 3 correctifs ci-dessus inclus |
| **AI offline ML Kit (reconnaissance produit)** | **18/06/2026** | **`google_mlkit_image_labeling`, `ImageLabelerService` avec dict EN→FR, auto-remplissage nom produit dès photo prise** |
| Build Flutter APK v1.3.0 | 18/06/2026 | 71 MB, ML Kit IA + 3 correctifs inclus |
| Dashboard Super Admin (React) | 14/06/2026 | React 19 + Express 5 + Capacitor, APK 4.5 MB |
| Voucher validation API | 14/06/2026 | Flutter ↔ Express, 4 plans, max_products |
| Product limit enforcement | 14/06/2026 | Blocage ajout + bannière dans produits |
| Dashboard UI Mobile First | 14/06/2026 | Bottom Nav, cartes, charts, mobile design |
| GitHub repo dashboard | 14/06/2026 | BENsidneykokolo/yabisso-admin-dashboard |
| Render déploiement config | 14/06/2026 | render.yaml + Procfile pushés |
| Google Drive Sync | 13/06/2026 | Architecture offline-first, QR code pairing, sync auto 5min |
| Rapport détail vente | 13/06/2026 | Clic sur vente → image produit, nom, quantité, prix |
| Stock validation | 13/06/2026 | Ne pas vendre plus que le stock dispo |
| Notification stock faible | 13/06/2026 | Popup après vente si stock ≤ alerte |
| Écran gestion stock amélioré | 13/06/2026 | Images, prix cliquable, marge %, success modal |
| Achat stock fix + design | 13/06/2026 | Call/WhatsApp fournisseurs |
| Rapports Année + Bénéfice + Meilleur produit | 13/06/2026 | Filtrage jour/semaine/mois/année |
| Fournisseurs popup détails | 13/06/2026 | Nom, adresse, téléphone, call, WhatsApp |
| Imprimante Bluetooth search | 13/06/2026 | Dans paramètres |
| Vendeurs PIN à création | 13/06/2026 | Champ PIN ajouté au dialog |
| Fix bouton Valider Paiement | 14/06/2026 | Migration DB v4→v5 discount_amount |
| Écran Historique Reçus | 13/06/2026 | Dans Paramètres, détail complet de chaque vente |
| Top 20 meilleurs produits | 13/06/2026 | Rapports: montant ventes + quantités par période |
| Inventaire remplace Stock | 13/06/2026 | Menu bottom nav: Stock → Inventaire |
| Popup Inventaire en français | 13/06/2026 | Texte traduit + popup au-dessus du clavier |
| Fournisseurs call/WhatsApp | 13/06/2026 | Boutons fonctionnels avec error handling |
| Nom fournisseur dans produits | 13/06/2026 | Affiché sous le nom du produit |
| Login boutique via QR code | 13/06/2026 | Bouton "Se connecter à une boutique" |
| Fix Google Drive connexion | 13/06/2026 | Validation accessToken avant création client |
| Création vendeur depuis auth | 13/06/2026 | Écran "Qui êtes-vous?" avec bouton créer |
| Git/GitHub setup | 13/06/2026 | https://github.com/BENsidneykokolo/yabisso-kassa |
| Build APK v1.1 | 13/06/2026 | 66.8 MB avec sync Google Drive |
| Fix image produit (affichage) | 12/06/2026 | Image.file() au lieu du placeholder |
| Fix rafraîchissement produits | 12/06/2026 | ref.invalidate(productsProvider) |
| Fix fournisseurs mock → DB | 12/06/2026 | _suppliers depuis DatabaseHelper |
| Fix navigation mobile persistante | 12/06/2026 | MainScreen + ProductsContent |
| flutter analyze 0 erreurs | 12/06/2026 | 0 erreurs, 0 nouveaux warnings |
| Bouton "+" dans menu | 12/06/2026 | Bottom nav + FAB + sidebar desktop |
| Système catégories/sous-catégories | 12/06/2026 | DB, écran gestion, filtres dynamiques |
| Rebuild APK release | 13/06/2026 | 51.8 MB, flutter build apk --release |
| Écran Vendeurs (vendors/) | 12/06/2026 | vendors_screen.dart créé |
| Widget Numpad (numpad/) | 12/06/2026 | app_numpad.dart créé |
| Fix bouton Pay Now + FAB | 13/06/2026 | FAB masqué quand panier visible, texte "Pay Now →" |

---

| Offline Voucher System (OFF-XXXX-XXXX) | 14/06/2026 | Voucher offline pour WhatsApp, validation locale sans Internet |
| Points System (PTS-XXXX-XXXX-XXXX) | 15/06/2026 | Achat/recharge points, payer abonnement avec points (1pt=1FCFA) |
| Points Screen (Paramètres) | 15/06/2026 | Solde, code PTS, WhatsApp, validation |
| Payer abonnement avec points | 15/06/2026 | 4 plans: Micro(1000pts), Basic(1500pts), Premium(3000pts), Illimité(5000pts) |
| App Icons (Flutter + Dashboard) | 15/06/2026 | Icône caisse pour app, icône dashboard pour admin |
| Fix TS Errors Dashboard | 15/06/2026 | 6 fichiers TypeScript corrigés |
| Build APK v1.0.2 | 15/06/2026 | 67.4 MB, commit f97801a |
| Git push Dashboard | 15/06/2026 | Commit 1c5bffb, build OK |
| Mode Carton (Ajouter Produit) | 15/06/2026 | Toggle Unité/Carton, bénéfice auto-calculé, nb pièces |
| Nouveaux icônes (kassa_app.png + Dashbord.png) | 15/06/2026 | Flutter + Dashboard/Capacitor |
| Build APK Flutter v1.0.3 | 15/06/2026 | 70.7 MB, mode Carton + nouveaux icônes |
| Build Dashboard APK | 15/06/2026 | 4.2 MB, nouveau favicon |
| Fix contournement abonnement (CRITIQUE) | 16/06/2026 | _login() vérifie _hasSubscription, dialog voucher OFF obligatoire après WhatsApp |
| OFF voucher plan encoding | 16/06/2026 | OFF-{hash}-{M/B/P/U}{3random}, extractPlanFromCode() + getMaxProductsForPlan() |
| Points rechargement dans auth | 16/06/2026 | Si solde insuffisant → dialog rechargement via code PTS |
| Dashboard WhatsApp direct | 16/06/2026 | Bouton WhatsApp à côté des codes générés + dans chaque ligne |
| Icônes redimensionnés par densité | 16/06/2026 | PIL resize pour tous les mipmap (48→192px) |
| Build APK Flutter v1.1.0 | 16/06/2026 | 67.5 MB, fix abonnement, OFF plan, nouveaux icônes |
| Build Dashboard APK v2 | 16/06/2026 | 4.1 MB, WhatsApp direct, OFF plan encoding |
| Git push Flutter | 16/06/2026 | da60b78 |
| Git push Dashboard | 16/06/2026 | e392d76 |
| Fix compteur abonnement (jours restants) | 16/06/2026 | Lecture de `subscription_expires` depuis SharedPreferences au lieu de now+30 |
| Popup rappel J-5 et J-1 | 16/06/2026 | WhatsApp + Points + Appel + Fermer, reset flags au renouvellement |
| Fix OFF voucher activation (subscription_screen) | 16/06/2026 | extractPlanFromCode au lieu de BASIC hardcodé, + subscription_expires manquant |
| Fix tablette paysage bouton Payer | 16/06/2026 | isDesktop → breakpoint 1200, cart bar ajouté au layout desktop |
| Build Flutter APK v1.2.0 | 16/06/2026 | 68 MB, tous les correctifs ci-dessus |

---

*Dernière mise à jour: 26/06/2026*
