// ============================================================
// sync_manager.dart
// Gestionnaire de sync automatique toutes les 5 minutes
// Gère : détection des changements, upload delta, apply delta
// ============================================================

import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'drive_sync_service.dart';

// Type de l'appareil
enum DeviceType { boutique, proprietaire }

class SyncManager {
  final DriveSyncService _driveService;
  final Database _db;
  final DeviceType deviceType;
  final String deviceId; // ex: "boutique_001" ou "proprietaire"

  Timer? _syncTimer;
  DateTime? _lastCheckTime;
  bool _isSyncing = false;

  // Callback appelé quand de nouvelles données arrivent
  final Function(DeltaPayload delta)? onDeltaReceived;

  SyncManager({
    required DriveSyncService driveService,
    required Database db,
    required this.deviceType,
    required this.deviceId,
    this.onDeltaReceived,
  })  : _driveService = driveService,
        _db = db;

  // -------------------------------------------------------
  // DÉMARRER LA SYNC AUTOMATIQUE
  // -------------------------------------------------------
  void startAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _runSync(),
    );
    print('[SyncManager] Sync automatique démarrée (toutes les 5 min)');
  }

  void stopAutoSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
    print('[SyncManager] Sync automatique arrêtée');
  }

  // -------------------------------------------------------
  // CYCLE DE SYNC COMPLET
  // -------------------------------------------------------
  Future<void> _runSync() async {
    if (_isSyncing) return;
    if (!_driveService.isSignedIn) return;

    _isSyncing = true;
    print('[SyncManager] Début sync — ${DateTime.now()}');

    try {
      // 1. Préparer et uploader le delta local
      final delta = await _buildDelta();
      if (!delta.isEmpty) {
        await _driveService.uploadDelta(delta);
        await _markAsSynced();
      }

      // 2. Télécharger les deltas des autres appareils
      final newDeltas = await _driveService.downloadNewDeltas(
        excludeDeviceId: deviceId,
      );

      // 3. Appliquer chaque delta reçu
      for (final incoming in newDeltas) {
        await _applyDelta(incoming);
        onDeltaReceived?.call(incoming);
      }

      // 4. Nettoyage hebdomadaire (1 chance sur 12 = ~1x par heure)
      if (DateTime.now().minute < 5) {
        await _driveService.cleanOldDeltas();
      }
    } catch (e) {
      print('[SyncManager] Erreur sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  // Sync manuelle (bouton "Synchroniser maintenant")
  Future<void> syncNow() => _runSync();

  // -------------------------------------------------------
  // CONSTRUIRE LE DELTA DEPUIS SQLITE
  // Récupère uniquement les enregistrements modifiés
  // depuis la dernière sync (champ updated_at)
  // -------------------------------------------------------
  Future<DeltaPayload> _buildDelta() async {
    final since = _lastCheckTime ?? DateTime(2000);
    final sinceStr = since.toIso8601String();

    final ventes = await _db.query(
      'ventes',
      where: 'updated_at > ?',
      whereArgs: [sinceStr],
    );
    final produits = await _db.query(
      'produits',
      where: 'updated_at > ?',
      whereArgs: [sinceStr],
    );
    final stocks = await _db.query(
      'stocks',
      where: 'updated_at > ?',
      whereArgs: [sinceStr],
    );
    final clients = await _db.query(
      'clients',
      where: 'updated_at > ?',
      whereArgs: [sinceStr],
    );
    final depenses = await _db.query(
      'depenses',
      where: 'updated_at > ?',
      whereArgs: [sinceStr],
    );

    return DeltaPayload(
      deviceId: deviceId,
      timestamp: DateTime.now(),
      ventes: ventes.cast<Map<String, dynamic>>(),
      produits: produits.cast<Map<String, dynamic>>(),
      stocks: stocks.cast<Map<String, dynamic>>(),
      clients: clients.cast<Map<String, dynamic>>(),
      depenses: depenses.cast<Map<String, dynamic>>(),
    );
  }

  // -------------------------------------------------------
  // APPLIQUER UN DELTA REÇU DANS SQLITE
  // Stratégie : le timestamp le plus récent gagne (last-write-wins)
  // -------------------------------------------------------
  Future<void> _applyDelta(DeltaPayload delta) async {
    print('[SyncManager] Application delta de ${delta.deviceId}');

    await _upsertRows('ventes', delta.ventes);
    await _upsertRows('produits', delta.produits);
    await _upsertRows('stocks', delta.stocks);
    await _upsertRows('clients', delta.clients);
    await _upsertRows('depenses', delta.depenses);
  }

  Future<void> _upsertRows(
    String table,
    List<Map<String, dynamic>> rows,
  ) async {
    for (final row in rows) {
      // Vérifier si l'enregistrement existe localement
      final existing = await _db.query(
        table,
        where: 'id = ?',
        whereArgs: [row['id']],
      );

      if (existing.isEmpty) {
        // Insertion
        await _db.insert(table, row);
      } else {
        // Comparer les timestamps — le plus récent gagne
        final localUpdatedAt = DateTime.parse(existing.first['updated_at'] as String);
        final remoteUpdatedAt = DateTime.parse(row['updated_at'] as String);

        if (remoteUpdatedAt.isAfter(localUpdatedAt)) {
          await _db.update(
            table,
            row,
            where: 'id = ?',
            whereArgs: [row['id']],
          );
        }
      }
    }
  }

  // -------------------------------------------------------
  // MARQUER LA SYNC COMME EFFECTUÉE
  // -------------------------------------------------------
  Future<void> _markAsSynced() async {
    _lastCheckTime = DateTime.now();
  }

  // -------------------------------------------------------
  // PREMIER DÉMARRAGE : snapshot complet
  // À appeler quand le propriétaire installe l'app
  // -------------------------------------------------------
  Future<bool> cloneFromBoutique() async {
    print('[SyncManager] Téléchargement du snapshot complet...');
    final snapshot = await _driveService.downloadSnapshot();
    if (snapshot == null) {
      print('[SyncManager] Aucun snapshot trouvé sur Drive');
      return false;
    }

    // Insérer toutes les données dans SQLite local
    await _db.transaction((txn) async {
      for (final table in ['ventes', 'produits', 'stocks', 'clients', 'depenses']) {
        final rows = snapshot[table] as List<dynamic>? ?? [];
        for (final row in rows) {
          await txn.insert(
            table,
            Map<String, dynamic>.from(row),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    });

    _lastCheckTime = DateTime.now();
    print('[SyncManager] Clone terminé avec succès');
    return true;
  }

  // À appeler depuis la boutique pour publier le snapshot initial
  Future<bool> publishSnapshot() async {
    final data = <String, dynamic>{};
    for (final table in ['ventes', 'produits', 'stocks', 'clients', 'depenses']) {
      data[table] = await _db.query(table);
    }
    return _driveService.uploadSnapshot(data);
  }

  void dispose() {
    stopAutoSync();
  }
}
