import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Finances',
      icon: Icons.account_balance_wallet_rounded,
      description: 'Revenus, dépenses, bénéfices et trésorerie avec graphiques et filtres par période.',
      plannedFeatures: ['Graphiques revenus / dépenses / bénéfices', 'Filtres : Aujourd\'hui, Semaine, Mois, Année'],
    );
  }
}
