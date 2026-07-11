import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});
  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _attendance = [];
  String _filterStatus = 'all';
  String _searchQuery = '';
  static const _primary = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final records = await db.getAll('attendance', orderBy: 'date DESC, check_in DESC');
    setState(() { _attendance = records; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Présence & Pointage'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: Column(
        children: [
          _buildStatsBar(),
          _buildFilters(),
          _buildSearchBar(),
          Expanded(child: _buildAttendanceList()),
        ],
      ),
    );
  }

  Widget _buildStatsBar() {
    final present = _attendance.where((a) => a['status'] == 'present').length;
    final late = _attendance.where((a) => a['status'] == 'late').length;
    final absent = _attendance.where((a) => a['status'] == 'absent').length;
    final overtime = _attendance.fold<double>(0, (s, a) => s + ((a['overtime_hours'] ?? 0) as double));

    return Container(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _buildStatMini('$present', 'Présent', AppColors.successGreen),
          const SizedBox(width: 6),
          _buildStatMini('$late', 'Retard', AppColors.primaryAmber),
          const SizedBox(width: 6),
          _buildStatMini('$absent', 'Absent', AppColors.primaryRed),
          const SizedBox(width: 6),
          _buildStatMini('${overtime.toStringAsFixed(1)}h', 'Heures supp.', AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _buildStatMini(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
            Text(label, style: TextStyle(fontSize: 9, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          _buildChip('Tous', 'all'),
          const SizedBox(width: 4),
          _buildChip('Présent', 'present'),
          const SizedBox(width: 4),
          _buildChip('Retard', 'late'),
          const SizedBox(width: 4),
          _buildChip('Absent', 'absent'),
        ],
      ),
    );
  }

  Widget _buildChip(String label, String value) {
    final sel = _filterStatus == value;
    return GestureDetector(
      onTap: () => setState(() => _filterStatus = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: sel ? _primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? _primary : AppColors.border),
        ),
        child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppColors.textDark)),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher par nom...',
          prefixIcon: const Icon(Icons.search, size: 18),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          isDense: true, contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
      ),
    );
  }

  Widget _buildAttendanceList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _primary));
    final filtered = _attendance.where((a) {
      if (_filterStatus != 'all' && a['status'] != _filterStatus) return false;
      if (_searchQuery.isNotEmpty) {
        final name = (a['employee_name'] ?? '').toString().toLowerCase();
        if (!name.contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucun enregistrement', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );

    return RefreshIndicator(
      onRefresh: _loadAttendance,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _buildAttendanceCard(filtered[i]),
      ),
    );
  }

  Widget _buildAttendanceCard(Map<String, dynamic> record) {
    final status = record['status'] ?? 'present';
    final isLate = (record['is_late'] ?? 0) == 1;
    final isEarlyDeparture = (record['early_departure'] ?? 0) == 1;
    final overtime = (record['overtime_hours'] ?? 0) as double;

    final statusColor = status == 'present' ? AppColors.successGreen
        : status == 'late' ? AppColors.primaryAmber
        : AppColors.primaryRed;
    final statusLabel = status == 'present' ? 'Présent'
        : status == 'late' ? 'En retard'
        : 'Absent';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  child: Text((record['employee_name'] ?? '?')[0], style: TextStyle(color: statusColor, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record['employee_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                      Text(record['date'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.login, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('Arrivée: ${record['check_in'] ?? '—'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(width: 16),
                Icon(Icons.logout, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text('Départ: ${record['check_out'] ?? '—'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              ],
            ),
            if (isLate || isEarlyDeparture || overtime > 0) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                children: [
                  if (isLate) _buildTag('Retard', AppColors.primaryAmber),
                  if (isEarlyDeparture) _buildTag('Départ anticipé', AppColors.primaryRed),
                  if (overtime > 0) _buildTag('+${overtime.toStringAsFixed(1)}h supp', AppColors.primaryBlue),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: color)),
    );
  }
}
