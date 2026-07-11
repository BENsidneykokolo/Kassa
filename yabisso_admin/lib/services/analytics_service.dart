import 'database_helper.dart';

class AnalyticsService {
  static final AnalyticsService instance = AnalyticsService._init();
  AnalyticsService._init();
  final _db = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getFullAnalytics() async {
    final now = DateTime.now();
    final today = now.toIso8601String().substring(0, 10);
    final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    return {
      'employees': await _getEmployeeAnalytics(today, monthStart),
      'sales': await _getSalesAnalytics(today, monthStart),
      'checkins': await _getCheckinAnalytics(today),
      'candidates': await _getCandidateAnalytics(),
      'teams': await _getTeamAnalysis(),
    };
  }

  Future<Map<String, dynamic>> _getEmployeeAnalytics(String today, String monthStart) async {
    final allEmployees = await _db.getAll('employees');
    final activeEmployees = allEmployees.where((e) => e['is_active'] == 1).toList();

    final saleRecords = await _db.getAll('sale_records');
    final checkinRequests = await _db.getAll('checkin_requests');
    // sharedSales available for AI analysis via ai_service.dart

    final Map<String, int> employeeSalesCount = {};
    final Map<String, int> employeeSalesAmount = {};
    for (final s in saleRecords) {
      final eid = s['employee_id'] as String;
      employeeSalesCount[eid] = (employeeSalesCount[eid] ?? 0) + 1;
      employeeSalesAmount[eid] = (employeeSalesAmount[eid] ?? 0) + ((s['amount'] as int?) ?? 0);
    }

    final List<Map<String, dynamic>> employeePerformance = [];
    for (final emp in activeEmployees) {
      final eid = emp['id'] as String;
      final approvedCheckins = checkinRequests.where((c) =>
        c['employee_id'] == eid && c['status'] == 'approved'
      ).length;
      final pendingCheckins = checkinRequests.where((c) =>
        c['employee_id'] == eid && c['status'] == 'pending'
      ).length;
      final rejectedCheckins = checkinRequests.where((c) =>
        c['employee_id'] == eid && c['status'] == 'rejected'
      ).length;

      employeePerformance.add({
        'id': eid,
        'name': emp['name'] ?? '',
        'role': emp['role'] ?? '',
        'sales_count': employeeSalesCount[eid] ?? 0,
        'sales_amount': employeeSalesAmount[eid] ?? 0,
        'checkins_approved': approvedCheckins,
        'checkins_pending': pendingCheckins,
        'checkins_rejected': rejectedCheckins,
        'is_active': true,
      });
    }

    employeePerformance.sort((a, b) => (b['sales_amount'] as int).compareTo(a['sales_amount'] as int));

    return {
      'total': allEmployees.length,
      'active': activeEmployees.length,
      'performance': employeePerformance,
    };
  }

  Future<Map<String, dynamic>> _getSalesAnalytics(String today, String monthStart) async {
    final allSales = await _db.getAll('sale_records');
    final todaySales = allSales.where((s) => (s['created_at'] as String).startsWith(today)).toList();
    final monthSales = allSales.where((s) => (s['created_at'] as String).compareTo(monthStart) >= 0).toList();

    int todayTotal = 0;
    int monthTotal = 0;
    int totalAllTime = 0;
    for (final s in allSales) {
      totalAllTime += (s['amount'] as int?) ?? 0;
    }
    for (final s in todaySales) {
      todayTotal += (s['amount'] as int?) ?? 0;
    }
    for (final s in monthSales) {
      monthTotal += (s['amount'] as int?) ?? 0;
    }

    final planCounts = <String, int>{};
    for (final s in allSales) {
      final plan = s['plan'] as String? ?? 'UNKNOWN';
      planCounts[plan] = (planCounts[plan] ?? 0) + 1;
    }

    return {
      'total_records': allSales.length,
      'today_count': todaySales.length,
      'today_amount': todayTotal,
      'month_count': monthSales.length,
      'month_amount': monthTotal,
      'all_time_amount': totalAllTime,
      'plans': planCounts,
    };
  }

  Future<Map<String, dynamic>> _getCheckinAnalytics(String today) async {
    final allCheckins = await _db.getAll('checkin_requests');
    final pending = allCheckins.where((c) => c['status'] == 'pending').length;
    final approved = allCheckins.where((c) => c['status'] == 'approved').length;
    final rejected = allCheckins.where((c) => c['status'] == 'rejected').length;

    return {
      'total': allCheckins.length,
      'pending': pending,
      'approved': approved,
      'rejected': rejected,
    };
  }

  Future<Map<String, dynamic>> _getCandidateAnalytics() async {
    final allCandidates = await _db.getAll('candidates');

    final notContacted = allCandidates.where((c) => c['contact_status'] == 'not_contacted').toList();
    final contacted = allCandidates.where((c) => c['contact_status'] == 'contacted').toList();
    final notAttended = allCandidates.where((c) => c['presentation_status'] == 'not_attended').toList();
    final attended = allCandidates.where((c) => c['presentation_status'] == 'attended').toList();
    final notCome = allCandidates.where((c) => c['meeting_status'] == 'not_come').toList();
    final come = allCandidates.where((c) => c['meeting_status'] == 'come').toList();

    return {
      'total': allCandidates.length,
      'not_contacted': notContacted.map((c) => {'id': c['id'], 'name': c['name'], 'phone': c['phone'] ?? ''}).toList(),
      'contacted_count': contacted.length,
      'not_attended_count': notAttended.length,
      'attended_count': attended.length,
      'not_come_count': notCome.length,
      'come_count': come.length,
      'conversion_contact': allCandidates.isNotEmpty ? (contacted.length / allCandidates.length * 100).toStringAsFixed(0) : '0',
      'conversion_live': allCandidates.isNotEmpty ? (attended.length / allCandidates.length * 100).toStringAsFixed(0) : '0',
      'conversion_meeting': allCandidates.isNotEmpty ? (come.length / allCandidates.length * 100).toStringAsFixed(0) : '0',
    };
  }

  Future<Map<String, dynamic>> _getTeamAnalysis() async {
    final employees = await _db.getAll('employees');
    final activeEmps = employees.where((e) => e['is_active'] == 1).toList();
    final saleRecords = await _db.getAll('sale_records');

    final Map<String, int> empSales = {};
    for (final s in saleRecords) {
      final eid = s['employee_id'] as String;
      empSales[eid] = (empSales[eid] ?? 0) + ((s['amount'] as int?) ?? 0);
    }

    if (activeEmps.isEmpty) return {'top_performers': [], 'low_performers': [], 'avg_sales': 0};

    final List<Map<String, dynamic>> ranked = activeEmps.map((e) {
      return {
        'id': e['id'],
        'name': e['name'] ?? '',
        'role': e['role'] ?? '',
        'total_sales': empSales[e['id']] ?? 0,
      };
    }).toList();

    ranked.sort((a, b) => (b['total_sales'] as int).compareTo(a['total_sales'] as int));

    final totalSalesSum = ranked.fold<int>(0, (sum, e) => sum + (e['total_sales'] as int));
    final avgSales = ranked.isNotEmpty ? totalSalesSum ~/ ranked.length : 0;

    final topCount = (ranked.length * 0.3).ceil().clamp(1, ranked.length);
    final lowCount = (ranked.length * 0.3).ceil().clamp(1, ranked.length);

    final topPerformers = ranked.take(topCount).toList();
    final lowPerformers = ranked.reversed.take(lowCount).toList();

    final suggestions = <Map<String, String>>[];
    if (topPerformers.isNotEmpty && lowPerformers.isNotEmpty) {
      for (final low in lowPerformers) {
        final bestMatch = topPerformers.first;
        suggestions.add({
          'mentor': bestMatch['name'] as String,
          'mentor_id': bestMatch['id'] as String,
          'mentee': low['name'] as String,
          'mentee_id': low['id'] as String,
          'reason': '${bestMatch['name']} (${_formatAmount(bestMatch['total_sales'] as int)} FCFA) peut encadrer ${low['name']} (${_formatAmount(low['total_sales'] as int)} FCFA)',
        });
      }
    }

    return {
      'top_performers': topPerformers,
      'low_performers': lowPerformers,
      'avg_sales': avgSales,
      'pairing_suggestions': suggestions,
    };
  }

  String _formatAmount(int amount) {
    return amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
  }
}
