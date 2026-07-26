import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/file_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_drive.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE files (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, path TEXT, parent_folder_id TEXT, type TEXT DEFAULT 'file', size_bytes REAL DEFAULT 0, mime_type TEXT, created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now')), is_favorite INTEGER DEFAULT 0, is_deleted INTEGER DEFAULT 0)''');
    await db.execute('''CREATE TABLE vendors (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, role TEXT, pin_hash TEXT, color TEXT, initials TEXT, created_at TEXT DEFAULT (datetime('now')))''');
    await db.execute('''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)''');
  }

  Future<int> insertFile(Map<String, dynamic> f) async => (await database).insert('files', f);
  Future<List<Map<String, dynamic>>> getAllFiles() async => (await database).query('files', where: 'is_deleted = 0', orderBy: 'type DESC, name ASC');
  Future<List<Map<String, dynamic>>> getFilesByFolder(String? folderId) async => (await database).query('files', where: 'parent_folder_id ${folderId == null ? 'IS NULL' : '= ?'} AND is_deleted = 0', whereArgs: folderId != null ? [folderId] : null, orderBy: 'type DESC, name ASC');
  Future<List<Map<String, dynamic>>> getFavoriteFiles() async => (await database).query('files', where: 'is_favorite = 1 AND is_deleted = 0', orderBy: 'name ASC');
  Future<List<Map<String, dynamic>>> getRecentFiles() async => (await database).query('files', where: 'is_deleted = 0', orderBy: 'updated_at DESC', limit: 20);
  Future<List<Map<String, dynamic>>> searchFiles(String query) async => (await database).query('files', where: 'name LIKE ? AND is_deleted = 0', whereArgs: ['%$query%'], orderBy: 'name ASC');
  Future<List<Map<String, dynamic>>> getDeletedFiles() async => (await database).query('files', where: 'is_deleted = 1', orderBy: 'updated_at DESC');
  Future<int> updateFile(int id, Map<String, dynamic> f) async => (await database).update('files', f, where: 'id = ?', whereArgs: [id]);
  Future<int> deleteFile(int id) async => (await database).update('files', {'is_deleted': 1}, where: 'id = ?', whereArgs: [id]);
  Future<int> permanentDeleteFile(int id) async => (await database).delete('files', where: 'id = ?', whereArgs: [id]);
  Future<int> restoreFile(int id) async => (await database).update('files', {'is_deleted': 0}, where: 'id = ?', whereArgs: [id]);
  Future<int> toggleFavorite(int id, bool fav) async => (await database).update('files', {'is_favorite': fav ? 1 : 0}, where: 'id = ?', whereArgs: [id]);

  Future<Map<String, dynamic>?> getSetting(String key) async { final r = await (await database).query('settings', where: 'key = ?', whereArgs: [key]); return r.isNotEmpty ? r.first : null; }
  Future<void> setSetting(String key, String value) async => (await database).insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  Future<double> getTotalStorageUsed() async { final r = await (await database).rawQuery('SELECT COALESCE(SUM(size_bytes), 0) as total FROM files WHERE is_deleted = 0'); return (r.first['total'] as num?)?.toDouble() ?? 0; }
  Future<int> getFileCount() async { final r = await (await database).rawQuery('SELECT COUNT(*) as c FROM files WHERE is_deleted = 0'); return r.first['c'] as int; }
  Future<int> getFolderCount() async { final r = await (await database).rawQuery('SELECT COUNT(*) as c FROM files WHERE type = \'folder\' AND is_deleted = 0'); return r.first['c'] as int; }

  // Vendors
  Future<int> insertVendor(Map<String, dynamic> v) async => (await database).insert('vendors', v);
  Future<List<Map<String, dynamic>>> getAllVendors() async => (await database).query('vendors');
  Future<int> updateVendor(int id, Map<String, dynamic> v) async => (await database).update('vendors', v, where: 'id = ?', whereArgs: [id]);
  Future<int> deleteVendor(int id) async => (await database).delete('vendors', where: 'id = ?', whereArgs: [id]);
}
