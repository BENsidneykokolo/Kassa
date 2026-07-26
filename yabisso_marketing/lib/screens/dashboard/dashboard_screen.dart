import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/currency_service.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final campaignsCount = ref.watch(campaignsCountProvider);
    final activePromotionsCount = ref.watch(activePromotionsCountProvider);
    final totalCouponUsage = ref.watch(totalCouponUsageProvider);
    final campaigns = ref.watch(campaignsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau de bord'),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(campaignsCountProvider);
          ref.invalidate(activePromotionsCountProvider);
          ref.invalidate(totalCouponUsageProvider);
          ref.read(campaignsProvider.notifier).loadCampaigns();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resume marketing',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Campagnes',
                      value: campaignsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      icon: Icons.campaign,
                      color: AppTheme.primaryColor,
                      onTap: () => context.go('/campaigns'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Promotions',
                      value: activePromotionsCount.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      icon: Icons.local_offer,
                      color: AppTheme.secondaryColor,
                      onTap: () => context.go('/promotions'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Coupons',
                      value: totalCouponUsage.when(
                        data: (count) => count.toString(),
                        loading: () => '...',
                        error: (_, __) => '0',
                      ),
                      icon: Icons.confirmation_num,
                      color: AppTheme.warningColor,
                      onTap: () => context.go('/coupons'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Actions rapides',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Nouvelle campagne',
                      subtitle: 'SMS, WhatsApp, Email',
                      icon: Icons.add_circle,
                      color: AppTheme.primaryColor,
                      onTap: () => context.go('/campaigns/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Nouvelle promotion',
                      subtitle: 'Remises et offres',
                      icon: Icons.local_offer,
                      color: AppTheme.secondaryColor,
                      onTap: () => context.go('/promotions/add'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Nouveau coupon',
                      subtitle: 'Codes promo',
                      icon: Icons.confirmation_num,
                      color: AppTheme.warningColor,
                      onTap: () => context.go('/coupons/add'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Partager',
                      subtitle: 'Envoyer via WhatsApp',
                      icon: Icons.share,
                      color: const Color(0xFF25D366),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Campagnes recentes',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              campaigns.when(
                data: (list) {
                  if (list.isEmpty) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Icon(Icons.campaign,
                                size: 48, color: AppTheme.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                              'Aucune campagne',
                              style: TextStyle(color: AppTheme.textSecondary),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => context.go('/campaigns/add'),
                              child: const Text('Creer une campagne'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: list.take(3).map((campaign) {
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                AppTheme.primaryColor.withOpacity(0.1),
                            child: Icon(
                              _getCampaignIcon(campaign.type),
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          title: Text(campaign.name),
                          subtitle: Text(campaign.typeLabel),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(campaign.status)
                                  .withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              campaign.statusLabel,
                              style: TextStyle(
                                color: _getStatusColor(campaign.status),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Erreur: $e')),
              ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCampaignIcon(String type) {
    switch (type) {
      case 'sms':
        return Icons.sms;
      case 'whatsapp':
        return Icons.chat;
      case 'email':
        return Icons.email;
      case 'reseaux_sociaux':
        return Icons.public;
      default:
        return Icons.campaign;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'envoye':
        return AppTheme.successColor;
      case 'programme':
        return AppTheme.warningColor;
      case 'brouillon':
        return AppTheme.textSecondary;
      default:
        return AppTheme.textSecondary;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
