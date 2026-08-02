import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../data/models/employee.dart';

/// Liste des employés — section 23. Statut de présence en direct.
class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  Color _statusColor(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return AppColors.success;
      case AttendanceStatus.absent:
        return AppColors.danger;
      case AttendanceStatus.enPause:
        return AppColors.warning;
      case AttendanceStatus.enConge:
        return AppColors.info;
    }
  }

  String _statusLabel(AttendanceStatus s) {
    switch (s) {
      case AttendanceStatus.present:
        return 'Présent';
      case AttendanceStatus.absent:
        return 'Absent';
      case AttendanceStatus.enPause:
        return 'En pause';
      case AttendanceStatus.enConge:
        return 'En congé';
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = MockData.employees;
    return Scaffold(
      appBar: AppBar(title: const Text('Employés')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: employees.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
        itemBuilder: (context, i) {
          final e = employees[i];
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(e.firstName[0] + e.lastName[0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.fullName, style: Theme.of(context).textTheme.titleMedium),
                      Text('${e.position} — ${e.department}', style: Theme.of(context).textTheme.bodyMedium),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: _statusColor(e.attendanceStatus).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    _statusLabel(e.attendanceStatus),
                    style: TextStyle(color: _statusColor(e.attendanceStatus), fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.person_add_alt_rounded),
        label: const Text('Nouvel employé'),
      ),
    );
  }
}
