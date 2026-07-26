import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/vendor.dart';
import '../models/analytics_data.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_analytics.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final docDir = await getApplicationDocumentsDirectory();
    final newPath = join(docDir.path, filePath);

    final dbPath = await getDatabasesPath();
    final oldPath = join(dbPath, filePath);
    final oldFile = File(oldPath);
    if (await oldFile.exists()) {
      final newFile = File(newPath);
      if (!await newFile.exists()) {
        await newFile.parent.create(recursive: true);
        await oldFile.copy(newPath);
      }
    }

    return await openDatabase(
      newPath,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT,
        pin_hash TEXT,
        color TEXT,
        initials TEXT,
        employee_id TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE analytics_events (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        label TEXT NOT NULL,
        value REAL NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        metadata TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        vendor_id TEXT,
        total REAL DEFAULT 0,
        discount REAL DEFAULT 0,
        received REAL DEFAULT 0,
        change_given REAL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT,
        product_id TEXT,
        product_name TEXT,
        quantity INTEGER DEFAULT 0,
        unit_price REAL DEFAULT 0,
        category TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL DEFAULT 0,
        cost_price REAL DEFAULT 0,
        stock INTEGER DEFAULT 0,
        category TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
  }

  String _now() => DateTime.now().toIso8601String();

  // ============ VENDORS ============

  Future<int> insertVendor(Vendor vendor) async {
    final db = await database;
    final data = vendor.toMap();
    data['updated_at'] = _now();
    return await db.insert('vendors', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Vendor>> getAllVendors() async {
    final db = await database;
    final maps = await db.query('vendors');
    return maps.map((map) => Vendor.fromMap(map)).toList();
  }

  Future<int> updateVendor(Vendor vendor) async {
    final db = await database;
    final data = vendor.toMap();
    data['updated_at'] = _now();
    return await db.update('vendors', data,
        where: 'id = ?', whereArgs: [vendor.id]);
  }

  Future<int> deleteVendor(String id) async {
    final db = await database;
    return await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
  }

  // ============ ANALYTICS EVENTS ============

  Future<int> insertEvent(AnalyticsEvent event) async {
    final db = await database;
    final data = event.toMap();
    data['created_at'] = _now();
    return await db.insert('analytics_events', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<AnalyticsEvent>> getEventsByPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final maps = await db.query(
      'analytics_events',
      where: 'date >= ? AND date <= ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return maps.map((map) => AnalyticsEvent.fromMap(map)).toList();
  }

  // ============ SALES QUERIES ============

  Future<List<Map<String, dynamic>>> getSalesByDay({int days = 30}) async {
    final db = await database;
    final start = DateTime.now().subtract(Duration(days: days));
    final result = await db.rawQuery('''
      SELECT 
        DATE(created_at) as day,
        COUNT(*) as count,
        COALESCE(SUM(total), 0) as revenue
      FROM sales
      WHERE created_at >= ?
      GROUP BY DATE(created_at)
      ORDER BY day ASC
    ''', [start.toIso8601String()]);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 10, String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE si.created_at >= ? AND si.created_at <= ?';
      whereArgs = [startDate, endDate];
    }

    final result = await db.rawQuery('''
      SELECT 
        si.product_name,
        SUM(si.quantity) as total_quantity,
        SUM(si.unit_price * si.quantity) as total_revenue
      FROM sale_items si
      $whereClause
      GROUP BY si.product_name
      ORDER BY total_revenue DESC
      LIMIT $limit
    ''', whereArgs);
    return result;
  }

  Future<List<Map<String, dynamic>>> getSalesByCategory({String? startDate, String? endDate}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null && endDate != null) {
      whereClause = 'WHERE si.created_at >= ? AND si.created_at <= ?';
      whereArgs = [startDate, endDate];
    }

    final result = await db.rawQuery('''
      SELECT 
        COALESCE(si.category, 'Sans categorie') as category,
        SUM(si.unit_price * si.quantity) as total_revenue,
        COUNT(DISTINCT si.sale_id) as sales_count
      FROM sale_items si
      $whereClause
      GROUP BY si.category
      ORDER BY total_revenue DESC
    ''', whereArgs);
    return result;
  }

  Future<Map<String, dynamic>> getRevenueByPeriod(DateTime start, DateTime end) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT
        COALESCE(SUM(total), 0) as revenue,
        COUNT(*) as sales_count,
        COALESCE(AVG(total), 0) as avg_sale,
        COALESCE(SUM(discount), 0) as total_discount
      FROM sales
      WHERE created_at >= ? AND created_at <= ?
    ''', [start.toIso8601String(), end.toIso8601String()]);
    return result.isNotEmpty ? result.first : {'revenue': 0, 'sales_count': 0, 'avg_sale': 0, 'total_discount': 0};
  }

  Future<Map<String, dynamic>> getCustomerStats({DateTime? start, DateTime? end}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE created_at >= ? AND created_at <= ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
    }

    final result = await db.rawQuery('''
      SELECT
        COUNT(DISTINCT vendor_id) as unique_vendors,
        COUNT(*) as total_transactions,
        COALESCE(AVG(total), 0) as avg_basket,
        COALESCE(MAX(total), 0) as max_sale
      FROM sales
      $whereClause
    ''', whereArgs);
    return result.isNotEmpty ? result.first : {'unique_vendors': 0, 'total_transactions': 0, 'avg_basket': 0, 'max_sale': 0};
  }

  Future<List<Map<String, dynamic>>> getSalesTrend({int days = 7}) async {
    final db = await database;
    final start = DateTime.now().subtract(Duration(days: days));
    final result = await db.rawQuery('''
      SELECT 
        DATE(created_at) as day,
        COALESCE(SUM(total), 0) as revenue,
        COUNT(*) as count
      FROM sales
      WHERE created_at >= ?
      GROUP BY DATE(created_at)
      ORDER BY day ASC
    ''', [start.toIso8601String()]);
    return result;
  }

  Future<double> getTotalRevenue({DateTime? start, DateTime? end}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE created_at >= ? AND created_at <= ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
    }

    final result = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) as total FROM sales $whereClause',
      whereArgs,
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  Future<int> getTotalSalesCount({DateTime? start, DateTime? end}) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (start != null && end != null) {
      whereClause = 'WHERE created_at >= ? AND created_at <= ?';
      whereArgs = [start.toIso8601String(), end.toIso8601String()];
    }

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM sales $whereClause',
      whereArgs,
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // ============ SETTINGS ============

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String?;
  }
}
