import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/session_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/stat_card.dart';
import '../../core/widgets/sync_indicator.dart';
import '../../data/mock/mock_data.dart';

/// Dashboard Propriétaire — section 3 du prompt UI/UX.
/// Statistiques, graphique de revenus, activité en temps réel, alertes,
/// conseils IA.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final firstName = (session.userName ?? 'Ben').split(' ').first;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Bonjour, $firstName', style: Theme.of(context).textTheme.headlineMedium),
                              const SizedBox(height: 2),
                              Text(MockData.hotel.name, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                        const SyncIndicator(),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.35,
                      children: const [
                        StatCard(
                          label: "Chiffre d'affaires (jour)",
                          value: '1 240 000 F',
                          icon: Icons.payments_rounded,
                          color: AppColors.success,
                          trend: '+8%',
                        ),
                        StatCard(
                          label: "Taux d'occupation",
                          value: '76%',
                          icon: Icons.hotel_rounded,
                          color: AppColors.info,
                          trend: '-15%',
                          trendIsPositive: false,
                        ),
                        StatCard(
                          label: 'Réservations',
                          value: '12',
                          icon: Icons.event_available_rounded,
                          color: AppColors.primary,
                          trend: '+3',
                        ),
                        StatCard(
                          label: 'Clients présents',
                          value: '34',
                          icon: Icons.groups_rounded,
                          color: AppColors.accentGold,
                        ),
                        StatCard(
                          label: 'Revenus restaurant',
                          value: '380 000 F',
                          icon: Icons.restaurant_rounded,
                          color: AppColors.warning,
                        ),
                        StatCard(
                          label: 'Revenus bar',
                          value: '210 000 F',
                          icon: Icons.local_bar_rounded,
                          color: AppColors.danger,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _RevenueChartCard(),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Activité en temps réel', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.list(
                children: const [
                  _ActivityTile(icon: Icons.login_rounded, color: AppColors.success, text: 'Check-in — Chambre 202, Aïcha Bemba', time: 'il y a 5 min'),
                  _ActivityTile(icon: Icons.restaurant_menu_rounded, color: AppColors.warning, text: 'Commande restaurant — Chambre 202', time: 'il y a 12 min'),
                  _ActivityTile(icon: Icons.event_available_rounded, color: AppColors.info, text: 'Nouvelle réservation — Chambre 104', time: 'il y a 40 min'),
                  _ActivityTile(icon: Icons.logout_rounded, color: AppColors.textSecondary, text: 'Check-out — Chambre 301', time: 'il y a 1 h'),
                ],
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Alertes', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    const _AlertRow(icon: Icons.cleaning_services_rounded, text: '3 chambres à nettoyer'),
                    const _AlertRow(icon: Icons.build_rounded, text: '1 ticket de maintenance ouvert'),
                    const _AlertRow(icon: Icons.inventory_2_rounded, text: 'Stock faible : eau minérale'),
                    const SizedBox(height: AppSpacing.lg),
                    _AiTipCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevenueChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          Text('Revenus — 7 derniers jours', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 160,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true, color: AppColors.primary.withValues(alpha: 0.08)),
                    spots: const [
                      FlSpot(0, 3), FlSpot(1, 4.2), FlSpot(2, 3.8), FlSpot(3, 5),
                      FlSpot(4, 4.6), FlSpot(5, 6.1), FlSpot(6, 5.4),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;
  final String time;

  const _ActivityTile({required this.icon, required this.color, required this.text, required this.time});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm + 4),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
            Text(time, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _AlertRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.warning),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyLarge)),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}

class _AiTipCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_awesome_rounded, color: Colors.white),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Conseil IA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  "Votre taux d'occupation est inférieur de 15% cette semaine. Découvrez 3 stratégies pour l'améliorer.",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
