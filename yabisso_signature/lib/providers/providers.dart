import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yabisso_signature/database/database_helper.dart';
import 'package:yabisso_signature/models/signature.dart';
import 'package:yabisso_signature/models/vendor.dart';
import 'package:yabisso_signature/services/offline_voucher_service.dart';
import 'package:yabisso_signature/services/points_service.dart';
import 'package:yabisso_signature/services/currency_service.dart';

final databaseProvider = Provider<DatabaseHelper>((ref) => DatabaseHelper.instance);

final vendorServiceProvider = Provider<OfflineVoucherService>((ref) => OfflineVoucherService.instance);

final pointsServiceProvider = Provider<PointsService>((ref) => PointsService.instance);

final currencyServiceProvider = Provider<CurrencyService>((ref) => CurrencyService());

final vendorsProvider = StateNotifierProvider<VendorsNotifier, AsyncValue<List<Vendor>>>((ref) {
  return VendorsNotifier(ref.read(databaseProvider));
});

class VendorsNotifier extends StateNotifier<AsyncValue<List<Vendor>>> {
  final DatabaseHelper _db;
  VendorsNotifier(this._db) : super(const AsyncValue.loading()) {
    loadVendors();
  }

  Future<void> loadVendors() async {
    state = const AsyncValue.loading();
    try {
      final maps = await _db.getAllVendors();
      final vendors = maps.map((m) => Vendor.fromMap(m)).toList();
      state = AsyncValue.data(vendors);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addVendor(Vendor vendor) async {
    await _db.insertVendor(vendor.toMap());
    await loadVendors();
  }

  Future<void> updateVendor(Vendor vendor) async {
    await _db.updateVendor(vendor.id, vendor.toMap());
    await loadVendors();
  }

  Future<void> deleteVendor(String id) async {
    await _db.deleteVendor(id);
    await loadVendors();
  }
}

final signaturesProvider = StateNotifierProvider<SignaturesNotifier, AsyncValue<List<SignatureModel>>>((ref) {
  return SignaturesNotifier(ref.read(databaseProvider));
});

class SignaturesNotifier extends StateNotifier<AsyncValue<List<SignatureModel>>> {
  final DatabaseHelper _db;
  SignaturesNotifier(this._db) : super(const AsyncValue.loading()) {
    loadSignatures();
  }

  Future<void> loadSignatures() async {
    state = const AsyncValue.loading();
    try {
      final maps = await _db.getAllSignatures();
      final signatures = maps.map((m) => SignatureModel.fromMap(m)).toList();
      state = AsyncValue.data(signatures);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addSignature(SignatureModel signature) async {
    await _db.insertSignature(signature.toMap());
    await loadSignatures();
  }

  Future<void> updateSignature(SignatureModel signature) async {
    await _db.updateSignature(signature.id, signature.toMap());
    await loadSignatures();
  }

  Future<void> deleteSignature(String id) async {
    await _db.deleteSignature(id);
    await loadSignatures();
  }
}

final signatureCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getSignatureCount();
});

final signedCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getSignedCount();
});

final draftCountProvider = FutureProvider<int>((ref) async {
  final db = ref.read(databaseProvider);
  return await db.getDraftCount();
});

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSignaturesProvider = Provider<AsyncValue<List<SignatureModel>>>((ref) {
  final signatures = ref.watch(signaturesProvider);
  final query = ref.watch(searchQueryProvider);

  return signatures.whenData((list) {
    if (query.isEmpty) return list;
    return list.where((s) =>
      s.documentName.toLowerCase().contains(query.toLowerCase()) ||
      s.signerName.toLowerCase().contains(query.toLowerCase()) ||
      s.signerEmail.toLowerCase().contains(query.toLowerCase())
    ).toList();
  });
});

final selectedSignatureProvider = StateProvider<SignatureModel?>((ref) => null);

final subscriptionProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {
    'plan': 'Gratuit',
    'signatures_remaining': 10,
    'pdf_remaining': 5,
    'expiry': null,
  };
});

final currentVendorProvider = StateProvider<Vendor?>((ref) => null);
