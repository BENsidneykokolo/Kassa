import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/vendor.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getAllVendors();
});

final currentVendorProvider = StateProvider<Vendor?>((ref) => null);

final storeNameProvider = FutureProvider<String>((ref) async {
  final db = ref.watch(databaseProvider);
  return await db.getSetting('store_name') ?? 'Yabisso Analytics';
});

final selectedPeriodProvider = StateProvider<String>((ref) => 'jour');

final dashboardRefreshProvider = StateProvider<int>((ref) => 0);
