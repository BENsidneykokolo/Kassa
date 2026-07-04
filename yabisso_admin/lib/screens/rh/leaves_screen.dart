import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class LeavesScreen extends ConsumerStatefulWidget {
  const LeavesScreen({super.key});
  @override
  ConsumerState<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends ConsumerState<LeavesScreen> {
  String _filterStatus = 'all';
  List<Map<String, dynamic>> _leaves = [];
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  static const _leaveTypes = ['Congé annuel', 'Congé maladie', 'Congé maternité', 'Congé paternité', 'Congé sans solde', 'Convenance personnelle', 'Autre'];
  static const _statusLabels = {'all': 'Tous', 'pending': 'En attente', 'approved': 'Approuvé', 'rejected': 'Refusé'};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    _leaves = await db.getAll('leaves', orderBy: 'created_at DESC');
    _employees = await db.getAll('employees');
    setState(() => _loading = false);
  }

  Future<void> _updateStatus(String id, String status, String? comment) async {
    final db = DatabaseHelper.instance;
    final admin = ref.read(currentAdminProvider);
    await db.update('leaves', {
      'status': status,
      'reviewed_by': admin?.id,
      'reviewed_at': DateTime.now().toIso8601String(),
      'review_comment': comment ?? '',
      'updated_at': DateTime.now().toIso8601String(),
    }, id);
    await db.logActivity(admin?.id, 'leave_$status', 'Demande de congé $status');
    _loadData();
  }

  void _showAddLeaveDialog() {
    String? selectedEmployee;
    String selectedType = _leaveTypes.first;
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now();
    final reasonController = TextEditingController();
    final daysController = TextEditingController(text: '1');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nouvelle demande de congé', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedEmployee,
                  decoration: InputDecoration(labelText: 'Employé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _employees.map((e) => DropdownMenuItem(value: e['id'] as String, child: Text(e['name'] as String))).toList(),
                  onChanged: (v) => setModalState(() => selectedEmployee = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: InputDecoration(labelText: 'Type de congé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _leaveTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setModalState(() => selectedType = v ?? selectedType),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Début', startDate, (d) => setModalState(() { startDate = d; final diff = endDate.difference(startDate).inDays + 1; daysController.text = '$diff'; })),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField('Fin', endDate, (d) => setModalState(() { endDate = d; final diff = endDate.difference(startDate).inDays + 1; daysController.text = '$diff'; })),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: daysController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Nombre de jours', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: 'Motif', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: selectedEmployee == null ? null : () async {
                      final db = DatabaseHelper.instance;
                      final emp = _employees.firstWhere((e) => e['id'] == selectedEmployee);
                      final now = DateTime.now().toIso8601String();
                      await db.insert('leaves', {
                        'id': const Uuid().v4(),
                        'employee_id': selectedEmployee,
                        'employee_name': emp['name'],
                        'leave_type': selectedType,
                        'start_date': startDate.toIso8601String().substring(0, 10),
                        'end_date': endDate.toIso8601String().substring(0, 10),
                        'days': int.tryParse(daysController.text) ?? 1,
                        'reason': reasonController.text,
                        'status': 'pending',
                        'created_at': now,
                        'updated_at': now,
                      });
                      await db.logActivity(ref.read(currentAdminProvider)?.id, 'leave_created', 'Demande de congé pour ${emp['name']}');
                      _loadData();
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Enregistrer'),
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

  Widget _buildDateField(String label, DateTime date, Function(DateTime) onPicked) {
    return GestureDetector(
      onTap: () async {
        final d = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.now().subtract(const Duration(days: 365)), lastDate: DateTime.now().add(const Duration(days: 365)));
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text('${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}', style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterStatus == 'all' ? _leaves : _leaves.where((l) => l['status'] == _filterStatus).toList();
    final pending = _leaves.where((l) => l['status'] == 'pending').length;
    final approved = _leaves.where((l) => l['status'] == 'approved').length;
    final rejected = _leaves.where((l) => l['status'] == 'rejected').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gestion des congés'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddLeaveDialog)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildMiniStat('$pending', 'En attente', AppColors.primaryAmber),
                      const SizedBox(width: 8),
                      _buildMiniStat('$approved', 'Approuvés', AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat('$rejected', 'Refusés', AppColors.primaryRed),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _statusLabels.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(e.value, style: TextStyle(fontSize: 12, color: _filterStatus == e.key ? Colors.white : Colors.grey[700])),
                        selected: _filterStatus == e.key,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (v) => setState(() => _filterStatus = e.key),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(child: Text('Aucune demande de congé', style: TextStyle(color: Colors.grey[500])))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _buildLeaveCard(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave) {
    final status = leave['status'] ?? 'pending';
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'approved': statusColor = AppColors.primaryGreen; statusLabel = 'Approuvé'; break;
      case 'rejected': statusColor = AppColors.primaryRed; statusLabel = 'Refusé'; break;
      default: statusColor = AppColors.primaryAmber; statusLabel = 'En attente';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: Icon(Icons.event, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(leave['employee_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(leave['leave_type'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: statusColor)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text('${leave['start_date']} → ${leave['end_date']} (${leave['days']} j)', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
          if (leave['reason'] != null && (leave['reason'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(leave['reason'], style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          if (status == 'pending') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateStatus(leave['id'], 'approved', null),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approuver', style: TextStyle(fontSize: 12)),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _updateStatus(leave['id'], 'rejected', null),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Refuser', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryRed, side: const BorderSide(color: AppColors.primaryRed), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
