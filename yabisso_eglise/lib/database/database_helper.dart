import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/member.dart';
import '../models/event.dart';
import '../models/tithe.dart';
import '../models/vendor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_eglise.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'member',
        pin_hash TEXT,
        color TEXT DEFAULT '#040C1C',
        initials TEXT,
        employee_id TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE members (
        id TEXT PRIMARY KEY,
        first_name TEXT NOT NULL,
        last_name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        address TEXT,
        photo_path TEXT,
        role TEXT DEFAULT 'member',
        baptism_date TEXT,
        membership_date TEXT,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE events (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        event_type TEXT NOT NULL DEFAULT 'worship',
        start_date TEXT NOT NULL,
        end_date TEXT,
        location TEXT,
        speaker TEXT,
        expected_attendees INTEGER,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE tithes (
        id TEXT PRIMARY KEY,
        member_id TEXT NOT NULL,
        member_name TEXT NOT NULL,
        amount REAL NOT NULL,
        tithe_type TEXT NOT NULL DEFAULT 'tithe',
        notes TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (member_id) REFERENCES members(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE offerings (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        offering_type TEXT NOT NULL DEFAULT 'general',
        description TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        label TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT,
        notes TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE prayer_requests (
        id TEXT PRIMARY KEY,
        author_name TEXT,
        is_anonymous INTEGER DEFAULT 0,
        content TEXT NOT NULL,
        prayer_count INTEGER DEFAULT 0,
        is_active INTEGER DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE donations (
        id TEXT PRIMARY KEY,
        donor_name TEXT,
        donor_phone TEXT,
        amount REAL NOT NULL,
        purpose TEXT,
        payment_method TEXT DEFAULT 'cash',
        is_anonymous INTEGER DEFAULT 0,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // === SETTINGS ===
  Future<String?> getSetting(String key) async {
    final db = await database;
    final result = await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (result.isEmpty) return null;
    return result.first['value'] as String?;
  }

  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // === MEMBERS ===
  Future<String> insertMember(Member member) async {
    final db = await database;
    await db.insert('members', member.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return member.id;
  }

  Future<int> updateMember(Member member) async {
    final db = await database;
    return await db.update('members', member.toMap(),
        where: 'id = ?', whereArgs: [member.id]);
  }

  Future<int> deleteMember(String id) async {
    final db = await database;
    return await db.delete('members', where: 'id = ?', whereArgs: [id]);
  }

  Future<Member?> getMember(String id) async {
    final db = await database;
    final result = await db.query('members', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Member.fromMap(result.first);
  }

  Future<List<Member>> getAllMembers() async {
    final db = await database;
    final result = await db.query('members', orderBy: 'last_name ASC');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<List<Member>> getActiveMembers() async {
    final db = await database;
    final result = await db.query('members',
        where: 'is_active = ?', whereArgs: [1], orderBy: 'last_name ASC');
    return result.map((map) => Member.fromMap(map)).toList();
  }

  Future<int> getMemberCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM members WHERE is_active = 1');
    return (result.first['count'] as int?) ?? 0;
  }

  // === EVENTS ===
  Future<String> insertEvent(ChurchEvent event) async {
    final db = await database;
    await db.insert('events', event.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return event.id;
  }

  Future<int> updateEvent(ChurchEvent event) async {
    final db = await database;
    return await db.update('events', event.toMap(),
        where: 'id = ?', whereArgs: [event.id]);
  }

  Future<int> deleteEvent(String id) async {
    final db = await database;
    return await db.delete('events', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ChurchEvent>> getAllEvents() async {
    final db = await database;
    final result = await db.query('events', orderBy: 'start_date DESC');
    return result.map((map) => ChurchEvent.fromMap(map)).toList();
  }

  Future<List<ChurchEvent>> getUpcomingEvents() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.query('events',
        where: 'start_date >= ?', whereArgs: [now], orderBy: 'start_date ASC');
    return result.map((map) => ChurchEvent.fromMap(map)).toList();
  }

  Future<List<ChurchEvent>> getEventsByType(String type) async {
    final db = await database;
    final result = await db.query('events',
        where: 'event_type = ?', whereArgs: [type], orderBy: 'start_date DESC');
    return result.map((map) => ChurchEvent.fromMap(map)).toList();
  }

  Future<int> getEventCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM events');
    return (result.first['count'] as int?) ?? 0;
  }

  // === TITHES ===
  Future<String> insertTithe(Tithe tithe) async {
    final db = await database;
    await db.insert('tithes', tithe.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return tithe.id;
  }

  Future<List<Tithe>> getAllTithes() async {
    final db = await database;
    final result = await db.query('tithes', orderBy: 'date DESC');
    return result.map((map) => Tithe.fromMap(map)).toList();
  }

  Future<List<Tithe>> getTithesByDateRange(String start, String end) async {
    final db = await database;
    final result = await db.query('tithes',
        where: 'date BETWEEN ? AND ?', whereArgs: [start, end], orderBy: 'date DESC');
    return result.map((map) => Tithe.fromMap(map)).toList();
  }

  Future<double> getTotalTithes() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM tithes');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // === OFFERINGS ===
  Future<String> insertOffering(Map<String, dynamic> offering) async {
    final db = await database;
    await db.insert('offerings', offering, conflictAlgorithm: ConflictAlgorithm.replace);
    return offering['id'] ?? '';
  }

  Future<List<Map<String, dynamic>>> getAllOfferings() async {
    final db = await database;
    return await db.query('offerings', orderBy: 'date DESC');
  }

  Future<double> getTotalOfferings() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM offerings');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // === EXPENSES ===
  Future<String> insertExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('expenses', expense, conflictAlgorithm: ConflictAlgorithm.replace);
    return expense['id'] ?? '';
  }

  Future<List<Map<String, dynamic>>> getAllExpenses() async {
    final db = await database;
    return await db.query('expenses', orderBy: 'date DESC');
  }

  Future<double> getTotalExpenses() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM expenses');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // === VENDORS (Leaders/Pastors) ===
  Future<String> insertVendor(Vendor vendor) async {
    final db = await database;
    await db.insert('vendors', vendor.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    return vendor.id;
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

  Future<List<Vendor>> getAllVendors() async {
    final db = await database;
    final result = await db.query('vendors', orderBy: 'name ASC');
    return result.map((map) => Vendor.fromMap(map)).toList();
  }

  Future<Vendor?> getVendor(String id) async {
    final db = await database;
    final result = await db.query('vendors', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Vendor.fromMap(result.first);
  }

  // === PRAYER REQUESTS ===
  Future<String> insertPrayerRequest(Map<String, dynamic> request) async {
    final db = await database;
    await db.insert('prayer_requests', request, conflictAlgorithm: ConflictAlgorithm.replace);
    return request['id'] ?? '';
  }

  Future<List<Map<String, dynamic>>> getAllPrayerRequests() async {
    final db = await database;
    return await db.query('prayer_requests',
        where: 'is_active = ?', whereArgs: [1], orderBy: 'created_at DESC');
  }

  Future<int> incrementPrayerCount(String id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE prayer_requests SET prayer_count = prayer_count + 1 WHERE id = ?',
      [id],
    );
  }

  Future<int> deletePrayerRequest(String id) async {
    final db = await database;
    return await db.delete('prayer_requests', where: 'id = ?', whereArgs: [id]);
  }

  // === DONATIONS ===
  Future<String> insertDonation(Map<String, dynamic> donation) async {
    final db = await database;
    await db.insert('donations', donation, conflictAlgorithm: ConflictAlgorithm.replace);
    return donation['id'] ?? '';
  }

  Future<List<Map<String, dynamic>>> getAllDonations() async {
    final db = await database;
    return await db.query('donations', orderBy: 'date DESC');
  }

  Future<double> getTotalDonations() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COALESCE(SUM(amount), 0) as total FROM donations');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // === STATS ===
  Future<Map<String, dynamic>> getDashboardStats() async {
    final memberCount = await getMemberCount();
    final totalTithes = await getTotalTithes();
    final totalOfferings = await getTotalOfferings();
    final totalExpenses = await getTotalExpenses();
    final totalDonations = await getTotalDonations();
    final eventCount = await getEventCount();

    return {
      'member_count': memberCount,
      'total_tithes': totalTithes,
      'total_offerings': totalOfferings,
      'total_expenses': totalExpenses,
      'total_donations': totalDonations,
      'balance': (totalTithes + totalOfferings + totalDonations) - totalExpenses,
      'event_count': eventCount,
    };
  }
}
