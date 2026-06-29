import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/ai_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});
  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  static const _primary = AppColors.primaryGreen;
  static const _bg = AppColors.background;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AiService.instance.generateDailyProposals();
    });
  }

  @override
  Widget build(BuildContext context) {
    final admin = ref.watch(currentAdminProvider);
    if (admin == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/login'));
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final statsAsync = ref.watch(dashboardStatsProvider);
    final proposalsAsync = ref.watch(pendingProposalsProvider);

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardStatsProvider);
            ref.invalidate(pendingProposalsProvider);
            ref.invalidate(employeesProvider);
            ref.invalidate(allSalesProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(admin.name, admin.initials),
                const SizedBox(height: 20),
                _buildStatsGrid(statsAsync),
                const SizedBox(height: 20),
                _buildAiSection(proposalsAsync),
                const SizedBox(height: 20),
                _buildQuickActions(),
                const SizedBox(height: 20),
                _buildRecentActivity(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildHeader(String name, String initials) {
    final now = DateTime.now();
    final greeting = now.hour < 12 ? 'Bonjour' : (now.hour < 18 ? 'Bon après-midi' : 'Bonsoir');
    return Row(
      children: [
        CircleAvatar(
          radius: 24, backgroundColor: _primary,
          child: Text(initials.isNotEmpty ? initials : name[0], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting, $name', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Tableau de bord Super Admin', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryAmber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.notifications_outlined, color: AppColors.primaryAmber, size: 22),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(AsyncValue<Map<String, dynamic>> statsAsync) {
    return statsAsync.when(
      data: (stats) => Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard(
                'Employés totaux', '${stats['totalEmployees'] ?? 0}',
                Icons.people, const Color(0xFFE8F5E9), _primary,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                'Abonnements actifs', '${stats['totalSales'] ?? 0}',
                Icons.card_membership, const Color(0xFFE3F2FD), AppColors.primaryBlue,
              )),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(
                'Revenus du jour', _formatPrice(stats['todayRevenue'] ?? 0),
                Icons.attach_money, const Color(0xFFFFF3E0), AppColors.primaryAmber,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(
                'Décisions en attente', '${stats['pendingDecisions'] ?? 0}',
                Icons.pending_actions, const Color(0xFFFCE4EC), AppColors.primaryRed,
              )),
            ],
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const Center(child: Text('Erreur de chargement')),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildAiSection(AsyncValue<List<dynamic>> proposalsAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.primaryBlue, size: 18),
            ),
            const SizedBox(width: 8),
            const Text('IA - Propositions du jour', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        proposalsAsync.when(
          data: (proposals) {
            if (proposals.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 40, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Aucune proposition en attente', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                  ],
                ),
              );
            }
            return Column(
              children: proposals.take(3).map((p) => _buildProposalCard(p)).toList(),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const SizedBox(),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => context.push('/ai-ceo'),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Voir toutes les propositions', style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, color: AppColors.primaryBlue, size: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProposalCard(dynamic proposal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getPriorityColor(proposal.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_getCategoryIcon(proposal.category), color: _getPriorityColor(proposal.priority), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(proposal.title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                Text(proposal.description, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getPriorityColor(proposal.priority).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(proposal.priorityLabel, style: TextStyle(fontSize: 11, color: _getPriorityColor(proposal.priority), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high': return AppColors.primaryRed;
      case 'medium': return AppColors.primaryAmber;
      default: return AppColors.primaryBlue;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'marketing': return Icons.campaign;
      case 'sales': return Icons.trending_up;
      case 'hr': return Icons.people;
      case 'finance': return Icons.account_balance;
      case 'operations': return Icons.settings;
      default: return Icons.lightbulb;
    }
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard('Employés', Icons.people, _primary, () => context.push('/employees'))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard('Ventes', Icons.trending_up, AppColors.primaryBlue, () => context.push('/sales'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard('Assignations', Icons.assignment, AppColors.primaryAmber, () => context.push('/assignments'))),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard('IA Marketing', Icons.campaign, AppColors.primaryRed, () => context.push('/ai-marketing'))),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard('Générateur de vouchers', Icons.vpn_key, AppColors.primaryGreen, () => context.push('/vouchers'))),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey[800])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Aperçu rapide', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [const Color(0xFF00694C), const Color(0xFF1D9E75)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text('RÉSUMÉ IA', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'L\'IA a généré de nouvelles propositions marketing pour booster les ventes de cette semaine.',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push('/ai-ceo'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('Consulter', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA';
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Dashboard', true, () {}),
          _buildNavItem(Icons.people, 'Employés', false, () => context.push('/employees')),
          _buildNavItem(Icons.trending_up, 'Ventes', false, () => context.push('/sales')),
          _buildNavItem(Icons.vpn_key, 'Vouchers', false, () => context.push('/vouchers')),
          _buildNavItem(Icons.smart_toy, 'IA', false, () => context.push('/ai-ceo')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _primary : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? _primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
