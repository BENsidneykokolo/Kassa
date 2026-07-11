import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class PerformanceDashboardScreen extends StatefulWidget {
  const PerformanceDashboardScreen({super.key});
  @override
  State<PerformanceDashboardScreen> createState() => _PerformanceDashboardScreenState();
}

class _PerformanceDashboardScreenState extends State<PerformanceDashboardScreen> {
  bool _loading = true;
  Map<String, Map<String, dynamic>> _employeeStats = {};
  String _selectedPeriod = 'month';
  static const _primary = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _loadPerformance();
  }

  Future<void> _loadPerformance() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final employees = await db.getAll('employees', where: 'is_active = 1');
    final now = DateTime.now();
    String dateFilter;
    if (_selectedPeriod == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      dateFilter = weekAgo.toIso8601String().substring(0, 10);
    } else if (_selectedPeriod == 'year') {
      dateFilter = '${now.year}-01-01';
    } else {
      dateFilter = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    }

    final stats = <String, Map<String, dynamic>>{};
    for (final emp in employees) {
      final empId = emp['id'] as String;
      final empName = emp['name'] as String? ?? '';
      final tasks = await db.getAll('employee_tasks', where: "employee_id = ? AND created_at >= ?", whereArgs: [empId, dateFilter]);
      final completedTasks = tasks.where((t) => t['status'] == 'completed').length;
      final prospectives = await db.getAll('prospectives', where: "employee_id = ? AND created_at >= ?", whereArgs: [empId, dateFilter]);
      final sales = await db.getAll('sale_records', where: "employee_id = ? AND created_at >= ?", whereArgs: [empId, dateFilter]);
      final reports = await db.getAll('daily_reports', where: "employee_id = ? AND created_at >= ?", whereArgs: [empId, dateFilter]);
      final attendance = await db.getAll('attendance', where: "employee_id = ? AND date >= ?", whereArgs: [empId, dateFilter]);
      final totalSalesAmount = sales.fold<int>(0, (sum, s) => sum + ((s['amount'] ?? 0) as int));
      final objectives = await db.getAll('objectives', where: "employee_id = ? AND status = 'active'", whereArgs: [empId]);
      final completedObj = objectives.where((o) => (o['current_value'] ?? 0) >= (o['target_value'] ?? 1)).length;
      final daysPresent = attendance.where((a) => a['status'] == 'present' || a['status'] == 'late').length;
      final daysLate = attendance.where((a) => a['status'] == 'late').length;

      stats[empId] = {
        'name': empName,
        'totalTasks': tasks.length,
        'completedTasks': completedTasks,
        'taskRate': tasks.isNotEmpty ? ((completedTasks / tasks.length) * 100).round() : 0,
        'prospected': prospectives.length,
        'salesCount': sales.length,
        'salesAmount': totalSalesAmount,
        'reportsCount': reports.length,
        'daysPresent': daysPresent,
        'daysLate': daysLate,
        'objectivesTotal': objectives.length,
        'objectivesCompleted': completedObj,
        'objectiveRate': objectives.isNotEmpty ? ((completedObj / objectives.length) * 100).round() : 0,
        'globalScore': _calculateScore(completedTasks, tasks.length, prospectives.length, sales.length, daysPresent, daysLate),
      };
    }

    setState(() {
      _employeeStats = stats;
      _loading = false;
    });
  }

  int _calculateScore(int completed, int total, int prospected, int salesCount, int present, int late) {
    int score = 0;
    if (total > 0) score += ((completed / total) * 30).round();
    score += (prospected * 2).clamp(0, 25);
    score += (salesCount * 5).clamp(0, 25);
    if (present > 0) score += (((present - late) / present) * 20).round();
    return score.clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Performances'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primary))
          : RefreshIndicator(
              onRefresh: _loadPerformance,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPeriodSelector(),
                    const SizedBox(height: 16),
                    _buildOverallStats(),
                    const SizedBox(height: 20),
                    const Text('Classement Employés', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ..._buildEmployeeRanking(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Row(
      children: [
        _buildPeriodChip('Semaine', 'week'),
        const SizedBox(width: 8),
        _buildPeriodChip('Mois', 'month'),
        const SizedBox(width: 8),
        _buildPeriodChip('Année', 'year'),
      ],
    );
  }

  Widget _buildPeriodChip(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return GestureDetector(
      onTap: () { setState(() => _selectedPeriod = value); _loadPerformance(); },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? _primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark)),
      ),
    );
  }

  Widget _buildOverallStats() {
    final totTasks = _employeeStats.values.fold<int>(0, (s, e) => s + ((e['totalTasks'] ?? 0) as int));
    final compTasks = _employeeStats.values.fold<int>(0, (s, e) => s + ((e['completedTasks'] ?? 0) as int));
    final totProspected = _employeeStats.values.fold<int>(0, (s, e) => s + ((e['prospected'] ?? 0) as int));
    final totSales = _employeeStats.values.fold<int>(0, (s, e) => s + ((e['salesCount'] ?? 0) as int));
    final avgScore = _employeeStats.isNotEmpty
        ? (_employeeStats.values.fold<int>(0, (s, e) => s + ((e['globalScore'] ?? 0) as int)) / _employeeStats.length).round()
        : 0;

    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('$compTasks', 'Tâches faites', Icons.task_alt, AppColors.primaryGreen),
            const SizedBox(width: 8),
            _buildStatCard('$totProspected', 'Démarchés', Icons.store, AppColors.primaryBlue),
            const SizedBox(width: 8),
            _buildStatCard('$totSales', 'Ventes', Icons.shopping_cart, AppColors.primaryAmber),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildStatCard('$avgScore%', 'Score moyen', Icons.star, AppColors.primaryGreen),
            const SizedBox(width: 8),
            _buildStatCard('$totTasks', 'Total tâches', Icons.list_alt, AppColors.primaryRed),
            const SizedBox(width: 8),
            _buildStatCard('${_employeeStats.length}', 'Actifs', Icons.people, AppColors.primaryBlue),
          ],
        ),
      ],
    );
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
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildEmployeeRanking() {
    final sorted = _employeeStats.entries.toList()..sort((a, b) => ((b.value['globalScore'] ?? 0) as int).compareTo((a.value['globalScore'] ?? 0) as int));
    return sorted.asMap().entries.map((entry) {
      final rank = entry.key + 1;
      final stats = entry.value.value;
      final score = (stats['globalScore'] ?? 0) as int;
      final scoreColor = score >= 70 ? AppColors.primaryGreen : (score >= 40 ? AppColors.primaryAmber : AppColors.primaryRed);
      final medals = {1: '🥇', 2: '🥈', 3: '🥉'};

      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: scoreColor.withValues(alpha: 0.1),
            child: Text(medals[rank] ?? '$rank', style: TextStyle(fontSize: medals.containsKey(rank) ? 20 : 14, fontWeight: FontWeight.bold, color: scoreColor)),
          ),
          title: Text(stats['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Row(
            children: [
              _buildMiniStat('${stats['completedTasks'] ?? 0}/${stats['totalTasks'] ?? 0}', 'tâches'),
              const SizedBox(width: 8),
              _buildMiniStat('${stats['prospected'] ?? 0}', 'démarchés'),
              const SizedBox(width: 8),
              _buildMiniStat('${stats['salesCount'] ?? 0}', 'ventes'),
            ],
          ),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('$score%', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: scoreColor)),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMiniStat(String value, String label) {
    return Text('$value $label', style: TextStyle(fontSize: 11, color: Colors.grey[600]));
  }
}
