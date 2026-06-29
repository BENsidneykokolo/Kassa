import 'package:bcrypt/bcrypt.dart';
import 'package:uuid/uuid.dart';
import '../models/admin.dart';
import 'database_helper.dart';

class AuthService {
  static final AuthService instance = AuthService._init();
  AuthService._init();

  final _db = DatabaseHelper.instance;

  Future<Admin?> loginByPhone(String phone) async {
    final maps = await _db.getAll('admins', where: 'phone = ?', whereArgs: [phone]);
    if (maps.isEmpty) return null;
    return Admin.fromMap(maps.first);
  }

  Future<bool> verifyPin(Admin admin, String pin) async {
    if (admin.pinHash == null) return false;
    return BCrypt.checkpw(pin, admin.pinHash!);
  }

  Future<void> setPin(Admin admin, String pin) async {
    final hash = BCrypt.hashpw(pin, BCrypt.gensalt());
    await _db.update('admins', {
      'pin_hash': hash,
      'updated_at': DateTime.now().toIso8601String(),
    }, admin.id);
  }

  Future<Admin> register(String name, String phone, String role) async {
    final id = const Uuid().v4();
    final now = DateTime.now().toIso8601String();
    final initials = name.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase();
    final admin = Admin(
      id: id, name: name, phone: phone, role: role,
      initials: initials, createdAt: now, updatedAt: now,
    );
    await _db.insert('admins', admin.toMap());
    await _db.logActivity(id, 'inscription', 'Nouvel admin créé: $name ($role)');
    return admin;
  }

  Future<List<Admin>> getAllAdmins() async {
    final maps = await _db.getAll('admins', orderBy: 'created_at DESC');
    return maps.map((m) => Admin.fromMap(m)).toList();
  }

  Future<void> logAction(String? adminId, String action, String? details) async {
    await _db.logActivity(adminId, action, details);
  }
}
