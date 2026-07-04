import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class ObjectivesScreen extends ConsumerStatefulWidget {
  const ObjectivesScreen({super.key});
  @override
  ConsumerState<ObjectivesScreen> createState() => _ObjectivesScreenState();
}

class _ObjectivesScreenState extends ConsumerState<ObjectivesScreen> {
  String _filterStatus = 'all';
  List<Map<String, dynamic>> _objectives = [];
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  static const _units = ['commerces', 'inscriptions', 'démonstrations', 'ventes', 'autre'];
  static const _periods = {'monthly': 'Mensuel', 'quarterly': 'Trimestriel', 'yearly': 'Annuel'};
  static const _statusLabels = {'all': 'Tous', 'active': 'Actifs', 'completed': 'Terminés'};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    _objectives = await db.getAll('objectives', orderBy: 'created_at DESC');
    _employees = await db.getAll('employees');
    for (final obj in _objectives) {
      if (obj['status'] == 'active' && obj['current_value'] >= obj['target_value'] && obj['target_value'] > 0) {
        await db.update('objectives', {
          'status': 'completed',
          'updated_at': DateTime.now().toIso8601String(),
        }, obj['id']);
      }
      if (obj['status'] == 'active' && obj['end_date'] != null) {
        final endDate = DateTime.tryParse(obj['end_date'] as String);
        if (endDate != null && endDate.isBefore(DateTime.now()) && obj['current_value'] < obj['target_value']) {
          await db.update('objectives', {
            'status': 'overdue',
            'updated_at': DateTime.now().toIso8601String(),
          }, obj['id']);
        }
      }
    }
    _objectives = await db.getAll('objectives', orderBy: 'created_at DESC');
    setState(() => _loading = false);
  }

  Future<void> _incrementObjective(Map<String, dynamic> obj) async {
    final newCurrent = (obj['current_value'] as int) + 1;
    final newStatus = newCurrent >= (obj['target_value'] as int) ? 'completed' : obj['status'];
    await DatabaseHelper.instance.update('objectives', {
      'current_value': newCurrent,
      'status': newStatus,
      'updated_at': DateTime.now().toIso8601String(),
    }, obj['id']);
    final admin = ref.read(currentAdminProvider);
    await DatabaseHelper.instance.logActivity(admin?.id, 'objective_incremented', 'Objectif "${obj['title']}" incrementé à $newCurrent');
    _loadData();
  }

  void _showAddObjectiveDialog() {
    String? selectedEmployee;
    String selectedUnit = _units.first;
    String selectedPeriod = 'monthly';
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 30));

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
                const Text('Nouvel objectif', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: selectedEmployee,
                  decoration: InputDecoration(labelText: 'Employé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _employees.map((e) => DropdownMenuItem(value: e['id'] as String, child: Text(e['name'] as String))).toList(),
                  onChanged: (v) => setModalState(() => selectedEmployee = v),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Titre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: targetController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Objectif cible', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedUnit,
                  decoration: InputDecoration(labelText: 'Unité', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (v) => setModalState(() => selectedUnit = v ?? selectedUnit),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedPeriod,
                  decoration: InputDecoration(labelText: 'Période', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _periods.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                  onChanged: (v) => setModalState(() => selectedPeriod = v ?? selectedPeriod),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildDateField('Début', startDate, (d) => setModalState(() => startDate = d)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildDateField('Fin', endDate, (d) => setModalState(() => endDate = d)),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: selectedEmployee == null || titleController.text.isEmpty ? null : () async {
                      final db = DatabaseHelper.instance;
                      final emp = _employees.firstWhere((e) => e['id'] == selectedEmployee);
                      final admin = ref.read(currentAdminProvider);
                      final now = DateTime.now().toIso8601String();
                      await db.insert('objectives', {
                        'id': const Uuid().v4(),
                        'employee_id': selectedEmployee,
                        'employee_name': emp['name'],
                        'title': titleController.text,
                        'description': descController.text,
                        'target_value': int.tryParse(targetController.text) ?? 0,
                        'current_value': 0,
                        'unit': selectedUnit,
                        'period': selectedPeriod,
                        'start_date': startDate.toIso8601String().substring(0, 10),
                        'end_date': endDate.toIso8601String().substring(0, 10),
                        'status': 'active',
                        'created_by': admin?.id,
                        'created_at': now,
                        'updated_at': now,
                      });
                      await db.logActivity(admin?.id, 'objective_created', 'Objectif "${titleController.text}" créé pour ${emp['name']}');
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
    final filtered = _filterStatus == 'all' ? _objectives : _objectives.where((o) => o['status'] == _filterStatus).toList();
    final activeCount = _objectives.where((o) => o['status'] == 'active').length;
    final completedCount = _objectives.where((o) => o['status'] == 'completed').length;
    final overdueCount = _objectives.where((o) => o['status'] == 'overdue').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Objectifs'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddObjectiveDialog)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildMiniStat('$activeCount', 'Actifs', AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat('$completedCount', 'Terminés', AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      _buildMiniStat('$overdueCount', 'En retard', AppColors.primaryRed),
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
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.flag_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('Aucun objectif', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Appuyez sur + pour ajouter un objectif', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _buildObjectiveCard(filtered[i]),
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

  Widget _buildObjectiveCard(Map<String, dynamic> obj) {
    final status = obj['status'] ?? 'active';
    final currentValue = obj['current_value'] as int? ?? 0;
    final targetValue = obj['target_value'] as int? ?? 1;
    final progress = targetValue > 0 ? (currentValue / targetValue).clamp(0.0, 1.0) : 0.0;
    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'completed': statusColor = AppColors.primaryBlue; statusLabel = 'Terminé'; break;
      case 'overdue': statusColor = AppColors.primaryRed; statusLabel = 'En retard'; break;
      default: statusColor = AppColors.primaryGreen; statusLabel = 'Actif';
    }
    final periodLabel = _periods[obj['period']] ?? obj['period'];
    final unitLabel = obj['unit'] ?? '';

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
                child: Icon(Icons.flag, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(obj['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(obj['employee_name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          if (obj['description'] != null && (obj['description'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(obj['description'], style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.track_changes, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text('$currentValue / $targetValue $unitLabel', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(periodLabel, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(statusColor),
            ),
          ),
          if (obj['start_date'] != null && obj['end_date'] != null) ...[
            const SizedBox(height: 6),
            Text('${obj['start_date']} → ${obj['end_date']}', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
          ],
          if (status == 'active') ...[
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _incrementObjective(obj),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Incrémenter (+1)', style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
