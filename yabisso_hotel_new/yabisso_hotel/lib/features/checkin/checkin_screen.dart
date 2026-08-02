import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class CheckinScreen extends StatelessWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Check-in',
      icon: Icons.login_rounded,
      description: 'Parcours étape par étape : informations client, pièce d\'identité, chambre, paiement, confirmation.',
      plannedFeatures: [
        'Étape 1 — Informations client',
        'Étape 2 — Pièce d\'identité',
        'Étape 3 — Attribution de chambre',
        'Étape 4 — Paiement',
        'Étape 5 — Confirmation',
      ],
    );
  }
}
