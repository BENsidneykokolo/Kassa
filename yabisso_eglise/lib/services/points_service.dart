import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class PointsService {
  static final PointsService instance = PointsService._init();
  PointsService._init();

  final _random = Random();

  String generateCode() {
    String segment() {
      final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      return List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    }
    return 'PTS-${segment()}-${segment()}-${segment()}';
  }

  Future<bool> validateCode(String code) async {
    final pattern = RegExp(r'^PTS-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    if (!pattern.hasMatch(code)) return false;

    final prefs = await SharedPreferences.getInstance();
    final usedCodes = prefs.getStringList('used_pts_codes') ?? [];
    if (usedCodes.contains(code)) return false;

    usedCodes.add(code);
    await prefs.setStringList('used_pts_codes', usedCodes);
    return true;
  }

  Future<int> getBalance() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('pts_balance') ?? 0;
  }

  Future<void> addPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pts_balance') ?? 0;
    await prefs.setInt('pts_balance', current + amount);
  }

  Future<void> deductPoints(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt('pts_balance') ?? 0;
    if (current >= amount) {
      await prefs.setInt('pts_balance', current - amount);
    }
  }

  Future<void> redeemCode(String code) async {
    final isValid = await validateCode(code);
    if (isValid) {
      await addPoints(1000);
    }
  }
}
