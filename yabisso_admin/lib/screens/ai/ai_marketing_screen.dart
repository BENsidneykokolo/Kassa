import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/ai_service.dart';

class AiMarketingScreen extends ConsumerStatefulWidget {
  const AiMarketingScreen({super.key});
  @override
  ConsumerState<AiMarketingScreen> createState() => _AiMarketingScreenState();
}

class _AiMarketingScreenState extends ConsumerState<AiMarketingScreen> {
  String _filter = 'all';
  static const _primary = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(aiProposalsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IA - Marketing'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: _primary.withValues(alpha: 0.05),
            child: Row(
              children: [
                Icon(Icons.campaign, color: _primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Assistant Marketing IA',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)),
                      Text('Propositions et strategies marketing',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildFilterTabs(),
          Expanded(
            child: proposalsAsync.when(
              data: (proposals) {
                final marketing = proposals.where((p) =>
                    p.category == 'marketing' &&
                    (_filter == 'all' || p.status == _filter)).toList();
                if (marketing.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.campaign_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucune proposition marketing',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: marketing.length,
                  itemBuilder: (ctx, i) => _buildProposalCard(marketing[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'key': 'all', 'label': 'Toutes', 'icon': Icons.all_inclusive},
      {'key': 'pending', 'label': 'En attente', 'icon': Icons.hourglass_empty},
      {'key': 'approved', 'label': 'Approuvees', 'icon': Icons.check_circle},
      {'key': 'rejected', 'label': 'Rejetees', 'icon': Icons.cancel},
    ];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final tab = tabs[i];
          final selected = _filter == tab['key'];
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab['icon'] as IconData, size: 16,
                    color: selected ? Colors.white : _primary),
                const SizedBox(width: 4),
                Text(tab['label'] as String),
              ],
            ),
            selected: selected,
            selectedColor: _primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: selected ? Colors.white : _primary, fontSize: 12),
            onSelected: (_) => setState(() => _filter = tab['key']! as String),
          );
        },
      ),
    );
  }

  Widget _buildProposalCard(dynamic proposal) {
    final priorityColor = proposal.priority == 'high'
        ? AppColors.primaryRed
        : proposal.priority == 'medium'
            ? AppColors.primaryAmber
            : AppColors.primaryGreen;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(proposal.priority.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: priorityColor)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('MARKETING',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _primary)),
                ),
                const Spacer(),
                _buildStatusBadge(proposal.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(proposal.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(proposal.description, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, size: 16, color: _primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(proposal.expectedImpact,
                        style: TextStyle(fontSize: 12, color: _primary, fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            ),
            if (proposal.status == 'pending') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _rejectProposal(proposal.id),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Rejeter'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryRed),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _approveProposal(proposal.id),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approuver'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = AppColors.successGreen;
        label = 'Approuve';
        break;
      case 'rejected':
        color = AppColors.primaryRed;
        label = 'Rejete';
        break;
      default:
        color = AppColors.primaryAmber;
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Future<void> _approveProposal(String id) async {
    final admin = ref.read(currentAdminProvider);
    await AiService.instance.approveProposal(id, admin?.id ?? '');
    ref.invalidate(aiProposalsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposition approuvee'), backgroundColor: AppColors.primaryGreen),
      );
    }
  }

  Future<void> _rejectProposal(String id) async {
    final admin = ref.read(currentAdminProvider);
    await AiService.instance.rejectProposal(id, admin?.id ?? '');
    ref.invalidate(aiProposalsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposition rejetee'), backgroundColor: AppColors.primaryRed),
      );
    }
  }
}
