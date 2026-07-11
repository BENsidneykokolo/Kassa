import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class CommerceTrackingScreen extends StatefulWidget {
  const CommerceTrackingScreen({super.key});
  @override
  State<CommerceTrackingScreen> createState() => _CommerceTrackingScreenState();
}

class _CommerceTrackingScreenState extends State<CommerceTrackingScreen> {
  String _selectedCategory = 'Tous';
  String _selectedResult = 'Tous';
  List<Map<String, dynamic>> _allProspections = [];
  bool _loading = true;

  static const _categories = [
    'Tous', 'Boutique', 'Restaurant', 'Quincaillerie', 'Pharmacie',
    'Salon de coiffure', 'Hôtel', 'Bar', 'Épicerie', 'Supermarché', 'Autre',
  ];

  static const _results = ['Tous', 'interested', 'not_interested', 'callback'];

  @override
  void initState() {
    super.initState();
    _loadProspections();
  }

  Future<void> _loadProspections() async {
    setState(() => _loading = true);
    final data = await DatabaseHelper.instance.getAll('prospectives',
      orderBy: 'created_at DESC',
    );
    setState(() { _allProspections = data; _loading = false; });
  }

  List<Map<String, dynamic>> get _filteredProspections {
    return _allProspections.where((p) {
      if (_selectedCategory != 'Tous' && p['category'] != _selectedCategory) return false;
      if (_selectedResult != 'Tous' && p['result'] != _selectedResult) return false;
      return true;
    }).toList();
  }

  Future<void> _updateManagerNotes(String id, String notes) async {
    await DatabaseHelper.instance.update('prospectives', {
      'manager_notes': notes,
      'updated_at': DateTime.now().toIso8601String(),
    }, id);
    _loadProspections();
  }

  Future<void> _updateManagerStatus(String id, String status) async {
    await DatabaseHelper.instance.update('prospectives', {
      'manager_status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }, id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(status == 'contacted' ? 'Marqué comme contacté' : 'Marqué comme pas intéressé'),
          backgroundColor: status == 'contacted' ? AppColors.primaryGreen : AppColors.primaryRed,
        ),
      );
    }
    _loadProspections();
  }

  void _showNotesDialog(Map<String, dynamic> p) {
    final notesController = TextEditingController(text: p['manager_notes'] ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Notes - ${p['shop_name'] ?? ''}'),
        content: TextField(
          controller: notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Notes du manager...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              _updateManagerNotes(p['id'], notesController.text);
              Navigator.pop(ctx);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredProspections;
    final totalInterested = _allProspections.where((p) => p['result'] == 'interested').length;
    final totalNotInterested = _allProspections.where((p) => p['result'] == 'not_interested').length;
    final totalCallback = _allProspections.where((p) => p['result'] == 'callback').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Suivi des commerces'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : Column(
              children: [
                // Stats
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _buildStatCard('${_allProspections.length}', 'Total', Icons.store, AppColors.primaryBlue),
                      const SizedBox(width: 8),
                      _buildStatCard('$totalInterested', 'Intéressés', Icons.check_circle, AppColors.primaryGreen),
                      const SizedBox(width: 8),
                      _buildStatCard('$totalNotInterested', 'Pas int.', Icons.cancel, AppColors.primaryRed),
                      const SizedBox(width: 8),
                      _buildStatCard('$totalCallback', 'À rappeler', Icons.schedule, AppColors.primaryAmber),
                    ],
                  ),
                ),

                // Filters
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c, style: const TextStyle(fontSize: 13)))).toList(),
                          onChanged: (v) => setState(() => _selectedCategory = v ?? 'Tous'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: _selectedResult,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          items: _results.map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(
                              r == 'Tous' ? 'Tous' : r == 'interested' ? 'Intéressé' : r == 'not_interested' ? 'Pas intéressé' : 'À rappeler',
                              style: const TextStyle(fontSize: 13),
                            ),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedResult = v ?? 'Tous'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.store_outlined, size: 64, color: Colors.grey[300]),
                              const SizedBox(height: 12),
                              Text('Aucun démarchage', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filtered.length,
                          itemBuilder: (ctx, i) => _buildProspectionCard(filtered[i]),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
            Text(label, style: TextStyle(fontSize: 9, color: color.withValues(alpha: 0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildProspectionCard(Map<String, dynamic> p) {
    final result = p['result'] ?? 'interested';
    Color resultColor;
    IconData resultIcon;
    String resultLabel;
    switch (result) {
      case 'interested':
        resultColor = AppColors.primaryGreen;
        resultIcon = Icons.check_circle;
        resultLabel = 'Intéressé';
        break;
      case 'not_interested':
        resultColor = AppColors.primaryRed;
        resultIcon = Icons.cancel;
        resultLabel = 'Pas intéressé';
        break;
      default:
        resultColor = AppColors.primaryAmber;
        resultIcon = Icons.schedule;
        resultLabel = 'À rappeler';
    }

    final managerStatus = p['manager_status'] ?? 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
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
                width: 42, height: 42,
                decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(resultIcon, color: resultColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p['shop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('${p['category'] ?? ''} • ${p['employee_name'] ?? 'Employé inconnu'}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                child: Text(resultLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: resultColor)),
              ),
            ],
          ),
          if (p['owner_name'] != null && (p['owner_name'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text('Propriétaire: ${p['owner_name']}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
          if (p['comment'] != null && (p['comment'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Commentaire: ${p['comment']}', style: TextStyle(fontSize: 12, color: Colors.grey[500]), maxLines: 2, overflow: TextOverflow.ellipsis),
            ),
          if (p['manager_notes'] != null && (p['manager_notes'] as String).isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.note, size: 14, color: AppColors.primaryBlue),
                  const SizedBox(width: 6),
                  Expanded(child: Text(p['manager_notes'], style: const TextStyle(fontSize: 11, color: AppColors.primaryBlue))),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showNotesDialog(p),
                  icon: const Icon(Icons.edit_note, size: 16),
                  label: const Text('Notes', style: TextStyle(fontSize: 11)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (managerStatus != 'contacted')
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateManagerStatus(p['id'], 'contacted'),
                    icon: const Icon(Icons.phone, size: 16),
                    label: const Text('Contacter', style: TextStyle(fontSize: 11)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
              if (managerStatus != 'rejected')
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: OutlinedButton.icon(
                    onPressed: () => _updateManagerStatus(p['id'], 'rejected'),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Pas int.', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 6),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
