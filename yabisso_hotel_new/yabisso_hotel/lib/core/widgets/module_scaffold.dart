import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'sync_indicator.dart';

/// Scaffold générique pour un module pas encore développé en détail.
///
/// Sert de point d'ancrage dans la navigation dès maintenant : chaque écran
/// listé dans le prompt UI/UX a une route fonctionnelle, prête à être
/// remplacée par l'écran réel (fait main, ou importé depuis Stitch AI).
class ModuleScaffold extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;
  final List<String> plannedFeatures;

  const ModuleScaffold({
    super.key,
    required this.title,
    required this.icon,
    required this.description,
    this.plannedFeatures = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: const [Padding(padding: EdgeInsets.only(right: 16), child: SyncIndicator())],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              if (plannedFeatures.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('À construire dans ce module', style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: AppSpacing.sm),
                      ...plannedFeatures.map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline, size: 16, color: AppColors.textSecondary),
                              const SizedBox(width: 8),
                              Expanded(child: Text(f, style: Theme.of(context).textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
