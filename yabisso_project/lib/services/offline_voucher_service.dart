import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineVoucherService {
  static const _usedVouchersKey = 'used_offline_vouchers';

  static String generateBoutiqueId(String phone, String name) {
    final phoneClean = phone.replaceAll(RegExp(r'[^0-9]'), '');
    final last4 = phoneClean.length >= 4 ? phoneClean.substring(phoneClean.length - 4) : phoneClean;
    final initials = name.split(' ').where((n) => n.isNotEmpty).map((n) => n[0].toUpperCase()).join('');
    return 'B-$last4-$initials';
  }

  static String _hashBoutiqueId(String boutiqueId) {
    int hash = 0;
    for (var i = 0; i < boutiqueId.length; i++) {
      hash = ((hash << 5) - hash) + boutiqueId.codeUnitAt(i);
      hash = hash.toSigned(32);
    }
    final positive = hash.abs();
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    var result = '';
    var num = positive;
    for (var i = 0; i < 4; i++) {
      result = '${chars[num % chars.length]}$result';
      num = num ~/ chars.length;
    }
    return result;
  }

  static String? _extractBoutiqueHash(String code) {
    final parts = code.split('-');
    if (parts.length != 3 || parts[0] != 'OFF') return null;
    return parts[1];
  }

  static bool _codeBelongsToBoutique(String code, String boutiqueId) {
    final codeHash = _extractBoutiqueHash(code);
    if (codeHash == null) return false;
    final expectedHash = _hashBoutiqueId(boutiqueId);
    return codeHash == expectedHash;
  }

  static Future<void> saveBoutiqueId(String boutiqueId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('boutique_id', boutiqueId);
  }

  static Future<String?> getBoutiqueId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('boutique_id');
  }

  static Future<String?> getOrCreateBoutiqueId() async {
    final existing = await getBoutiqueId();
    if (existing != null) return existing;
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    if (!isLoggedIn) return null;
    const secureStorage = FlutterSecureStorage();
    final phone = await secureStorage.read(key: 'user_phone');
    final name = prefs.getString('user_name');
    if (phone == null || name == null) return null;
    final boutiqueId = generateBoutiqueId(phone, name);
    await saveBoutiqueId(boutiqueId);
    return boutiqueId;
  }

  static Future<bool> isCodeUsed(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getStringList(_usedVouchersKey) ?? [];
    return used.contains(code);
  }

  static Future<void> markCodeUsed(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final used = prefs.getStringList(_usedVouchersKey) ?? [];
    used.add(code);
    await prefs.setStringList(_usedVouchersKey, used);
  }

  static String? extractPlanFromCode(String code) {
    final parts = code.trim().toUpperCase().split('-');
    if (parts.length != 3 || parts[0] != 'OFF' || parts[2].isEmpty) return null;
    switch (parts[2][0]) {
      case 'M': return 'MICRO';
      case 'B': return 'BASIC';
      case 'P': return 'PREMIUM';
      case 'U': return 'UNLIMITED';
      default: return 'BASIC';
    }
  }

  static int? getMaxProductsForPlan(String plan) {
    switch (plan) {
      case 'MICRO': return 10;
      case 'BASIC': return 25;
      case 'PREMIUM': return 50;
      case 'UNLIMITED': return null;
      default: return 25;
    }
  }

  static Future<String?> validateOfflineVoucher(String code, String boutiqueId) async {
    final trimmedCode = code.trim().toUpperCase();
    final parts = trimmedCode.split('-');
    if (parts.length != 3 || parts[0] != 'OFF') return 'Code invalide. Format: OFF-XXXX-XXXX';
    if (!_codeBelongsToBoutique(trimmedCode, boutiqueId)) return 'Ce code ne vous appartient pas';
    if (await isCodeUsed(trimmedCode)) return 'Ce code a déjà été utilisé';
    return null;
  }
}
