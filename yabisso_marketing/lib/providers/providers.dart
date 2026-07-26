import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database_helper.dart';
import '../models/campaign.dart';
import '../models/promotion.dart';
import '../models/coupon.dart';
import '../models/vendor.dart';
import '../services/offline_voucher_service.dart';
import '../services/points_service.dart';

// Database provider
final databaseProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

// Services providers
final voucherServiceProvider = Provider<OfflineVoucherService>((ref) {
  return OfflineVoucherService();
});

final pointsServiceProvider = Provider<PointsService>((ref) {
  return PointsService();
});

// Campaign providers
final campaignsProvider =
    StateNotifierProvider<CampaignsNotifier, AsyncValue<List<Campaign>>>(
        (ref) {
  return CampaignsNotifier(ref);
});

class CampaignsNotifier extends StateNotifier<AsyncValue<List<Campaign>>> {
  final Ref ref;

  CampaignsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCampaigns();
  }

  Future<void> loadCampaigns() async {
    state = const AsyncValue.loading();
    try {
      final campaigns = await ref.read(databaseProvider).getCampaigns();
      state = AsyncValue.data(campaigns);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCampaign(Campaign campaign) async {
    await ref.read(databaseProvider).insertCampaign(campaign);
    await loadCampaigns();
  }

  Future<void> updateCampaign(Campaign campaign) async {
    await ref.read(databaseProvider).updateCampaign(campaign);
    await loadCampaigns();
  }

  Future<void> deleteCampaign(String id) async {
    await ref.read(databaseProvider).deleteCampaign(id);
    await loadCampaigns();
  }
}

final campaignsByStatusProvider =
    FutureProvider.family<List<Campaign>, String>((ref, status) async {
  return ref.read(databaseProvider).getCampaignsByStatus(status);
});

final campaignsCountProvider = FutureProvider<int>((ref) async {
  return ref.read(databaseProvider).getCampaignsCount();
});

// Promotion providers
final promotionsProvider =
    StateNotifierProvider<PromotionsNotifier, AsyncValue<List<Promotion>>>(
        (ref) {
  return PromotionsNotifier(ref);
});

class PromotionsNotifier extends StateNotifier<AsyncValue<List<Promotion>>> {
  final Ref ref;

  PromotionsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadPromotions();
  }

  Future<void> loadPromotions() async {
    state = const AsyncValue.loading();
    try {
      final promotions = await ref.read(databaseProvider).getPromotions();
      state = AsyncValue.data(promotions);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addPromotion(Promotion promotion) async {
    await ref.read(databaseProvider).insertPromotion(promotion);
    await loadPromotions();
  }

  Future<void> updatePromotion(Promotion promotion) async {
    await ref.read(databaseProvider).updatePromotion(promotion);
    await loadPromotions();
  }

  Future<void> togglePromotion(Promotion promotion) async {
    final updated = promotion.copyWith(isActive: !promotion.isActive);
    await ref.read(databaseProvider).updatePromotion(updated);
    await loadPromotions();
  }

  Future<void> deletePromotion(String id) async {
    await ref.read(databaseProvider).deletePromotion(id);
    await loadPromotions();
  }
}

final activePromotionsCountProvider = FutureProvider<int>((ref) async {
  return ref.read(databaseProvider).getActivePromotionsCount();
});

// Coupon providers
final couponsProvider =
    StateNotifierProvider<CouponsNotifier, AsyncValue<List<Coupon>>>((ref) {
  return CouponsNotifier(ref);
});

class CouponsNotifier extends StateNotifier<AsyncValue<List<Coupon>>> {
  final Ref ref;

  CouponsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadCoupons();
  }

  Future<void> loadCoupons() async {
    state = const AsyncValue.loading();
    try {
      final coupons = await ref.read(databaseProvider).getCoupons();
      state = AsyncValue.data(coupons);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addCoupon(Coupon coupon) async {
    await ref.read(databaseProvider).insertCoupon(coupon);
    await loadCoupons();
  }

  Future<void> updateCoupon(Coupon coupon) async {
    await ref.read(databaseProvider).updateCoupon(coupon);
    await loadCoupons();
  }

  Future<void> deleteCoupon(String id) async {
    await ref.read(databaseProvider).deleteCoupon(id);
    await loadCoupons();
  }
}

final totalCouponUsageProvider = FutureProvider<int>((ref) async {
  return ref.read(databaseProvider).getTotalCouponUsage();
});

// Vendor providers
final vendorsProvider =
    StateNotifierProvider<VendorsNotifier, AsyncValue<List<Vendor>>>((ref) {
  return VendorsNotifier(ref);
});

class VendorsNotifier extends StateNotifier<AsyncValue<List<Vendor>>> {
  final Ref ref;

  VendorsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadVendors();
  }

  Future<void> loadVendors() async {
    state = const AsyncValue.loading();
    try {
      final vendors = await ref.read(databaseProvider).getVendors();
      state = AsyncValue.data(vendors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVendor(Vendor vendor) async {
    await ref.read(databaseProvider).insertVendor(vendor);
    await loadVendors();
  }

  Future<void> updateVendor(Vendor vendor) async {
    await ref.read(databaseProvider).updateVendor(vendor);
    await loadVendors();
  }

  Future<void> deleteVendor(String id) async {
    await ref.read(databaseProvider).deleteVendor(id);
    await loadVendors();
  }
}

// Auth provider
final currentVendorProvider = StateProvider<Vendor?>((ref) => null);

final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(currentVendorProvider) != null;
});
