import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../services/sync_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Indicateur global "Mode hors ligne / Synchronisation en cours / Synchronisé"
/// demandé dans le prompt (section 40 — États UI). À placer dans les AppBars
/// ou en bannière sous l'AppBar.
class SyncIndicator extends ConsumerWidget {
  const SyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);

    late final Color color;
    late final IconData icon;
    late final String label;

    switch (syncState) {
      case SyncState.offline:
        color = AppColors.offline;
        icon = Icons.cloud_off_rounded;
        label = 'Mode hors ligne';
      case SyncState.syncing:
        color = AppColors.syncing;
        icon = Icons.sync_rounded;
        label = 'Synchronisation en cours';
      case SyncState.synced:
        color = AppColors.synced;
        icon = Icons.cloud_done_rounded;
        label = 'Synchronisé';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
