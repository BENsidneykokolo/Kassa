import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../models/employee.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});
  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen> {
  static const _primary = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Détail Employé'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employees'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showEditDialog(),
          ),
        ],
      ),
      body: employeesAsync.when(
        data: (employees) {
          final employee = employees.firstWhere(
            (e) => e.id == widget.employeeId,
            orElse: () => employees.first,
          );
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(employee),
                const SizedBox(height: 16),
                _buildQuickStats(employee),
                const SizedBox(height: 16),
                _buildSalesHistory(employee),
                const SizedBox(height: 16),
                _buildAttendanceSection(employee),
                const SizedBox(height: 16),
                _buildActionButtons(employee),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildProfileCard(Employee employee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF0B4D3C), _primary],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: _primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white24,
            child: Text(employee.initials.isNotEmpty ? employee.initials : employee.name[0],
              style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          Text(employee.name, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(employee.phone, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 15)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: employee.isActive ? Colors.white24 : AppColors.primaryRed.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(employee.isActive ? employee.roleLabel : 'Inactif',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(Employee employee) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Salaire base', '${employee.baseSalary} FCFA', Icons.account_balance_wallet, AppColors.primaryAmber)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Statut', employee.isActive ? 'Actif' : 'Inactif', Icons.circle, employee.isActive ? AppColors.successGreen : AppColors.primaryRed)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatItem('Rôle', employee.roleLabel, Icons.work, AppColors.primaryBlue)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildSalesHistory(Employee employee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.trending_up, color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text('Historique des ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(5, (i) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: AppColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.receipt, color: AppColors.primaryGreen, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vente #${i + 1}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                      Text('Il y a ${i + 1} jour(s)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
                Text('${(i + 1) * 2500} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 13)),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildAttendanceSection(Employee employee) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: AppColors.primaryBlue, size: 20),
              SizedBox(width: 8),
              Text('Présence', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildAttendanceStat('Présent', '22', AppColors.successGreen),
              const SizedBox(width: 12),
              _buildAttendanceStat('Absent', '2', AppColors.primaryRed),
              const SizedBox(width: 12),
              _buildAttendanceStat('Retard', '1', AppColors.primaryAmber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceStat(String label, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Employee employee) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _toggleActive(employee),
            icon: Icon(employee.isActive ? Icons.block : Icons.check_circle),
            label: Text(employee.isActive ? 'Désactiver' : 'Activer'),
            style: ElevatedButton.styleFrom(
              backgroundColor: employee.isActive ? AppColors.primaryRed : AppColors.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showEditDialog(),
            icon: const Icon(Icons.edit),
            label: const Text('Modifier'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _toggleActive(Employee employee) async {
    final db = DatabaseHelper.instance;
    await db.update('employees', {
      'is_active': employee.isActive ? 0 : 1,
      'updated_at': DateTime.now().toIso8601String(),
    }, employee.id);
    ref.invalidate(employeesProvider);
  }

  void _showEditDialog() {
    final employees = ref.read(employeesProvider).valueOrNull;
    if (employees == null) return;
    final employee = employees.firstWhere((e) => e.id == widget.employeeId);
    final nameController = TextEditingController(text: employee.name);
    final phoneController = TextEditingController(text: employee.phone);

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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modifier l\'employé', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nom complet',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final db = DatabaseHelper.instance;
                    final initials = nameController.text.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                    await db.update('employees', {
                      'name': nameController.text,
                      'phone': phoneController.text,
                      'initials': initials,
                      'updated_at': DateTime.now().toIso8601String(),
                    }, employee.id);
                    ref.invalidate(employeesProvider);
                    if (mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Sauvegarder'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
