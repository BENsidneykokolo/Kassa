import 'package:flutter/material.dart';

/// Palette Yabisso Hôtel — premium, sobre, lisible.
/// Bleu = identité Yabisso / actions principales.
/// Vert = succès, disponibilité, revenus positifs.
/// Ambre = alertes / attention.
/// Rouge = erreurs, indisponibilité, urgence.
class AppColors {
  AppColors._();

  // Marque
  static const Color primary = Color(0xFF1B4B8F); // Bleu Yabisso
  static const Color primaryDark = Color(0xFF0F3162);
  static const Color primaryLight = Color(0xFF4B7BC4);
  static const Color accentGold = Color(0xFFC9A24B); // Touche "5 étoiles"

  // Neutres
  static const Color background = Color(0xFFF6F7FB);
  static const Color backgroundDark = Color(0xFF0E1420);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF171F2E);
  static const Color border = Color(0xFFE4E7EE);
  static const Color borderDark = Color(0xFF2A3446);

  static const Color textPrimary = Color(0xFF161B22);
  static const Color textSecondary = Color(0xFF5B6472);
  static const Color textOnDarkPrimary = Color(0xFFF3F5F9);
  static const Color textOnDarkSecondary = Color(0xFFA6AFBD);

  // États fonctionnels
  static const Color success = Color(0xFF1E9E5A);
  static const Color successBg = Color(0xFFE6F6ED);
  static const Color warning = Color(0xFFE3A008);
  static const Color warningBg = Color(0xFFFCF1D9);
  static const Color danger = Color(0xFFD64545);
  static const Color dangerBg = Color(0xFFFBE7E7);
  static const Color info = Color(0xFF2E7FE0);
  static const Color infoBg = Color(0xFFE7F1FD);

  // Statuts de chambre
  static const Color roomAvailable = success;
  static const Color roomOccupied = Color(0xFF2E7FE0);
  static const Color roomReserved = Color(0xFF8656D6);
  static const Color roomCleaning = warning;
  static const Color roomInspection = Color(0xFF17A2B8);
  static const Color roomMaintenance = Color(0xFF6C757D);
  static const Color roomOutOfService = danger;

  // Offline / sync
  static const Color offline = Color(0xFF9AA1AC);
  static const Color syncing = warning;
  static const Color synced = success;
}
