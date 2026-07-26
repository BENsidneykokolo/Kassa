import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});
  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  String _search = '';
  String? _filterStatus;
  List<Map<String, dynamic>> _projects = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _loading = true);
    final projects = await DatabaseHelper.instance.getAllProjects();
    setState(() {
      _projects = projects;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    var result = _projects;
    if (_filterStatus != null) {
      result = result.where((p) => p['status'] == _filterStatus).toList();
    }
    if (_search.isNotEmpty) {
      result = result
          .where(
            (p) =>
                (p['name'] as String).toLowerCase().contains(
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
        title: const Text('Projets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await context.push('/projects/add');
              _loadProjects();
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
                hintText: 'Rechercher un projet...',
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
                _filterChip('Tous', null),
                _filterChip('En cours', 'en_cours'),
                _filterChip('Terminé', 'termine'),
                _filterChip('En attente', 'en_attente'),
                _filterChip('Archivé', 'archive'),
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
                          'Aucun projet trouvé',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProjects,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filtered.length,
                          itemBuilder: (context, i) => _buildCard(_filtered[i]),
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/projects/add');
          _loadProjects();
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

  Widget _buildCard(Map<String, dynamic> project) {
    final progress = (project['progress'] as num?)?.toDouble() ?? 0;
    final status = project['status'] ?? 'en_cours';
    Color statusColor;
    switch (status) {
      case 'termine':
        statusColor = AppColors.primaryGreen;
        break;
      case 'en_attente':
        statusColor = AppColors.primaryAmber;
        break;
      case 'archive':
        statusColor = Colors.grey;
        break;
      default:
        statusColor = AppColors.primaryBlue;
    }

    final deadline = project['deadline'] as String?;
    final priority = project['priority'] ?? 'moyenne';
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
        await context.push('/projects/${project['id']}');
        _loadProjects();
      },
      child: Container(
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'] ?? '',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (deadline != null)
                        Text(
                          'Échéance: ${deadline.substring(0, 10)}',
                          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
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
                        (project['status'] as String?)
                                ?.replaceAll('_', ' ') ??
                            '',
                        style: TextStyle(
                          fontSize: 11,
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
                          fontSize: 10,
                          color: priorityColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (project['description'] != null &&
                (project['description'] as String).isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                project['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation(statusColor),
                    minHeight: 5,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${progress.round()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
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
