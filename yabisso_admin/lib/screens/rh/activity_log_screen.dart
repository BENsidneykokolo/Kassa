import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});
  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _logs = [];
  String _filterAction = 'all';
  String _searchQuery = '';
  static const _primary = AppColors.primaryGreen;

  static const _actionLabels = {
    'task_created': 'Tâche créée',
    'task_in_progress': 'Tâche démarrée',
    'task_completed': 'Tâche terminée',
    'employee_created': 'Employé créé',
    'employee_updated': 'Employé modifié',
    'candidate_created': 'Candidat créé',
    'candidate_stage': 'Étape candidat',
    'leave_requested': 'Congé demandé',
    'leave_approved': 'Congé approuvé',
    'leave_rejected': 'Congé refusé',
    'objective_created': 'Objectif créé',
    'objective_completed': 'Objectif atteint',
    'reward_given': 'Récompense attribuée',
    'sanction_issued': 'Sanction émise',
    'training_enrolled': 'Inscription formation',
    'training_completed': 'Formation terminée',
    'daily_report': 'Rapport journalier',
    'attendance_checkin': 'Arrivée pointée',
    'attendance_checkout': 'Départ pointé',
    'login': 'Connexion',
    'logout': 'Déconnexion',
    'prospective_added': 'Commerce démarché',
    'manager_note': 'Note manager',
    'notification_sent': 'Notification envoyée',
  };

  static const _actionIcons = {
    'task_created': Icons.add_task,
    'task_in_progress': Icons.play_arrow,
    'task_completed': Icons.check_circle,
    'employee_created': Icons.person_add,
    'employee_updated': Icons.edit,
    'candidate_created': Icons.person_search,
    'candidate_stage': Icons.arrow_forward,
    'leave_requested': Icons.event_busy,
    'leave_approved': Icons.check,
    'leave_rejected': Icons.close,
    'objective_created': Icons.flag,
    'objective_completed': Icons.emoji_events,
    'reward_given': Icons.stars,
    'sanction_issued': Icons.gavel,
    'training_enrolled': Icons.school,
    'training_completed': Icons.school,
    'daily_report': Icons.assessment,
    'attendance_checkin': Icons.login,
    'attendance_checkout': Icons.logout,
    'login': Icons.lock_open,
    'logout': Icons.lock,
    'prospective_added': Icons.store,
    'manager_note': Icons.note,
    'notification_sent': Icons.notifications,
  };

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final logs = await db.getAll('activity_log', orderBy: 'created_at DESC');
    setState(() { _logs = logs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Journal d\'activité'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.go('/')),
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildActionFilter(),
          Expanded(child: _buildLogList()),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Rechercher dans le journal...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setState(() => _searchQuery = ''))
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          isDense: true,
        ),
      ),
    );
  }

  Widget _buildActionFilter() {
    final actionTypes = ['all', ..._actionLabels.keys.take(8)];
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: actionTypes.map((action) {
          final isSelected = _filterAction == action;
          final label = action == 'all' ? 'Toutes' : (_actionLabels[action] ?? action);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => setState(() => _filterAction = action),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _primary : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelected ? _primary : AppColors.border),
                ),
                child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : AppColors.textDark)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLogList() {
    if (_loading) return const Center(child: CircularProgressIndicator(color: _primary));
    final filtered = _logs.where((log) {
      if (_filterAction != 'all' && log['action'] != _filterAction) return false;
      if (_searchQuery.isNotEmpty) {
        final action = (log['action'] ?? '').toString().toLowerCase();
        final details = (log['details'] ?? '').toString().toLowerCase();
        if (!action.contains(_searchQuery.toLowerCase()) && !details.contains(_searchQuery.toLowerCase())) return false;
      }
      return true;
    }).toList();

    if (filtered.isEmpty) return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucune activité', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
        ],
      ),
    );

    return RefreshIndicator(
      onRefresh: _loadLogs,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        itemBuilder: (ctx, i) => _buildLogItem(filtered[i]),
      ),
    );
  }

  Widget _buildLogItem(Map<String, dynamic> log) {
    final action = log['action'] ?? '';
    final icon = _actionIcons[action] ?? Icons.info;
    final label = _actionLabels[action] ?? action;
    final createdAt = log['created_at'] ?? '';
    DateTime? dt;
    try { dt = DateTime.parse(createdAt); } catch (_) {}

    Color iconColor;
    if (action.contains('completed') || action.contains('approved')) {
      iconColor = AppColors.primaryGreen;
    } else if (action.contains('rejected') || action.contains('sanction')) {
      iconColor = AppColors.primaryRed;
    } else if (action.contains('created') || action.contains('requested')) {
      iconColor = AppColors.primaryBlue;
    } else {
      iconColor = AppColors.primaryAmber;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.1),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        title: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        subtitle: log['details'] != null && (log['details'] as String).isNotEmpty
            ? Text(log['details'], style: TextStyle(fontSize: 11, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis)
            : null,
        trailing: dt != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                  Text('${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                ],
              )
            : null,
      ),
    );
  }
}
