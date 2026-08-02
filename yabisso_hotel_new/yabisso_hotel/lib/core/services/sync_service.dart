import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import 'connectivity_service.dart';

/// Squelette du moteur de synchronisation offline-first.
///
/// Principe (aligné sur l'écosystème Yabisso) :
/// - Toute écriture locale (réservation, commande, pointage...) est stockée
///   dans SQLite avec une colonne `synced` (0/1).
/// - Dès que la connectivité revient, on envoie par lots (batch) les lignes
///   `synced = 0` vers le backend, puis on les marque `synced = 1`.
/// - Ce service ne fait pour l'instant que gérer l'état visuel
///   (offline / syncing / synced) ; le vrai transport réseau est à brancher
///   plus tard (Supabase / API Yabisso).
class SyncService extends StateNotifier<SyncState> {
  SyncService(this._ref) : super(SyncState.offline) {
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      next.whenData((online) => online ? _runSync() : state = SyncState.offline);
    });
  }

  final Ref _ref;

  Future<void> _runSync() async {
    state = SyncState.syncing;
    // TODO: brancher ici l'envoi réel des lignes non synchronisées
    // (réservations, commandes, pointages, mouvements de stock...)
    await Future.delayed(const Duration(milliseconds: 600));
    state = SyncState.synced;
  }

  Future<void> forceSync() => _runSync();
}

final syncServiceProvider = StateNotifierProvider<SyncService, SyncState>((ref) {
  return SyncService(ref);
});
