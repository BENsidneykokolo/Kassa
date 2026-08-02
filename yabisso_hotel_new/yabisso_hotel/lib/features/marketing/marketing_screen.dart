import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class MarketingScreen extends StatelessWidget {
  const MarketingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Marketing',
      icon: Icons.campaign_rounded,
      description: 'Campagnes, promotions, clients ciblés et revenus générés.',
      plannedFeatures: ['Tableau de bord campagnes', 'Créer une campagne'],
    );
  }
}
