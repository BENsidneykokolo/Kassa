import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';

class SubscriptionRequestsScreen extends StatefulWidget {
  const SubscriptionRequestsScreen({super.key});

  @override
  State<SubscriptionRequestsScreen> createState() => _SubscriptionRequestsScreenState();
}

class _SubscriptionRequestsScreenState extends State<SubscriptionRequestsScreen> with SingleTickerProviderStateMixin {
  static const _primary = AppColors.primaryGreen;
  late TabController _tabController;
  String _filterStatus = 'all';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() => _filterStatus = _tabController.index == 0 ? 'pending' : 'all');
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> _getRequestsStream() {
    return FirebaseFirestore.instance
        .collection('subscription_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> _acceptRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final notesController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accepter la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutique: ${data['storeName'] ?? ''}'),
            Text('Forfait: ${data['requestedPlan'] ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Notes (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.successGreen),
            child: const Text('Accepter'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('subscription_requests').doc(doc.id).update({
        'status': 'accepted',
        'processedAt': DateTime.now().toIso8601String(),
        'notes': notesController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande acceptée'), backgroundColor: AppColors.successGreen),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    }
  }

  Future<void> _rejectRequest(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Refuser la demande'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Boutique: ${data['storeName'] ?? ''}'),
            Text('Forfait: ${data['requestedPlan'] ?? ''}'),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Raison du refus (optionnel)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            child: const Text('Refuser'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('subscription_requests').doc(doc.id).update({
        'status': 'rejected',
        'processedAt': DateTime.now().toIso8601String(),
        'rejectionReason': reasonController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Demande refusée'), backgroundColor: AppColors.primaryRed),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.primaryRed),
        );
      }
    }
  }

  void _copyPhone(String phone) {
    Clipboard.setData(ClipboardData(text: phone));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Téléphone copié: $phone'), backgroundColor: AppColors.successGreen, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Demandes d\'abonnement'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedColor: Colors.white70,
          tabs: const [
            Tab(text: 'En attente'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getRequestsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.primaryRed),
                  const SizedBox(height: 12),
                  Text('Erreur: ${snapshot.error}', style: const TextStyle(color: AppColors.primaryRed)),
                ],
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final pending = docs.where((d) => (d.data() as Map)['status'] == 'pending').toList();
          final processed = docs.where((d) => (d.data() as Map)['status'] != 'pending').toList();

          if (_tabController.index == 0) {
            return _buildPendingList(pending);
          } else {
            return _buildProcessedList(processed);
          }
        },
      ),
    );
  }

  Widget _buildPendingList(List<DocumentSnapshot> pending) {
    if (pending.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucune demande en attente', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (context, index) => _buildRequestCard(pending[index], isPending: true),
    );
  }

  Widget _buildProcessedList(List<DocumentSnapshot> processed) {
    if (processed.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text('Aucun historique', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: processed.length,
      itemBuilder: (context, index) => _buildRequestCard(processed[index], isPending: false),
    );
  }

  Widget _buildRequestCard(DocumentSnapshot doc, {required bool isPending}) {
    final data = doc.data() as Map<String, dynamic>;
    final storeName = data['storeName'] ?? 'N/A';
    final ownerName = data['ownerName'] ?? 'N/A';
    final phone = data['phone'] ?? '';
    final plan = data['requestedPlan'] ?? '';
    final status = data['status'] ?? 'pending';
    final createdAt = DateTime.tryParse(data['createdAt'] ?? '') ?? DateTime.now();
    final processedAt = data['processedAt'] != null ? DateTime.tryParse(data['processedAt']) : null;
    final notes = data['notes'] ?? '';
    final rejectionReason = data['rejectionReason'] ?? '';

    final statusColor = status == 'accepted'
        ? AppColors.successGreen
        : status == 'rejected'
            ? AppColors.primaryRed
            : AppColors.primaryAmber;
    final statusLabel = status == 'accepted'
        ? 'Acceptée'
        : status == 'rejected'
            ? 'Refusée'
            : 'En attente';

    final planColor = _getPlanColor(plan);
    final planPrice = _getPlanPrice(plan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.08),
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(_getStatusIcon(status), color: statusColor, size: 18),
                const SizedBox(width: 8),
                Text(statusLabel, style: TextStyle(color: statusColor, fontWeight: FontWeight.w700, fontSize: 13)),
                const Spacer(),
                Text(_formatDate(createdAt), style: TextStyle(color: Colors.grey[600], fontSize: 12)),
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
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.store, color: _primary, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text('Propriétaire: $ownerName', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: planColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: planColor.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(color: planColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)),
                        child: Text(plan.isNotEmpty ? plan[0] : '?', style: TextStyle(color: planColor, fontWeight: FontWeight.bold, fontSize: 14)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Forfait $plan', style: TextStyle(color: planColor, fontWeight: FontWeight.w600, fontSize: 14)),
                            Text(planPrice, style: TextStyle(color: planColor.withValues(alpha: 0.7), fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => _copyPhone(phone),
                    child: Row(
                      children: [
                        Icon(Icons.phone, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 6),
                        Text(phone, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                        const SizedBox(width: 4),
                        Icon(Icons.copy, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ],
                if (notes.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                    child: Text('Notes: $notes', style: TextStyle(color: Colors.grey[700], fontSize: 12)),
                  ),
                ],
                if (rejectionReason.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColors.primaryRed.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(8)),
                    child: Text('Raison du refus: $rejectionReason', style: const TextStyle(color: AppColors.primaryRed, fontSize: 12)),
                  ),
                ],
                if (processedAt != null) ...[
                  const SizedBox(height: 6),
                  Text('Traité le ${_formatDate(processedAt)}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                ],
                if (isPending) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _acceptRequest(doc),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Accepter'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.successGreen,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _rejectRequest(doc),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Refuser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryRed,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 44),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  String _getPlanPrice(String plan) {
    switch (plan) {
      case 'Micro': return '5 000 FCFA/mois';
      case 'Basic': return '10 000 FCFA/mois';
      case 'Premium': return '20 000 FCFA/mois';
      case 'Illimité': return '50 000 FCFA/mois';
      default: return '';
    }
  }

  Color _getPlanColor(String plan) {
    switch (plan) {
      case 'Micro': return Colors.grey;
      case 'Basic': return _primary;
      case 'Premium': return AppColors.primaryAmber;
      case 'Illimité': return AppColors.primaryBlue;
      default: return _primary;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'accepted': return Icons.check_circle;
      case 'rejected': return Icons.cancel;
      default: return Icons.hourglass_top;
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year;
    final h = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$d/$m/$y à $h:$min';
  }
}
