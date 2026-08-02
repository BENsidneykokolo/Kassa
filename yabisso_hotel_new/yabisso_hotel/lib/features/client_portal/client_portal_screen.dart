import 'package:flutter/material.dart';
import '../../core/widgets/module_scaffold.dart';

/// Portail client Wi-Fi local — interface distincte de l'admin (section 16-22).
class ClientPortalScreen extends StatelessWidget {
  const ClientPortalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ModuleScaffold(
      title: 'Portail Client',
      icon: Icons.wifi_rounded,
      description: 'Interface accessible via le Wi-Fi local : chambres, restaurant, bar, room service, panier, QR Code.',
      plannedFeatures: [
        'Catalogue chambres / menu restaurant / menu bar',
        'Panier client (payer maintenant ou ajouter à la chambre)',
        'QR Code de confirmation',
      ],
    );
  }
}
