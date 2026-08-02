import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class AiManagerScreen extends StatelessWidget {
  const AiManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'AI Hotel Manager',
      icon: Icons.auto_awesome_rounded,
      description: 'Insights et recommandations IA, chat conversationnel, rapport intelligent de la semaine.',
      plannedFeatures: ['Insights IA', 'Recommandations avec impact estimé', 'Chat IA', 'Rapport hebdomadaire'],
    );
  }
}
