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

  return {
    'totalEmployees': totalEmployees,
    'activeEmployees': activeEmployees,
    'todayRevenue': todayRevenue,
    'monthlyRevenue': monthlyRevenue,
    'totalSales': totalSales,
    'pendingProposals': pendingProposals,
    'pendingAssignments': pendingAssignments,
    'pendingDecisions': pendingProposals + pendingAssignments,
  };
});
