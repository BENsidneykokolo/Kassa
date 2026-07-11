import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../models/employee.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class EmployeeDetailScreen extends ConsumerStatefulWidget {
  final String employeeId;
  const EmployeeDetailScreen({super.key, required this.employeeId});
  @override
  ConsumerState<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends ConsumerState<EmployeeDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _documents = [];
  List<Map<String, dynamic>> _trainings = [];
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _sanctions = [];
  List<Map<String, dynamic>> _notes = [];
  List<Map<String, dynamic>> _attendance = [];
  List<Map<String, dynamic>> _sales = [];
  List<Map<String, dynamic>> _objectives = [];
  int _presentDays = 0;
  int _absentDays = 0;
  int _lateDays = 0;

  static const _primary = AppColors.primaryGreen;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final eid = widget.employeeId;

    final profiles = await db.getAll('employee_profiles', where: 'employee_id = ?', whereArgs: [eid]);
    _profile = profiles.isNotEmpty ? profiles.first : null;
    _documents = await db.getAll('employee_documents', where: 'employee_id = ?', whereArgs: [eid]);
    _trainings = await db.getAll('employee_trainings', where: 'employee_id = ?', whereArgs: [eid]);
    _rewards = await db.getAll('rewards', where: 'employee_id = ?', whereArgs: [eid]);
    _sanctions = await db.getAll('sanctions', where: 'employee_id = ?', whereArgs: [eid]);
    _notes = await db.getAll('manager_notes', where: 'employee_id = ?', whereArgs: [eid]);
    _attendance = await db.getAll('attendance', where: 'employee_id = ?', whereArgs: [eid], orderBy: 'date DESC');
    _sales = await db.getAll('sale_records', where: 'employee_id = ?', whereArgs: [eid], orderBy: 'created_at DESC');
    _objectives = await db.getAll('objectives', where: 'employee_id = ?', whereArgs: [eid]);

    _presentDays = _attendance.where((a) => a['status'] == 'present').length;
    _absentDays = _attendance.where((a) => a['status'] == 'absent').length;
    _lateDays = _attendance.where((a) => a['status'] == 'late').length;

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: employeesAsync.when(
        data: (employees) {
          final emp = employees.where((e) => e.id == widget.employeeId).toList();
          if (emp.isEmpty) return const Center(child: Text('Employé non trouvé'));
          final employee = emp.first;
          return NestedScrollView(
            headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: _primary,
                leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => context.go('/employees')),
                actions: [
                  IconButton(icon: const Icon(Icons.edit, color: Colors.white), onPressed: () => _showEditProfileDialog(employee)),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProfileHeader(employee),
                ),
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white60,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Profil'),
                    Tab(text: 'Documents'),
                    Tab(text: 'Présence'),
                    Tab(text: 'Performance'),
                    Tab(text: 'Formations'),
                    Tab(text: 'Notes'),
                  ],
                ),
              ),
            ],
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildProfilTab(employee),
                _buildDocumentsTab(),
                _buildAttendanceTab(),
                _buildPerformanceTab(),
                _buildTrainingsTab(),
                _buildNotesTab(employee),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: _primary)),
        error: (e, _) => Center(child: Text('Erreur: $e')),
      ),
    );
  }

  Widget _buildProfileHeader(Employee employee) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0xFF0B4D3C), _primary]),
      ),
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white24,
                backgroundImage: _profile?['photo_path'] != null
                    ? NetworkImage(_profile!['photo_path'])
                    : null,
                child: _profile?['photo_path'] == null
                    ? Text(employee.initials.isNotEmpty ? employee.initials : employee.name[0],
                        style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(height: 8),
              Text(employee.name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(employee.phone, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: employee.isActive ? Colors.white24 : AppColors.primaryRed.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(employee.isActive ? employee.roleLabel : 'Inactif',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilTab(Employee employee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildInfoCard('Informations personnelles', [
            _infoRow('ID', employee.id.substring(0, 8)),
            _infoRow('Nom complet', employee.name),
            _infoRow('Téléphone', employee.phone),
            _infoRow('Email', _profile?['email'] ?? '—'),
            _infoRow('Rôle', employee.roleLabel),
            _infoRow('Salaire', '${employee.baseSalary} FCFA'),
          ]),
          const SizedBox(height: 12),
          _buildInfoCard('Emploi', [
            _infoRow('Poste', _profile?['position'] ?? '—'),
            _infoRow('Département', _profile?['department'] ?? '—'),
            _infoRow('Manager', _profile?['manager_name'] ?? '—'),
            _infoRow('Date d\'embauche', _profile?['hire_date'] ?? '—'),
            _infoRow('Type contrat', _profile?['contract_type'] ?? '—'),
            _infoRow('Adresse', _profile?['address'] ?? '—'),
          ]),
          const SizedBox(height: 12),
          _buildInfoCard('Urgence', [
            _infoRow('Contact urgence', _profile?['emergency_contact'] ?? '—'),
            _infoRow('Tél urgence', _profile?['emergency_phone'] ?? '—'),
          ]),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildMiniStat('$_presentDays', 'Présent', AppColors.successGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('$_absentDays', 'Absent', AppColors.primaryRed)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('$_lateDays', 'Retard', AppColors.primaryAmber)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('${_sales.length}', 'Ventes', AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _toggleActive(employee),
                  icon: Icon(employee.isActive ? Icons.block : Icons.check_circle),
                  label: Text(employee.isActive ? 'Désactiver' : 'Activer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: employee.isActive ? AppColors.primaryRed : AppColors.successGreen,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showEditProfileDialog(employee),
                  icon: const Icon(Icons.edit),
                  label: const Text('Modifier'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Documents', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: _primary),
                onPressed: () => _showAddDocumentDialog(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_documents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.folder_open, size: 50, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    Text('Aucun document', style: TextStyle(color: Colors.grey[500], fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('Appuyez + pour ajouter un document', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                  ],
                ),
              ),
            )
          else
            ..._documents.map((doc) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _primary.withValues(alpha: 0.1),
                  child: Icon(_getDocIcon(doc['doc_type']), color: _primary, size: 20),
                ),
                title: Text(doc['doc_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                subtitle: Text(doc['doc_type'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.primaryRed),
                  onPressed: () async {
                    await DatabaseHelper.instance.delete('employee_documents', doc['id']);
                    _loadData();
                  },
                ),
              ),
            )),
        ],
      ),
    );
  }

  Widget _buildAttendanceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildMiniStat('$_presentDays', 'Présent', AppColors.successGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('$_absentDays', 'Absent', AppColors.primaryRed)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('$_lateDays', 'Retard', AppColors.primaryAmber)),
            ],
          ),
          const SizedBox(height: 16),
          const Text('Historique', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_attendance.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucun historique de présence', style: TextStyle(color: Colors.grey[500])),
            ))
          else
            ..._attendance.take(30).map((a) {
              final status = a['status'] ?? 'present';
              final color = status == 'present' ? AppColors.successGreen
                  : status == 'late' ? AppColors.primaryAmber
                  : AppColors.primaryRed;
              final label = status == 'present' ? 'Présent' : status == 'late' ? 'En retard' : 'Absent';
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(radius: 4, backgroundColor: color),
                  title: Text(a['date'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${a['check_in'] ?? '—'} → ${a['check_out'] ?? '—'}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildPerformanceTab() {
    final totalSales = _sales.fold<int>(0, (s, r) => s + ((r['amount'] ?? 0) as int));
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: _buildMiniStat('${_sales.length}', 'Ventes', AppColors.primaryGreen)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('$totalSales FCFA', 'CA', AppColors.primaryAmber)),
              const SizedBox(width: 8),
              Expanded(child: _buildMiniStat('${_objectives.length}', 'Objectifs', AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 16),
          if (_rewards.isNotEmpty) ...[
            const Text('Récompenses', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._rewards.map((r) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.emoji_events, color: AppColors.primaryAmber, size: 20),
                title: Text(r['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('${r['reward_type']} — ${r['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (_sanctions.isNotEmpty) ...[
            const Text('Sanctions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._sanctions.map((s) => Card(
              margin: const EdgeInsets.only(bottom: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.gavel, color: AppColors.primaryRed, size: 20),
                title: Text(s['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Text('${s['sanction_type']} — ${s['date']}', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ),
            )),
            const SizedBox(height: 12),
          ],
          if (_objectives.isNotEmpty) ...[
            const Text('Objectifs', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._objectives.map((o) {
              final target = (o['target_value'] ?? 1) as int;
              final current = (o['current_value'] ?? 0) as int;
              final pct = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
              return Card(
                margin: const EdgeInsets.only(bottom: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(o['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      LinearProgressIndicator(value: pct, backgroundColor: Colors.grey[200], color: pct >= 1 ? AppColors.primaryGreen : AppColors.primaryBlue),
                      const SizedBox(height: 4),
                      Text('$current/$target (${(pct * 100).round()}%)', style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                    ],
                  ),
                ),
              );
            }),
          ],
          if (_sales.isEmpty && _rewards.isEmpty && _sanctions.isEmpty && _objectives.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucune donnée de performance', style: TextStyle(color: Colors.grey[500])),
            )),
        ],
      ),
    );
  }

  Widget _buildTrainingsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Formations', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_trainings.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucune formation suivie', style: TextStyle(color: Colors.grey[500])),
            ))
          else
            ..._trainings.map((t) {
              final status = t['status'] ?? 'enrolled';
              final color = status == 'completed' ? AppColors.successGreen : AppColors.primaryBlue;
              final label = status == 'completed' ? 'Terminée' : 'En cours';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(Icons.school, color: color, size: 18)),
                  title: Text(t['training_title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  subtitle: Text(label, style: TextStyle(fontSize: 11, color: color)),
                  trailing: status != 'completed'
                      ? IconButton(
                          icon: const Icon(Icons.check_circle, color: AppColors.primaryGreen, size: 20),
                          onPressed: () async {
                            await DatabaseHelper.instance.update('employee_trainings', {
                              'status': 'completed',
                              'completion_date': DateTime.now().toIso8601String().substring(0, 10),
                            }, t['id']);
                            _loadData();
                          },
                        )
                      : null,
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNotesTab(Employee employee) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Notes du manager', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: _primary),
                onPressed: () => _showAddNoteDialog(employee),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_notes.isEmpty)
            Center(child: Padding(
              padding: const EdgeInsets.all(40),
              child: Text('Aucune note', style: TextStyle(color: Colors.grey[500])),
            ))
          else
            ..._notes.map((n) {
              final sentiment = n['sentiment'] ?? 'neutral';
              final sentimentColor = sentiment == 'positive' ? AppColors.successGreen
                  : sentiment == 'negative' ? AppColors.primaryRed
                  : AppColors.primaryBlue;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: sentimentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                            child: Text(n['category'] ?? 'Général', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: sentimentColor)),
                          ),
                          const Spacer(),
                          Text(n['created_at']?.toString().substring(0, 10) ?? '', style: TextStyle(fontSize: 10, color: Colors.grey[500])),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(n['note'] ?? '', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: color)),
        ],
      ),
    );
  }

  IconData _getDocIcon(String? type) {
    switch (type) {
      case 'contrat': return Icons.description;
      case 'cv': return Icons.article;
      case 'diplome': return Icons.school;
      case 'photo': return Icons.photo;
      default: return Icons.insert_drive_file;
    }
  }

  Future<void> _toggleActive(Employee employee) async {
    final db = DatabaseHelper.instance;
    await db.update('employees', {
      'is_active': employee.isActive ? 0 : 1,
      'updated_at': DateTime.now().toIso8601String(),
    }, employee.id);
    await db.logActivity(null, employee.isActive ? 'employee_deactivated' : 'employee_activated', employee.name);
    ref.invalidate(employeesProvider);
    _loadData();
  }

  void _showEditProfileDialog(Employee employee) {
    final nameCtrl = TextEditingController(text: employee.name);
    final phoneCtrl = TextEditingController(text: employee.phone);
    final emailCtrl = TextEditingController(text: _profile?['email'] ?? '');
    final positionCtrl = TextEditingController(text: _profile?['position'] ?? '');
    final deptCtrl = TextEditingController(text: _profile?['department'] ?? '');
    final managerCtrl = TextEditingController(text: _profile?['manager_name'] ?? '');
    final addressCtrl = TextEditingController(text: _profile?['address'] ?? '');
    final emergencyContactCtrl = TextEditingController(text: _profile?['emergency_contact'] ?? '');
    final emergencyPhoneCtrl = TextEditingController(text: _profile?['emergency_phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Modifier le profil', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDialogField(nameCtrl, 'Nom complet'),
              _buildDialogField(phoneCtrl, 'Téléphone'),
              _buildDialogField(emailCtrl, 'Email'),
              _buildDialogField(positionCtrl, 'Poste'),
              _buildDialogField(deptCtrl, 'Département'),
              _buildDialogField(managerCtrl, 'Manager'),
              _buildDialogField(addressCtrl, 'Adresse'),
              _buildDialogField(emergencyContactCtrl, 'Contact urgence'),
              _buildDialogField(emergencyPhoneCtrl, 'Tél urgence'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final db = DatabaseHelper.instance;
                    final initials = nameCtrl.text.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
                    await db.update('employees', {
                      'name': nameCtrl.text, 'phone': phoneCtrl.text, 'initials': initials,
                      'updated_at': DateTime.now().toIso8601String(),
                    }, employee.id);

                    final profileData = {
                      'employee_id': employee.id,
                      'email': emailCtrl.text,
                      'position': positionCtrl.text,
                      'department': deptCtrl.text,
                      'manager_name': managerCtrl.text,
                      'address': addressCtrl.text,
                      'emergency_contact': emergencyContactCtrl.text,
                      'emergency_phone': emergencyPhoneCtrl.text,
                      'updated_at': DateTime.now().toIso8601String(),
                    };
                    if (_profile != null) {
                      await db.update('employee_profiles', profileData, _profile!['id']);
                    } else {
                      profileData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
                      profileData['created_at'] = DateTime.now().toIso8601String();
                      await db.insert('employee_profiles', profileData);
                    }

                    await db.logActivity(null, 'employee_updated', employee.name);
                    ref.invalidate(employeesProvider);
                    _loadData();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                  child: const Text('Sauvegarder'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          isDense: true,
        ),
      ),
    );
  }

  void _showAddDocumentDialog() {
    String docType = 'contrat';
    final nameCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajouter un document', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: docType,
                items: const [
                  DropdownMenuItem(value: 'contrat', child: Text('Contrat')),
                  DropdownMenuItem(value: 'cv', child: Text('CV')),
                  DropdownMenuItem(value: 'diplome', child: Text('Diplôme')),
                  DropdownMenuItem(value: 'photo', child: Text('Photo')),
                  DropdownMenuItem(value: 'autre', child: Text('Autre')),
                ],
                onChanged: (v) => setModalState(() => docType = v!),
                decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nom du document', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final db = DatabaseHelper.instance;
                    await db.insert('employee_documents', {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'employee_id': widget.employeeId,
                      'doc_type': docType,
                      'doc_name': nameCtrl.text,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    _loadData();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                  child: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(Employee employee) {
    final noteCtrl = TextEditingController();
    String category = 'Général';
    String sentiment = 'neutral';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ajouter une note', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: const [
                  DropdownMenuItem(value: 'Général', child: Text('Général')),
                  DropdownMenuItem(value: 'Performance', child: Text('Performance')),
                  DropdownMenuItem(value: 'Ponctualité', child: Text('Ponctualité')),
                  DropdownMenuItem(value: 'Relation client', child: Text('Relation client')),
                  DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                ],
                onChanged: (v) => setModalState(() => category = v!),
                decoration: InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: sentiment,
                items: const [
                  DropdownMenuItem(value: 'neutral', child: Text('Neutre')),
                  DropdownMenuItem(value: 'positive', child: Text('Positif')),
                  DropdownMenuItem(value: 'negative', child: Text('Négatif')),
                ],
                onChanged: (v) => setModalState(() => sentiment = v!),
                decoration: InputDecoration(labelText: 'Sentiment', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
              ),
              const SizedBox(height: 12),
              TextField(controller: noteCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Note', border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)))),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (noteCtrl.text.isEmpty) return;
                    final db = DatabaseHelper.instance;
                    await db.insert('manager_notes', {
                      'id': DateTime.now().millisecondsSinceEpoch.toString(),
                      'employee_id': employee.id,
                      'employee_name': employee.name,
                      'note': noteCtrl.text,
                      'category': category,
                      'sentiment': sentiment,
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    await db.logActivity(null, 'manager_note', 'Note pour ${employee.name}');
                    _loadData();
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white),
                  child: const Text('Ajouter'),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
