import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_theme.dart';
import '../../services/database_helper.dart';

class DailyReportsAdminScreen extends StatefulWidget {
  const DailyReportsAdminScreen({super.key});

  @override
  State<DailyReportsAdminScreen> createState() => _DailyReportsAdminScreenState();
}

class _DailyReportsAdminScreenState extends State<DailyReportsAdminScreen> {
  List<Map<String, dynamic>> _reports = [];
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredReports = [];
  String? _selectedEmployeeId;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final reports = await DatabaseHelper.instance.getAll('daily_reports', orderBy: 'date DESC');
      final employees = await DatabaseHelper.instance.getAll('employees');
      setState(() {
        _reports = reports;
        _employees = employees;
        _filteredReports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement: $e')),
        );
      }
    }
  }

  void _filterReports() {
    setState(() {
      _filteredReports = _reports.where((report) {
        final reportEmployeeId = report['employee_id'].toString();
        final reportDateStr = report['date'] ?? '';

        bool matchesEmployee = _selectedEmployeeId == null ||
            reportEmployeeId == _selectedEmployeeId.toString();

        bool matchesDateRange = true;
        if (reportDateStr.isNotEmpty) {
          try {
            final reportDate = DateTime.parse(reportDateStr);
            if (_startDate != null) {
              matchesDateRange = matchesDateRange &&
                  !reportDate.isBefore(_startDate!);
            }
            if (_endDate != null) {
              final endOfDay = DateTime(
                _endDate!.year,
                _endDate!.month,
                _endDate!.day,
                23, 59, 59,
              );
              matchesDateRange = matchesDateRange &&
                  !reportDate.isAfter(endOfDay);
            }
          } catch (_) {
            matchesDateRange = true;
          }
        }

        return matchesEmployee && matchesDateRange;
      }).toList();
    });
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      locale: const Locale('fr', 'FR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryGreen,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
      _filterReports();
    }
  }

  int _totalShops() => _filteredReports.fold(0, (sum, r) => sum + ((r['shops_visited'] ?? 0) as int));
  int _totalDemos() => _filteredReports.fold(0, (sum, r) => sum + ((r['demonstrations'] ?? 0) as int));
  int _totalSubscriptions() => _filteredReports.fold(0, (sum, r) => sum + ((r['subscriptions'] ?? 0) as int));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Rapports quotidiens',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedEmployeeId,
                  decoration: InputDecoration(
                    labelText: 'Filtrer par employé',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    prefixIcon: const Icon(Icons.person, color: AppColors.primaryGreen),
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Tous les employés'),
                    ),
                    ..._employees.map<DropdownMenuItem<String>>((emp) {
                      return DropdownMenuItem<String>(
                        value: emp['id'].toString(),
                        child: Text(emp['name'] ?? 'Sans nom'),
                      );
                    }),
                  ],
                  onChanged: (val) {
                    setState(() => _selectedEmployeeId = val);
                    _filterReports();
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _DateButton(
                        label: _startDate != null
                            ? _formatDate(_startDate!.toIso8601String())
                            : 'Date début',
                        icon: Icons.calendar_today,
                        onTap: () => _pickDate(isStart: true),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _DateButton(
                        label: _endDate != null
                            ? _formatDate(_endDate!.toIso8601String())
                            : 'Date fin',
                        icon: Icons.calendar_today,
                        onTap: () => _pickDate(isStart: false),
                      ),
                    ),
                    if (_startDate != null || _endDate != null) ...[
                      const SizedBox(width: 6),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _startDate = null;
                            _endDate = null;
                          });
                          _filterReports();
                        },
                        icon: const Icon(Icons.clear, color: Colors.grey, size: 20),
                        tooltip: 'Effacer les dates',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_filteredReports.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  _StatChip(
                    label: '${_filteredReports.length} rapports',
                    icon: Icons.description,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '$_totalShops() magasins',
                    icon: Icons.store,
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '$_totalDemos() démos',
                    icon: Icons.present_to_all,
                    color: AppColors.primaryAmber,
                  ),
                  const SizedBox(width: 8),
                  _StatChip(
                    label: '$_totalSubscriptions() abonnements',
                    icon: Icons.card_membership,
                    color: AppColors.primaryRed,
                  ),
                ],
              ),
            ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
                : _filteredReports.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Aucun rapport',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Les rapports quotidiens des employés apparaîtront ici',
                              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadData,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _filteredReports.length,
                          itemBuilder: (context, index) {
                            final report = _filteredReports[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 10),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.1),
                                          child: const Icon(Icons.person, color: AppColors.primaryGreen, size: 20),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                report['employee_name'] ?? 'Employé inconnu',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: AppColors.textDark,
                                                ),
                                              ),
                                              Text(
                                                _formatDate(report['date']),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        _MetricBadge(
                                          label: '${report['shops_visited'] ?? 0}',
                                          sublabel: 'Magasins',
                                          color: AppColors.primaryGreen,
                                        ),
                                        const SizedBox(width: 8),
                                        _MetricBadge(
                                          label: '${report['demonstrations'] ?? 0}',
                                          sublabel: 'Démos',
                                          color: AppColors.primaryAmber,
                                        ),
                                        const SizedBox(width: 8),
                                        _MetricBadge(
                                          label: '${report['subscriptions'] ?? 0}',
                                          sublabel: 'Abonnements',
                                          color: AppColors.primaryBlue,
                                        ),
                                        const SizedBox(width: 8),
                                        _MetricBadge(
                                          label: '${report['sales_count'] ?? 0}',
                                          sublabel: 'Ventes',
                                          color: AppColors.primaryRed,
                                        ),
                                      ],
                                    ),
                                    if ((report['difficulties'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 10),
                                      _DetailRow(
                                        icon: Icons.warning_amber,
                                        label: 'Difficultés',
                                        value: report['difficulties'] ?? '',
                                        color: AppColors.primaryAmber,
                                      ),
                                    ],
                                    if ((report['suggestions'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      _DetailRow(
                                        icon: Icons.lightbulb_outline,
                                        label: 'Suggestions',
                                        value: report['suggestions'] ?? '',
                                        color: AppColors.primaryBlue,
                                      ),
                                    ],
                                    if ((report['general_notes'] ?? '').toString().isNotEmpty) ...[
                                      const SizedBox(height: 6),
                                      _DetailRow(
                                        icon: Icons.notes,
                                        label: 'Notes',
                                        value: report['general_notes'] ?? '',
                                        color: Colors.grey,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _DateButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: label.startsWith('Date') ? Colors.grey : AppColors.textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricBadge extends StatelessWidget {
  final String label;
  final String sublabel;
  final Color color;

  const _MetricBadge({
    required this.label,
    required this.sublabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              sublabel,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
