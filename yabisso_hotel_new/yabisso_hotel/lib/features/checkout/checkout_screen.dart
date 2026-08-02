import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Check-out',
      icon: Icons.logout_rounded,
      description: 'Résumé du séjour, facture (chambre, restaurant, bar, room service, minibar), paiement et finalisation.',
      plannedFeatures: [
        'Durée du séjour et détail des consommations',
        'Total à payer',
        'Paiement : Cash, Mobile Money, Carte',
        'Finaliser le check-out',
      ],
    );
  }
}
