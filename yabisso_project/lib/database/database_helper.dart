import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vendor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_project.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE projects (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'en_cours',
        priority TEXT DEFAULT 'moyenne',
        deadline TEXT,
        progress REAL DEFAULT 0,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE tasks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        project_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        status TEXT DEFAULT 'a_faire',
        priority TEXT DEFAULT 'moyenne',
        due_date TEXT,
        assignee TEXT,
        created_at TEXT DEFAULT (datetime('now')),
        updated_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE team_members (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        email TEXT,
        phone TEXT,
        role TEXT,
        color TEXT,
        created_at TEXT DEFAULT (datetime('now'))
      )
    ''');

    await db.execute('''
      CREATE TABLE task_comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        task_id INTEGER NOT NULL,
        author TEXT NOT NULL,
        content TEXT NOT NULL,
        created_at TEXT DEFAULT (datetime('now')),
        FOREIGN KEY (task_id) REFERENCES tasks(id) ON DELETE CASCADE
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

  // === PROJECTS ===
  Future<int> insertProject(Map<String, dynamic> project) async {
    final db = await database;
    return await db.insert('projects', project);
  }

  Future<List<Map<String, dynamic>>> getAllProjects() async {
    final db = await database;
    return await db.query('projects', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getProject(int id) async {
    final db = await database;
    final results = await db.query('projects', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateProject(int id, Map<String, dynamic> project) async {
    final db = await database;
    return await db.update('projects', project, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteProject(int id) async {
    final db = await database;
    return await db.delete('projects', where: 'id = ?', whereArgs: [id]);
  }

  // === TASKS ===
  Future<int> insertTask(Map<String, dynamic> task) async {
    final db = await database;
    return await db.insert('tasks', task);
  }

  Future<List<Map<String, dynamic>>> getTasksByProject(int projectId) async {
    final db = await database;
    return await db.query('tasks', where: 'project_id = ?', whereArgs: [projectId], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getAllTasks() async {
    final db = await database;
    return await db.query('tasks', orderBy: 'created_at DESC');
  }

  Future<Map<String, dynamic>?> getTask(int id) async {
    final db = await database;
    final results = await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateTask(int id, Map<String, dynamic> task) async {
    final db = await database;
    return await db.update('tasks', task, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteTask(int id) async {
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  // === TEAM MEMBERS ===
  Future<int> insertTeamMember(Map<String, dynamic> member) async {
    final db = await database;
    return await db.insert('team_members', member);
  }

  Future<List<Map<String, dynamic>>> getAllTeamMembers() async {
    final db = await database;
    return await db.query('team_members', orderBy: 'name ASC');
  }

  Future<int> deleteTeamMember(int id) async {
    final db = await database;
    return await db.delete('team_members', where: 'id = ?', whereArgs: [id]);
  }

  // === TASK COMMENTS ===
  Future<int> insertTaskComment(Map<String, dynamic> comment) async {
    final db = await database;
    return await db.insert('task_comments', comment);
  }

  Future<List<Map<String, dynamic>>> getTaskComments(int taskId) async {
    final db = await database;
    return await db.query('task_comments', where: 'task_id = ?', whereArgs: [taskId], orderBy: 'created_at ASC');
  }

  // === SETTINGS ===
  Future<String?> getSetting(String key) async {
    final db = await database;
    final results = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    return results.isNotEmpty ? results.first['value'] as String? : null;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // === VENDORS ===
  Future<int> insertVendor(Vendor vendor) async {
    final db = await database;
    final data = vendor.toMap();
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
    return await db.update('vendors', data,
        where: 'id = ?', whereArgs: [vendor.id]);
  }

  Future<int> deleteVendor(String id) async {
    final db = await database;
    return await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
  }
}
