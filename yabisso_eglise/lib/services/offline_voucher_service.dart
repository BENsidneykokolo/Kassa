import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class OfflineVoucherService {
  static final OfflineVoucherService instance = OfflineVoucherService._init();
  OfflineVoucherService._init();

  final _random = Random();

  String generateBoutiqueId() {
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final id = List.generate(6, (_) => chars[_random.nextInt(chars.length)]).join();
    return 'BOUT-$id';
  }

  String generateVoucherCode() {
    String segment() {
      final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      return List.generate(4, (_) => chars[_random.nextInt(chars.length)]).join();
    }
    return 'OFF-${segment()}-${segment()}-${segment()}';
  }

  Future<void> saveBoutiqueId(String boutiqueId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('boutique_id', boutiqueId);
  }

  Future<String?> getBoutiqueId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('boutique_id');
  }

  Future<bool> validateVoucher(String code) async {
    final pattern = RegExp(r'^OFF-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    if (!pattern.hasMatch(code)) return false;

    final prefs = await SharedPreferences.getInstance();
    final usedCodes = prefs.getStringList('used_off_codes') ?? [];
    if (usedCodes.contains(code)) return false;

    usedCodes.add(code);
    await prefs.setStringList('used_off_codes', usedCodes);
    return true;
  }

  Future<void> createVoucher({required double amount, required String description}) async {
    final code = generateVoucherCode();
    final prefs = await SharedPreferences.getInstance();
    final vouchers = prefs.getStringList('active_vouchers') ?? [];
    vouchers.add('$code|$amount|$description|${DateTime.now().toIso8601String()}');
    await prefs.setStringList('active_vouchers', vouchers);
  }

  Future<List<Map<String, dynamic>>> getActiveVouchers() async {
    final prefs = await SharedPreferences.getInstance();
    final vouchers = prefs.getStringList('active_vouchers') ?? [];
    return vouchers.map((v) {
      final parts = v.split('|');
      return {
        'code': parts[0],
        'amount': double.tryParse(parts[1]) ?? 0,
        'description': parts.length > 2 ? parts[2] : '',
        'created_at': parts.length > 3 ? parts[3] : '',
      };
    }).toList();
  }

  Future<void> deactivateVoucher(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final vouchers = prefs.getStringList('active_vouchers') ?? [];
    vouchers.removeWhere((v) => v.startsWith('$code|'));
    await prefs.setStringList('active_vouchers', vouchers);
  }
}
