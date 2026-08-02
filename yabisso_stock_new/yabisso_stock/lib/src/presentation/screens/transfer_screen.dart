import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/enums.dart';
import '../providers/stock_providers.dart';

class TransferScreen extends ConsumerStatefulWidget {
  const TransferScreen({super.key});

  @override
  ConsumerState<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends ConsumerState<TransferScreen> {
  String? _stockItemId;
  String? _sourceId;
  String? _destId;
  final _qtyCtrl = TextEditingController();
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(stockDatabaseProvider);
    final itemsAsync = ref.watch(allStockItemsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transfert entre magasins')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: itemsAsync.when(
          data: (items) => ListView(
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Article'),
                value: _stockItemId,
                items: items
                    .map((i) => DropdownMenuItem(value: i.id, child: Text(i.catalogProductId)))
                    .toList(),
                onChanged: (v) => setState(() => _stockItemId = v),
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<Warehouse>>(
                future: db.select(db.warehouses).get(),
                builder: (context, snap) {
                  final warehouses = snap.data ?? [];
                  return Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Magasin source'),
                        value: _sourceId,
                        items: warehouses
                            .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _sourceId = v),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(labelText: 'Magasin destination'),
                        value: _destId,
                        items: warehouses
                            .where((w) => w.id != _sourceId)
                            .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                            .toList(),
                        onChanged: (v) => setState(() => _destId = v),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Quantité à transférer'),
              ),
              const SizedBox(height: 8),
              const Text(
                'Le transfert apparaîtra sur l\'appareil du magasin destinataire dès '
                'qu\'il sera à portée (WiFi Direct / Bluetooth) ou dès la prochaine '
                'connexion internet — pas besoin d\'être connectés en même temps.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.swap_horiz),
                label: _saving ? const Text('Envoi…') : const Text('Transférer'),
                onPressed: _saving ? null : () => _submit(items),
              ),
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text('Erreur : $e'),
        ),
      ),
    );
  }

  Future<void> _submit(List<StockItem> items) async {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
    if (_stockItemId == null || _sourceId == null || _destId == null || qty == null || qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Merci de compléter tous les champs.')),
      );
      return;
    }
    setState(() => _saving = true);
    final item = items.firstWhere((i) => i.id == _stockItemId);
    final service = ref.read(stockServiceProvider);
    final tenantId = ref.read(currentTenantIdProvider);

    await service.transfer(
      tenantId: tenantId,
      stockItemId: _stockItemId!,
      sourceWarehouseId: _sourceId!,
      destWarehouseId: _destId!,
      quantity: qty,
      unit: StockUnit.values.byName(item.unit),
    );

    if (mounted) Navigator.of(context).pop();
  }
}
