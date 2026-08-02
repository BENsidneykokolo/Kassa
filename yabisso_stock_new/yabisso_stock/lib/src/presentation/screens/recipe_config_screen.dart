import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:uuid/uuid.dart';
import '../../domain/enums.dart';
import '../providers/stock_providers.dart';

/// Écran "Recettes" — permet à un restaurant de définir qu'une vente de
/// menu (ex: "Poulet Braisé" côté Kassa) décrémente automatiquement les
/// matières premières correspondantes. C'est ce qui répond au besoin :
/// "Restaurant → consommation automatique selon recettes".
class RecipeListScreen extends ConsumerWidget {
  const RecipeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(stockDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recettes & nomenclatures')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle recette'),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecipeEditScreen()),
        ),
      ),
      body: StreamBuilder<List<Recipe>>(
        stream: db.select(db.recipes).watch(),
        builder: (context, snap) {
          final recipes = snap.data ?? [];
          if (recipes.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Aucune recette. Créez-en une pour lier un plat vendu '
                  '(ex. Poulet Braisé) à ses ingrédients (poulet, oignon, huile…) '
                  'et laisser Yabisso Stock décrémenter tout seul à chaque vente.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView(
            children: recipes
                .map((r) => ListTile(
                      leading: const Icon(Icons.restaurant_menu),
                      title: Text(r.name),
                      subtitle: Text('Produit lié : ${r.catalogProductId} · ${r.yieldQuantity} portion(s)'),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => RecipeEditScreen(recipeId: r.id)),
                      ),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class RecipeEditScreen extends ConsumerStatefulWidget {
  final String? recipeId;
  const RecipeEditScreen({super.key, this.recipeId});

  @override
  ConsumerState<RecipeEditScreen> createState() => _RecipeEditScreenState();
}

class _RecipeEditScreenState extends ConsumerState<RecipeEditScreen> {
  final _nameCtrl = TextEditingController();
  final _catalogProductCtrl = TextEditingController();
  final _yieldCtrl = TextEditingController(text: '1');
  final List<_IngredientRow> _ingredients = [];

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allStockItemsProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipeId == null ? 'Nouvelle recette' : 'Modifier la recette')),
      body: itemsAsync.when(
        data: (stockItems) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Nom de la recette (ex: Poulet Braisé)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catalogProductCtrl,
              decoration: const InputDecoration(
                labelText: 'ID produit catalogue vendu (menu Kassa)',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _yieldCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Portions produites par exécution'),
            ),
            const SizedBox(height: 20),
            const Text('Ingrédients', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._ingredients.asMap().entries.map((entry) {
              final i = entry.key;
              final row = entry.value;
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          decoration: const InputDecoration(labelText: 'Matière première'),
                          value: row.stockItemId,
                          items: stockItems
                              .map((s) => DropdownMenuItem(value: s.id, child: Text(s.catalogProductId)))
                              .toList(),
                          onChanged: (v) => setState(() => row.stockItemId = v),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: row.qtyCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Qté'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: DropdownButtonFormField<StockUnit>(
                          decoration: const InputDecoration(labelText: 'Unité'),
                          value: row.unit,
                          items: StockUnit.values
                              .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                              .toList(),
                          onChanged: (v) => setState(() => row.unit = v ?? StockUnit.g),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => setState(() => _ingredients.removeAt(i)),
                      ),
                    ],
                  ),
                ),
              );
            }),
            TextButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un ingrédient'),
              onPressed: () => setState(() => _ingredients.add(_IngredientRow())),
            ),
            const SizedBox(height: 24),
            FilledButton(onPressed: _save, child: const Text('Enregistrer la recette')),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Text('Erreur : $e'),
      ),
    );
  }

  Future<void> _save() async {
    final db = ref.read(stockDatabaseProvider);
    final tenantId = ref.read(currentTenantIdProvider);
    final yieldQty = double.tryParse(_yieldCtrl.text) ?? 1;

    final recipeId = widget.recipeId ?? const Uuid().v4();
    await db.into(db.recipes).insert(
          RecipesCompanion.insert(
            id: drift.Value(recipeId),
            tenantId: tenantId,
            name: _nameCtrl.text,
            catalogProductId: _catalogProductCtrl.text,
            yieldQuantity: drift.Value(yieldQty),
          ),
          mode: drift.InsertMode.insertOrReplace,
        );

    for (final row in _ingredients) {
      if (row.stockItemId == null) continue;
      final qty = double.tryParse(row.qtyCtrl.text.replaceAll(',', '.')) ?? 0;
      if (qty <= 0) continue;
      await db.into(db.recipeIngredients).insert(
            RecipeIngredientsCompanion.insert(
              tenantId: tenantId,
              recipeId: recipeId,
              stockItemId: row.stockItemId!,
              quantity: qty,
              unit: row.unit.name,
            ),
          );
    }

    if (mounted) Navigator.of(context).pop();
  }
}

class _IngredientRow {
  String? stockItemId;
  StockUnit unit = StockUnit.g;
  final qtyCtrl = TextEditingController();
}
