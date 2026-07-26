import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/campaign.dart';
import '../models/promotion.dart';
import '../models/coupon.dart';
import '../models/vendor.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('yabisso_marketing.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE campaigns (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        message TEXT NOT NULL,
        segment TEXT NOT NULL,
        status TEXT NOT NULL,
        scheduledAt TEXT,
        sentAt TEXT,
        recipientsCount INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE promotions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        discountType TEXT NOT NULL,
        discountValue REAL NOT NULL,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE coupons (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        discountType TEXT NOT NULL,
        discountValue REAL NOT NULL,
        minPurchase REAL DEFAULT 0,
        maxUses INTEGER DEFAULT 0,
        usedCount INTEGER DEFAULT 0,
        startDate TEXT NOT NULL,
        endDate TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE vendors (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL,
        phone TEXT NOT NULL,
        businessName TEXT NOT NULL,
        businessType TEXT NOT NULL,
        address TEXT NOT NULL,
        profileImage TEXT,
        isActive INTEGER DEFAULT 1,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');
  }

  // Campaign operations
  Future<void> insertCampaign(Campaign campaign) async {
    final db = await database;
    await db.insert('campaigns', campaign.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Campaign>> getCampaigns() async {
    final db = await database;
    final maps = await db.query('campaigns', orderBy: 'createdAt DESC');
    return maps.map((map) => Campaign.fromMap(map)).toList();
  }

  Future<List<Campaign>> getCampaignsByStatus(String status) async {
    final db = await database;
    final maps = await db.query('campaigns',
        where: 'status = ?', whereArgs: [status], orderBy: 'createdAt DESC');
    return maps.map((map) => Campaign.fromMap(map)).toList();
  }

  Future<Campaign?> getCampaign(String id) async {
    final db = await database;
    final maps = await db.query('campaigns', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Campaign.fromMap(maps.first);
  }

  Future<void> updateCampaign(Campaign campaign) async {
    final db = await database;
    await db.update('campaigns', campaign.toMap(),
        where: 'id = ?', whereArgs: [campaign.id]);
  }

  Future<void> deleteCampaign(String id) async {
    final db = await database;
    await db.delete('campaigns', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getCampaignsCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM campaigns');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Promotion operations
  Future<void> insertPromotion(Promotion promotion) async {
    final db = await database;
    await db.insert('promotions', promotion.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Promotion>> getPromotions() async {
    final db = await database;
    final maps = await db.query('promotions', orderBy: 'createdAt DESC');
    return maps.map((map) => Promotion.fromMap(map)).toList();
  }

  Future<Promotion?> getPromotion(String id) async {
    final db = await database;
    final maps = await db.query('promotions', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Promotion.fromMap(maps.first);
  }

  Future<void> updatePromotion(Promotion promotion) async {
    final db = await database;
    await db.update('promotions', promotion.toMap(),
        where: 'id = ?', whereArgs: [promotion.id]);
  }

  Future<void> deletePromotion(String id) async {
    final db = await database;
    await db.delete('promotions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> getActivePromotionsCount() async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    final result = await db.rawQuery(
        "SELECT COUNT(*) as count FROM promotions WHERE isActive = 1 AND endDate > ?",
        [now]);
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Coupon operations
  Future<void> insertCoupon(Coupon coupon) async {
    final db = await database;
    await db.insert('coupons', coupon.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Coupon>> getCoupons() async {
    final db = await database;
    final maps = await db.query('coupons', orderBy: 'createdAt DESC');
    return maps.map((map) => Coupon.fromMap(map)).toList();
  }

  Future<Coupon?> getCoupon(String id) async {
    final db = await database;
    final maps = await db.query('coupons', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Coupon.fromMap(maps.first);
  }

  Future<Coupon?> getCouponByCode(String code) async {
    final db = await database;
    final maps =
        await db.query('coupons', where: 'code = ?', whereArgs: [code]);
    if (maps.isEmpty) return null;
    return Coupon.fromMap(maps.first);
  }

  Future<void> updateCoupon(Coupon coupon) async {
    final db = await database;
    await db.update('coupons', coupon.toMap(),
        where: 'id = ?', whereArgs: [coupon.id]);
  }

  Future<void> deleteCoupon(String id) async {
    final db = await database;
    await db.delete('coupons', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> incrementCouponUsage(String id) async {
    final db = await database;
    await db.rawUpdate('UPDATE coupons SET usedCount = usedCount + 1 WHERE id = ?',
        [id]);
  }

  Future<int> getTotalCouponUsage() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT COALESCE(SUM(usedCount), 0) as total FROM coupons');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Vendor operations
  Future<void> insertVendor(Vendor vendor) async {
    final db = await database;
    await db.insert('vendors', vendor.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Vendor>> getVendors() async {
    final db = await database;
    final maps = await db.query('vendors', orderBy: 'createdAt DESC');
    return maps.map((map) => Vendor.fromMap(map)).toList();
  }

  Future<Vendor?> getVendor(String id) async {
    final db = await database;
    final maps = await db.query('vendors', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Vendor.fromMap(maps.first);
  }

  Future<void> updateVendor(Vendor vendor) async {
    final db = await database;
    await db.update('vendors', vendor.toMap(),
        where: 'id = ?', whereArgs: [vendor.id]);
  }

  Future<void> deleteVendor(String id) async {
    final db = await database;
    await db.delete('vendors', where: 'id = ?', whereArgs: [id]);
  }

  // Settings operations
  Future<void> setSetting(String key, String value) async {
    final db = await database;
    await db.insert('settings', {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<String?> getSetting(String key) async {
    final db = await database;
    final maps =
        await db.query('settings', where: 'key = ?', whereArgs: [key]);
    if (maps.isEmpty) return null;
    return maps.first['value'] as String;
  }

  Future<void> deleteSetting(String key) async {
    final db = await database;
    await db.delete('settings', where: 'key = ?', whereArgs: [key]);
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
