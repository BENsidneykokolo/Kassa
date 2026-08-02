import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class HousekeepingScreen extends StatelessWidget {
  const HousekeepingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Housekeeping',
      icon: Icons.cleaning_services_rounded,
      description: 'Chambres à nettoyer, en nettoyage, nettoyées, en inspection, prêtes — avec affectation du personnel.',
      plannedFeatures: ['Tableau par statut de nettoyage', 'Affectation employé / horaires', 'Contrôle qualité'],
    );
  }
}
