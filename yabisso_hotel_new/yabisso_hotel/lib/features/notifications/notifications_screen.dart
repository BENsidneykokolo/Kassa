import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Notifications',
      icon: Icons.notifications_rounded,
      description: 'Centre de notifications : Hôtel, Finance, Employés, Stocks, Maintenance, IA.',
      plannedFeatures: ['Filtres par catégorie', 'Marquer comme lu / tout effacer'],
    );
  }
}
