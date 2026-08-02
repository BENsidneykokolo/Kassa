import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../domain/enums.dart';
import '../providers/stock_providers.dart';

/// Mode "inventaire physique" : l'utilisateur scanne les produits un par un
/// dans le magasin, saisit la quantité comptée, et l'app calcule l'écart
/// avec le stock système pour générer un mouvement d'ajustement.
/// Fonctionne intégralement hors-ligne (le scan et le calcul sont locaux).
class InventoryScanScreen extends ConsumerStatefulWidget {
  const InventoryScanScreen({super.key});

  @override
  ConsumerState<InventoryScanScreen> createState() => _InventoryScanScreenState();
}

class _InventoryScanScreenState extends ConsumerState<InventoryScanScreen> {
  bool _scannerActive = true;
  String? _scannedCatalogProductId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventaire par scan')),
      body: Column(
        children: [
          SizedBox(
            height: 260,
            child: _scannerActive
                ? MobileScanner(
                    onDetect: (capture) {
                      final barcode = capture.barcodes.firstOrNull?.rawValue;
                      if (barcode != null) {
                        setState(() {
                          _scannedCatalogProductId = barcode;
                          _scannerActive = false;
                        });
                      }
                    },
                  )
                : Container(
                    color: Colors.black87,
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _scannerActive = true),
                      icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                      label: const Text('Scanner à nouveau', style: TextStyle(color: Colors.white)),
                    ),
                  ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _scannedCatalogProductId == null
                ? const Center(child: Text('Scannez un code-barres pour commencer.'))
                : _CountForm(catalogBarcode: _scannedCatalogProductId!),
          ),
        ],
      ),
    );
  }
}

class _CountForm extends ConsumerStatefulWidget {
  final String catalogBarcode;
  const _CountForm({required this.catalogBarcode});

  @override
  ConsumerState<_CountForm> createState() => _CountFormState();
}

class _CountFormState extends ConsumerState<_CountForm> {
  final _countCtrl = TextEditingController();
  String? _warehouseId;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(stockDatabaseProvider);

    // NB: en production, la résolution code-barres -> StockItem passe par
    // le package `yabisso_catalog` (barcode -> catalogProductId -> StockItem).
    return FutureBuilder<StockItem?>(
      future: (db.select(db.stockItems)
            ..where((t) => t.catalogProductId.equals(widget.catalogBarcode))
            ..limit(1))
          .getSingleOrNull(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final item = snap.data;
        if (item == null) {
          return Center(child: Text('Aucun article Stock lié au code ${widget.catalogBarcode}.'));
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.catalogProductId, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              FutureBuilder<List<Warehouse>>(
                future: db.select(db.warehouses).get(),
                builder: (context, wSnap) {
                  final warehouses = wSnap.data ?? [];
                  return DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Magasin compté'),
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
                controller: _countCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Quantité comptée (${item.unit})'),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _saving ? null : () => _submit(item),
                child: const Text('Valider le comptage'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submit(StockItem item) async {
    final counted = double.tryParse(_countCtrl.text.replaceAll(',', '.'));
    if (counted == null || _warehouseId == null) return;
    setState(() => _saving = true);

    final repo = ref.read(stockItemRepositoryProvider);
    final systemQty = await repo.watchQuantity(item.id, warehouseId: _warehouseId).first;
    final service = ref.read(stockServiceProvider);
    final tenantId = ref.read(currentTenantIdProvider);

    await service.adjustFromInventory(
      tenantId: tenantId,
      stockItemId: item.id,
      warehouseId: _warehouseId!,
      countedQuantity: counted,
      systemQuantity: systemQty,
      unit: StockUnit.values.byName(item.unit),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Écart de ${(counted - systemQty).toStringAsFixed(2)} ${item.unit} enregistré.')),
      );
      Navigator.of(context).pop();
    }
  }
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
