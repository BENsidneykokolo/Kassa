import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Pointage',
      icon: Icons.qr_code_scanner_rounded,
      description: 'Scanner le QR Code employé pour enregistrer arrivée / départ, avec historique et heures travaillées.',
      plannedFeatures: ['Scan QR arrivée / départ', 'Historique de pointage', 'Calcul des heures et retards'],
    );
  }
}
