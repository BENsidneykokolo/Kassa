import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class CrmScreen extends StatelessWidget {
  const CrmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Clients / CRM',
      icon: Icons.people_alt_rounded,
      description: 'Liste des clients avec séjours, dépenses et fidélité, et fiche client détaillée.',
      plannedFeatures: ['Liste clients', 'Fiche client détaillée', 'Programme de fidélité'],
    );
  }
}
