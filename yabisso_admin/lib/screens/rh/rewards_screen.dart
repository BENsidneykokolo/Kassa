import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});
  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  String _filterType = 'all';
  List<Map<String, dynamic>> _rewards = [];
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  static const _rewardTypes = ['Prime', 'Augmentation', 'Certification', 'Mention', 'Autre'];
  static const _filterLabels = {'all': 'Tous', 'Prime': 'Prime', 'Augmentation': 'Augmentation', 'Certification': 'Certification', 'Mention': 'Mention', 'Autre': 'Autre'};

  Color _typeColor(String type) {
    switch (type) {
      case 'Prime': return AppColors.primaryAmber;
      case 'Augmentation': return AppColors.primaryGreen;
      case 'Certification': return AppColors.primaryBlue;
      case 'Mention': return AppColors.primaryRed;
      default: return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Prime': return Icons.attach_money;
      case 'Augmentation': return Icons.trending_up;
      case 'Certification': return Icons.verified;
      case 'Mention': return Icons.emoji_events;
      default: return Icons.star;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    _rewards = await db.getAll('rewards', orderBy: 'created_at DESC');
    _employees = await db.getAll('employees');
    setState(() => _loading = false);
  }

  void _showAddRewardDialog() {
    String? selectedEmployee;
    String selectedType = _rewardTypes.first;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Nouvelle récompense', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedEmployee,
                  decoration: InputDecoration(labelText: 'Employé', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _employees.map((e) => DropdownMenuItem(value: e['id'] as String, child: Text(e['name'] as String))).toList(),
                  onChanged: (v) => setModalState(() => selectedEmployee = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(labelText: 'Type', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  items: _rewardTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (v) => setModalState(() => selectedType = v ?? selectedType),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Titre', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime.now().add(const Duration(days: 365)));
                    if (d != null) setModalState(() => selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text('${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}', style: const TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity, height: 48,
                  child: ElevatedButton(
                    onPressed: selectedEmployee == null || titleController.text.isEmpty ? null : () async {
                      final db = DatabaseHelper.instance;
                      final emp = _employees.firstWhere((e) => e['id'] == selectedEmployee);
                      final admin = ref.read(currentAdminProvider);
                      final now = DateTime.now().toIso8601String();
                      await db.insert('rewards', {
                        'id': const Uuid().v4(),
                        'employee_id': selectedEmployee,
                        'employee_name': emp['name'],
                        'reward_type': selectedType,
                        'title': titleController.text,
                        'description': descController.text,
                        'date': selectedDate.toIso8601String().substring(0, 10),
                        'awarded_by': admin?.name ?? '',
                        'created_at': now,
                      });
                      await db.logActivity(admin?.id, 'reward_created', 'Récompense "${titleController.text}" ($selectedType) pour ${emp['name']}');
                      _loadData();
                      if (mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Enregistrer'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterType == 'all' ? _rewards : _rewards.where((r) => r['reward_type'] == _filterType).toList();
    final totalCount = _rewards.length;
    final primeCount = _rewards.where((r) => r['reward_type'] == 'Prime').length;
    final augCount = _rewards.where((r) => r['reward_type'] == 'Augmentation').length;
    final certCount = _rewards.where((r) => r['reward_type'] == 'Certification').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Récompenses'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [IconButton(icon: const Icon(Icons.add), onPressed: _showAddRewardDialog)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildMiniStat('$totalCount', 'Total', AppColors.primaryAmber),
                      const SizedBox(width: 8),
                      _buildMiniStat('$primeCount', 'Primes', AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat('$augCount', 'Augment.', AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      _buildMiniStat('$certCount', 'Certifs.', AppColors.primaryRed),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filterLabels.entries.map((e) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(e.value, style: TextStyle(fontSize: 12, color: _filterType == e.key ? Colors.white : Colors.grey[700])),
                        selected: _filterType == e.key,
                        selectedColor: AppColors.primaryGreen,
                        onSelected: (v) => setState(() => _filterType = e.key),
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('Aucune récompense', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Appuyez sur + pour ajouter une récompense', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _buildRewardCard(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }

  Widget _buildRewardCard(Map<String, dynamic> reward) {
    final type = reward['reward_type'] ?? 'Autre';
    final color = _typeColor(type);
    final icon = _typeIcon(type);

    return Container(
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
              CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.1),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(reward['employee_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(reward['title'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          if (reward['description'] != null && (reward['description'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(reward['description'], style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(reward['date'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              if (reward['awarded_by'] != null && (reward['awarded_by'] as String).isNotEmpty) ...[
                Icon(Icons.person, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(reward['awarded_by'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
