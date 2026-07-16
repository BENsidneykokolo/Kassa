import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/yce_service.dart';

class HotspotSyncScreen extends ConsumerStatefulWidget {
  const HotspotSyncScreen({super.key});

  @override
  ConsumerState<HotspotSyncScreen> createState() => _HotspotSyncScreenState();
}

class _HotspotSyncScreenState extends ConsumerState<HotspotSyncScreen> {
  String _syncMode = 'automatic';
  YCEMode _currentMode = YCEMode.idle;
  YCEStatus _currentStatus = YCEStatus.disconnected;
  List<YCEPeer> _peers = [];
  StreamSubscription<YCEMode>? _modeSub;
  StreamSubscription<YCEStatus>? _statusSub;
  StreamSubscription<List<YCEPeer>>? _peersSub;

  @override
  void initState() {
    super.initState();
    _initYCE();
  }

  Future<void> _initYCE() async {
    final yce = ref.read(yceServiceProvider);
    await yce.init();
    _modeSub = yce.modeStream.listen((m) {
      if (mounted) setState(() => _currentMode = m);
    });
    _statusSub = yce.statusStream.listen((s) {
      if (mounted) setState(() => _currentStatus = s);
    });
    _peersSub = yce.peersStream.listen((p) {
      if (mounted) setState(() => _peers = p);
    });
  }

  @override
  void dispose() {
    _modeSub?.cancel();
    _statusSub?.cancel();
    _peersSub?.cancel();
    super.dispose();
  }

  void _startSync() {
    final yce = ref.read(yceServiceProvider);
    yce.startDiscovery();
  }

  void _stopSync() {
    ref.read(yceServiceProvider).stop();
  }

  void _sendData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Envoi des données en cours...'),
        backgroundColor: AppColors.secondary,
      ),
    );
  }

  void _receiveData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reception des données en cours...'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _getModeLabel() {
    switch (_currentMode) {
      case YCEMode.idle: return 'Inactif';
      case YCEMode.searching: return 'Recherche...';
      case YCEMode.hotspot: return 'Hotspot actif';
      case YCEMode.client: return 'Connecté en client';
    }
  }

  String _getStatusLabel() {
    switch (_currentStatus) {
      case YCEStatus.disconnected: return 'Déconnecté';
      case YCEStatus.connecting: return 'Connexion...';
      case YCEStatus.connected: return 'Connecté';
      case YCEStatus.syncing: return 'Synchronisation...';
    }
  }

  Color _getStatusColor() {
    switch (_currentStatus) {
      case YCEStatus.disconnected: return Colors.grey;
      case YCEStatus.connecting: return Colors.orange;
      case YCEStatus.connected: return Colors.green;
      case YCEStatus.syncing: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('YCE Hotspot Sync'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(Icons.wifi_tethering, color: AppColors.secondary, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'Yabisso Connectivity Engine',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusLabel(),
                  style: TextStyle(color: _getStatusColor(), fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Mode de synchronisation', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          _buildModeCard(
            'automatic',
            'Mode Automatique',
            'Recommandé - Découverte BLE, élection de hotspot, transfert WiFi',
            Icons.auto_awesome,
          ),
          const SizedBox(height: 8),
          _buildModeCard(
            'manual',
            'Mode Manuel',
            'Contrôle manuel: Envoyer ou Recevoir',
            Icons.tune,
          ),
          const SizedBox(height: 8),
          _buildModeCard(
            'fallback',
            'Mode Secours',
            'Cycle: Recherche 20s → Hotspot 5s → Recherche 20s',
            Icons.build,
          ),
          const SizedBox(height: 24),
          if (_syncMode == 'manual') ...[
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _sendData,
                    icon: const Icon(Icons.upload, color: Colors.white),
                    label: const Text('Envoyer', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _receiveData,
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Recevoir', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _currentMode == YCEMode.idle ? _startSync : _stopSync,
                icon: Icon(
                  _currentMode == YCEMode.idle ? Icons.play_arrow : Icons.stop,
                  color: Colors.white,
                ),
                label: Text(
                  _currentMode == YCEMode.idle ? 'Démarrer la synchronisation' : 'Arrêter',
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentMode == YCEMode.idle ? AppColors.secondary : AppColors.error,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _buildStatusSection(),
          const SizedBox(height: 16),
          _buildPeersSection(),
        ],
      ),
    );
  }

  Widget _buildModeCard(String mode, String title, String subtitle, IconData icon) {
    final isSelected = _syncMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _syncMode = mode),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 14, fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('État', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildStatusRow('Mode', _getModeLabel()),
            _buildStatusRow('Connexion', _getStatusLabel()),
            _buildStatusRow('Appareils détectés', '${_peers.length}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: AppColors.onSurfaceVariant)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPeersSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Appareils découverts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            if (_peers.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(Icons.devices_other, size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 8),
                      Text('Aucun appareil détecté', style: TextStyle(color: Colors.grey[500])),
                      const SizedBox(height: 4),
                      Text(
                        'Activez le WiFi et Bluetooth\nsur les autres appareils',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ),
              )
            else
              ..._peers.map((peer) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.secondaryContainer,
                  child: const Icon(Icons.phone_android, color: AppColors.primary),
                ),
                title: Text(peer.name),
                subtitle: Text('ID: ${peer.id}'),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('En ligne', style: TextStyle(fontSize: 11, color: Colors.green)),
                ),
              )),
          ],
        ),
      ),
    );
  }
}
