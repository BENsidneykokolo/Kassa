import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/member.dart';
import '../models/event.dart';
import '../models/tithe.dart';
import '../models/vendor.dart';
import '../services/yce_service.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final churchNameProvider = FutureProvider<String?>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getSetting('church_name');
});

final membersProvider = FutureProvider<List<Member>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllMembers();
});

final activeMembersProvider = FutureProvider<List<Member>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getActiveMembers();
});

final eventsProvider = FutureProvider<List<ChurchEvent>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllEvents();
});

final upcomingEventsProvider = FutureProvider<List<ChurchEvent>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getUpcomingEvents();
});

final tithesProvider = FutureProvider<List<Tithe>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllTithes();
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllVendors();
});

final currentVendorProvider = StateProvider<Vendor?>((ref) => null);

final dashboardStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getDashboardStats();
});

final yceServiceProvider = Provider<YCEService>((ref) => YCEService.instance);

final prayerRequestsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllPrayerRequests();
});

final donationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllDonations();
});

final offeringsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getAllOfferings();
});
