import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const _balanceKey = 'points_balance';
  static const _usedVouchersKey = 'used_points_vouchers';

  static const planPrices = {
    'MICRO': 3500,
    'BASIC': 5000,
    'PREMIUM': 8000,
    'UNLIMITED': 10000,
  };

  static const planLabels = {
    'MICRO': 'Micro (10 produits)',
    'BASIC': 'Basique (25 produits)',
    'PREMIUM': 'Premium (50 produits)',
    'UNLIMITED': 'Illimite',
  };

  static const planLimits = {
    'MICRO': 10,
    'BASIC': 25,
    'PREMIUM': 50,
    'UNLIMITED': null,
  };

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
    if (parts.length != 4 || parts[0] != 'PTS') return null;
    return parts[1];
  }

  static bool _codeBelongsToBoutique(String code, String boutiqueId) {
    final codeHash = _extractBoutiqueHash(code);
    if (codeHash == null) return false;
    return codeHash == _hashBoutiqueId(boutiqueId);
  }

  static Future<int> getPointsBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_balanceKey) ?? 0;
  }

  static Future<void> savePointsBalance(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_balanceKey, amount);
  }

  static Future<void> addPoints(int amount) async {
    final current = await getPointsBalance();
    await savePointsBalance(current + amount);
  }

  static Future<bool> deductPoints(int amount) async {
    final current = await getPointsBalance();
    if (current < amount) return false;
    await savePointsBalance(current - amount);
    return true;
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

  static Future<String?> validatePointsVoucher(String code, String boutiqueId) async {
    final trimmedCode = code.trim().toUpperCase();
    final parts = trimmedCode.split('-');
    if (parts.length != 4 || parts[0] != 'PTS') {
      return 'Code invalide. Format: PTS-XXXX-XXXX-XXXX';
    }
    if (!_codeBelongsToBoutique(trimmedCode, boutiqueId)) {
      return 'Ce code ne vous appartient pas';
    }
    if (await isCodeUsed(trimmedCode)) {
      return 'Ce code a deja ete utilise';
    }
    return null;
  }

  static int extractPointsAmount(String code) {
    final parts = code.split('-');
    if (parts.length != 4) return 0;
    try {
      return int.parse(parts[2], radix: 16);
    } catch (_) {
      return 0;
    }
  }
}
