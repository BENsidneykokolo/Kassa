import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_admin.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE admins (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT DEFAULT 'admin',
        pin_hash TEXT,
        initials TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        role TEXT DEFAULT 'prestataire',
        pin_hash TEXT,
        color TEXT DEFAULT '#00694C',
        initials TEXT DEFAULT '',
        is_active INTEGER DEFAULT 1,
        base_salary INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE assignments (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        shop_name TEXT NOT NULL,
        territory TEXT,
        description TEXT,
        status TEXT DEFAULT 'pending',
        date TEXT NOT NULL,
        completed_at TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ai_proposals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        expected_impact TEXT,
        priority TEXT DEFAULT 'medium',
        category TEXT DEFAULT 'general',
        status TEXT DEFAULT 'pending',
        created_at TEXT,
        reviewed_at TEXT,
        reviewed_by TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sale_records (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        shop_name TEXT NOT NULL,
        plan TEXT NOT NULL,
        amount INTEGER NOT NULL,
        commission INTEGER DEFAULT 0,
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
      CREATE TABLE activity_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        admin_id TEXT,
        action TEXT NOT NULL,
        details TEXT,
        created_at TEXT
      )
    ''');
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    final db = await database;
    await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAll(String table, {String? where, List<dynamic>? whereArgs, String? orderBy}) async {
    final db = await database;
    return await db.query(table, where: where, whereArgs: whereArgs, orderBy: orderBy);
  }

  Future<void> update(String table, Map<String, dynamic> data, String id) async {
    final db = await database;
    await db.update(table, data, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> delete(String table, String id) async {
    final db = await database;
    await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> setSetting(String key, String value) async {
    await insert('settings', {'key': key, 'value': value});
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return result.isNotEmpty ? result.first['value'] as String? : null;
  }

  Future<void> logActivity(String? adminId, String action, String? details) async {
    await insert('activity_log', {
      'admin_id': adminId,
      'action': action,
      'details': details,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<int> count(String table, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM $table${where != null ? ' WHERE $where' : ''}', whereArgs);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> sum(String table, String column, {String? where, List<dynamic>? whereArgs}) async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM($column), 0) as total FROM $table${where != null ? ' WHERE $where' : ''}', whereArgs);
    return (result.first['total'] as int?) ?? 0;
  }
}
