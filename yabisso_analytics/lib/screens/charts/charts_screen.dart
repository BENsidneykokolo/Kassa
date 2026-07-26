import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../services/currency_service.dart';

class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  String _selectedPeriod = 'semaine';
  List<Map<String, dynamic>> _salesTrend = [];
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _categorySales = [];
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
    final days = _selectedPeriod == 'jour' ? 1 : _selectedPeriod == 'semaine' ? 7 : _selectedPeriod == 'mois' ? 30 : 365;
    final start = now.subtract(Duration(days: days));
    final end = now;

    final trend = await db.getSalesTrend(days: days);
    final top = await db.getTopProducts(limit: 10, startDate: start.toIso8601String(), endDate: end.toIso8601String());
    final categories = await db.getSalesByCategory(startDate: start.toIso8601String(), endDate: end.toIso8601String());

    if (mounted) {
      setState(() {
        _salesTrend = trend;
        _topProducts = top;
        _categorySales = categories;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graphiques'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (v) { setState(() => _selectedPeriod = v); _loadData(); },
            icon: const Icon(Icons.filter_list),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'jour', child: Text('Aujourd\'hui')),
              const PopupMenuItem(value: 'semaine', child: Text('Cette semaine')),
              const PopupMenuItem(value: 'mois', child: Text('Ce mois')),
              const PopupMenuItem(value: 'annee', child: Text('Cette annee')),
            ],
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Evolution des ventes'),
                  const SizedBox(height: 8),
                  _buildLineChartCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Top produits'),
                  const SizedBox(height: 8),
                  _buildBarChartCard(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Ventes par categorie'),
                  const SizedBox(height: 8),
                  _buildPieChartCard(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark));
  }

  Widget _buildLineChartCard() {
    if (_salesTrend.isEmpty) {
      return _buildEmptyCard('Aucune donnee de ventes disponible');
    }

    final spots = <FlSpot>[];
    final labels = <String>[];
    for (var i = 0; i < _salesTrend.length; i++) {
      spots.add(FlSpot(i.toDouble(), (_salesTrend[i]['revenue'] as num).toDouble()));
      final day = _salesTrend[i]['day'] as String;
      labels.add(day.length >= 10 ? day.substring(8, 10) : day);
    }

    final maxY = spots.fold<double>(0, (max, spot) => spot.y > max ? spot.y : max);
    final interval = maxY > 0 ? (maxY / 4).ceilToDouble() : 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      height: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Ventes quotidiennes', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(fmtPrice(spots.fold<double>(0, (s, e) => s + e.y)),
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: interval,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[200]!,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(fmtPriceCompact(value), style: TextStyle(fontSize: 10, color: Colors.grey[500]));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 20,
                      interval: _salesTrend.length > 14 ? (_salesTrend.length / 7).ceilToDouble() : 1,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < labels.length) {
                          return Text(labels[idx], style: TextStyle(fontSize: 10, color: Colors.grey[500]));
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    curveSmoothness: 0.3,
                    color: AppColors.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.3),
                          AppColors.primary.withValues(alpha: 0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                    dotData: FlDotData(
                      show: spots.length <= 7,
                      getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeColor: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final idx = spot.x.toInt();
                        final label = idx >= 0 && idx < labels.length ? labels[idx] : '';
                        return LineTooltipItem(
                          '$label\n${fmtPrice(spot.y)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChartCard() {
    if (_topProducts.isEmpty) {
      return _buildEmptyCard('Aucune donnee de produits disponible');
    }

    final bars = <BarChartGroupData>[];
    final maxY = _topProducts.fold<double>(0, (max, p) {
      final rev = (p['total_revenue'] as num?)?.toDouble() ?? 0;
      return rev > max ? rev : max;
    });

    for (var i = 0; i < _topProducts.length && i < 8; i++) {
      final revenue = (_topProducts[i]['total_revenue'] as num?)?.toDouble() ?? 0;
      bars.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: revenue,
            color: i % 2 == 0 ? AppColors.primary : AppColors.primaryLight,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          ),
        ],
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      height: 300,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Produits les plus vendus', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          Expanded(
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY > 0 ? maxY * 1.2 : 100,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final name = _topProducts[group.x]['product_name'] as String? ?? '';
                      return BarTooltipItem(
                        '$name\n${fmtPrice(rod.toY)}',
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        return Text(fmtPriceCompact(value), style: TextStyle(fontSize: 10, color: Colors.grey[500]));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx >= 0 && idx < _topProducts.length) {
                          final name = _topProducts[idx]['product_name'] as String? ?? '';
                          final shortName = name.length > 8 ? name.substring(0, 8) + '..' : name;
                          return Text(shortName, style: TextStyle(fontSize: 9, color: Colors.grey[500]), rotation: 0);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChartCard() {
    if (_categorySales.isEmpty) {
      return _buildEmptyCard('Aucune donnee de categories disponible');
    }

    final totalRevenue = _categorySales.fold<double>(0, (sum, c) => sum + ((c['total_revenue'] as num?)?.toDouble() ?? 0));
    final colors = [
      AppColors.chartPie1, AppColors.chartPie2, AppColors.chartPie3,
      AppColors.chartPie4, AppColors.chartPie5,
    ];

    final sections = <PieChartSectionData>[];
    for (var i = 0; i < _categorySales.length && i < 5; i++) {
      final revenue = (_categorySales[i]['total_revenue'] as num?)?.toDouble() ?? 0;
      final percentage = totalRevenue > 0 ? (revenue / totalRevenue * 100) : 0;
      final category = _categorySales[i]['category'] as String? ?? 'Autre';
      sections.add(PieChartSectionData(
        value: revenue,
        title: '${percentage.toStringAsFixed(0)}%',
        color: colors[i % colors.length],
        radius: 80,
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Repartition par categorie', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                sections: sections,
                centerSpaceRadius: 40,
                sectionsSpace: 3,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_categorySales.length.clamp(0, 5), (i) {
            final revenue = (_categorySales[i]['total_revenue'] as num?)?.toDouble() ?? 0;
            final category = _categorySales[i]['category'] as String? ?? 'Autre';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(category, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Text(fmtPrice(revenue), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textDark)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          Icon(Icons.bar_chart, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(fontSize: 14, color: Colors.grey[500]), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
