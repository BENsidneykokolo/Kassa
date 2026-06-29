import 'dart:math';

class VoucherGeneratorService {
  static const _chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  static const _planChars = {'MICRO': 'M', 'BASIC': 'B', 'PREMIUM': 'P', 'UNLIMITED': 'U'};
  static const _businessPrefixes = {'boutique': 'B', 'restaurant': 'R', 'hotel': 'H'};

  static String _hashId(String id) {
    int hash = 0;
    for (var i = 0; i < id.length; i++) {
      hash = ((hash << 5) - hash) + id.codeUnitAt(i);
      hash |= 0;
    }
    final positive = hash.abs();
    var result = '';
    var num = positive;
    for (var i = 0; i < 4; i++) {
      result = '${_chars[num % _chars.length]}$result';
      num = num ~/ _chars.length;
    }
    return result;
  }

  static String _randomChars(int length) {
    final rng = Random();
    return List.generate(length, (_) => _chars[rng.nextInt(_chars.length)]).join();
  }

  /// Generate an offline voucher code
  /// businessType: 'boutique', 'restaurant', 'hotel'
  /// businessId: the full ID like B-4567-JP, R-1234-MK, H-5678-AB
  static String generateOfflineVoucher(String businessType, String businessId, String plan) {
    final hash = _hashId(businessId);
    final planChar = _planChars[plan] ?? 'B';
    final random = _randomChars(3);
    return 'OFF-$hash-$planChar$random';
  }

  /// Generate a points voucher code
  static String generatePointsVoucher(String businessType, String businessId, int points) {
    final hash = _hashId(businessId);
    final hexPoints = points.toRadixString(16).toUpperCase().padLeft(3, '0');
    final check = _randomChars(2);
    return 'PTS-$hash-$hexPoints-$check';
  }
}
