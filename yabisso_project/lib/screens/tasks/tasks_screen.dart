import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});
  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  String _search = '';
  String? _filterStatus;
  List<Map<String, dynamic>> _tasks = [];
  Map<int, String> _projectNames = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final tasks = await DatabaseHelper.instance.getAllTasks();
    final projects = await DatabaseHelper.instance.getAllProjects();
    final projectMap = <int, String>{};
    for (final p in projects) {
      projectMap[p['id'] as int] = p['name'] as String;
    }
    setState(() {
      _tasks = tasks;
      _projectNames = projectMap;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    var result = _tasks;
    if (_filterStatus != null) {
      result = result.where((t) => t['status'] == _filterStatus).toList();
    }
    if (_search.isNotEmpty) {
      result = result
          .where(
            (t) =>
                (t['title'] as String).toLowerCase().contains(
                  _search.toLowerCase(),
                ),
          )
          .toList();
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/tasks/add');
              _loadData();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher une tâche...',
                prefixIcon: const Icon(Icons.search, size: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (v) => setState(() => _search = v),
            ),
          ),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _filterChip('Toutes', null),
                _filterChip('À faire', 'a_faire'),
                _filterChip('En cours', 'en_cours'),
                _filterChip('Terminée', 'terminee'),
                _filterChip('Annulée', 'annulee'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'Aucune tâche trouvée',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => _buildTaskCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/tasks/add');
          _loadData();
        },
        backgroundColor: AppColors.primaryGreen,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _filterChip(String label, String? status) {
    final selected = _filterStatus == status;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
        selected: selected,
        onSelected: (_) => setState(() => _filterStatus = status),
        selectedColor: AppColors.primaryGreen,
        checkmarkColor: Colors.white,
        backgroundColor: Colors.white,
        side: BorderSide(
          color: selected ? AppColors.primaryGreen : AppColors.border,
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'a_faire';
    final priority = task['priority'] ?? 'moyenne';
    final projectName = _projectNames[task['project_id']] ?? 'Sans projet';
    final isDone = status == 'terminee';

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'terminee':
        statusColor = AppColors.primaryGreen;
        statusLabel = 'Terminée';
        break;
      case 'en_cours':
        statusColor = AppColors.primaryBlue;
        statusLabel = 'En cours';
        break;
      case 'annulee':
        statusColor = Colors.grey;
        statusLabel = 'Annulée';
        break;
      default:
        statusColor = AppColors.primaryAmber;
        statusLabel = 'À faire';
    }

    Color priorityColor;
    switch (priority) {
      case 'haute':
        priorityColor = AppColors.primaryRed;
        break;
      case 'basse':
        priorityColor = AppColors.primaryGreen;
        break;
      default:
        priorityColor = AppColors.primaryAmber;
    }

    return GestureDetector(
      onTap: () async {
        final newStatus = isDone ? 'a_faire' : 'terminee';
        await DatabaseHelper.instance.updateTask(task['id'], {
          'status': newStatus,
          'updated_at': DateTime.now().toIso8601String(),
        });
        _loadData();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () async {
                final newStatus = isDone ? 'a_faire' : 'terminee';
                await DatabaseHelper.instance.updateTask(task['id'], {
                  'status': newStatus,
                  'updated_at': DateTime.now().toIso8601String(),
                });
                _loadData();
              },
              child: Icon(
                isDone ? Icons.check_circle : Icons.radio_button_unchecked,
                color: isDone ? AppColors.primaryGreen : Colors.grey,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task['title'] ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.folder_outlined,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        projectName,
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                      if (task['assignee'] != null &&
                          (task['assignee'] as String).isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Icon(
                          Icons.person_outline,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          task['assignee'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 10,
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: priorityColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    priority[0].toUpperCase() + priority.substring(1),
                    style: TextStyle(
                      fontSize: 9,
                      color: priorityColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
