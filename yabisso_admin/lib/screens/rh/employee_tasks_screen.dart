import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class EmployeeTasksScreen extends ConsumerStatefulWidget {
  const EmployeeTasksScreen({super.key});
  @override
  ConsumerState<EmployeeTasksScreen> createState() => _EmployeeTasksScreenState();
}

class _EmployeeTasksScreenState extends ConsumerState<EmployeeTasksScreen> {
  String _filterStatus = 'all';
  String _filterPriority = 'all';
  String _searchQuery = '';
  static const _primary = AppColors.primaryGreen;

  static const _taskTypeLabels = {
    'demarchage': 'Démarchage',
    'suivi_client': 'Suivi client',
    'relance': 'Relance',
    'presentation': 'Présentation',
    'inscription': 'Inscription boutique',
    'stock': 'Mise à jour stock',
    'rapport': 'Rapport journalier',
    'meeting': 'Meeting / Live',
    'formation': 'Formation interne',
    'autre': 'Autre',
  };

  static const _priorityLabels = {
    'high': 'Haute',
    'medium': 'Moyenne',
    'low': 'Basse',
  };

  static const _priorityColors = {
    'high': AppColors.primaryRed,
    'medium': AppColors.primaryAmber,
    'low': AppColors.primaryGreen,
  };

  static const _statusLabels = {
    'pending': 'À faire',
    'in_progress': 'En cours',
    'completed': 'Terminée',
    'overdue': 'En retard',
  };

  static const _statusColors = {
    'pending': AppColors.primaryAmber,
    'in_progress': AppColors.primaryBlue,
    'completed': AppColors.primaryGreen,
    'overdue': AppColors.primaryRed,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tâches des Employés'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _showAddTaskDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          _buildSearchBar(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Toutes', 'all', _filterStatus, (v) => setState(() => _filterStatus = v)),
            const SizedBox(width: 6),
            _buildFilterChip('À faire', 'pending', _filterStatus, (v) => setState(() => _filterStatus = v)),
            const SizedBox(width: 6),
            _buildFilterChip('En cours', 'in_progress', _filterStatus, (v) => setState(() => _filterStatus = v)),
            const SizedBox(width: 6),
            _buildFilterChip('Terminées', 'completed', _filterStatus, (v) => setState(() => _filterStatus = v)),
            const SizedBox(width: 6),
            _buildFilterChip('En retard', 'overdue', _filterStatus, (v) => setState(() => _filterStatus = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, String current, ValueChanged<String> onSelected) {
    final isSelected = current == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher une tâche...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildTaskList() {
    final db = DatabaseHelper.instance;
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _loadTasks(db),
      builder: (ctx, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: _primary));
        final tasks = snapshot.data!;
        if (tasks.isEmpty) return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.task_alt, size: 60, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text('Aucune tâche', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
            ],
          ),
        );
        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (ctx, i) => _buildTaskCard(tasks[i]),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _loadTasks(DatabaseHelper db) async {
    final allTasks = await db.getAll('employee_tasks', orderBy: 'created_at DESC');
    return allTasks.where((t) {
      if (_filterStatus != 'all' && t['status'] != _filterStatus) return false;
      if (_filterPriority != 'all' && t['priority'] != _filterPriority) return false;
      if (_searchQuery.isNotEmpty) {
        final title = (t['title'] ?? '').toString().toLowerCase();
        final empName = (t['employee_name'] ?? '').toString().toLowerCase();
        if (!title.contains(_searchQuery.toLowerCase()) && !empName.contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'pending';
    final priority = task['priority'] ?? 'medium';
    final taskType = task['task_type'] ?? 'autre';
    final statusColor = _statusColors[status] ?? Colors.grey;
    final priorityColor = _priorityColors[priority] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_statusLabels[status] ?? status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: priorityColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(_priorityLabels[priority] ?? priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: priorityColor)),
                ),
                const Spacer(),
                Text(_taskTypeLabels[taskType] ?? taskType, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 10),
            Text(task['title'] ?? '', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            if (task['description'] != null && (task['description'] as String).isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(task['description'], style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(task['employee_name'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const Spacer(),
                if (task['due_date'] != null)
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(task['due_date'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (status == 'pending')
                  Expanded(
                    child: _buildActionButton('Commencer', AppColors.primaryBlue, () => _updateTaskStatus(task['id'], 'in_progress')),
                  ),
                if (status == 'in_progress')
                  Expanded(
                    child: _buildActionButton('Terminer', AppColors.primaryGreen, () => _updateTaskStatus(task['id'], 'completed')),
                  ),
                if (status != 'completed') ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18, color: AppColors.primaryAmber),
                    onPressed: () => _showEditTaskDialog(task),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Text(label, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
      ),
    );
  }

  Future<void> _updateTaskStatus(String taskId, String status) async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now().toIso8601String();
    final updates = <String, dynamic>{'status': status, 'updated_at': now};
    if (status == 'in_progress') updates['started_at'] = now;
    if (status == 'completed') updates['completed_at'] = now;
    await db.update('employee_tasks', updates, taskId);
    await db.logActivity(null, 'task_$status', 'Tâche $taskId → $status');
    setState(() {});
  }

  void _showAddTaskDialog() {
    final employeesAsync = ref.read(employeesProvider);
    employeesAsync.whenData((employees) {
      String selectedEmployeeId = employees.isNotEmpty ? employees.first.id : '';
      String selectedEmployeeName = employees.isNotEmpty ? employees.first.name : '';
      String selectedType = 'demarchage';
      String selectedPriority = 'medium';
      final titleController = TextEditingController();
      final descController = TextEditingController();
      DateTime? dueDate;

      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => StatefulBuilder(
          builder: (ctx, setDialogState) => Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nouvelle tâche', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedEmployeeId,
                    items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.name))).toList(),
                    onChanged: (v) {
                      final emp = employees.firstWhere((e) => e.id == v);
                      setDialogState(() { selectedEmployeeId = v!; selectedEmployeeName = emp.name; });
                    },
                    decoration: InputDecoration(labelText: 'Employé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: titleController, decoration: InputDecoration(labelText: 'Titre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 12),
                  TextField(controller: descController, maxLines: 2, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    items: _taskTypeLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (v) => setDialogState(() => selectedType = v!),
                    decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedPriority,
                    items: _priorityLabels.entries.map((e) => DropdownMenuItem(value: e.key, child: Text(e.value))).toList(),
                    onChanged: (v) => setDialogState(() => selectedPriority = v!),
                    decoration: InputDecoration(labelText: 'Priorité', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(dueDate != null ? 'Échéance: ${dueDate!.day}/${dueDate!.month}/${dueDate!.year}' : 'Choisir une échéance'),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
                      if (picked != null) setDialogState(() => dueDate = picked);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty) return;
                        final db = DatabaseHelper.instance;
                        const uuid = Uuid();
                        final now = DateTime.now().toIso8601String();
                        await db.insert('employee_tasks', {
                          'id': uuid.v4(),
                          'employee_id': selectedEmployeeId,
                          'employee_name': selectedEmployeeName,
                          'title': titleController.text.trim(),
                          'description': descController.text.trim(),
                          'task_type': selectedType,
                          'priority': selectedPriority,
                          'due_date': dueDate?.toIso8601String().substring(0, 10),
                          'status': 'pending',
                          'created_at': now,
                          'updated_at': now,
                        });
                        await db.logActivity(null, 'task_created', 'Tâche: ${titleController.text.trim()} pour $selectedEmployeeName');
                        if (ctx.mounted) Navigator.pop(ctx);
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                      child: const Text('Créer la tâche'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showEditTaskDialog(Map<String, dynamic> task) {
    final commentController = TextEditingController(text: task['comment'] ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Modifier: ${task['title']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Commentaire',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final db = DatabaseHelper.instance;
                  await db.update('employee_tasks', {
                    'comment': commentController.text.trim(),
                    'updated_at': DateTime.now().toIso8601String(),
                  }, task['id']);
                  if (ctx.mounted) Navigator.pop(ctx);
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                child: const Text('Sauvegarder'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
