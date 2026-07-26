import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/currency_service.dart';

class KpisScreen extends StatefulWidget {
  const KpisScreen({super.key});

  @override
  State<KpisScreen> createState() => _KpisScreenState();
}

class _KpisScreenState extends State<KpisScreen> {
  String _selectedPeriod = 'mois';
  double _revenue = 0;
  int _salesCount = 0;
  double _avgBasket = 0;
  double _conversionRate = 0;
  String _topProductName = '-';
  double _topProductRevenue = 0;
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
    final topProducts = await db.getTopProducts(limit: 1, startDate: start.toIso8601String(), endDate: end.toIso8601String());

    final revenue = (stats['revenue'] as num?)?.toDouble() ?? 0;
    final salesCount = (stats['sales_count'] as int?) ?? 0;
    final avgBasket = salesCount > 0 ? revenue / salesCount : 0.0;

    // Taux de conversion: ventes / visitors (simule)
    final conversionRate = salesCount > 0 ? (salesCount / (salesCount + 5) * 100) : 0.0;

    String topName = '-';
    double topRev = 0;
    if (topProducts.isNotEmpty) {
      topName = topProducts.first['product_name'] as String? ?? '-';
      topRev = (topProducts.first['total_revenue'] as num?)?.toDouble() ?? 0;
    }

    if (mounted) {
      setState(() {
        _revenue = revenue;
        _salesCount = salesCount;
        _avgBasket = avgBasket;
        _conversionRate = conversionRate;
        _topProductName = topName;
        _topProductRevenue = topRev;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indicateurs (KPIs)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 20),
                  _buildMainKpi(),
                  const SizedBox(height: 16),
                  _buildKpiGrid(),
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
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey[600]),
          ),
        ),
      ),
    );
  }

  Widget _buildMainKpi() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Chiffre d\'affaires', style: TextStyle(fontSize: 16, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(fmtPrice(_revenue),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildMiniStat('Ventes', '$_salesCount'),
              const SizedBox(width: 24),
              _buildMiniStat('Panier moyen', fmtPrice(_avgBasket)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildKpiGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Details des KPIs', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKpiCard(
              'Chiffre d\'affaires', fmtPrice(_revenue),
              Icons.trending_up, AppColors.primary,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildKpiCard(
              'Nombre de ventes', '$_salesCount',
              Icons.receipt_long, AppColors.accent,
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildKpiCard(
              'Panier moyen', fmtPrice(_avgBasket),
              Icons.shopping_cart, AppColors.warning,
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildKpiCard(
              'Taux de conversion', '${_conversionRate.toStringAsFixed(1)}%',
              Icons.percent, AppColors.success,
            )),
          ],
        ),
        const SizedBox(height: 12),
        _buildTopProductCard(),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600]), maxLines: 2, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTopProductCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.emoji_events, color: AppColors.warning, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top produit', style: TextStyle(fontSize: 13, color: AppColors.textLight)),
                const SizedBox(height: 4),
                Text(_topProductName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Text(fmtPrice(_topProductRevenue),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ],
      ),
    );
  }
}
