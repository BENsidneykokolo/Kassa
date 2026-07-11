import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/database_helper.dart';

class SharedSalesScreen extends ConsumerStatefulWidget {
  const SharedSalesScreen({super.key});
  @override
  ConsumerState<SharedSalesScreen> createState() => _SharedSalesScreenState();
}

class _SharedSalesScreenState extends ConsumerState<SharedSalesScreen> {
  String _filter = 'all';

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(sharedSalesReportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ventes des Employés'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.content_paste),
            onPressed: _pasteSalesData,
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
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucune vente importée', style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(
                          'Collez les ventes partagées via WhatsApp\npuis cliquez "Importer"',
                          style: TextStyle(color: Colors.grey[400], fontSize: 12),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(sharedSalesReportsProvider),
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
    final totalAmount = report['total_amount'] ?? 0;
    final salesCount = report['sales_count'] ?? 0;
    final date = report['date'] ?? '';
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
                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.1),
                  child: Text(
                    empName.isNotEmpty ? empName[0].toUpperCase() : '?',
                    style: const TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(empName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      Text(date, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
                _statBadge(Icons.shopping_cart, '$salesCount ventes', AppColors.primaryGreen),
                const SizedBox(width: 8),
                _statBadge(Icons.attach_money, '${_formatPrice(totalAmount)} FCFA', AppColors.primaryAmber),
                const SizedBox(width: 8),
                if (report['total_commission'] != null && (report['total_commission'] as int) > 0)
                  _statBadge(Icons.percent, '+${_formatPrice(report['total_commission'])} FCFA', AppColors.primaryBlue),
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
    await db.update('shared_sales_reports', {'status': 'viewed'}, report['id']);
    ref.invalidate(sharedSalesReportsProvider);

    final salesData = jsonDecode(report['sales_json'] ?? '[]') as List;

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
                    backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                    child: Text(
                      (report['employee_name'] ?? '?')[0].toUpperCase(),
                      style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
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
                  _summaryCard('Ventes', '${report['sales_count'] ?? 0}', AppColors.primaryGreen),
                  const SizedBox(width: 8),
                  _summaryCard('Total', '${_formatPrice(report['total_amount'] ?? 0)} F', AppColors.primaryAmber),
                  const SizedBox(width: 8),
                  _summaryCard('Salaire', '${_formatPrice(report['salaire'] ?? 0)} F', AppColors.primaryBlue),
                ],
              ),
              if (report['total_commission'] != null && (report['total_commission'] as int) > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Text('Commissions: ${_formatPrice(report['total_commission'])} FCFA',
                        style: const TextStyle(color: AppColors.successGreen, fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              const Text('Détail des ventes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: salesData.length,
                  itemBuilder: (ctx, i) {
                    final sale = salesData[i];
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
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${i + 1}', style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(sale['shop_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                const SizedBox(height: 2),
                                Text('${sale['owner_name'] ?? ''} • ${sale['plan'] ?? ''}',
                                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                if (sale['owner_phone'] != null && (sale['owner_phone'] as String).isNotEmpty)
                                  Text(sale['owner_phone'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('${_formatPrice(sale['amount'] ?? 0)} F', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(sale['time'] ?? '', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                              if ((sale['commission'] ?? 0) > 0)
                                Text('+${_formatPrice(sale['commission'])} F', style: const TextStyle(fontSize: 11, color: AppColors.successGreen, fontWeight: FontWeight.w600)),
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

  Future<void> _pasteSalesData() async {
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
        title: const Text('Coller les ventes'),
        content: TextField(
          controller: controller,
          maxLines: 12,
          decoration: InputDecoration(
            hintText: 'Collez le rapport de ventes partagé via WhatsApp ici...\n\nCommence par === YABISSO_VENTES ===',
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
    if (!text.contains('YABISSO_VENTES')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Format non reconnu. Collez un rapport Yabisso.'), backgroundColor: AppColors.primaryRed),
        );
      }
      return;
    }

    final empId = _extract(text, 'EMP_ID:');
    final empName = _extract(text, 'EMP_NAME:');
    final empPhone = _extract(text, 'EMP_PHONE:');
    final date = _extract(text, 'DATE:');
    final dateDisplay = _extract(text, 'DATE_DISPLAY:');
    final totalCount = int.tryParse(_extract(text, 'VENTES_COUNT:')) ?? 0;
    final totalAmount = int.tryParse(_extract(text, 'TOTAL_AMOUNT:')) ?? 0;
    final totalCommission = int.tryParse(_extract(text, 'TOTAL_COMMISSION:')) ?? 0;
    final salaire = int.tryParse(_extract(text, 'SALAIRE:')) ?? 0;

    final salesJson = <Map<String, dynamic>>[];
    final detailStart = text.indexOf('---DETAIL_START---');
    final detailEnd = text.indexOf('---DETAIL_END---');
    if (detailStart >= 0 && detailEnd > detailStart) {
      final detailSection = text.substring(detailStart + 16, detailEnd);
      for (final line in detailSection.split('\n')) {
        if (line.startsWith('VENTE|')) {
          final parts = line.substring(6).split('|');
          if (parts.length >= 7) {
            salesJson.add({
              'shop_name': parts[0],
              'owner_name': parts[1],
              'owner_phone': parts[2],
              'plan': parts[3],
              'amount': int.tryParse(parts[4]) ?? 0,
              'commission': int.tryParse(parts[5]) ?? 0,
              'time': parts[6],
            });
          }
        }
      }
    }

    if (empId.isEmpty || empName.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Données incomplètes. Vérifiez le format.'), backgroundColor: AppColors.primaryRed),
        );
      }
      return;
    }

    final db = DatabaseHelper.instance;
    final existing = await db.getAll('shared_sales_reports',
      where: 'employee_id = ? AND date = ?',
      whereArgs: [empId, date],
    );
    if (existing.isNotEmpty) {
      await db.update('shared_sales_reports', {
        'employee_name': empName,
        'sales_count': totalCount,
        'total_amount': totalAmount,
        'total_commission': totalCommission,
        'salaire': salaire,
        'sales_json': jsonEncode(salesJson),
        'status': 'imported',
      }, existing.first['id']);
    } else {
      await db.insert('shared_sales_reports', {
        'id': const Uuid().v4(),
        'employee_id': empId,
        'employee_name': empName,
        'employee_phone': empPhone,
        'date': date,
        'date_display': dateDisplay,
        'sales_count': totalCount,
        'total_amount': totalAmount,
        'total_commission': totalCommission,
        'salaire': salaire,
        'sales_json': jsonEncode(salesJson),
        'status': 'imported',
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    ref.invalidate(sharedSalesReportsProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ventes de $empName importées: ${salesJson.length} vente(s), ${_formatPrice(totalAmount)} FCFA'),
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

  String _formatPrice(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
