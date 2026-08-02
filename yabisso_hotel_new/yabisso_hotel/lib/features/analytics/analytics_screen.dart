import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Analytics',
      icon: Icons.query_stats_rounded,
      description: 'Performance de l\'hôtel : chambres, restaurant, bar, employés, stocks, finance.',
      plannedFeatures: ['Graphiques interactifs par section', 'Comparaisons période sur période'],
    );
  }
}
