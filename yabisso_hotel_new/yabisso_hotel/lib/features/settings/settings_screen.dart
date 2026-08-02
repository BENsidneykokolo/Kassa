import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Paramètres — section 39. Profil hôtel, utilisateurs, paiements,
/// Wi-Fi local, synchronisation, mode hors-ligne, sécurité.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final items = <_SettingItem>[
      _SettingItem(Icons.apartment_rounded, 'Profil hôtel'),
      _SettingItem(Icons.meeting_room_rounded, 'Chambres'),
      _SettingItem(Icons.group_rounded, 'Utilisateurs & rôles'),
      _SettingItem(Icons.payments_rounded, 'Paiements & Mobile Money'),
      _SettingItem(Icons.print_rounded, 'Imprimantes'),
      _SettingItem(Icons.wifi_rounded, 'Wi-Fi local'),
      _SettingItem(Icons.sync_rounded, 'Synchronisation & mode hors-ligne'),
      _SettingItem(Icons.security_rounded, 'Sécurité'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          if (session.userName != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const CircleAvatar(radius: 24, backgroundColor: AppColors.primary, child: Icon(Icons.person, color: Colors.white)),
                  const SizedBox(width: AppSpacing.md),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(session.userName!, style: Theme.of(context).textTheme.titleMedium),
                      if (session.role != null) Text(session.role!.label, style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ...items.map(
            (i) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(i.icon, color: AppColors.primary),
                title: Text(i.label),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            label: const Text('Se déconnecter', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String label;
  _SettingItem(this.icon, this.label);
}
