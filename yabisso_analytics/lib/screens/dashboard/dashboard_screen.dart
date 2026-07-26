import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/app_theme.dart';
import '../../database/database_helper.dart';
import '../../providers/providers.dart';
import '../../services/currency_service.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  double _todayRevenue = 0;
  int _todaySales = 0;
  double _avgBasket = 0;
  double _monthRevenue = 0;
  String _storeName = 'Yabisso Analytics';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final db = DatabaseHelper.instance;
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final startOfMonth = DateTime(now.year, now.month, 1);

    final todayRevenue = await db.getTotalRevenue(start: startOfDay, end: endOfDay);
    final todaySales = await db.getTotalSalesCount(start: startOfDay, end: endOfDay);
    final monthRevenue = await db.getTotalRevenue(start: startOfMonth, end: endOfDay);
    final avgBasket = todaySales > 0 ? todayRevenue / todaySales : 0.0;

    final prefs = await SharedPreferences.getInstance();
    final storeName = prefs.getString('store_name') ?? 'Yabisso Analytics';

    if (mounted) {
      setState(() {
        _todayRevenue = todayRevenue;
        _todaySales = todaySales;
        _avgBasket = avgBasket;
        _monthRevenue = monthRevenue;
        _storeName = storeName;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildKpiRow(),
                    const SizedBox(height: 20),
                    _buildQuickActions(),
                    const SizedBox(height: 20),
                    _buildRecentActivity(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          switch (index) {
            case 0: break;
            case 1: context.push('/charts'); break;
            case 2: context.push('/reports'); break;
            case 3: context.push('/kpis'); break;
            case 4: context.push('/settings'); break;
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'Accueil'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'Graphiques'),
          NavigationDestination(icon: Icon(Icons.assessment_outlined), selectedIcon: Icon(Icons.assessment), label: 'Rapports'),
          NavigationDestination(icon: Icon(Icons.speed_outlined), selectedIcon: Icon(Icons.speed), label: 'KPIs'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Parametres'),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Bonjour !',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              Text(_storeName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.notifications_outlined, color: AppColors.primary),
        ),
      ],
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        Expanded(child: _buildKpiCard(
          'CA Aujourd\'hui', fmtPrice(_todayRevenue),
          Icons.trending_up, AppColors.primary,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard(
          'Ventes', _todaySales.toString(),
          Icons.receipt_long, AppColors.accent,
        )),
        const SizedBox(width: 12),
        Expanded(child: _buildKpiCard(
          'Panier Moyen', fmtPrice(_avgBasket),
          Icons.shopping_cart_outlined, AppColors.warning,
        )),
      ],
    );
  }

  Widget _buildKpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Actions rapides', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(
              'Graphiques', Icons.bar_chart, AppColors.primary,
              () => context.push('/charts'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(
              'Rapports', Icons.assessment, AppColors.accent,
              () => context.push('/reports'),
            )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildActionCard(
              'KPIs', Icons.speed, AppColors.warning,
              () => context.push('/kpis'),
            )),
            const SizedBox(width: 12),
            Expanded(child: _buildActionCard(
              'Parametres', Icons.settings, AppColors.primaryDark,
              () => context.push('/settings'),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Resume du mois', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            Text(fmtPrice(_monthRevenue), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chiffre d\'affaires mensuel',
                  style: TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(height: 8),
              Text(fmtPrice(_monthRevenue),
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              const Text('Continuez vos efforts !',
                  style: TextStyle(fontSize: 13, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }
}
