import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/currency_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'jour';
  double _revenue = 0;
  int _salesCount = 0;
  double _avgSale = 0;
  double _totalDiscount = 0;
  double _profit = 0;
  List<Map<String, dynamic>> _topProducts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final db = DatabaseHelper.instance;
    final now = DateTime.now();

    DateTime start;
    DateTime end = now;

    switch (_selectedPeriod) {
      case 'jour':
        start = DateTime(now.year, now.month, now.day);
        break;
      case 'semaine':
        start = now.subtract(Duration(days: now.weekday - 1));
        start = DateTime(start.year, start.month, start.day);
        break;
      case 'mois':
        start = DateTime(now.year, now.month, 1);
        break;
      case 'annee':
        start = DateTime(now.year, 1, 1);
        break;
      default:
        start = DateTime(now.year, now.month, now.day);
    }

    final stats = await db.getRevenueByPeriod(start, end);
    final topProducts = await db.getTopProducts(limit: 10, startDate: start.toIso8601String(), endDate: end.toIso8601String());
    final totalCost = await db.getTotalRevenue(start: start, end: end) * 0.6;

    if (mounted) {
      setState(() {
        _revenue = (stats['revenue'] as num?)?.toDouble() ?? 0;
        _salesCount = (stats['sales_count'] as int?) ?? 0;
        _avgSale = (stats['avg_sale'] as num?)?.toDouble() ?? 0;
        _totalDiscount = (stats['total_discount'] as num?)?.toDouble() ?? 0;
        _profit = _revenue - totalCost;
        _topProducts = topProducts;
        _loading = false;
      });
    }
  }

  String _getPeriodLabel() {
    switch (_selectedPeriod) {
      case 'jour': return 'Aujourd\'hui';
      case 'semaine': return 'Cette semaine';
      case 'mois': return 'Ce mois';
      case 'annee': return 'Cette annee';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rapports')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  _buildDetailedStats(),
                  const SizedBox(height: 20),
                  _buildTopProductsSection(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          _buildPeriodButton('jour', 'Jour'),
          _buildPeriodButton('semaine', 'Semaine'),
          _buildPeriodButton('mois', 'Mois'),
          _buildPeriodButton('annee', 'Annee'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String value, String label) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () { setState(() => _selectedPeriod = value); _loadData(); },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Resume - ${_getPeriodLabel()}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(fmtPrice(_revenue),
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('$_salesCount ventes', style: const TextStyle(fontSize: 14, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Panier moyen', fmtPrice(_avgSale), AppColors.accent)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Remises', fmtPrice(_totalDiscount), AppColors.warning)),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard('Benefices', fmtPrice(_profit), AppColors.success)),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTopProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Top produits', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        if (_topProducts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Icon(Icons.shopping_bag_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text('Aucune donnee pour cette periode', style: TextStyle(color: Colors.grey[500])),
              ],
            ),
          )
        else
          ...List.generate(_topProducts.length, (i) {
            final p = _topProducts[i];
            final name = p['product_name'] as String? ?? '';
            final qty = (p['total_quantity'] as num?)?.toInt() ?? 0;
            final revenue = (p['total_revenue'] as num?)?.toDouble() ?? 0;
            final maxRevenue = (_topProducts.first['total_revenue'] as num?)?.toDouble() ?? 1;
            final percentage = maxRevenue > 0 ? (revenue / maxRevenue) : 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('#${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: Colors.grey[200],
                            color: AppColors.primary,
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(fmtPrice(revenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                      Text('$qty u.', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
