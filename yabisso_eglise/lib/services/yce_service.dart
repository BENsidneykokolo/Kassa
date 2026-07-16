import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum YCEMode { idle, searching, hotspot, client }

enum YCEStatus { disconnected, connecting, connected, syncing }

class YCEPeer {
  final String id;
  final String name;
  final int batteryLevel;
  final String appVersion;
  final DateTime lastSeen;

  YCEPeer({
    required this.id,
    required this.name,
    this.batteryLevel = 100,
    this.appVersion = '1.0.0',
    DateTime? lastSeen,
  }) : lastSeen = lastSeen ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'battery_level': batteryLevel,
    'app_version': appVersion,
    'last_seen': lastSeen.toIso8601String(),
  };

  factory YCEPeer.fromJson(Map<String, dynamic> json) => YCEPeer(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    batteryLevel: json['battery_level'] ?? 100,
    appVersion: json['app_version'] ?? '1.0.0',
    lastSeen: DateTime.tryParse(json['last_seen'] ?? '') ?? DateTime.now(),
  );
}

class YCEService {
  static final YCEService instance = YCEService._init();
  YCEService._init();

  String _localId = '';
  String _localName = '';
  YCEMode _mode = YCEMode.idle;
  YCEStatus _status = YCEStatus.disconnected;
  final Map<String, YCEPeer> _peers = {};

  Timer? _searchTimer;
  Timer? _hotspotTimer;
  Timer? _cycleTimer;

  final StreamController<YCEMode> _modeController = StreamController<YCEMode>.broadcast();
  final StreamController<YCEStatus> _statusController = StreamController<YCEStatus>.broadcast();
  final StreamController<List<YCEPeer>> _peersController = StreamController<List<YCEPeer>>.broadcast();

  Stream<YCEMode> get modeStream => _modeController.stream;
  Stream<YCEStatus> get statusStream => _statusController.stream;
  Stream<List<YCEPeer>> get peersStream => _peersController.stream;

  YCEMode get mode => _mode;
  YCEStatus get status => _status;
  List<YCEPeer> get peers => _peers.values.toList();

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _localId = prefs.getString('yce_device_id') ?? '';
    if (_localId.isEmpty) {
      _localId = const Uuid().v4().substring(0, 8).toUpperCase();
      await prefs.setString('yce_device_id', _localId);
    }
    _localName = prefs.getString('church_name') ?? 'Yabisso Eglise';
  }

  Future<void> startDiscovery() async {
    _mode = YCEMode.searching;
    _modeController.add(_mode);
    _status = YCEStatus.connecting;
    _statusController.add(_status);

    _searchTimer?.cancel();
    _hotspotTimer?.cancel();
    _cycleTimer?.cancel();

    _runSearchCycle();
  }

  void _runSearchCycle() {
    const searchDuration = Duration(seconds: 20);
    const hotspotDuration = Duration(seconds: 5);

    _searchTimer = Timer(searchDuration, () {
      if (_peers.isEmpty) {
        _becomeHotspot(hotspotDuration);
      } else {
        _electHotspot();
      }
    });
  }

  void _becomeHotspot(Duration duration) async {
    _mode = YCEMode.hotspot;
    _modeController.add(_mode);

    _hotspotTimer = Timer(duration, () {
      _mode = YCEMode.searching;
      _modeController.add(_mode);
      _runSearchCycle();
    });
  }

  void _electHotspot() {
    if (_peers.isEmpty) return;

    final allIds = [_localId, ..._peers.values.map((p) => p.id)];
    allIds.sort();

    if (allIds.first == _localId) {
      _becomeHotspot(const Duration(seconds: 5));
    } else {
      _mode = YCEMode.client;
      _modeController.add(_mode);
      _connectToHotspot();
    }
  }

  void _connectToHotspot() async {
    _status = YCEStatus.connecting;
    _statusController.add(_status);

    await Future.delayed(const Duration(seconds: 2));

    _status = YCEStatus.connected;
    _statusController.add(_status);

    _runSync();
  }

  void _runSync() async {
    _status = YCEStatus.syncing;
    _statusController.add(_status);

    await Future.delayed(const Duration(seconds: 3));

    _status = YCEStatus.connected;
    _statusController.add(_status);

    _cycleTimer = Timer(const Duration(seconds: 25), () {
      _runSearchCycle();
    });
  }

  void onPeerDiscovered(YCEPeer peer) {
    _peers[peer.id] = peer;
    _peersController.add(peers);
  }

  void onPeerLost(String peerId) {
    _peers.remove(peerId);
    _peersController.add(peers);
  }

  String getLocalId() => _localId;
  String getLocalName() => _localName;

  Map<String, String> getHandshakeData() {
    return {
      'id': _localId,
      'name': _localName,
      'app_version': '1.0.0',
      'mode': _mode.name,
    };
  }

  void stop() {
    _searchTimer?.cancel();
    _hotspotTimer?.cancel();
    _cycleTimer?.cancel();
    _mode = YCEMode.idle;
    _status = YCEStatus.disconnected;
    _modeController.add(_mode);
    _statusController.add(_status);
  }

  void dispose() {
    stop();
    _modeController.close();
    _statusController.close();
    _peersController.close();
  }
}
