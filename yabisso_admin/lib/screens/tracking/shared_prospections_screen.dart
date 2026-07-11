import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class SharedProspectionsScreen extends ConsumerStatefulWidget {
  const SharedProspectionsScreen({super.key});
  @override
  ConsumerState<SharedProspectionsScreen> createState() => _SharedProspectionsScreenState();
}

class _SharedProspectionsScreenState extends ConsumerState<SharedProspectionsScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(sharedProspectionsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Démarchage des Employés'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteData,
            tooltip: 'Coller depuis WhatsApp',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: reportsAsync.when(
              data: (reports) {
                final filtered = _filter == 'all'
                    ? reports
                    : reports.where((r) => r['status'] == _filter).toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.store_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucun démarchage importé', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Collez les démarchages partagés via WhatsApp\npuis cliquez "Importer"',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(sharedProspectionsProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) => _buildReportCard(filtered[i]),
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _chip('all', 'Tous', Colors.grey),
          const SizedBox(width: 8),
          _chip('imported', 'Importé', AppColors.successGreen),
          const SizedBox(width: 8),
          _chip('viewed', 'Consulté', AppColors.primaryBlue),
        ],
      ),
    );
  }

  Widget _chip(String value, String label, Color color) {
    final isActive = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: isActive ? color : Colors.grey[600],
        )),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    final status = report['status'] ?? 'imported';
    final statusColor = status == 'viewed' ? AppColors.primaryBlue : AppColors.successGreen;
    final total = report['total'] ?? 0;
    final interesses = report['interesses'] ?? 0;
    final pasInteresses = report['pas_interesses'] ?? 0;
    final aRappeler = report['a_rappeler'] ?? 0;
    final empName = report['employee_name'] ?? '';

    return GestureDetector(
      onTap: () => _showReportDetail(report),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.1),
                  child: Text(
                    empName.isNotEmpty ? empName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(empName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(report['date'] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(
                    status == 'viewed' ? 'Consulté' : 'Importé',
                    style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _statBadge(Icons.store, '$total visites', AppColors.primaryBlue),
                const SizedBox(width: 8),
                _statBadge(Icons.check_circle, '$interesses intéressés', AppColors.successGreen),
                const SizedBox(width: 8),
                _statBadge(Icons.cancel, '$pasInteresses pas int.', AppColors.primaryRed),
                const SizedBox(width: 8),
                _statBadge(Icons.schedule, '$aRappeler à rappeler', AppColors.primaryAmber),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBadge(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Future<void> _showReportDetail(Map<String, dynamic> report) async {
    final db = DatabaseHelper.instance;
    await db.update('shared_prospections_reports', {'status': 'viewed'}, report['id']);
    ref.invalidate(sharedProspectionsProvider);

    final prospectionsData = jsonDecode(report['prospections_json'] ?? '[]') as List;

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (ctx, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.primaryAmber.withValues(alpha: 0.1),
                    child: Text(
                      (report['employee_name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primaryAmber, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report['employee_name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(report['date'] ?? '', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _summaryCard('Total', '${report['total'] ?? 0}', AppColors.primaryBlue),
                  const SizedBox(width: 8),
                  _summaryCard('Intéressés', '${report['interesses'] ?? 0}', AppColors.successGreen),
                  const SizedBox(width: 8),
                  _summaryCard('Pas int.', '${report['pas_interesses'] ?? 0}', AppColors.primaryRed),
                  const SizedBox(width: 8),
                  _summaryCard('À rappeler', '${report['a_rappeler'] ?? 0}', AppColors.primaryAmber),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Détail des démarchages', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: prospectionsData.length,
                  itemBuilder: (ctx, i) {
                    final p = prospectionsData[i];
                    final result = p['result'] ?? '';
                    Color resultColor;
                    switch (result) {
                      case 'Interesse':
                        resultColor = AppColors.successGreen;
                        break;
                      case 'Pas interesse':
                        resultColor = AppColors.primaryRed;
                        break;
                      default:
                        resultColor = AppColors.primaryAmber;
                    }
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: resultColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${i + 1}', style: TextStyle(color: resultColor, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p['shop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${p['category'] ?? ''} • ${p['owner_name'] ?? ''}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                if (p['address'] != null && (p['address'] as String).isNotEmpty)
                                  Text(p['address'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: resultColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(6)),
                                child: Text(result, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: resultColor)),
                              ),
                              if (p['visit_date'] != null && (p['visit_date'] as String).isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(p['visit_date'], style: const TextStyle(fontSize: 10, color: Color(0xFF999999))),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }

  Future<void> _pasteData() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      if (data?.text != null && data!.text!.isNotEmpty) {
        _parseAndImport(data.text!);
      } else {
        _showPasteDialog();
      }
    } catch (_) {
      _showPasteDialog();
    }
  }

  void _showPasteDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Coller les démarchages'),
        content: TextField(
          controller: controller,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'Collez le rapport de démarchage partagé via WhatsApp ici...\n\nCommence par === YABISSO_DEMARCHAGE ===',
            filled: true, fillColor: const Color(0xFFF7F8FA),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _parseAndImport(controller.text);
            },
            child: const Text('Importer'),
          ),
        ],
      ),
    );
  }

  Future<void> _parseAndImport(String text) async {
    if (!text.contains('YABISSO_DEMARCHAGE')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format non reconnu. Collez un rapport YABISSO_DEMARCHAGE.'), backgroundColor: AppColors.primaryRed),
        );
      }
      return;
    }

    final empName = _extract(text, 'EMP_NAME:');
    final empPhone = _extract(text, 'EMP_PHONE:');
    final total = int.tryParse(_extract(text, 'TOTAL:')) ?? 0;
    final interesses = int.tryParse(_extract(text, 'INTERESSES:')) ?? 0;
    final pasInteresses = int.tryParse(_extract(text, 'PAS_INTERESSES:')) ?? 0;
    final aRappeler = int.tryParse(_extract(text, 'A_RAPPELER:')) ?? 0;

    final prospectionsJson = <Map<String, dynamic>>[];
    final detailStart = text.indexOf('---DETAIL_START---');
    final detailEnd = text.indexOf('---DETAIL_END---');
    if (detailStart >= 0 && detailEnd > detailStart) {
      final detailSection = text.substring(detailStart + 16, detailEnd);
      for (final line in detailSection.split('\n')) {
        if (line.startsWith('DEMARCHAGE|')) {
          final parts = line.substring(11).split('|');
          if (parts.length >= 8) {
            prospectionsJson.add({
              'shop_name': parts[0],
              'category': parts[1],
              'owner_name': parts[2],
              'owner_phone': parts[3],
              'address': parts[4],
              'result': parts[5],
              'comment': parts[6],
              'visit_date': parts[7],
            });
          }
        }
      }
    }

    if (empName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données incomplètes. Vérifiez le format.'), backgroundColor: AppColors.primaryRed),
        );
      }
      return;
    }

    final db = DatabaseHelper.instance;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final existing = await db.getAll('shared_prospections_reports',
      where: 'employee_name = ? AND date = ?',
      whereArgs: [empName, today],
    );
    if (existing.isNotEmpty) {
      await db.update('shared_prospections_reports', {
        'employee_phone': empPhone,
        'total': total,
        'interesses': interesses,
        'pas_interesses': pasInteresses,
        'a_rappeler': aRappeler,
        'prospections_json': jsonEncode(prospectionsJson),
        'status': 'imported',
      }, existing.first['id']);
    } else {
      await db.insert('shared_prospections_reports', {
        'id': const Uuid().v4(),
        'employee_id': '',
        'employee_name': empName,
        'employee_phone': empPhone,
        'date': today,
        'total': total,
        'interesses': interesses,
        'pas_interesses': pasInteresses,
        'a_rappeler': aRappeler,
        'prospections_json': jsonEncode(prospectionsJson),
        'status': 'imported',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    ref.invalidate(sharedProspectionsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Démarchages de $empName importés: $total visite(s)'),
          backgroundColor: AppColors.successGreen,
        ),
      );
    }
  }

  String _extract(String text, String key) {
    final regex = RegExp('$key(.+)');
    final match = regex.firstMatch(text);
    return match?.group(1)?.trim() ?? '';
  }
}
