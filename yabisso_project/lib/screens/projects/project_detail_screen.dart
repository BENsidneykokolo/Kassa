import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class ProjectDetailScreen extends StatefulWidget {
  final int projectId;
  const ProjectDetailScreen({super.key, required this.projectId});
  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  Map<String, dynamic>? _project;
  List<Map<String, dynamic>> _tasks = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final project = await DatabaseHelper.instance.getProject(widget.projectId);
    final tasks = await DatabaseHelper.instance.getTasksByProject(widget.projectId);
    setState(() {
      _project = project;
      _tasks = tasks;
      _loading = false;
    });
  }

  Future<void> _updateProgress(double value) async {
    await DatabaseHelper.instance.updateProject(widget.projectId, {
      'progress': value,
      'updated_at': DateTime.now().toIso8601String(),
    });
    _loadData();
  }

  Future<void> _updateStatus(String status) async {
    await DatabaseHelper.instance.updateProject(widget.projectId, {
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    });
    _loadData();
  }

  Future<void> _deleteProject() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le projet'),
        content: const Text('Êtes-vous sûr de vouloir supprimer ce projet ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await DatabaseHelper.instance.deleteProject(widget.projectId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projet supprimé'),
            backgroundColor: AppColors.primaryRed,
          ),
        );
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail du projet')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Détail du projet')),
        body: const Center(child: Text('Projet non trouvé')),
      );
    }

    final project = _project!;
    final progress = (project['progress'] as num?)?.toDouble() ?? 0;
    final status = project['status'] ?? 'en_cours';
    final priority = project['priority'] ?? 'moyenne';
    final deadline = project['deadline'] as String?;

    Color statusColor;
    String statusLabel;
    switch (status) {
      case 'termine':
        statusColor = AppColors.primaryGreen;
        statusLabel = 'Terminé';
        break;
      case 'en_attente':
        statusColor = AppColors.primaryAmber;
        statusLabel = 'En attente';
        break;
      case 'archive':
        statusColor = Colors.grey;
        statusLabel = 'Archivé';
        break;
      default:
        statusColor = AppColors.primaryBlue;
        statusLabel = 'En cours';
    }

    final completedTasks = _tasks.where((t) => t['status'] == 'terminee').length;

    return Scaffold(
      appBar: AppBar(
        title: Text(project['name'] ?? 'Détail'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'delete') _deleteProject();
              else _updateStatus(value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'en_cours', child: Text('Marquer en cours')),
              const PopupMenuItem(value: 'en_attente', child: Text('Mettre en attente')),
              const PopupMenuItem(value: 'termine', child: Text('Marquer terminé')),
              const PopupMenuItem(value: 'archive', child: Text('Archiver')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Supprimer', style: TextStyle(color: AppColors.primaryRed)),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAmber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Priorité ${priority[0].toUpperCase()}${priority.substring(1)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primaryAmber,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (project['description'] != null &&
                      (project['description'] as String).isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      project['description'],
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                  const SizedBox(height: 16),
                  if (deadline != null) ...[
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: AppColors.primaryGreen,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Échéance: ${deadline.substring(0, 10)}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppColors.primaryGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$completedTasks/${_tasks.length} tâches terminées',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Progression',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Avancement',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${progress.round()}%',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Slider(
                    value: progress,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: AppColors.primaryGreen,
                    onChanged: _updateProgress,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tâches',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await context.push('/tasks/add?project_id=${widget.projectId}');
                    _loadData();
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Ajouter'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (_tasks.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.task_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aucune tâche',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            else
              ..._tasks.map((task) => _buildTaskCard(task)),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final status = task['status'] ?? 'a_faire';
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

    final isDone = status == 'terminee';

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
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppColors.primaryGreen : Colors.grey,
              size: 22,
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
                  if (task['assignee'] != null &&
                      (task['assignee'] as String).isNotEmpty)
                    Text(
                      task['assignee'],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
          ],
        ),
      ),
    );
  }
}
