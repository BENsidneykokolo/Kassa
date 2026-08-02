import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_states.dart';
import '../../core/widgets/status_badge.dart';
import '../../data/mock/mock_data.dart';

/// Liste des réservations — section 6 du prompt.
class ReservationsScreen extends StatelessWidget {
  const ReservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final reservations = MockData.reservations;
    final dateFmt = DateFormat('dd MMM', 'fr_FR');

    return Scaffold(
      appBar: AppBar(title: const Text('Réservations')),
      body: reservations.isEmpty
          ? const AppEmptyState(
              title: 'Aucune réservation',
              message: 'Les nouvelles réservations apparaîtront ici.',
              icon: Icons.event_busy_rounded,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: reservations.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final r = reservations[i];
                return Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(r.guestName, style: Theme.of(context).textTheme.titleMedium),
                          StatusBadge.reservation(r.status),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('Chambre ${r.roomNumber}', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 6),
                          Text(
                            '${dateFmt.format(r.checkIn)} → ${dateFmt.format(r.checkOut)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Spacer(),
                          Text(
                            '${r.totalAmount.toStringAsFixed(0)} F',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle réservation'),
      ),
    );
  }
}
