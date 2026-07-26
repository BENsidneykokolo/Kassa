import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final _uuid = const Uuid();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_signature.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT NOT NULL,
        business_name TEXT,
        address TEXT,
        created_at TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1
      )
    ''');

    await db.execute('''
      CREATE TABLE signatures (
        id TEXT PRIMARY KEY,
        document_name TEXT NOT NULL,
        signer_name TEXT NOT NULL,
        signer_email TEXT NOT NULL,
        signature_path TEXT,
        signature_type INTEGER NOT NULL,
        status INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        font_style TEXT,
        text_color TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  String generateId() => _uuid.v4();

  Future<void> insertVendor(Map<String, dynamic> vendor) async {
    final db = await database;
    await db.insert('vendors', vendor, conflictAlgorithm: ConflictAlgorithm.replace);
  }

 Future<List<Map<String, dynamic>>> getAllVendors() async {
    final db = await database;
    return await db.query('vendors');
  }

  Future<Map<String, dynamic>?> getVendorById(String id) async {
    final db = await database;
    final results = await db.query('vendors', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateVendor(String id, Map<String, dynamic> vendor) async {
    final db = await database;
    await db.update('vendors', vendor, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteVendor(String id) async {
    final db = await database;
    await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSignature(Map<String, dynamic> signature) async {
    final db = await database;
    await db.insert('signatures', signature, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getAllSignatures() async {
    final db = await database;
    return await db.query('signatures', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getSignatureById(String id) async {
    final db = await database;
    final results = await db.query('signatures', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<void> updateSignature(String id, Map<String, dynamic> signature) async {
    final db = await database;
    await db.update('signatures', signature, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteSignature(String id) async {
    final db = await database;
    await db.delete('signatures', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  Future<void> updateSetting(String key, String value) async {
    final db = await database;
    await db.update('settings', {'value': value}, where: 'key = ?', whereArgs: [key]);
  }

  Future<int> getSignatureCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM signatures');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getSignedCount() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM signatures WHERE status = 1");
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> getDraftCount() async {
    final db = await database;
    final result = await db.rawQuery("SELECT COUNT(*) as count FROM signatures WHERE status = 0");
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
