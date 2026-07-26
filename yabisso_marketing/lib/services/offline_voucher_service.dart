import 'package:uuid/uuid.dart';
import '../database/database_helper.dart';
import '../models/coupon.dart';

class OfflineVoucherService {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _uuid = const Uuid();

  Future<Coupon> createCoupon({
    required String code,
    required String discountType,
    required double discountValue,
    double minPurchase = 0,
    int maxUses = 0,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final coupon = Coupon(
      id: _uuid.v4(),
      code: code.toUpperCase(),
      discountType: discountType,
      discountValue: discountValue,
      minPurchase: minPurchase,
      maxUses: maxUses,
      usedCount: 0,
      startDate: startDate,
      endDate: endDate,
      isActive: true,
      createdAt: DateTime.now(),
    );

    await _db.insertCoupon(coupon);
    return coupon;
  }

  Future<bool> validateCoupon(String code, double purchaseAmount) async {
    final coupon = await _db.getCouponByCode(code.toUpperCase());
    if (coupon == null) return false;
    if (!coupon.isCurrentlyValid) return false;
    if (coupon.minPurchase > 0 && purchaseAmount < coupon.minPurchase) return false;
    return true;
  }

  Future<double> applyCoupon(String code, double purchaseAmount) async {
    final coupon = await _db.getCouponByCode(code.toUpperCase());
    if (coupon == null || !coupon.isCurrentlyValid) return purchaseAmount;

    double discount = 0;
    if (coupon.discountType == 'pourcentage') {
      discount = purchaseAmount * (coupon.discountValue / 100);
    } else {
      discount = coupon.discountValue;
    }

    if (discount > purchaseAmount) discount = purchaseAmount;

    await _db.incrementCouponUsage(coupon.id);
    return purchaseAmount - discount;
  }

  Future<List<Coupon>> getActiveCoupons() async {
    final coupons = await _db.getCoupons();
    return coupons.where((c) => c.isCurrentlyValid).toList();
  }

  Future<void> deactivateCoupon(String id) async {
    final coupon = await _db.getCoupon(id);
    if (coupon != null) {
      await _db.updateCoupon(coupon.copyWith(isActive: false));
    }
  }

  Future<void> deleteCoupon(String id) async {
    await _db.deleteCoupon(id);
  }
}
