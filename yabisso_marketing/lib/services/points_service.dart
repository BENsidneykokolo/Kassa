import '../database/database_helper.dart';

class PointsService {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<int> getTotalPointsEarned(String vendorId) async {
    final setting = await _db.getSetting('points_$vendorId');
    return int.tryParse(setting ?? '0') ?? 0;
  }

  Future<void> addPoints(String vendorId, int points) async {
    final current = await getTotalPointsEarned(vendorId);
    await _db.setSetting('points_$vendorId', (current + points).toString());
  }

  Future<void> redeemPoints(String vendorId, int points) async {
    final current = await getTotalPointsEarned(vendorId);
    final newAmount = (current - points).clamp(0, current);
    await _db.setSetting('points_$vendorId', newAmount.toString());
  }

  Future<Map<String, dynamic>> getPointsSummary(String vendorId) async {
    final total = await getTotalPointsEarned(vendorId);
    return {
      'totalPoints': total,
      'tier': _getTier(total),
      'nextTier': _getNextTier(total),
      'pointsToNextTier': _getPointsToNextTier(total),
    };
  }

  String _getTier(int points) {
    if (points >= 10000) return 'Or';
    if (points >= 5000) return 'Argent';
    if (points >= 1000) return 'Bronze';
    return 'Standard';
  }

  String _getNextTier(int points) {
    if (points >= 10000) return 'Or';
    if (points >= 5000) return 'Or';
    if (points >= 1000) return 'Argent';
    return 'Bronze';
  }

  int _getPointsToNextTier(int points) {
    if (points >= 10000) return 0;
    if (points >= 5000) return 10000 - points;
    if (points >= 1000) return 5000 - points;
    return 1000 - points;
  }
}
