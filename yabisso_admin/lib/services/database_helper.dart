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
    return await openDatabase(path, version: 13, onCreate: _createDB, onUpgrade: _upgradeDB);
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

    await db.execute('''
      CREATE TABLE checkin_requests (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        employee_phone TEXT,
        date TEXT NOT NULL,
        check_in_time TEXT,
        check_out_time TEXT,
        status TEXT DEFAULT 'pending',
        reviewed_by TEXT,
        reviewed_at TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shared_sales_reports (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        employee_phone TEXT,
        date TEXT NOT NULL,
        date_display TEXT,
        sales_count INTEGER DEFAULT 0,
        total_amount INTEGER DEFAULT 0,
        total_commission INTEGER DEFAULT 0,
        salaire INTEGER DEFAULT 0,
        sales_json TEXT,
        status TEXT DEFAULT 'imported',
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE candidates (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        cv_path TEXT,
        cv_type TEXT,
        contact_status TEXT DEFAULT 'not_contacted',
        presentation_status TEXT DEFAULT 'not_attended',
        meeting_status TEXT DEFAULT 'not_come',
        relance_status TEXT DEFAULT 'active',
        relance_stage TEXT,
        last_contact_date TEXT,
        notes TEXT,
        validation_status TEXT DEFAULT 'not_validated',
        validated_at TEXT,
        transformed_to_employee INTEGER DEFAULT 0,
        employee_id TEXT,
        transformed_at TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE prospectives (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT,
        shop_name TEXT NOT NULL,
        category TEXT,
        owner_name TEXT,
        owner_phone TEXT,
        address TEXT,
        visit_date TEXT,
        visit_time TEXT,
        result TEXT DEFAULT 'interested',
        comment TEXT,
        manager_notes TEXT,
        manager_status TEXT DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_profiles (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        email TEXT,
        photo_path TEXT,
        department TEXT,
        position TEXT,
        manager_id TEXT,
        manager_name TEXT,
        hire_date TEXT,
        status TEXT DEFAULT 'active',
        contract_type TEXT,
        address TEXT,
        emergency_contact TEXT,
        emergency_phone TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_documents (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        doc_type TEXT NOT NULL,
        doc_name TEXT NOT NULL,
        file_path TEXT,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE leaves (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        leave_type TEXT NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        days INTEGER DEFAULT 1,
        reason TEXT,
        status TEXT DEFAULT 'pending',
        reviewed_by TEXT,
        reviewed_at TEXT,
        review_comment TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE objectives (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        target_value INTEGER DEFAULT 0,
        current_value INTEGER DEFAULT 0,
        unit TEXT DEFAULT '',
        period TEXT DEFAULT 'monthly',
        start_date TEXT,
        end_date TEXT,
        status TEXT DEFAULT 'active',
        created_by TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE rewards (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        reward_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        awarded_by TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE sanctions (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        sanction_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        date TEXT NOT NULL,
        issued_by TEXT,
        status TEXT DEFAULT 'active',
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE trainings (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        trainer TEXT,
        duration_hours INTEGER DEFAULT 0,
        date TEXT,
        status TEXT DEFAULT 'planned',
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_trainings (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        training_id TEXT NOT NULL,
        training_title TEXT NOT NULL,
        status TEXT DEFAULT 'enrolled',
        completion_date TEXT,
        score INTEGER,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE manager_notes (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        note TEXT NOT NULL,
        category TEXT DEFAULT 'general',
        sentiment TEXT DEFAULT 'neutral',
        created_by TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE daily_reports (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        date TEXT NOT NULL,
        shops_visited INTEGER DEFAULT 0,
        demonstrations INTEGER DEFAULT 0,
        subscriptions INTEGER DEFAULT 0,
        sales_count INTEGER DEFAULT 0,
        difficulties TEXT,
        suggestions TEXT,
        general_notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        user_id TEXT,
        user_role TEXT,
        title TEXT NOT NULL,
        body TEXT NOT NULL,
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        reference_id TEXT,
        reference_type TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE attendance (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        date TEXT NOT NULL,
        check_in TEXT,
        check_out TEXT,
        status TEXT DEFAULT 'present',
        is_late INTEGER DEFAULT 0,
        early_departure INTEGER DEFAULT 0,
        overtime_hours REAL DEFAULT 0,
        notes TEXT,
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE contact_history (
        id TEXT PRIMARY KEY,
        shop_id TEXT NOT NULL,
        shop_name TEXT NOT NULL,
        agent_name TEXT DEFAULT '',
        channel TEXT DEFAULT 'appel',
        result TEXT DEFAULT 'relance_necessaire',
        notes TEXT DEFAULT '',
        created_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE employee_tasks (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        task_type TEXT DEFAULT 'demarchage',
        priority TEXT DEFAULT 'medium',
        due_date TEXT,
        status TEXT DEFAULT 'pending',
        started_at TEXT,
        completed_at TEXT,
        comment TEXT,
        proof_path TEXT,
        assigned_by TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE shared_prospections_reports (
        id TEXT PRIMARY KEY,
        employee_id TEXT NOT NULL,
        employee_name TEXT NOT NULL,
        employee_phone TEXT,
        date TEXT NOT NULL,
        total INTEGER DEFAULT 0,
        interesses INTEGER DEFAULT 0,
        pas_interesses INTEGER DEFAULT 0,
        a_rappeler INTEGER DEFAULT 0,
        prospections_json TEXT,
        status TEXT DEFAULT 'imported',
        created_at TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS checkin_requests (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_phone TEXT,
          date TEXT NOT NULL,
          check_in_time TEXT,
          status TEXT DEFAULT 'pending',
          reviewed_by TEXT,
          reviewed_at TEXT,
          created_at TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shared_sales_reports (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_phone TEXT,
          date TEXT NOT NULL,
          date_display TEXT,
          sales_count INTEGER DEFAULT 0,
          total_amount INTEGER DEFAULT 0,
          total_commission INTEGER DEFAULT 0,
          salaire INTEGER DEFAULT 0,
          sales_json TEXT,
          status TEXT DEFAULT 'imported',
          created_at TEXT
        )
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS candidates (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          phone TEXT,
          cv_path TEXT,
          cv_type TEXT,
          contact_status TEXT DEFAULT 'not_contacted',
          presentation_status TEXT DEFAULT 'not_attended',
          meeting_status TEXT DEFAULT 'not_come',
          notes TEXT,
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS prospectives (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT,
          shop_name TEXT NOT NULL,
          category TEXT,
          owner_name TEXT,
          owner_phone TEXT,
          address TEXT,
          visit_date TEXT,
          visit_time TEXT,
          result TEXT DEFAULT 'interested',
          comment TEXT,
          manager_notes TEXT,
          manager_status TEXT DEFAULT 'pending',
          created_at TEXT,
          updated_at TEXT
        )
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('ALTER TABLE candidates ADD COLUMN relance_status TEXT DEFAULT \'active\'');
      await db.execute('ALTER TABLE candidates ADD COLUMN relance_stage TEXT');
      await db.execute('ALTER TABLE candidates ADD COLUMN last_contact_date TEXT');
    }
    if (oldVersion < 7) {
      await db.execute('''CREATE TABLE IF NOT EXISTS employee_profiles (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, email TEXT, photo_path TEXT,
        department TEXT, position TEXT, manager_id TEXT, manager_name TEXT,
        hire_date TEXT, status TEXT DEFAULT 'active', contract_type TEXT, address TEXT,
        emergency_contact TEXT, emergency_phone TEXT, created_at TEXT, updated_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS employee_documents (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, doc_type TEXT NOT NULL,
        doc_name TEXT NOT NULL, file_path TEXT, notes TEXT, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS leaves (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        leave_type TEXT NOT NULL, start_date TEXT NOT NULL, end_date TEXT NOT NULL,
        days INTEGER DEFAULT 1, reason TEXT, status TEXT DEFAULT 'pending',
        reviewed_by TEXT, reviewed_at TEXT, review_comment TEXT, created_at TEXT, updated_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS objectives (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        title TEXT NOT NULL, description TEXT, target_value INTEGER DEFAULT 0,
        current_value INTEGER DEFAULT 0, unit TEXT DEFAULT '', period TEXT DEFAULT 'monthly',
        start_date TEXT, end_date TEXT, status TEXT DEFAULT 'active', created_by TEXT,
        created_at TEXT, updated_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS rewards (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        reward_type TEXT NOT NULL, title TEXT NOT NULL, description TEXT, date TEXT NOT NULL,
        awarded_by TEXT, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS sanctions (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        sanction_type TEXT NOT NULL, title TEXT NOT NULL, description TEXT, date TEXT NOT NULL,
        issued_by TEXT, status TEXT DEFAULT 'active', created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS trainings (
        id TEXT PRIMARY KEY, title TEXT NOT NULL, description TEXT, trainer TEXT,
        duration_hours INTEGER DEFAULT 0, date TEXT, status TEXT DEFAULT 'planned',
        created_at TEXT, updated_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS employee_trainings (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        training_id TEXT NOT NULL, training_title TEXT NOT NULL, status TEXT DEFAULT 'enrolled',
        completion_date TEXT, score INTEGER, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS manager_notes (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        note TEXT NOT NULL, category TEXT DEFAULT 'general', sentiment TEXT DEFAULT 'neutral',
        created_by TEXT, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS daily_reports (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        date TEXT NOT NULL, shops_visited INTEGER DEFAULT 0, demonstrations INTEGER DEFAULT 0,
        subscriptions INTEGER DEFAULT 0, sales_count INTEGER DEFAULT 0, difficulties TEXT,
        suggestions TEXT, general_notes TEXT, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS notifications (
        id TEXT PRIMARY KEY, user_id TEXT, user_role TEXT, title TEXT NOT NULL,
        body TEXT NOT NULL, type TEXT DEFAULT 'info', is_read INTEGER DEFAULT 0,
        reference_id TEXT, reference_type TEXT, created_at TEXT
      )''');
      await db.execute('''CREATE TABLE IF NOT EXISTS attendance (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        date TEXT NOT NULL, check_in TEXT, check_out TEXT, status TEXT DEFAULT 'present',
        is_late INTEGER DEFAULT 0, early_departure INTEGER DEFAULT 0, overtime_hours REAL DEFAULT 0,
        notes TEXT, created_at TEXT
      )''');
    }
    if (oldVersion < 8) {
      await db.execute('''CREATE TABLE IF NOT EXISTS contact_history (
        id TEXT PRIMARY KEY, shop_id TEXT NOT NULL, shop_name TEXT NOT NULL,
        agent_name TEXT DEFAULT '', channel TEXT DEFAULT 'appel',
        result TEXT DEFAULT 'relance_necessaire', notes TEXT DEFAULT '', created_at TEXT
      )''');
    }
    if (oldVersion < 9) {
      await db.execute('''CREATE TABLE IF NOT EXISTS employee_tasks (
        id TEXT PRIMARY KEY, employee_id TEXT NOT NULL, employee_name TEXT NOT NULL,
        title TEXT NOT NULL, description TEXT, task_type TEXT DEFAULT 'demarchage',
        priority TEXT DEFAULT 'medium', due_date TEXT, status TEXT DEFAULT 'pending',
        started_at TEXT, completed_at TEXT, comment TEXT, proof_path TEXT,
        assigned_by TEXT, created_at TEXT, updated_at TEXT
      )''');
    }
    if (oldVersion < 10) {
      await db.execute("ALTER TABLE candidates ADD COLUMN validation_status TEXT DEFAULT 'not_validated'");
      await db.execute("ALTER TABLE candidates ADD COLUMN validated_at TEXT");
      await db.execute("ALTER TABLE candidates ADD COLUMN transformed_to_employee INTEGER DEFAULT 0");
      await db.execute("ALTER TABLE candidates ADD COLUMN employee_id TEXT");
      await db.execute("ALTER TABLE candidates ADD COLUMN transformed_at TEXT");
    }
    if (oldVersion < 11) {
      await db.execute("ALTER TABLE checkin_requests ADD COLUMN check_out_time TEXT");
    }
    if (oldVersion < 12) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS shared_prospections_reports (
          id TEXT PRIMARY KEY,
          employee_id TEXT NOT NULL,
          employee_name TEXT NOT NULL,
          employee_phone TEXT,
          date TEXT NOT NULL,
          total INTEGER DEFAULT 0,
          interesses INTEGER DEFAULT 0,
          pas_interesses INTEGER DEFAULT 0,
          a_rappeler INTEGER DEFAULT 0,
          prospections_json TEXT,
          status TEXT DEFAULT 'imported',
          created_at TEXT
        )
      ''');
    }
    if (oldVersion < 13) {
      try { await db.execute("ALTER TABLE checkin_requests ADD COLUMN check_out_time TEXT"); } catch (_) {}
    }
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
