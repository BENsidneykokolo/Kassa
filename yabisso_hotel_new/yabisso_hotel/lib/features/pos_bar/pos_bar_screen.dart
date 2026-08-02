import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class PosBarScreen extends StatelessWidget {
  const PosBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Caisse Bar',
      icon: Icons.local_bar_rounded,
      description: 'Interface POS pour le bar : cocktails, bières, vins, spiritueux, soft, snacks.',
      plannedFeatures: [
        'Catégories : Cocktails, Bières, Vins, Spiritueux, Soft, Snacks',
        'Panier & paiement',
        'Réutiliser les composants Kassa (cohérence UX)',
      ],
    );
  }
}
