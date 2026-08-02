import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Stocks',
      icon: Icons.inventory_2_rounded,
      description: 'Stock total, produits faibles, ruptures, produits expirés, entrées/sorties et fournisseurs.',
      plannedFeatures: ['Tableau de bord stocks', 'Inventaire, entrées, sorties', 'Fournisseurs'],
    );
  }
}
