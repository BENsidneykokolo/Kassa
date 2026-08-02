import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class ReceptionScreen extends StatelessWidget {
  const ReceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Réception',
      icon: Icons.support_agent_rounded,
      description: "Dashboard réception : arrivées et départs du jour, clients présents, chambres disponibles.",
      plannedFeatures: [
        'Arrivées / départs du jour',
        'Clients présents',
        'Actions rapides : Check-in, Check-out, Réservation, Scanner QR',
        'Recherche client',
      ],
    );
  }
}
