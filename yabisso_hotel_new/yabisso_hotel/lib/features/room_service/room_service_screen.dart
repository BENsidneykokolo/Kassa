import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class RoomServiceScreen extends StatelessWidget {
  const RoomServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Room Service',
      icon: Icons.room_service_rounded,
      description: 'Commandes reçues, en préparation et livrées, avec chambre et client associés.',
      plannedFeatures: ['File des commandes par statut', 'Détail chambre / client', 'Historique'],
    );
  }
}
