import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/analytics_service.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  Map<String, dynamic>? _analytics;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() => _loading = true);
    final data = await AnalyticsService.instance.getFullAnalytics();
    setState(() {
      _analytics = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analyse & Performance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _analytics == null
              ? const Center(child: Text('Aucune donnée disponible'))
              : RefreshIndicator(
                  onRefresh: _loadAnalytics,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildOverviewSection(),
                      const SizedBox(height: 16),
                      _buildEmployeePerformanceSection(),
                      const SizedBox(height: 16),
                      _buildSalesSection(),
                      const SizedBox(height: 16),
                      _buildCheckinSection(),
                      const SizedBox(height: 16),
                      _buildCandidateSection(),
                      const SizedBox(height: 16),
                      _buildTeamSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildOverviewSection() {
    final employees = _analytics!['employees'] as Map<String, dynamic>;
    final sales = _analytics!['sales'] as Map<String, dynamic>;
    final checkins = _analytics!['checkins'] as Map<String, dynamic>;
    final candidates = _analytics!['candidates'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Vue d\'ensemble',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildStatCard(
              'Employés actifs',
              '${employees['active']}',
              Icons.people,
              AppColors.primaryGreen,
            ),
            _buildStatCard(
              'Ventes aujourd\'hui',
              _fmtAmount(sales['today_amount'] ?? 0),
              Icons.trending_up,
              AppColors.primaryBlue,
            ),
            _buildStatCard(
              'Pointages en attente',
              '${checkins['pending']}',
              Icons.access_time,
              AppColors.primaryAmber,
            ),
            _buildStatCard(
              'Candidats',
              '${candidates['total']}',
              Icons.person_search,
              AppColors.primaryRed,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmployeePerformanceSection() {
    final employees = _analytics!['employees'] as Map<String, dynamic>;
    final performance = (employees['performance'] as List).cast<Map<String, dynamic>>();

    if (performance.isEmpty) {
      return _buildEmptyCard('Aucun employé actif');
    }

    final maxSales = performance.isNotEmpty
        ? (performance.first['sales_amount'] as int)
        : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Performance des employés',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('${employees['active']} actifs',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.primaryGreen)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...performance.take(10).map((emp) {
          final salesAmount = emp['sales_amount'] as int;
          final salesCount = emp['sales_count'] as int;
          final checkinsApproved = emp['checkins_approved'] as int;
          final checkinsRejected = emp['checkins_rejected'] as int;
          final ratio = maxSales > 0 ? salesAmount / maxSales : 0.0;

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        child: Text(
                          (emp['name'] as String).substring(0, 1).toUpperCase(),
                          style: const TextStyle(
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(emp['name'] as String,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(emp['role'] as String,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[600])),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_fmtAmount(salesAmount),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryGreen)),
                          Text('$salesCount ventes',
                              style: TextStyle(fontSize: 11, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: ratio.toDouble(),
                      backgroundColor: Colors.grey[200],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      minHeight: 6,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildMiniBadge(
                          '✓ $checkinsApproved', AppColors.successGreen),
                      const SizedBox(width: 8),
                      if (checkinsRejected > 0)
                        _buildMiniBadge(
                            '✗ $checkinsRejected', AppColors.primaryRed),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSalesSection() {
    final sales = _analytics!['sales'] as Map<String, dynamic>;
    final plans = sales['plans'] as Map<String, int>? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ventes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Aujourd\'hui',
                '${sales['today_count']} ventes\n${_fmtAmount(sales['today_amount'] ?? 0)}',
                Icons.today,
                AppColors.primaryBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'Ce mois',
                '${sales['month_count']} ventes\n${_fmtAmount(sales['month_amount'] ?? 0)}',
                Icons.calendar_month,
                AppColors.primaryGreen,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildStatCard(
          'Total tout temps',
          '${_fmtAmount(sales['all_time_amount'] ?? 0)}',
          Icons.account_balance_wallet,
          AppColors.primaryAmber,
        ),
        if (plans.isNotEmpty) ...[
          const SizedBox(height: 12),
          const Text('Répartition par plan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: plans.entries.map((e) {
              final color = _planColor(e.key);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Text('${e.key}: ${e.value}',
                    style: TextStyle(color: color, fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildCheckinSection() {
    final checkins = _analytics!['checkins'] as Map<String, dynamic>;
    final total = checkins['total'] as int;
    final pending = checkins['pending'] as int;
    final approved = checkins['approved'] as int;
    final rejected = checkins['rejected'] as int;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Pointages',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (total == 0)
          _buildEmptyCard('Aucun pointage enregistré')
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildCheckinBar('En attente', pending, total,
                      AppColors.primaryAmber),
                  const SizedBox(height: 8),
                  _buildCheckinBar(
                      'Approuvés', approved, total, AppColors.successGreen),
                  const SizedBox(height: 8),
                  _buildCheckinBar(
                      'Rejetés', rejected, total, AppColors.primaryRed),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCheckinBar(String label, int count, int total, Color color) {
    final ratio = total > 0 ? count / total : 0.0;
    return Row(
      children: [
        SizedBox(
            width: 90,
            child: Text(label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500))),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio.toDouble(),
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
            width: 40,
            child: Text('$count',
                textAlign: TextAlign.right,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
      ],
    );
  }

  Widget _buildCandidateSection() {
    final candidates = _analytics!['candidates'] as Map<String, dynamic>;
    final total = candidates['total'] as int;
    final notContacted =
        (candidates['not_contacted'] as List).cast<Map<String, dynamic>>();
    final conversionContact = candidates['conversion_contact'] ?? '0';
    final conversionLive = candidates['conversion_live'] ?? '0';
    final conversionMeeting = candidates['conversion_meeting'] ?? '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Candidats',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        if (total == 0)
          _buildEmptyCard('Aucun candidat enregistré')
        else ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildFunnelStep('Total candidats', total, AppColors.primaryBlue),
                  _buildFunnelStep(
                      'Contactés', '${candidates['contacted_count']}',
                      AppColors.primaryGreen),
                  _buildFunnelStep(
                      'Présentation live', '${candidates['attended_count']}',
                      AppColors.primaryAmber),
                  _buildFunnelStep(
                      'Venue au RDV', '${candidates['come_count']}',
                      AppColors.primaryRed),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildConversionChip('Contact', '$conversionContact%', AppColors.primaryGreen),
                      _buildConversionChip('Live', '$conversionLive%', AppColors.primaryAmber),
                      _buildConversionChip('RDV', '$conversionMeeting%', AppColors.primaryRed),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (notContacted.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.orange[50],
              child: ListTile(
                leading: const Icon(Icons.warning_amber, color: Colors.orange),
                title: Text('${notContacted.length} candidat(s) non contacté(s)',
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(
                  notContacted.take(3).map((c) => c['name'] as String).join(', ') +
                      (notContacted.length > 3 ? '...' : ''),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildTeamSection() {
    final teams = _analytics!['teams'] as Map<String, dynamic>;
    final topPerformers =
        (teams['top_performers'] as List).cast<Map<String, dynamic>>();
    final lowPerformers =
        (teams['low_performers'] as List).cast<Map<String, dynamic>>();
    final avgSales = teams['avg_sales'] as int;
    final suggestions =
        (teams['pairing_suggestions'] as List).cast<Map<String, dynamic>>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Analyse d\'équipe',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Ventes moyennes',
                        style: TextStyle(fontSize: 13)),
                    Text(_fmtAmount(avgSales),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen)),
                  ],
                ),
                const SizedBox(height: 12),
                if (topPerformers.isNotEmpty) ...[
                  const Text('Top performers',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryGreen)),
                  const SizedBox(height: 6),
                  ...topPerformers.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 14, color: AppColors.primaryAmber),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(e['name'] as String,
                                    style: const TextStyle(fontSize: 13))),
                            Text(_fmtAmount(e['total_sales'] as int),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      )),
                ],
                if (lowPerformers.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  const Text('À accompagner',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryRed)),
                  const SizedBox(height: 6),
                  ...lowPerformers.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          children: [
                            const Icon(Icons.trending_down,
                                size: 14, color: AppColors.primaryRed),
                            const SizedBox(width: 6),
                            Expanded(
                                child: Text(e['name'] as String,
                                    style: const TextStyle(fontSize: 13))),
                            Text(_fmtAmount(e['total_sales'] as int),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 13)),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
        ),
        if (suggestions.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text('Suggestions de parrainage',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...suggestions.map((s) => Card(
                color: Colors.blue[50],
                child: ListTile(
                  leading: const Icon(Icons.handshake, color: AppColors.primaryBlue),
                  title: Text('${s['mentor']} → ${s['mentee']}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(s['reason'] as String,
                      style: const TextStyle(fontSize: 12)),
                ),
              )),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(title,
                style: TextStyle(fontSize: 11, color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCard(String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(message, style: TextStyle(color: Colors.grey[500])),
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 10, color: color)),
    );
  }

  Widget _buildFunnelStep(String label, dynamic count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 13))),
          Text('$count',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildConversionChip(String label, String value, Color color) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        Text(label,
            style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ],
    );
  }

  String _fmtAmount(int amount) {
    return '${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} FCFA';
  }

  Color _planColor(String plan) {
    switch (plan.toUpperCase()) {
      case 'MICRO':
        return AppColors.primaryBlue;
      case 'BASIC':
        return AppColors.primaryGreen;
      case 'PREMIUM':
        return AppColors.primaryAmber;
      case 'UNLIMITED':
        return AppColors.primaryRed;
      default:
        return Colors.grey;
    }
  }
}
