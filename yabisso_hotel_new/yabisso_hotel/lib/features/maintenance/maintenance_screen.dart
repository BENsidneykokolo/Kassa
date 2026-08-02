import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Maintenance',
      icon: Icons.build_rounded,
      description: 'Incidents, équipements et tickets de maintenance avec priorité, technicien assigné et coût.',
      plannedFeatures: ['Liste des tickets', 'Création d\'un ticket', 'Priorité, statut, coût, technicien'],
    );
  }
}
