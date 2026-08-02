import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../../domain/enums.dart';
import '../providers/stock_providers.dart';

class StockMovementFormScreen extends ConsumerStatefulWidget {
  final String stockItemId;
  const StockMovementFormScreen({super.key, required this.stockItemId});

  @override
  ConsumerState<StockMovementFormScreen> createState() => _StockMovementFormScreenState();
}

class _StockMovementFormScreenState extends ConsumerState<StockMovementFormScreen> {
  StockMovementType _type = StockMovementType.entree;
  final _qtyCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  DateTime? _expiration;
  String? _warehouseId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(stockDatabaseProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau mouvement')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            SegmentedButton<StockMovementType>(
              segments: const [
                ButtonSegment(value: StockMovementType.entree, label: Text('Entrée'), icon: Icon(Icons.call_received)),
                ButtonSegment(value: StockMovementType.sortie, label: Text('Sortie'), icon: Icon(Icons.call_made)),
                ButtonSegment(value: StockMovementType.perte, label: Text('Perte'), icon: Icon(Icons.delete_outline)),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Warehouse>>(
              future: db.select(db.warehouses).get(),
              builder: (context, snap) {
                final warehouses = snap.data ?? [];
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Magasin / entrepôt'),
                  value: _warehouseId,
                  items: warehouses
                      .map((w) => DropdownMenuItem(value: w.id, child: Text(w.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _warehouseId = v),
                );
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _qtyCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Quantité'),
            ),
            if (_type == StockMovementType.entree) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _batchCtrl,
                decoration: const InputDecoration(labelText: 'N° de lot (optionnel)'),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(_expiration == null
                    ? 'Date de péremption (optionnel)'
                    : 'Expire le ${_expiration!.day}/${_expiration!.month}/${_expiration!.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 7)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
                  );
                  if (picked != null) setState(() => _expiration = picked);
                },
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final qty = double.tryParse(_qtyCtrl.text.replaceAll(',', '.'));
    if (qty == null || qty <= 0 || _warehouseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Quantité et magasin requis.')),
      );
      return;
    }
    setState(() => _saving = true);
    final service = ref.read(stockServiceProvider);
    final tenantId = ref.read(currentTenantIdProvider);
    final db = ref.read(stockDatabaseProvider);
    final item = await (db.select(db.stockItems)
          ..where((t) => t.id.equals(widget.stockItemId)))
        .getSingle();
    final unit = StockUnit.values.byName(item.unit);

    switch (_type) {
      case StockMovementType.entree:
        await service.receiveStock(
          tenantId: tenantId,
          stockItemId: widget.stockItemId,
          warehouseId: _warehouseId!,
          quantity: qty,
          unit: unit,
          batchNumber: _batchCtrl.text.isEmpty ? null : _batchCtrl.text,
          expirationDate: _expiration,
        );
        break;
      case StockMovementType.sortie:
        await service.recordSale(
          tenantId: tenantId,
          stockItemId: widget.stockItemId,
          warehouseId: _warehouseId!,
          quantity: qty,
          unit: unit,
        );
        break;
      case StockMovementType.perte:
        // Une perte est modélisée comme une sortie FEFO avec motif dédié.
        await service.recordSale(
          tenantId: tenantId,
          stockItemId: widget.stockItemId,
          warehouseId: _warehouseId!,
          quantity: qty,
          unit: unit,
        );
        break;
      default:
        break;
    }

    if (mounted) Navigator.of(context).pop();
  }
}
