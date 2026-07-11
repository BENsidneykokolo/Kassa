import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class TrainingsScreen extends ConsumerStatefulWidget {
  const TrainingsScreen({super.key});
  @override
  ConsumerState<TrainingsScreen> createState() => _TrainingsScreenState();
}

class _TrainingsScreenState extends ConsumerState<TrainingsScreen> {
  String _filterStatus = 'all';
  List<Map<String, dynamic>> _trainings = [];
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  static const _statusLabels = {
    'all': 'Toutes',
    'planned': 'Planifiées',
    'in_progress': 'En cours',
    'completed': 'Terminées',
  };

  static const _statusDisplayLabels = {
    'planned': 'Planifiée',
    'in_progress': 'En cours',
    'completed': 'Terminée',
  };

  Color _statusColor(String status) {
    switch (status) {
      case 'planned':
        return AppColors.primaryBlue;
      case 'in_progress':
        return AppColors.primaryAmber;
      case 'completed':
        return AppColors.primaryGreen;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'planned':
        return Icons.event;
      case 'in_progress':
        return Icons.play_circle;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    _trainings = await db.getAll('trainings', orderBy: 'created_at DESC');
    _employees = await db.getAll('employees');
    setState(() => _loading = false);
  }

  void _showAddTrainingSheet() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final trainerController = TextEditingController();
    final durationController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String selectedStatus = 'planned';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle formation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trainerController,
                  decoration: InputDecoration(
                    labelText: 'Formateur',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: durationController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Durée (heures)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );
                    if (d != null) setModalState(() => selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon:
                          const Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _statusDisplayLabels.entries
                      .map((e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)))
                      .toList(),
                  onChanged: (v) =>
                      setModalState(() => selectedStatus = v ?? selectedStatus),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: titleController.text.isEmpty
                        ? null
                        : () async {
                            final db = DatabaseHelper.instance;
                            final admin = ref.read(currentAdminProvider);
                            final now = DateTime.now().toIso8601String();
                            await db.insert('trainings', {
                              'id': const Uuid().v4(),
                              'title': titleController.text,
                              'description': descController.text,
                              'trainer': trainerController.text,
                              'duration_hours':
                                  int.tryParse(durationController.text) ?? 0,
                              'date': selectedDate
                                  .toIso8601String()
                                  .substring(0, 10),
                              'status': selectedStatus,
                              'created_at': now,
                              'updated_at': now,
                            });
                            await db.logActivity(
                              admin?.id,
                              'training_created',
                              'Formation "${titleController.text}" créée',
                            );
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

  void _showEnrollDialog(Map<String, dynamic> training) async {
    final db = DatabaseHelper.instance;
    final existingEnrollments = await db.getAll(
      'employee_trainings',
      where: 'training_id = ?',
      whereArgs: [training['id']],
    );
    final enrolledIds =
        existingEnrollments.map((e) => e['employee_id'] as String).toSet();
    final selectedIds = <String>{};

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Inscrire - ${training['title']}'),
          content: SizedBox(
            width: double.maxFinite,
            child: _employees.isEmpty
                ? const Text('Aucun employé disponible')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _employees.length,
                    itemBuilder: (ctx, i) {
                      final emp = _employees[i];
                      final empId = emp['id'] as String;
                      final alreadyEnrolled = enrolledIds.contains(empId);
                      final isSelected = selectedIds.contains(empId);
                      return CheckboxListTile(
                        value: isSelected || alreadyEnrolled,
                        onChanged: alreadyEnrolled
                            ? null
                            : (v) {
                                setDialogState(() {
                                  if (v == true) {
                                    selectedIds.add(empId);
                                  } else {
                                    selectedIds.remove(empId);
                                  }
                                });
                              },
                        title: Text(emp['name'] as String),
                        subtitle: alreadyEnrolled
                            ? const Text('Déjà inscrit',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey))
                            : null,
                        activeColor: AppColors.primaryGreen,
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: selectedIds.isEmpty
                  ? null
                  : () async {
                      final now = DateTime.now().toIso8601String();
                      for (final empId in selectedIds) {
                        final emp = _employees
                            .firstWhere((e) => e['id'] == empId);
                        await db.insert('employee_trainings', {
                          'id': const Uuid().v4(),
                          'employee_id': empId,
                          'employee_name': emp['name'],
                          'training_id': training['id'],
                          'training_title': training['title'],
                          'status': 'enrolled',
                          'created_at': now,
                        });
                      }
                      final admin = ref.read(currentAdminProvider);
                      await db.logActivity(
                        admin?.id,
                        'training_enrolled',
                        '${selectedIds.length} employé(s) inscrit(s) à "${training['title']}"',
                      );
                      Navigator.pop(ctx);
                      _loadData();
                    },
              child: const Text('Inscrire',
                  style: TextStyle(color: AppColors.primaryGreen)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _markCompleted(Map<String, dynamic> training) async {
    final db = DatabaseHelper.instance;
    final admin = ref.read(currentAdminProvider);
    final now = DateTime.now().toIso8601String();
    await db.update('trainings', {
      'status': 'completed',
      'updated_at': now,
    }, training['id'] as String);
    final enrollments = await db.getAll(
      'employee_trainings',
      where: 'training_id = ?',
      whereArgs: [training['id']],
    );
    for (final enrollment in enrollments) {
      await db.update('employee_trainings', {
        'status': 'completed',
        'completion_date': now,
      }, enrollment['id'] as String);
    }
    await db.logActivity(
      admin?.id,
      'training_completed',
      'Formation "${training['title']}" marquée comme terminée',
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterStatus == 'all'
        ? _trainings
        : _trainings.where((t) => t['status'] == _filterStatus).toList();
    final totalCount = _trainings.length;
    final plannedCount =
        _trainings.where((t) => t['status'] == 'planned').length;
    final inProgressCount =
        _trainings.where((t) => t['status'] == 'in_progress').length;
    final completedCount =
        _trainings.where((t) => t['status'] == 'completed').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Formations'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddTrainingSheet,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildMiniStat(
                          '$totalCount', 'Total', AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat(
                          '$plannedCount', 'Planif.', AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      _buildMiniStat('$inProgressCount', 'En cours',
                          AppColors.primaryAmber),
                      const SizedBox(width: 8),
                      _buildMiniStat('$completedCount', 'Terminées',
                          AppColors.successGreen),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _statusLabels.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _filterStatus == e.key
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                selected: _filterStatus == e.key,
                                selectedColor: AppColors.primaryGreen,
                                onSelected: (v) =>
                                    setState(() => _filterStatus = e.key),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) =>
                              _buildTrainingCard(filtered[i]),
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
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.school_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucune formation',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 4),
          Text('Appuyez sur + pour ajouter une formation',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTrainingCard(Map<String, dynamic> training) {
    final status = training['status'] ?? 'planned';
    final color = _statusColor(status);
    final icon = _statusIcon(status);
    final isActive = status != 'completed';

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: DatabaseHelper.instance.getAll(
        'employee_trainings',
        where: 'training_id = ?',
        whereArgs: [training['id']],
      ),
      builder: (ctx, snapshot) {
        final enrollments = snapshot.data ?? [];

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
                    backgroundColor: color.withValues(alpha: 0.1),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(training['title'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14)),
                        if (training['trainer'] != null &&
                            (training['trainer'] as String).isNotEmpty)
                          Text('Formateur: ${training['trainer']}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                        _statusDisplayLabels[status] ?? status,
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: color)),
                  ),
                ],
              ),
              if (training['description'] != null &&
                  (training['description'] as String).isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(training['description'],
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 6),
                  Text(training['date'] ?? '',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(width: 12),
                  Icon(Icons.timer, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text('${training['duration_hours'] ?? 0}h',
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
              if (enrollments.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Inscrits (${enrollments.length})',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: enrollments.map((e) {
                          final empStatus = e['status'] ?? 'enrolled';
                          final empColor = empStatus == 'completed'
                              ? AppColors.primaryGreen
                              : Colors.grey[600];
                          return Chip(
                            avatar: Icon(
                              empStatus == 'completed'
                                  ? Icons.check_circle
                                  : Icons.person,
                              size: 14,
                              color: empColor,
                            ),
                            label: Text(e['employee_name'] ?? '',
                                style: TextStyle(
                                    fontSize: 10, color: empColor)),
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            labelPadding: const EdgeInsets.symmetric(
                                horizontal: 4),
                            backgroundColor:
                                (empColor ?? Colors.grey).withValues(alpha: 0.1),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  if (isActive) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showEnrollDialog(training),
                        icon: const Icon(Icons.person_add, size: 16),
                        label: const Text('Inscrire',
                            style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryGreen,
                          side: const BorderSide(color: AppColors.primaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Terminer la formation'),
                              content: Text(
                                  'Marquer "${training['title']}" comme terminée ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Annuler'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    _markCompleted(training);
                                  },
                                  child: const Text('Terminer',
                                      style: TextStyle(
                                          color: AppColors.primaryGreen)),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Terminer',
                            style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                  if (!isActive)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color:
                              AppColors.primaryGreen.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                size: 16, color: AppColors.primaryGreen),
                            SizedBox(width: 6),
                            Text('Terminée',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
