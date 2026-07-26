import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static const planPrices = {'MICRO': 1000, 'BASIC': 1500, 'PREMIUM': 3000, 'UNLIMITED': 5000};
  static const planLabels = {'MICRO': 'Micro (30j)', 'BASIC': 'Basic (30j)', 'PREMIUM': 'Premium (30j)', 'UNLIMITED': 'Illimite (30j)'};

  static Future<int> getPointsBalance() async { final p = await SharedPreferences.getInstance(); return p.getInt('points_balance') ?? 0; }
  static Future<void> addPoints(int amount) async { final p = await SharedPreferences.getInstance(); final current = p.getInt('points_balance') ?? 0; await p.setInt('points_balance', current + amount); }
  static Future<void> deductPoints(int amount) async { final p = await SharedPreferences.getInstance(); final current = p.getInt('points_balance') ?? 0; await p.setInt('points_balance', (current - amount).clamp(0, 999999)); }
  static Future<String?> validatePointsVoucher(String code, String boutiqueId) async { return null; }
  static int extractPointsAmount(String code) { return 0; }
  static Future<void> markCodeUsed(String code) async { final p = await SharedPreferences.getInstance(); final used = p.getStringList('used_points_codes') ?? []; used.add(code); await p.setStringList('used_points_codes', used); }
}
