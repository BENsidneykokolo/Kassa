import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_ia.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''CREATE TABLE conversations (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, last_message TEXT, created_at TEXT DEFAULT (datetime('now')), updated_at TEXT DEFAULT (datetime('now')))''');
    await db.execute('''CREATE TABLE messages (id INTEGER PRIMARY KEY AUTOINCREMENT, conversation_id INTEGER NOT NULL, role TEXT NOT NULL, content TEXT NOT NULL, created_at TEXT DEFAULT (datetime('now')), FOREIGN KEY (conversation_id) REFERENCES conversations(id) ON DELETE CASCADE)''');
    await db.execute('''CREATE TABLE insights (id INTEGER PRIMARY KEY AUTOINCREMENT, type TEXT NOT NULL, title TEXT NOT NULL, description TEXT NOT NULL, data TEXT, is_read INTEGER DEFAULT 0, created_at TEXT DEFAULT (datetime('now')))''');
    await db.execute('''CREATE TABLE ai_models (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, description TEXT, size_mb REAL, path TEXT, is_downloaded INTEGER DEFAULT 0, is_active INTEGER DEFAULT 0, api_key TEXT, api_url TEXT, created_at TEXT DEFAULT (datetime('now')))''');
    await db.execute('''CREATE TABLE settings (key TEXT PRIMARY KEY, value TEXT)''');

    // Insert default models
    final now = DateTime.now().toIso8601String();
    await db.insert('ai_models', {'name': 'Classification Mobile', 'type': 'offline', 'description': 'Classe automatiquement les documents et textes en catégories (facture, contrat, message, etc.)', 'size_mb': 5.2, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
    await db.insert('ai_models', {'name': 'Analyse Sentiments', 'type': 'offline', 'description': 'Analyse le sentiment des avis et messages clients (positif, négatif, neutre)', 'size_mb': 3.1, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
    await db.insert('ai_models', {'name': 'Génération Texte Business', 'type': 'offline', 'description': 'Génère des textes pour marketing, emails, descriptions produits', 'size_mb': 15.8, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
    await db.insert('ai_models', {'name': 'Résumé Documents', 'type': 'offline', 'description': 'Résume automatiquement les longs textes et documents', 'size_mb': 10.3, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
    await db.insert('ai_models', {'name': 'OpenAI GPT-4', 'type': 'online', 'description': 'Modèle OpenAI puissant - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://api.openai.com/v1/chat/completions', 'created_at': now});
    await db.insert('ai_models', {'name': 'Google Gemini', 'type': 'online', 'description': 'Modèle Google Gemini - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://generativelanguage.googleapis.com/v1beta/models', 'created_at': now});
    await db.insert('ai_models', {'name': 'Anthropic Claude', 'type': 'online', 'description': 'Modèle Claude par Anthropic - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://api.anthropic.com/v1/messages', 'created_at': now});
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''CREATE TABLE IF NOT EXISTS ai_models (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, type TEXT NOT NULL, description TEXT, size_mb REAL, path TEXT, is_downloaded INTEGER DEFAULT 0, is_active INTEGER DEFAULT 0, api_key TEXT, api_url TEXT, created_at TEXT DEFAULT (datetime('now')))''');
      // Insert default models on upgrade
      final now = DateTime.now().toIso8601String();
      await db.insert('ai_models', {'name': 'Classification Mobile', 'type': 'offline', 'description': 'Classe automatiquement les documents et textes en catégories (facture, contrat, message, etc.)', 'size_mb': 5.2, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
      await db.insert('ai_models', {'name': 'Analyse Sentiments', 'type': 'offline', 'description': 'Analyse le sentiment des avis et messages clients (positif, négatif, neutre)', 'size_mb': 3.1, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
      await db.insert('ai_models', {'name': 'Génération Texte Business', 'type': 'offline', 'description': 'Génère des textes pour marketing, emails, descriptions produits', 'size_mb': 15.8, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
      await db.insert('ai_models', {'name': 'Résumé Documents', 'type': 'offline', 'description': 'Résume automatiquement les longs textes et documents', 'size_mb': 10.3, 'is_downloaded': 0, 'is_active': 0, 'created_at': now});
      await db.insert('ai_models', {'name': 'OpenAI GPT-4', 'type': 'online', 'description': 'Modèle OpenAI puissant - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://api.openai.com/v1/chat/completions', 'created_at': now});
      await db.insert('ai_models', {'name': 'Google Gemini', 'type': 'online', 'description': 'Modèle Google Gemini - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://generativelanguage.googleapis.com/v1beta/models', 'created_at': now});
      await db.insert('ai_models', {'name': 'Anthropic Claude', 'type': 'online', 'description': 'Modèle Claude par Anthropic - nécessite Internet', 'size_mb': 0, 'is_downloaded': 0, 'is_active': 0, 'api_url': 'https://api.anthropic.com/v1/messages', 'created_at': now});
    }
  }

  // Conversations
  Future<int> insertConversation(Map<String, dynamic> c) async => (await database).insert('conversations', c);
  Future<int> insertConversationWithTitle(String title) async {
    final now = DateTime.now().toIso8601String();
    return (await database).insert('conversations', {'title': title, 'created_at': now, 'updated_at': now});
  }
  Future<List<Map<String, dynamic>>> getMessages(int convId) async => getMessagesByConversation(convId);
  Future<void> insertMessageSimple(int conversationId, String content, bool isUser) async {
    await (await database).insert('messages', {
      'conversation_id': conversationId, 'role': isUser ? 'user' : 'assistant',
      'content': content, 'created_at': DateTime.now().toIso8601String(),
    });
  }
  Future<List<Map<String, dynamic>>> getAllConversations() async => (await database).query('conversations', orderBy: 'updated_at DESC');
  Future<Map<String, dynamic>?> getConversation(int id) async {
    final r = await (await database).query('conversations', where: 'id = ?', whereArgs: [id]);
    return r.isNotEmpty ? r.first : null;
  }
  Future<void> updateConversationLastMessage(int id, String lastMessage) async {
    await (await database).update('conversations', {'last_message': lastMessage, 'updated_at': DateTime.now().toIso8601String()}, where: 'id = ?', whereArgs: [id]);
  }
  Future<int> updateConversation(int id, Map<String, dynamic> c) async => (await database).update('conversations', c, where: 'id = ?', whereArgs: [id]);
  Future<int> deleteConversation(int id) async => (await database).delete('conversations', where: 'id = ?', whereArgs: [id]);

  // Messages
  Future<int> insertMessage(Map<String, dynamic> m) async => (await database).insert('messages', m);
  Future<List<Map<String, dynamic>>> getMessagesByConversation(int convId) async => (await database).query('messages', where: 'conversation_id = ?', whereArgs: [convId], orderBy: 'created_at ASC');

  // Insights
  Future<int> insertInsight(Map<String, dynamic> i) async => (await database).insert('insights', i);
  Future<List<Map<String, dynamic>>> getAllInsights() async => (await database).query('insights', orderBy: 'created_at DESC');
  Future<List<Map<String, dynamic>>> getInsightsByType(String type) async => (await database).query('insights', where: 'type = ?', whereArgs: [type], orderBy: 'created_at DESC');
  Future<void> markInsightRead(int id) async => (await database).update('insights', {'is_read': 1}, where: 'id = ?', whereArgs: [id]);
  Future<void> markInsightAsRead(int id) async => markInsightRead(id);

  // AI Models
  Future<List<Map<String, dynamic>>> getAllModels() async => (await database).query('ai_models', orderBy: 'type ASC, name ASC');
  Future<List<Map<String, dynamic>>> getOfflineModels() async => (await database).query('ai_models', where: 'type = ?', whereArgs: ['offline']);
  Future<List<Map<String, dynamic>>> getOnlineModels() async => (await database).query('ai_models', where: 'type = ?', whereArgs: ['online']);
  Future<Map<String, dynamic>?> getActiveModel() async {
    final r = await (await database).query('ai_models', where: 'is_active = 1');
    return r.isNotEmpty ? r.first : null;
  }
  Future<void> setActiveModel(int id) async {
    final db = await database;
    await db.update('ai_models', {'is_active': 0});
    await db.update('ai_models', {'is_active': 1}, where: 'id = ?', whereArgs: [id]);
  }
  Future<void> updateModelDownloaded(int id, bool downloaded, String? path) async => (await database).update('ai_models', {'is_downloaded': downloaded ? 1 : 0, 'path': path}, where: 'id = ?', whereArgs: [id]);
  Future<void> updateModelApiKey(int id, String? apiKey) async => (await database).update('ai_models', {'api_key': apiKey}, where: 'id = ?', whereArgs: [id]);
  Future<int> getUnreadInsightsCount() async {
    final r = await (await database).rawQuery('SELECT COUNT(*) as c FROM insights WHERE is_read = 0');
    return r.first['c'] as int;
  }

  // Settings
  Future<String?> getSetting(String key) async {
    final r = await (await database).query('settings', where: 'key = ?', whereArgs: [key]);
    return r.isNotEmpty ? r.first['value'] as String? : null;
  }
  Future<void> setSetting(String key, String value) async => (await database).insert('settings', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
}
