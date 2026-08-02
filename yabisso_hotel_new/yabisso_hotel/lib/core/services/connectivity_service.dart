import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service de détection de connectivité, base du mode "offline-first".
/// Le reste de l'app (SyncService) s'appuie sur cet état pour déclencher
/// la synchronisation dès que le réseau redevient disponible.
class ConnectivityService {
  final _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  Stream<bool> get onStatusChange => _controller.stream;

  Future<void> start() async {
    final initial = await Connectivity().checkConnectivity();
    _controller.add(_isOnline(initial));
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      _controller.add(_isOnline(result));
    });
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      results.any((r) => r != ConnectivityResult.none);

  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService()..start();
  ref.onDispose(service.dispose);
  return service;
});

/// true = en ligne, false = hors-ligne.
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onStatusChange;
});
