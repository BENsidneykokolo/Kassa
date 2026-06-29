import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../models/ai_proposal.dart';
import '../../providers/providers.dart';
import '../../services/ai_service.dart';

class AiCeoScreen extends ConsumerStatefulWidget {
  const AiCeoScreen({super.key});
  @override
  ConsumerState<AiCeoScreen> createState() => _AiCeoScreenState();
}

class _AiCeoScreenState extends ConsumerState<AiCeoScreen> {
  String _filter = 'pending';
  static const _primary = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final proposalsAsync = ref.watch(aiProposalsProvider);
    final admin = ref.watch(currentAdminProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('IA - Directeur Général'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterTabs(),
          Expanded(
            child: proposalsAsync.when(
              data: (proposals) {
                final filtered = proposals.where((p) => _filter == 'all' || p.status == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle_outline, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucune proposition', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildProposalCard(filtered[i], admin?.id),
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0B4D3C), _primary],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('IA Directeur Général', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Propositions quotidiennes', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final filters = [
      ('pending', 'En attente'),
      ('approved', 'Approuvées'),
      ('rejected', 'Rejetées'),
      ('all', 'Toutes'),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: filters.map((f) {
          final isActive = _filter == f.$1;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 3),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isActive ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? _primary : Colors.grey[300]!),
                ),
                child: Center(
                  child: Text(f.$2, style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey[700],
                  )),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProposalCard(AiProposal proposal, String? adminId) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _getCategoryColor(proposal.category).withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(_getCategoryIcon(proposal.category), color: _getCategoryColor(proposal.category), size: 18),
                const SizedBox(width: 8),
                Text(proposal.categoryLabel, style: TextStyle(color: _getCategoryColor(proposal.category), fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                _buildStatusBadge(proposal.status),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(proposal.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                    _buildPriorityBadge(proposal.priority),
                  ],
                ),
                const SizedBox(height: 8),
                Text(proposal.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text('Impact: ${proposal.expectedImpact}', style: const TextStyle(fontSize: 13, color: AppColors.primaryGreen, fontWeight: FontWeight.w500))),
                    ],
                  ),
                ),
                if (proposal.status == 'pending') ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approveProposal(proposal.id, adminId),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Approuver'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryGreen,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectProposal(proposal.id, adminId),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Rejeter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'approved':
        color = AppColors.successGreen;
        label = 'Approuvé';
        break;
      case 'rejected':
        color = AppColors.primaryRed;
        label = 'Rejeté';
        break;
      default:
        color = AppColors.primaryAmber;
        label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildPriorityBadge(String priority) {
    Color color;
    switch (priority) {
      case 'high': color = AppColors.primaryRed; break;
      case 'medium': color = AppColors.primaryAmber; break;
      default: color = AppColors.primaryBlue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(priority == 'high' ? 'Haute' : priority == 'medium' ? 'Moyenne' : 'Basse',
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'marketing': return AppColors.primaryBlue;
      case 'sales': return AppColors.primaryGreen;
      case 'hr': return AppColors.primaryAmber;
      case 'finance': return const Color(0xFF8B5CF6);
      case 'operations': return AppColors.primaryRed;
      default: return Colors.grey;
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

  Future<void> _approveProposal(String id, String? adminId) async {
    await AiService.instance.approveProposal(id, adminId ?? '');
    ref.invalidate(aiProposalsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposition approuvée'), backgroundColor: AppColors.successGreen),
      );
    }
  }

  Future<void> _rejectProposal(String id, String? adminId) async {
    await AiService.instance.rejectProposal(id, adminId ?? '');
    ref.invalidate(aiProposalsProvider);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposition rejetée'), backgroundColor: AppColors.primaryRed),
      );
    }
  }
}
