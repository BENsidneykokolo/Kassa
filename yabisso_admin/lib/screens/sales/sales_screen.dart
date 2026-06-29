import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app_theme.dart';
import '../../providers/providers.dart';

class SalesScreen extends ConsumerStatefulWidget {
  const SalesScreen({super.key});
  @override
  ConsumerState<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends ConsumerState<SalesScreen> {
  String _filter = 'all';
  static const _primary = AppColors.primaryGreen;

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(allSalesProvider);
    final todayRevenueAsync = ref.watch(todayRevenueProvider);
    final monthlyRevenueAsync = ref.watch(monthlyRevenueProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ventes'),
        backgroundColor: _primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: Column(
        children: [
          _buildSummaryHeader(todayRevenueAsync, monthlyRevenueAsync),
          _buildFilterTabs(),
          Expanded(
            child: salesAsync.when(
              data: (sales) {
                final filtered = _applyFilter(sales);
                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 60, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text('Aucune vente',
                            style: TextStyle(color: Colors.grey[500], fontSize: 16)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (ctx, i) => _buildSaleCard(filtered[i]),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Erreur: $e')),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildSummaryHeader(AsyncValue<int> todayRevenue, AsyncValue<int> monthlyRevenue) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: _primary.withValues(alpha: 0.05),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              'Aujourd\'hui',
              todayRevenue.when(data: (v) => _formatPrice(v), loading: () => '...', error: (_, __) => '0 FCFA'),
              Icons.today,
              const Color(0xFFE3F2FD),
              AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              'Ce mois',
              monthlyRevenue.when(data: (v) => _formatPrice(v), loading: () => '...', error: (_, __) => '0 FCFA'),
              Icons.calendar_month,
              const Color(0xFFFFF3E0),
              AppColors.primaryAmber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600]), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    final tabs = [
      {'key': 'all', 'label': 'Toutes', 'icon': Icons.all_inclusive},
      {'key': 'today', 'label': 'Aujourd\'hui', 'icon': Icons.today},
      {'key': 'week', 'label': 'Cette semaine', 'icon': Icons.date_range},
      {'key': 'month', 'label': 'Ce mois', 'icon': Icons.calendar_month},
    ];
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) {
          final tab = tabs[i];
          final selected = _filter == tab['key'];
          return FilterChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab['icon'] as IconData, size: 16,
                    color: selected ? Colors.white : _primary),
                const SizedBox(width: 4),
                Text(tab['label'] as String),
              ],
            ),
            selected: selected,
            selectedColor: _primary,
            backgroundColor: Colors.white,
            labelStyle: TextStyle(color: selected ? Colors.white : _primary, fontSize: 12),
            onSelected: (_) => setState(() => _filter = tab['key']! as String),
          );
        },
      ),
    );
  }

  List<dynamic> _applyFilter(List<dynamic> sales) {
    final now = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);
    final weekAgo = now.subtract(const Duration(days: 7)).toIso8601String().substring(0, 10);
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    switch (_filter) {
      case 'today':
        return sales.where((s) => s.createdAt.startsWith(today)).toList();
      case 'week':
        return sales.where((s) => s.createdAt.compareTo(weekAgo) >= 0).toList();
      case 'month':
        return sales.where((s) => s.createdAt.compareTo(monthStart) >= 0).toList();
      default:
        return sales;
    }
  }

  Widget _buildSaleCard(dynamic sale) {
    final planColors = {
      'starter': AppColors.primaryBlue,
      'pro': AppColors.primaryAmber,
      'premium': _primary,
      'enterprise': AppColors.primaryRed,
    };
    final planColor = planColors[sale.plan] ?? AppColors.primaryBlue;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  sale.employeeName.isNotEmpty ? sale.employeeName[0].toUpperCase() : '?',
                  style: TextStyle(color: _primary, fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(sale.employeeName,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.store, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(sale.shopName,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: planColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(sale.plan.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: planColor)),
                ),
                const SizedBox(height: 6),
                Text(sale.formattedAmount,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF00694C))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA';
  }

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home, 'Dashboard', false, () => context.go('/')),
          _buildNavItem(Icons.people, 'Employés', false, () => context.push('/employees')),
          _buildNavItem(Icons.trending_up, 'Ventes', true, () {}),
          _buildNavItem(Icons.vpn_key, 'Vouchers', false, () => context.push('/vouchers')),
          _buildNavItem(Icons.smart_toy, 'IA', false, () => context.push('/ai-ceo')),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? _primary : Colors.grey, size: 24),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, color: isActive ? _primary : Colors.grey, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
