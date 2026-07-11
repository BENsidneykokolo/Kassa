import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';
import '../../services/permissions_service.dart';

class RhDashboardScreen extends ConsumerStatefulWidget {
  const RhDashboardScreen({super.key});
  @override
  ConsumerState<RhDashboardScreen> createState() => _RhDashboardScreenState();
}

class _RhDashboardScreenState extends ConsumerState<RhDashboardScreen> {
  bool _loading = true;
  int _totalEmployees = 0;
  int _totalCandidates = 0;
  int _presentToday = 0;
  int _absentToday = 0;
  int _lateToday = 0;
  int _prospectionToday = 0;
  int _totalObjectives = 0;
  int _completedObjectives = 0;
  int _pendingLeaves = 0;
  int _unreadNotifications = 0;
  int _pendingTasks = 0;
  int _completedTasks = 0;
  List<Map<String, dynamic>> _topPerformers = [];

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  bool _hasPermission(String permission) {
    final admin = ref.read(currentAdminProvider);
    if (admin == null) return false;
    return PermissionsService.instance.hasPermission(admin.role, permission);
  }

  Future<void> _loadDashboard() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final employees = await db.getAll('employees');
    final candidates = await db.getAll('candidates');
    final attendance = await db.getAll('attendance', where: 'date = ?', whereArgs: [today]);
    final prospections = await db.getAll('prospectives', where: 'visit_date = ?', whereArgs: [today]);
    final objectives = await db.getAll('objectives', where: "status = 'active'");
    final objectivesCompleted = await db.getAll('objectives', where: "status = 'completed'");
    final leaves = await db.getAll('leaves', where: "status = 'pending'");
    final notifications = await db.getAll('notifications', where: 'is_read = 0');
    final tasks = await db.getAll('employee_tasks');
    final pendingTasks = tasks.where((t) => t['status'] == 'pending' || t['status'] == 'in_progress').length;
    final completedTasks = tasks.where((t) => t['status'] == 'completed').length;

    final present = attendance.where((a) => a['status'] == 'present' || a['status'] == 'late').length;
    final absent = employees.length - attendance.length;
    final late = attendance.where((a) => a['status'] == 'late').length;

    // Calculate top performers
    final Map<String, int> employeeScores = {};
    for (final emp in employees) {
      final empId = emp['id']?.toString() ?? '';
      final empName = emp['name']?.toString() ?? '';
      if (empId.isEmpty || empName.isEmpty) continue;
      
      int score = 0;
      
      // Tasks completed (30 points max)
      final empTasks = tasks.where((t) => t['employee_id']?.toString() == empId).toList();
      final completedEmpTasks = empTasks.where((t) => t['status'] == 'completed').length;
      score += (completedEmpTasks * 6).clamp(0, 30);
      
      // Prospection (25 points max)
      final empProspections = prospections.where((p) => p['employee_id']?.toString() == empId).length;
      score += (empProspections * 5).clamp(0, 25);
      
      // Attendance (20 points max)
      final empAttendance = await db.getAll('attendance', where: 'employee_id = ?', whereArgs: [empId]);
      final empPresent = empAttendance.where((a) => a['status'] == 'present').length;
      if (empAttendance.isNotEmpty) {
        score += ((empPresent / empAttendance.length) * 20).round();
      }
      
      employeeScores[empName] = score;
    }
    
    final sorted = employeeScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _topPerformers = sorted.take(5).map((e) => {
      'name': e.key,
      'score': e.value,
    }).toList();

    setState(() {
      _totalEmployees = employees.length;
      _totalCandidates = candidates.length;
      _presentToday = present;
      _absentToday = absent < 0 ? 0 : absent;
      _lateToday = late;
      _prospectionToday = prospections.length;
      _totalObjectives = objectives.length;
      _completedObjectives = objectivesCompleted.length;
      _pendingLeaves = leaves.length;
      _unreadNotifications = notifications.length;
      _pendingTasks = pendingTasks;
      _completedTasks = completedTasks;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Tableau de bord RH'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () => context.push('/notifications'),
              ),
              if (_unreadNotifications > 0)
                Positioned(
                  right: 8, top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: AppColors.primaryRed, shape: BoxShape.circle),
                    child: Text('$_unreadNotifications', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
              onRefresh: _loadDashboard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('Effectifs'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('$_totalEmployees', 'Employés', Icons.people, AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        _buildStatCard('$_totalCandidates', 'Candidats', Icons.person_search, AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Présence aujourd\'hui'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('$_presentToday', 'Présents', Icons.check_circle, AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        _buildStatCard('$_absentToday', 'Absents', Icons.cancel, AppColors.primaryRed),
                        const SizedBox(width: 8),
                        _buildStatCard('$_lateToday', 'En retard', Icons.schedule, AppColors.primaryAmber),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Activité du jour'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('$_prospectionToday', 'Démarchés', Icons.store, AppColors.primaryBlue),
                        const SizedBox(width: 8),
                        _buildStatCard('$_pendingLeaves', 'Congés en attende', Icons.event_busy, AppColors.primaryAmber),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Objectifs'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('$_totalObjectives', 'Actifs', Icons.flag, AppColors.primaryGreen),
                        const SizedBox(width: 8),
                        _buildStatCard('$_completedObjectives', 'Terminés', Icons.check, AppColors.primaryBlue),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildSectionTitle('Tâches'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatCard('$_pendingTasks', 'En cours', Icons.pending_actions, AppColors.primaryAmber),
                        const SizedBox(width: 8),
                        _buildStatCard('$_completedTasks', 'Terminées', Icons.check_circle, AppColors.primaryGreen),
                      ],
                    ),
                    const SizedBox(height: 20),
                    if (_topPerformers.isNotEmpty) ...[
                      _buildSectionTitle('Top Performers'),
                      const SizedBox(height: 8),
                      _buildTopPerformersSection(),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle('Modules'),
                    const SizedBox(height: 8),
                    _buildModuleGrid(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textDark));
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
          boxShadow: [BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopPerformersSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: _topPerformers.asMap().entries.map((entry) {
          final index = entry.key;
          final performer = entry.value;
          final name = performer['name']?.toString() ?? '';
          final score = performer['score'] as int? ?? 0;
          
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: index < _topPerformers.length - 1 
                  ? BorderSide(color: Colors.grey.withValues(alpha: 0.2))
                  : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index == 0 
                      ? AppColors.primaryAmber.withValues(alpha: 0.2)
                      : index == 1 
                        ? Colors.grey.withValues(alpha: 0.2)
                        : index == 2 
                          ? Color(0xFFCD7F32).withValues(alpha: 0.2)
                          : AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: index == 0 
                          ? AppColors.primaryAmber
                          : index == 1 
                            ? Colors.grey[700]
                            : index == 2 
                              ? Color(0xFFCD7F32)
                              : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$score pts',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModuleGrid() {
    final modules = <Map<String, dynamic>>[];
    
    if (_hasPermission('candidates_view')) {
      modules.add({'icon': Icons.person_search, 'label': 'Candidats', 'route': '/candidates', 'color': AppColors.primaryBlue, 'permission': 'candidates_view'});
    }
    if (_hasPermission('employees_view')) {
      modules.add({'icon': Icons.people, 'label': 'Employés', 'route': '/employees', 'color': AppColors.primaryGreen, 'permission': 'employees_view'});
    }
    if (_hasPermission('tasks_view')) {
      modules.add({'icon': Icons.task_alt, 'label': 'Tâches', 'route': '/employee-tasks', 'color': AppColors.primaryGreen, 'permission': 'tasks_view'});
    }
    if (_hasPermission('leaves_view')) {
      modules.add({'icon': Icons.event, 'label': 'Congés', 'route': '/leaves', 'color': AppColors.primaryAmber, 'permission': 'leaves_view'});
    }
    if (_hasPermission('objectives_view')) {
      modules.add({'icon': Icons.flag, 'label': 'Objectifs', 'route': '/objectives', 'color': AppColors.primaryRed, 'permission': 'objectives_view'});
    }
    if (_hasPermission('performance_view')) {
      modules.add({'icon': Icons.trending_up, 'label': 'Performances', 'route': '/performance', 'color': AppColors.primaryBlue, 'permission': 'performance_view'});
    }
    if (_hasPermission('rewards_view')) {
      modules.add({'icon': Icons.emoji_events, 'label': 'Récompenses', 'route': '/rewards', 'color': AppColors.primaryGreen, 'permission': 'rewards_view'});
    }
    if (_hasPermission('sanctions_view')) {
      modules.add({'icon': Icons.gavel, 'label': 'Sanctions', 'route': '/sanctions', 'color': AppColors.primaryRed, 'permission': 'sanctions_view'});
    }
    if (_hasPermission('trainings_view')) {
      modules.add({'icon': Icons.school, 'label': 'Formations', 'route': '/trainings', 'color': AppColors.primaryBlue, 'permission': 'trainings_view'});
    }
    if (_hasPermission('attendance_view')) {
      modules.add({'icon': Icons.access_time, 'label': 'Présence', 'route': '/attendance', 'color': AppColors.primaryGreen, 'permission': 'attendance_view'});
    }
    if (_hasPermission('reports_view')) {
      modules.add({'icon': Icons.assessment, 'label': 'Rapports', 'route': '/daily-reports', 'color': AppColors.primaryAmber, 'permission': 'reports_view'});
    }
    if (_hasPermission('prospectives_view')) {
      modules.add({'icon': Icons.store_mall_directory, 'label': 'Démarchage', 'route': '/commerce-tracking', 'color': AppColors.primaryGreen, 'permission': 'prospectives_view'});
    }
    if (_hasPermission('prospectives_view')) {
      modules.add({'icon': Icons.phone_callback, 'label': 'Relance', 'route': '/relance', 'color': AppColors.primaryAmber, 'permission': 'prospectives_view'});
    }
    if (_hasPermission('manager_notes_view')) {
      modules.add({'icon': Icons.sticky_note_2, 'label': 'Notes manager', 'route': '/manager-notes', 'color': AppColors.primaryBlue, 'permission': 'manager_notes_view'});
    }
    if (_hasPermission('notifications_send')) {
      modules.add({'icon': Icons.notifications, 'label': 'Notifications', 'route': '/notifications', 'color': AppColors.primaryRed, 'permission': 'notifications_send'});
    }
    if (_hasPermission('activity_log_view')) {
      modules.add({'icon': Icons.history, 'label': 'Journal', 'route': '/activity-log', 'color': AppColors.primaryAmber, 'permission': 'activity_log_view'});
    }
    if (_hasPermission('settings_manage')) {
      modules.add({'icon': Icons.security, 'label': 'Permissions', 'route': '/settings', 'color': AppColors.primaryRed, 'permission': 'settings_manage'});
    }
    if (_hasPermission('reports_export')) {
      modules.add({'icon': Icons.file_download, 'label': 'Export PDF', 'route': '/export', 'color': AppColors.primaryGreen, 'permission': 'reports_export'});
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.0,
      ),
      itemCount: modules.length,
      itemBuilder: (ctx, i) {
        final m = modules[i];
        return GestureDetector(
          onTap: () => context.push(m['route'] as String),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: (m['color'] as Color).withValues(alpha: 0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(m['icon'] as IconData, size: 28, color: m['color'] as Color),
                const SizedBox(height: 6),
                Text(m['label'] as String, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.grey[700])),
              ],
            ),
          ),
        );
      },
    );
  }
}
