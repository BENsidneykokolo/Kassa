import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/vendor.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final vendorsProvider = FutureProvider<List<Vendor>>((ref) async {
  final db = DatabaseHelper.instance;
  final maps = await db.getAllVendors();
  return maps.map((m) => Vendor(
    id: m['id'] as int?,
    name: m['name'] as String,
    role: m['role'] as String?,
    pinHash: m['pin_hash'] as String?,
    color: m['color'] as String?,
    initials: m['initials'] as String?,
    createdAt: m['created_at'] != null ? DateTime.parse(m['created_at'] as String) : null,
  )).toList();
});

final currentVendorProvider = StateProvider<Vendor?>((ref) => null);
