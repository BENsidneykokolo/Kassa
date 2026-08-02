import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class RoleSelectionScreen extends StatelessWidget {
  final void Function(StaffRole role) onRoleSelected;
  const RoleSelectionScreen({super.key, required this.onRoleSelected});

  IconData _iconFor(StaffRole role) {
    switch (role) {
      case StaffRole.proprietaire:
        return Icons.workspace_premium_rounded;
      case StaffRole.manager:
        return Icons.manage_accounts_rounded;
      case StaffRole.reception:
        return Icons.support_agent_rounded;
      case StaffRole.caisse:
        return Icons.point_of_sale_rounded;
      case StaffRole.restaurant:
        return Icons.restaurant_rounded;
      case StaffRole.bar:
        return Icons.local_bar_rounded;
      case StaffRole.housekeeping:
        return Icons.cleaning_services_rounded;
      case StaffRole.maintenance:
        return Icons.build_rounded;
      case StaffRole.employe:
        return Icons.badge_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vous êtes connecté en tant que')),
      body: GridView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.md,
          mainAxisSpacing: AppSpacing.md,
          childAspectRatio: 1.05,
        ),
        itemCount: StaffRole.values.length,
        itemBuilder: (context, i) {
          final role = StaffRole.values[i];
          return InkWell(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            onTap: () => onRoleSelected(role),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconFor(role), size: 32, color: AppColors.primary),
                  const SizedBox(height: AppSpacing.sm),
                  Text(role.label, style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
