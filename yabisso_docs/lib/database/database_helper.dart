import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/document.dart';
import '../models/template.dart';
import '../models/vendor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_docs.db');
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
      CREATE TABLE documents (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT,
        template_id TEXT,
        type TEXT DEFAULT 'autre',
        status TEXT DEFAULT 'brouillon',
        client_name TEXT,
        amount REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE templates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        description TEXT,
        content TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL,
        pin_hash TEXT,
        color TEXT,
        initials TEXT,
        employee_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await _insertDefaultTemplates(db);
  }

  Future<void> _insertDefaultTemplates(Database db) async {
    for (final template in DocTemplate.defaults) {
      await db.insert('templates', template.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  String _now() => DateTime.now().toIso8601String();

  // ============ DOCUMENTS ============

  Future<int> insertDocument(Document doc) async {
    final db = await database;
    final data = doc.toMap();
    data['updated_at'] = _now();
    return await db.insert('documents', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Document>> getAllDocuments() async {
    final db = await database;
    final maps = await db.query('documents', orderBy: 'created_at DESC');
    return maps.map((m) => Document.fromMap(m)).toList();
  }

  Future<Document?> getDocumentById(int id) async {
    final db = await database;
    final maps = await db.query('documents', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Document.fromMap(maps.first);
  }

  Future<int> updateDocument(Document doc) async {
    final db = await database;
    final data = doc.toMap();
    data['updated_at'] = _now();
    return await db.update('documents', data,
        where: 'id = ?', whereArgs: [doc.id]);
  }

  Future<int> deleteDocument(int id) async {
    final db = await database;
    return await db.delete('documents', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Document>> searchDocuments(String query) async {
    final db = await database;
    final maps = await db.query(
      'documents',
      where: 'title LIKE ? OR client_name LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'created_at DESC',
    );
    return maps.map((m) => Document.fromMap(m)).toList();
  }

  Future<List<Document>> getDocumentsByType(String type) async {
    final db = await database;
    final maps = await db.query('documents',
        where: 'type = ?', whereArgs: [type], orderBy: 'created_at DESC');
    return maps.map((m) => Document.fromMap(m)).toList();
  }

  Future<List<Document>> getDocumentsByStatus(String status) async {
    final db = await database;
    final maps = await db.query('documents',
        where: 'status = ?', whereArgs: [status], orderBy: 'created_at DESC');
    return maps.map((m) => Document.fromMap(m)).toList();
  }

  Future<int> getDocumentCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM documents');
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> getDocumentCountByType(String type) async {
    final db = await database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM documents WHERE type = ?', [type]);
    return (result.first['count'] as int?) ?? 0;
  }

  Future<List<Document>> getRecentDocuments({int limit = 5}) async {
    final db = await database;
    final maps = await db.query('documents',
        orderBy: 'created_at DESC', limit: limit);
    return maps.map((m) => Document.fromMap(m)).toList();
  }

  // ============ TEMPLATES ============

  Future<List<DocTemplate>> getAllTemplates() async {
    final db = await database;
    final maps = await db.query('templates');
    return maps.map((m) => DocTemplate(
          id: m['id'] as String,
          name: m['name'] as String,
          type: m['type'] as String,
          description: m['description'] as String? ?? '',
          content: m['content'] as String,
        )).toList();
  }

  Future<DocTemplate?> getTemplateById(String id) async {
    final db = await database;
    final maps = await db.query('templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return DocTemplate(
      id: maps.first['id'] as String,
      name: maps.first['name'] as String,
      type: maps.first['type'] as String,
      description: maps.first['description'] as String? ?? '',
      content: maps.first['content'] as String,
    );
  }

  // ============ VENDORS ============

  Future<int> insertVendor(Vendor vendor) async {
    final db = await database;
    final data = vendor.toMap();
    return await db.insert('vendors', data,
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Vendor>> getAllVendors() async {
    final db = await database;
    final maps = await db.query('vendors');
    return maps.map((m) => Vendor.fromMap(m)).toList();
  }

  Future<int> updateVendor(Vendor vendor) async {
    final db = await database;
    return await db.update('vendors', vendor.toMap(),
        where: 'id = ?', whereArgs: [vendor.id]);
  }

  Future<int> deleteVendor(String id) async {
    final db = await database;
    return await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
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
