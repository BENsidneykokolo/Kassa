import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class PosRestaurantScreen extends StatelessWidget {
  const PosRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Caisse Restaurant',
      icon: Icons.restaurant_rounded,
      description: 'Interface POS façon Yabisso Kassa : catégories, produits, panier, remise, paiement.',
      plannedFeatures: [
        'Catégories & produits avec photos',
        'Panier (ajout, quantité, suppression, remise)',
        'Paiement (Cash / Mobile Money / Carte)',
        'Réutiliser les composants Kassa (cohérence UX)',
      ],
    );
  }
}
