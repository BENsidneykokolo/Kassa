// ============================================================
// drive_sync_service.dart
// Service de synchronisation Google Drive — Yabissokassa
// Architecture : delta JSON toutes les 5 min, sans serveur
// ============================================================

import 'dart:convert';
import 'dart:io';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

// -------------------------------------------------------
// MODÈLE DELTA
// -------------------------------------------------------
class DeltaPayload {
  final String deviceId;       // "boutique" ou "proprietaire"
  final DateTime timestamp;
  final List<Map<String, dynamic>> ventes;
  final List<Map<String, dynamic>> produits;
  final List<Map<String, dynamic>> stocks;
  final List<Map<String, dynamic>> clients;
  final List<Map<String, dynamic>> depenses;

  DeltaPayload({
    required this.deviceId,
    required this.timestamp,
    required this.ventes,
    required this.produits,
    required this.stocks,
    required this.clients,
    required this.depenses,
  });

  Map<String, dynamic> toJson() => {
    'deviceId': deviceId,
    'timestamp': timestamp.toIso8601String(),
    'ventes': ventes,
    'produits': produits,
    'stocks': stocks,
    'clients': clients,
    'depenses': depenses,
  };

  factory DeltaPayload.fromJson(Map<String, dynamic> json) => DeltaPayload(
    deviceId: json['deviceId'],
    timestamp: DateTime.parse(json['timestamp']),
    ventes: List<Map<String, dynamic>>.from(json['ventes'] ?? []),
    produits: List<Map<String, dynamic>>.from(json['produits'] ?? []),
    stocks: List<Map<String, dynamic>>.from(json['stocks'] ?? []),
    clients: List<Map<String, dynamic>>.from(json['clients'] ?? []),
    depenses: List<Map<String, dynamic>>.from(json['depenses'] ?? []),
  );

  bool get isEmpty =>
    ventes.isEmpty &&
    produits.isEmpty &&
    stocks.isEmpty &&
    clients.isEmpty &&
    depenses.isEmpty;
}

// -------------------------------------------------------
// CLIENT HTTP AUTHENTIFIÉ GOOGLE
// -------------------------------------------------------
class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._headers);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _client.send(request..headers.addAll(_headers));
  }
}

// -------------------------------------------------------
// SERVICE PRINCIPAL
// -------------------------------------------------------
class DriveSyncService {
  static const String _webClientId =
      '619625415079-tc4if41m9166l8jq4edp6jdad9lkpbga.apps.googleusercontent.com';

  static const String _folderName = 'YabissoKassa_Sync';
  static const String _snapshotFile = 'snapshot_complet.json';
  static const String _lastSyncKey = 'last_sync_timestamp';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: [
      'email',
      'https://www.googleapis.com/auth/drive.file',
    ],
  );

  drive.DriveApi? _driveApi;
  String? _folderId;
  DateTime? _lastSyncTime;

  // -------------------------------------------------------
  // CONNEXION
  // -------------------------------------------------------
  Future<bool> signIn() async {
    try {
      await _googleSignIn.disconnect();
      final account = await _googleSignIn.signIn();
      if (account == null) return false;

      final auth = await account.authentication;
      final client = _GoogleAuthClient({
        'Authorization': 'Bearer ${auth.accessToken}',
        'X-Goog-AuthUser': '0',
      });

      _driveApi = drive.DriveApi(client);
      _folderId = await _getOrCreateFolder();
      return true;
    } catch (e) {
      print('[DriveSyncService] Erreur signIn: $e');
      return false;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _driveApi = null;
    _folderId = null;
  }

  bool get isSignedIn => _driveApi != null;

  // -------------------------------------------------------
  // DOSSIER YABISSOKASSA SUR DRIVE
  // -------------------------------------------------------
  Future<String> _getOrCreateFolder() async {
    final result = await _driveApi!.files.list(
      q: "name='$_folderName' and mimeType='application/vnd.google-apps.folder' and trashed=false",
      spaces: 'drive',
    );

    if (result.files != null && result.files!.isNotEmpty) {
      return result.files!.first.id!;
    }

    // Créer le dossier s'il n'existe pas
    final folder = drive.File()
      ..name = _folderName
      ..mimeType = 'application/vnd.google-apps.folder';

    final created = await _driveApi!.files.create(folder);
    return created.id!;
  }

  // -------------------------------------------------------
  // UPLOAD DELTA (boutique → Drive)
  // -------------------------------------------------------
  Future<bool> uploadDelta(DeltaPayload delta) async {
    if (_driveApi == null || _folderId == null) return false;
    if (delta.isEmpty) {
      print('[DriveSyncService] Rien à envoyer — delta vide');
      return true;
    }

    try {
      final timestamp = delta.timestamp
          .toIso8601String()
          .replaceAll(':', '-')
          .replaceAll('.', '-');
      final fileName = 'delta_${delta.deviceId}_$timestamp.json';
      final content = jsonEncode(delta.toJson());
      final bytes = utf8.encode(content);

      final file = drive.File()
        ..name = fileName
        ..parents = [_folderId!];

      await _driveApi!.files.create(
        file,
        uploadMedia: drive.Media(
          Stream.value(bytes),
          bytes.length,
          contentType: 'application/json',
        ),
      );

      _lastSyncTime = delta.timestamp;
      print('[DriveSyncService] Delta uploadé : $fileName');
      return true;
    } catch (e) {
      print('[DriveSyncService] Erreur upload: $e');
      return false;
    }
  }

  // -------------------------------------------------------
  // DOWNLOAD DELTAS (Drive → propriétaire)
  // -------------------------------------------------------
  Future<List<DeltaPayload>> downloadNewDeltas({
    required String excludeDeviceId, // ne pas télécharger ses propres deltas
  }) async {
    if (_driveApi == null || _folderId == null) return [];

    try {
      // Filtrer par date si on a déjà syncé
      String query = "'$_folderId' in parents and name contains 'delta_' and trashed=false";

      final result = await _driveApi!.files.list(
        q: query,
        orderBy: 'createdTime asc',
        spaces: 'drive',
        $fields: 'files(id, name, createdTime)',
      );

      if (result.files == null || result.files!.isEmpty) return [];

      final List<DeltaPayload> payloads = [];

      for (final file in result.files!) {
        // Ignorer ses propres deltas
        if (file.name!.contains(excludeDeviceId)) continue;

        // Ignorer les deltas déjà traités
        if (_lastSyncTime != null &&
            file.createdTime != null &&
            file.createdTime!.isBefore(_lastSyncTime!)) continue;

        final media = await _driveApi!.files.get(
          file.id!,
          downloadOptions: drive.DownloadOptions.fullMedia,
        ) as drive.Media;

        final chunks = <List<int>>[];
        await for (final chunk in media.stream) {
          chunks.add(chunk);
        }
        final content = utf8.decode(chunks.expand((e) => e).toList());
        final payload = DeltaPayload.fromJson(jsonDecode(content));
        payloads.add(payload);
      }

      if (payloads.isNotEmpty) {
        _lastSyncTime = DateTime.now();
      }

      print('[DriveSyncService] ${payloads.length} delta(s) téléchargés');
      return payloads;
    } catch (e) {
      print('[DriveSyncService] Erreur download: $e');
      return [];
    }
  }

  // -------------------------------------------------------
  // SNAPSHOT COMPLET (premier clone de la boutique)
  // -------------------------------------------------------
  Future<bool> uploadSnapshot(Map<String, dynamic> fullData) async {
    if (_driveApi == null || _folderId == null) return false;

    try {
      // Supprimer l'ancien snapshot s'il existe
      final existing = await _driveApi!.files.list(
        q: "'$_folderId' in parents and name='$_snapshotFile' and trashed=false",
        spaces: 'drive',
      );
      if (existing.files != null && existing.files!.isNotEmpty) {
        await _driveApi!.files.delete(existing.files!.first.id!);
      }

      final content = jsonEncode({
        'timestamp': DateTime.now().toIso8601String(),
        'data': fullData,
      });
      final bytes = utf8.encode(content);

      final file = drive.File()
        ..name = _snapshotFile
        ..parents = [_folderId!];

      await _driveApi!.files.create(
        file,
        uploadMedia: drive.Media(
          Stream.value(bytes),
          bytes.length,
          contentType: 'application/json',
        ),
      );

      print('[DriveSyncService] Snapshot complet uploadé');
      return true;
    } catch (e) {
      print('[DriveSyncService] Erreur snapshot upload: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> downloadSnapshot() async {
    if (_driveApi == null || _folderId == null) return null;

    try {
      final result = await _driveApi!.files.list(
        q: "'$_folderId' in parents and name='$_snapshotFile' and trashed=false",
        spaces: 'drive',
      );

      if (result.files == null || result.files!.isEmpty) return null;

      final media = await _driveApi!.files.get(
        result.files!.first.id!,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final chunks = <List<int>>[];
      await for (final chunk in media.stream) {
        chunks.add(chunk);
      }
      final content = utf8.decode(chunks.expand((e) => e).toList());
      final json = jsonDecode(content);
      print('[DriveSyncService] Snapshot téléchargé');
      return json['data'];
    } catch (e) {
      print('[DriveSyncService] Erreur snapshot download: $e');
      return null;
    }
  }

  // -------------------------------------------------------
  // NETTOYAGE des vieux deltas (> 7 jours)
  // -------------------------------------------------------
  Future<void> cleanOldDeltas() async {
    if (_driveApi == null || _folderId == null) return;

    try {
      final cutoff = DateTime.now().subtract(const Duration(days: 7));
      final result = await _driveApi!.files.list(
        q: "'$_folderId' in parents and name contains 'delta_' and trashed=false",
        spaces: 'drive',
        $fields: 'files(id, createdTime)',
      );

      if (result.files == null) return;

      for (final file in result.files!) {
        if (file.createdTime != null && file.createdTime!.isBefore(cutoff)) {
          await _driveApi!.files.delete(file.id!);
        }
      }
      print('[DriveSyncService] Nettoyage des vieux deltas terminé');
    } catch (e) {
      print('[DriveSyncService] Erreur nettoyage: $e');
    }
  }
}
