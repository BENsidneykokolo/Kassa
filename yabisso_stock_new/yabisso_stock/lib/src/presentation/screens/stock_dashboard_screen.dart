import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stock_providers.dart';
import 'product_list_screen.dart';
import 'alerts_screen.dart';
import 'inventory_scan_screen.dart';
import 'transfer_screen.dart';

/// Écran d'accueil du module Stock. Structure pensée pour un gérant qui
/// consulte rapidement l'essentiel avant d'agir : ruptures, valeur du
/// stock, accès direct au scan et aux transferts.
class StockDashboardScreen extends ConsumerWidget {
  const StockDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lowStock = ref.watch(lowStockItemsProvider);
    final allItems = ref.watch(allStockItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yabisso Stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Inventaire par scan',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const InventoryScanScreen()),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(lowStockItemsProvider),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    label: 'Articles suivis',
                    value: allItems.maybeWhen(
                      data: (items) => items.length.toString(),
                      orElse: () => '—',
                    ),
                    icon: Icons.inventory_2_outlined,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Sous seuil',
                    value: lowStock.maybeWhen(
                      data: (items) => items.length.toString(),
                      orElse: () => '—',
                    ),
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AlertsScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionChip(
                  icon: Icons.list_alt,
                  label: 'Tous les articles',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  ),
                ),
                _ActionChip(
                  icon: Icons.swap_horiz,
                  label: 'Transfert entre magasins',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const TransferScreen()),
                  ),
                ),
                _ActionChip(
                  icon: Icons.warning_amber_outlined,
                  label: 'Alertes rupture / péremption',
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Alertes récentes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            lowStock.when(
              data: (items) => items.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Aucune alerte — tout est sous contrôle.'),
                    )
                  : Column(
                      children: items
                          .take(5)
                          .map((item) => ListTile(
                                leading: const Icon(Icons.error_outline, color: Colors.orange),
                                title: Text(item.catalogProductId),
                                subtitle: Text('Seuil : ${item.reorderThreshold} ${item.unit}'),
                                dense: true,
                              ))
                          .toList(),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Erreur : $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionChip({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
