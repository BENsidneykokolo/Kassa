import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../models/assignment.dart';
import '../../models/employee.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class AssignmentsScreen extends ConsumerStatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  ConsumerState<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends ConsumerState<AssignmentsScreen> {
  String _filter = 'all';
  static const _primary = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final assignmentsAsync = ref.watch(assignmentsProvider);
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Assignations'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showCreateAssignmentDialog(employeesAsync.valueOrNull ?? []),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: assignmentsAsync.when(
              data: (assignments) {
                final filtered = assignments.where((a) => _filter == 'all' || a.status == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assignment_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(_filter == 'all' ? 'Aucune assignation' : 'Aucune assignation ${_filter == 'pending' ? "en attente" : _filter == 'completed' ? "terminée" : "en cours"}',
                          style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(assignmentsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildAssignmentCard(filtered[i]),
                  ),
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
    final filters = [
      ('all', 'Toutes'),
      ('pending', 'En attente'),
      ('in_progress', 'En cours'),
      ('completed', 'Terminées'),
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

  Widget _buildAssignmentCard(Assignment assignment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getStatusColor(assignment.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_getStatusIcon(assignment.status), color: _getStatusColor(assignment.status), size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(assignment.shopName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                    Text(assignment.employeeName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
              _buildStatusBadge(assignment.status),
            ],
          ),
          const SizedBox(height: 10),
          Text(assignment.description, style: TextStyle(fontSize: 13, color: Colors.grey[700]), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey[400], size: 14),
              const SizedBox(width: 4),
              Text(assignment.territory, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              const Spacer(),
              Text(assignment.date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          if (assignment.status == 'pending' || assignment.status == 'in_progress') ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (assignment.status == 'pending')
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(assignment.id, 'in_progress'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Commencer'),
                    ),
                  ),
                if (assignment.status == 'in_progress') ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateStatus(assignment.id, 'completed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.successGreen,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Terminer'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(assignment.id, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
                if (assignment.status == 'pending') ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _updateStatus(assignment.id, 'cancelled'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryRed,
                        side: const BorderSide(color: AppColors.primaryRed),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String label;
    switch (status) {
      case 'completed': color = AppColors.successGreen; label = 'Terminé'; break;
      case 'in_progress': color = AppColors.primaryBlue; label = 'En cours'; break;
      case 'cancelled': color = AppColors.primaryRed; label = 'Annulé'; break;
      default: color = AppColors.primaryAmber; label = 'En attente';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed': return AppColors.successGreen;
      case 'in_progress': return AppColors.primaryBlue;
      case 'cancelled': return AppColors.primaryRed;
      default: return AppColors.primaryAmber;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed': return Icons.check_circle;
      case 'in_progress': return Icons.play_circle;
      case 'cancelled': return Icons.cancel;
      default: return Icons.schedule;
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final db = DatabaseHelper.instance;
    await db.update('assignments', {
      'status': status,
      'completed_at': status == 'completed' ? DateTime.now().toIso8601String() : null,
    }, id);
    ref.invalidate(assignmentsProvider);
  }

  void _showCreateAssignmentDialog(List<Employee> employees) {
    final shopController = TextEditingController();
    final territoryController = TextEditingController();
    final descriptionController = TextEditingController();
    String? selectedEmployeeId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nouvelle assignation', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Employé',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                  onChanged: (v) => setModalState(() => selectedEmployeeId = v),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: shopController,
                  decoration: InputDecoration(
                    labelText: 'Nom de la boutique',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: territoryController,
                  decoration: InputDecoration(
                    labelText: 'Territoire / Zone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedEmployeeId == null || shopController.text.isEmpty) return;
                      final emp = employees.firstWhere((e) => e.id == selectedEmployeeId);
                      final db = DatabaseHelper.instance;
                      final assignment = Assignment(
                        id: const Uuid().v4(),
                        employeeId: selectedEmployeeId!,
                        employeeName: emp.name,
                        shopName: shopController.text,
                        territory: territoryController.text,
                        description: descriptionController.text,
                        date: DateTime.now().toIso8601String().substring(0, 10),
                        createdAt: DateTime.now().toIso8601String(),
                      );
                      await db.insert('assignments', assignment.toMap());
                      ref.invalidate(assignmentsProvider);
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Créer l\'assignation'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
