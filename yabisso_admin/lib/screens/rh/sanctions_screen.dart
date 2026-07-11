import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class SanctionsScreen extends ConsumerStatefulWidget {
  const SanctionsScreen({super.key});
  @override
  ConsumerState<SanctionsScreen> createState() => _SanctionsScreenState();
}

class _SanctionsScreenState extends ConsumerState<SanctionsScreen> {
  String _filterType = 'all';
  List<Map<String, dynamic>> _sanctions = [];
  List<Map<String, dynamic>> _employees = [];
  bool _loading = true;

  static const _sanctionTypes = ['Avertissement', 'Blâme', 'Suspension', 'Autre'];
  static const _filterLabels = {
    'all': 'Tous',
    'Avertissement': 'Avertissement',
    'Blâme': 'Blâme',
    'Suspension': 'Suspension',
    'Autre': 'Autre',
  };

  Color _typeColor(String type) {
    switch (type) {
      case 'Avertissement':
        return AppColors.primaryAmber;
      case 'Blâme':
        return AppColors.primaryRed;
      case 'Suspension':
        return Colors.deepPurple;
      default:
        return Colors.grey;
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'Avertissement':
        return Icons.warning_amber;
      case 'Blâme':
        return Icons.gavel;
      case 'Suspension':
        return Icons.block;
      default:
        return Icons.help_outline;
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
    _sanctions = await db.getAll('sanctions', orderBy: 'created_at DESC');
    _employees = await db.getAll('employees');
    setState(() => _loading = false);
  }

  void _showAddSanctionSheet() {
    String? selectedEmployee;
    String selectedType = _sanctionTypes.first;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nouvelle sanction',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: selectedEmployee,
                  decoration: InputDecoration(
                    labelText: 'Employé',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _employees
                      .map((e) => DropdownMenuItem(
                            value: e['id'] as String,
                            child: Text(e['name'] as String),
                          ))
                      .toList(),
                  onChanged: (v) => setModalState(() => selectedEmployee = v),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: InputDecoration(
                    labelText: 'Type de sanction',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: _sanctionTypes
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setModalState(() => selectedType = v ?? selectedType),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(
                        const Duration(days: 365),
                      ),
                    );
                    if (d != null) setModalState(() => selectedDate = d);
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Date',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon:
                          const Icon(Icons.calendar_today, size: 18),
                    ),
                    child: Text(
                      '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: selectedEmployee == null ||
                            titleController.text.isEmpty
                        ? null
                        : () async {
                            final db = DatabaseHelper.instance;
                            final emp = _employees.firstWhere(
                                (e) => e['id'] == selectedEmployee);
                            final admin = ref.read(currentAdminProvider);
                            final now = DateTime.now().toIso8601String();
                            await db.insert('sanctions', {
                              'id': const Uuid().v4(),
                              'employee_id': selectedEmployee,
                              'employee_name': emp['name'],
                              'sanction_type': selectedType,
                              'title': titleController.text,
                              'description': descController.text,
                              'date': selectedDate
                                  .toIso8601String()
                                  .substring(0, 10),
                              'issued_by': admin?.name ?? '',
                              'status': 'active',
                              'created_at': now,
                            });
                            await db.logActivity(
                              admin?.id,
                              'sanction_created',
                              'Sanction "$selectedType" pour ${emp['name']}: ${titleController.text}',
                            );
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

  Future<void> _liftSanction(Map<String, dynamic> sanction) async {
    final db = DatabaseHelper.instance;
    final admin = ref.read(currentAdminProvider);
    await db.update('sanctions', {
      'status': 'lifted',
    }, sanction['id'] as String);
    await db.logActivity(
      admin?.id,
      'sanction_lifted',
      'Sanction levée pour ${sanction['employee_name']}: ${sanction['title']}',
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filterType == 'all'
        ? _sanctions
        : _sanctions.where((s) => s['sanction_type'] == _filterType).toList();
    final totalCount = _sanctions.length;
    final avertissementCount =
        _sanctions.where((s) => s['sanction_type'] == 'Avertissement').length;
    final blameCount =
        _sanctions.where((s) => s['sanction_type'] == 'Blâme').length;
    final suspensionCount =
        _sanctions.where((s) => s['sanction_type'] == 'Suspension').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sanctions'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddSanctionSheet,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildMiniStat(
                          '$totalCount', 'Total', AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildMiniStat('$avertissementCount', 'Avert.',
                          AppColors.primaryAmber),
                      const SizedBox(width: 8),
                      _buildMiniStat(
                          '$blameCount', 'Blâmes', AppColors.primaryRed),
                      const SizedBox(width: 8),
                      _buildMiniStat(
                          '$suspensionCount', 'Suspend.', Colors.deepPurple),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _filterLabels.entries
                        .map((e) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                label: Text(
                                  e.value,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: _filterType == e.key
                                        ? Colors.white
                                        : Colors.grey[700],
                                  ),
                                ),
                                selected: _filterType == e.key,
                                selectedColor: AppColors.primaryGreen,
                                onSelected: (v) =>
                                    setState(() => _filterType = e.key),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: filtered.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) =>
                              _buildSanctionCard(filtered[i]),
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
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color)),
          Text(label,
              style:
                  TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
        ]),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.gavel, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Aucune sanction',
              style: TextStyle(color: Colors.grey[500], fontSize: 16)),
          const SizedBox(height: 4),
          Text('Appuyez sur + pour ajouter une sanction',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSanctionCard(Map<String, dynamic> sanction) {
    final type = sanction['sanction_type'] ?? 'Autre';
    final color = _typeColor(type);
    final icon = _typeIcon(type);
    final status = sanction['status'] ?? 'active';
    final isActive = status == 'active';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? AppColors.border : Colors.grey.shade300,
        ),
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
                    Text(sanction['employee_name'] ?? '',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    Text(sanction['title'] ?? '',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(type,
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ),
            ],
          ),
          if (sanction['description'] != null &&
              (sanction['description'] as String).isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(sanction['description'],
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[500]),
              const SizedBox(width: 6),
              Text(sanction['date'] ?? '',
                  style:
                      TextStyle(fontSize: 12, color: Colors.grey[600])),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isActive ? 'Active' : 'Levée',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green : Colors.grey,
                  ),
                ),
              ),
            ],
          ),
          if (sanction['issued_by'] != null &&
              (sanction['issued_by'] as String).isNotEmpty) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(sanction['issued_by'],
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ],
          if (isActive) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Lever la sanction'),
                      content: Text(
                          'Voulez-vous vraiment lever la sanction pour ${sanction['employee_name']} ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _liftSanction(sanction);
                          },
                          child: const Text('Lever',
                              style: TextStyle(color: AppColors.primaryGreen)),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.check_circle_outline, size: 16),
                label: const Text('Lever la sanction',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
