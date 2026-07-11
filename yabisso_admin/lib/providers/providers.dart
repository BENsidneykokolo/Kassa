import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin.dart';
import '../models/employee.dart';
import '../models/assignment.dart';
import '../models/ai_proposal.dart';
import '../models/sale_record.dart';
import '../services/database_helper.dart';
import '../services/ai_service.dart';

final currentAdminProvider = StateProvider<Admin?>((ref) => null);

final employeesProvider = FutureProvider<List<Employee>>((ref) async {
  ref.watch(employeesRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('employees', orderBy: 'created_at DESC');
  return maps.map((m) => Employee.fromMap(m)).toList();
});

final employeesRefreshProvider = StateProvider<int>((ref) => 0);

final activeEmployeesProvider = FutureProvider<List<Employee>>((ref) async {
  final employees = await ref.watch(employeesProvider.future);
  return employees.where((e) => e.isActive).toList();
});

final assignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  ref.watch(assignmentsRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('assignments', orderBy: 'created_at DESC');
  return maps.map((m) => Assignment.fromMap(m)).toList();
});

final assignmentsRefreshProvider = StateProvider<int>((ref) => 0);

final todayAssignmentsProvider = FutureProvider<List<Assignment>>((ref) async {
  final assignments = await ref.watch(assignmentsProvider.future);
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return assignments.where((a) => a.date.startsWith(today)).toList();
});

final aiProposalsProvider = FutureProvider<List<AiProposal>>((ref) async {
  ref.watch(aiProposalsRefreshProvider);
  return AiService.instance.getAllProposals();
});

final aiProposalsRefreshProvider = StateProvider<int>((ref) => 0);

final pendingProposalsProvider = FutureProvider<List<AiProposal>>((ref) async {
  final proposals = await ref.watch(aiProposalsProvider.future);
  return proposals.where((p) => p.status == 'pending').toList();
});

final allSalesProvider = FutureProvider<List<SaleRecord>>((ref) async {
  ref.watch(salesRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('sale_records', orderBy: 'created_at DESC');
  return maps.map((m) => SaleRecord.fromMap(m)).toList();
});

final salesRefreshProvider = StateProvider<int>((ref) => 0);

final todayRevenueProvider = FutureProvider<int>((ref) async {
  final db = DatabaseHelper.instance;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  return db.sum('sale_records', 'amount',
    where: 'created_at LIKE ?', whereArgs: ['$today%']);
});

final monthlyRevenueProvider = FutureProvider<int>((ref) async {
  final db = DatabaseHelper.instance;
  final now = DateTime.now();
  final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
  return db.sum('sale_records', 'amount',
    where: 'created_at >= ?', whereArgs: [monthStart]);
});

final totalEmployeesProvider = FutureProvider<int>((ref) async {
  ref.watch(employeesRefreshProvider);
  final db = DatabaseHelper.instance;
  return db.count('employees');
});

final activeSubscriptionsProvider = FutureProvider<int>((ref) async {
  final db = DatabaseHelper.instance;
  return db.count('sale_records');
});

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(employeesRefreshProvider);
  ref.watch(salesRefreshProvider);
  ref.watch(assignmentsRefreshProvider);
  ref.watch(checkinRequestsRefreshProvider);
  final db = DatabaseHelper.instance;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final now = DateTime.now();
  final monthStart = '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

  final totalEmployees = await db.count('employees');
  final activeEmployees = await db.count('employees', where: 'is_active = 1');
  final todayRevenue = await db.sum('sale_records', 'amount',
    where: 'created_at LIKE ?', whereArgs: ['$today%']);
  final monthlyRevenue = await db.sum('sale_records', 'amount',
    where: 'created_at >= ?', whereArgs: [monthStart]);
  final totalSales = await db.count('sale_records');
  final pendingProposals = await db.count('ai_proposals', where: "status = 'pending'");
  final pendingAssignments = await db.count('assignments', where: "status = 'pending'");
  final pendingCheckins = await db.count('checkin_requests', where: "status = 'pending'");

  return {
    'totalEmployees': totalEmployees,
    'activeEmployees': activeEmployees,
    'todayRevenue': todayRevenue,
    'monthlyRevenue': monthlyRevenue,
    'totalSales': totalSales,
    'pendingProposals': pendingProposals,
    'pendingAssignments': pendingAssignments,
    'pendingCheckins': pendingCheckins,
    'pendingDecisions': pendingProposals + pendingAssignments + pendingCheckins,
  };
});

final checkinRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(checkinRequestsRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('checkin_requests', orderBy: 'created_at DESC');
  return maps;
});

final checkinRequestsRefreshProvider = StateProvider<int>((ref) => 0);

final pendingCheckinsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(checkinRequestsRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('checkin_requests', where: "status = 'pending'", orderBy: 'created_at DESC');
  return maps;
});

final sharedSalesReportsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(sharedSalesRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('shared_sales_reports', orderBy: 'created_at DESC');
  return maps;
});

final sharedSalesRefreshProvider = StateProvider<int>((ref) => 0);

final sharedProspectionsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(sharedProspectionsRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('shared_prospections_reports', orderBy: 'created_at DESC');
  return maps;
});

final sharedProspectionsRefreshProvider = StateProvider<int>((ref) => 0);

final candidatesProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(candidatesRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('candidates', orderBy: 'created_at DESC');
  return maps;
});

final candidatesRefreshProvider = StateProvider<int>((ref) => 0);

final contactHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('contact_history', orderBy: 'created_at DESC');
  return maps;
});

final employeeTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(employeeTasksRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('employee_tasks', orderBy: 'created_at DESC');
  return maps;
});

final employeeTasksRefreshProvider = StateProvider<int>((ref) => 0);

final pendingTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(employeeTasksRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('employee_tasks', where: "status = 'pending' OR status = 'in_progress'", orderBy: 'created_at DESC');
  return maps;
});

final todayTasksProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(employeeTasksRefreshProvider);
  final db = DatabaseHelper.instance;
  final today = DateTime.now().toIso8601String().substring(0, 10);
  final maps = await db.getAll('employee_tasks', where: "due_date = ? OR created_at LIKE ?", whereArgs: ['$today%', '$today%']);
  return maps;
});

final activityLogProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(activityLogRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('activity_log', orderBy: 'created_at DESC');
  return maps;
});

final activityLogRefreshProvider = StateProvider<int>((ref) => 0);

final notificationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  ref.watch(notificationsRefreshProvider);
  final db = DatabaseHelper.instance;
  final maps = await db.getAll('notifications', orderBy: 'created_at DESC');
  return maps;
});

final notificationsRefreshProvider = StateProvider<int>((ref) => 0);

final unreadNotificationsProvider = FutureProvider<int>((ref) async {
  ref.watch(notificationsRefreshProvider);
  final db = DatabaseHelper.instance;
  return db.count('notifications', where: 'is_read = 0');
});
