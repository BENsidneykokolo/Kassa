import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class RhDashboardScreen extends StatefulWidget {
  const RhDashboardScreen({super.key});
  @override
  State<RhDashboardScreen> createState() => _RhDashboardScreenState();
}

class _RhDashboardScreenState extends State<RhDashboardScreen> {
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
  int _totalTrainings = 0;
  int _unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
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
    final trainings = await db.getAll('trainings');
    final notifications = await db.getAll('notifications', where: 'is_read = 0');

    final present = attendance.where((a) => a['status'] == 'present' || a['status'] == 'late').length;
    final absent = employees.length - attendance.length;
    final late = attendance.where((a) => a['status'] == 'late').length;

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
      _totalTrainings = trainings.length;
      _unreadNotifications = notifications.length;
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
                    const SizedBox(height: 20),
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

  Widget _buildModuleGrid() {
    final modules = [
      {'icon': Icons.person_search, 'label': 'Candidats', 'route': '/candidates', 'color': AppColors.primaryBlue},
      {'icon': Icons.people, 'label': 'Employés', 'route': '/employees', 'color': AppColors.primaryGreen},
      {'icon': Icons.event, 'label': 'Congés', 'route': '/leaves', 'color': AppColors.primaryAmber},
      {'icon': Icons.flag, 'label': 'Objectifs', 'route': '/objectives', 'color': AppColors.primaryRed},
      {'icon': Icons.emoji_events, 'label': 'Récompenses', 'route': '/rewards', 'color': AppColors.primaryGreen},
      {'icon': Icons.gavel, 'label': 'Sanctions', 'route': '/sanctions', 'color': AppColors.primaryRed},
      {'icon': Icons.school, 'label': 'Formations', 'route': '/trainings', 'color': AppColors.primaryBlue},
      {'icon': Icons.assessment, 'label': 'Rapports', 'route': '/daily-reports', 'color': AppColors.primaryAmber},
      {'icon': Icons.store_mall_directory, 'label': 'Démarchage', 'route': '/commerce-tracking', 'color': AppColors.primaryGreen},
      {'icon': Icons.trending_up, 'label': 'Performances', 'route': '/analytics', 'color': AppColors.primaryBlue},
      {'icon': Icons.phone_callback, 'label': 'Relance', 'route': '/relance', 'color': AppColors.primaryAmber},
      {'icon': Icons.notifications, 'label': 'Notifications', 'route': '/notifications', 'color': AppColors.primaryRed},
    ];

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
