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
