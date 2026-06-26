# Problèmes et Solutions - Kassa

## Format d'enregistrement

| Date | Problème | Solution | Statut |
|------|----------|----------|--------|
| - | - | - | - |

---

## Historique des erreurs

| Date | Problème | Solution | Statut |
|------|----------|----------|--------|
| 11/06/2026 | Conflit dépendances : `gallery_saver` (http ^0.13.3) vs `google_fonts` (http ^1.0.0) | Downgrader `google_fonts` de ^6.2.1 → ^4.0.4 | ✅ Résolu |
| 11/06/2026 | Flutter non trouvé dans PATH | Utiliser le chemin complet : `C:\Users\Utilisateur\Downloads\flutter\bin\flutter.bat` | ✅ Résolu |
| 11/06/2026 | PowerShell non trouvé | Ajouter `C:\Windows\System32\WindowsPowerShell\v1.0\` au PATH | ✅ Résolu |
| 11/06/2026 | Developer Mode requis pour symlinks | Activer Developer Mode dans Windows Settings | ⚠️ À faire |
| 11/06/2026 | `CardTheme` ne peut pas être assigné à `CardThemeData?` | Remplacer `CardTheme` par `CardThemeData` dans app_theme.dart | ✅ Résolu |
| 11/06/2026 | `_buildSectionHeader` n'est pas un type de classe | Supprimer `const` devant les appels à `_buildSectionHeader()` | ✅ Résolu |
| 11/06/2026 | Import inutilisé : `database_helper.dart` dans analysis_screen.dart | Supprimer l'import inutilisé | ✅ Résolu |
| 11/06/2026 | Variable locale `isTablet` non utilisée | Supprimer la variable inutilisée | ✅ Résolu |
| 11/06/2026 | `withOpacity` déprécié | Remplacer par `withValues(alpha: ...)` | ✅ Résolu |
| 11/06/2026 | Package `kassa` n'est pas une dépendance | Renommer en `yabisso_kassa` dans le test | ✅ Résolu |
| 11/06/2026 | `MyApp` non défini dans le test | Remplacer par `YabissoApp` | ✅ Résolu |
| 11/06/2026 | Variable `isDesktop` non utilisée dans product_card.dart | Supprimer la variable inutilisée | ✅ Résolu |
| 11/06/2026 | `AppColors.black` n'existe pas | Utiliser `Colors.black` à la place | ✅ Résolu |
| 11/06/2026 | Erreur "parsing the package" à l'installation APK | 1. Ajouter permissions manquantes AndroidManifest.xml 2. minSdkVersion 24→21 3. targetSdkVersion 36→34 4. ndkVersion auto 5. Clean rebuild | ✅ Résolu |
| 12/06/2026 | Image produit jamais affichée après sélection (toujours placeholder) | Remplacer le conditionnel pour afficher `Image.file()` au lieu du placeholder | ✅ Résolu |
| 12/06/2026 | Produits pas rafraîchis après ajout (liste reste vide) | `ref.invalidate(productsProvider)` après `insertProduct()` + transformer en ConsumerStatefulWidget | ✅ Résolu |
| 12/06/2026 | Fournisseurs mock hardcodés au lieu de la DB | Supprimer `_mockSuppliers`, charger `_suppliers` depuis DatabaseHelper | ✅ Résolu |
| 12/06/2026 | Navigation mobile fragmentée (bottom nav disparaît en naviguant) | Créer `MainScreen` avec BottomNav persistante + `products_content.dart` | ✅ Résolu |

---

| 23/06/2026 | GitHub push bloqué (OAuth client secrets dans commit) | `git rm --cached` + `git commit --amend` + ajout au `.gitignore` | ✅ Résolu |
| 26/06/2026 | `sheet.maxRow` pas défini dans excel v4 (6 erreurs analyze) | Remplacer `sheet.maxRow` par `sheet.rows.length` | ✅ Résolu |
| 26/06/2026 | `.toDouble()` / `.toInt()` sur `CellValue?` null-safe | Pattern matching avec `DoubleCellValue` / `IntCellValue` au lieu de `val is num` | ✅ Résolu |
| 26/06/2026 | Imports inutilisés après refactoring Excel | Supprimé `dart:typed_data`, `category.dart`, `supplier.dart`, `isSelected` variables | ✅ Résolu |

---

*Dernière mise à jour: 26/06/2026*
