import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/vendor.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  final db = await DatabaseHelper.instance.database;
  final maps = await db.query('vendors');
  return maps.map((m) => Vendor.fromMap(m)).toList();
});

final currentVendorProvider = StateProvider<Vendor?>((ref) => null);
