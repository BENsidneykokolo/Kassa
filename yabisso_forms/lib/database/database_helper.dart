import 'dart:convert';
import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/form_template.dart';
import '../models/form_response.dart';
import '../models/vendor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_forms.db');
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
      CREATE TABLE form_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        fields_json TEXT,
        type TEXT DEFAULT 'autre',
        response_count INTEGER DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE form_responses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        form_id INTEGER NOT NULL,
        respondent_name TEXT,
        respondent_phone TEXT,
        answers_json TEXT,
        created_at TEXT,
        FOREIGN KEY (form_id) REFERENCES form_templates(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT,
        pin_hash TEXT,
        color TEXT,
        initials TEXT,
        employee_id TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');
  }

  // ============ FORM TEMPLATES ============

  Future<int> insertFormTemplate(FormTemplate template) async {
    final db = await database;
    final data = template.toMap();
    data.remove('id');
    return await db.insert('form_templates', data);
  }

  Future<List<FormTemplate>> getAllFormTemplates() async {
    final db = await database;
    final maps = await db.query('form_templates', orderBy: 'created_at DESC');
    return maps.map((m) => FormTemplate.fromMap(m)).toList();
  }

  Future<FormTemplate?> getFormTemplateById(int id) async {
    final db = await database;
    final maps = await db.query('form_templates', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return FormTemplate.fromMap(maps.first);
  }

  Future<int> updateFormTemplate(FormTemplate template) async {
    final db = await database;
    final data = template.toMap();
    return await db.update('form_templates', data,
        where: 'id = ?', whereArgs: [template.id]);
  }

  Future<int> deleteFormTemplate(int id) async {
    final db = await database;
    await db.delete('form_responses', where: 'form_id = ?', whereArgs: [id]);
    return await db.delete('form_templates', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementResponseCount(int formId) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE form_templates SET response_count = response_count + 1 WHERE id = ?',
      [formId],
    );
  }

  // ============ FORM RESPONSES ============

  Future<int> insertFormResponse(FormResponse response) async {
    final db = await database;
    final data = response.toMap();
    data.remove('id');
    return await db.insert('form_responses', data);
  }

  Future<List<FormResponse>> getResponsesByFormId(int formId) async {
    final db = await database;
    final maps = await db.query('form_responses',
        where: 'form_id = ?', whereArgs: [formId], orderBy: 'created_at DESC');
    return maps.map((m) => FormResponse.fromMap(m)).toList();
  }

  Future<int> getResponseCount(int formId) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM form_responses WHERE form_id = ?',
      [formId],
    );
    return (result.first['count'] as int?) ?? 0;
  }

  Future<int> deleteFormResponse(int id) async {
    final db = await database;
    return await db.delete('form_responses', where: 'id = ?', whereArgs: [id]);
  }

  // ============ VENDORS ============

  Future<int> insertVendor(Vendor vendor) async {
    final db = await database;
    return await db.insert('vendors', vendor.toMap(),
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

  // ============ HELPERS ============

  List<Map<String, dynamic>> parseFieldsJson(String? fieldsJson) {
    if (fieldsJson == null || fieldsJson.isEmpty) return [];
    try {
      final decoded = jsonDecode(fieldsJson);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  String encodeFieldsJson(List<Map<String, dynamic>> fields) {
    return jsonEncode(fields);
  }
}
