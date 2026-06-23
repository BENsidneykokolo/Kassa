// ============================================================
// GUIDE D'UTILISATION — Yabissokassa Sync
// ============================================================

// -------------------------------------------------------
// 1. AJOUTER DANS pubspec.yaml
// -------------------------------------------------------
/*
dependencies:
  flutter:
    sdk: flutter
  google_sign_in: ^6.2.1
  googleapis: ^13.2.0
  http: ^1.2.0
  sqflite: ^2.3.0
  path_provider: ^2.1.2
  path: ^1.9.0
*/

// -------------------------------------------------------
// 2. SCHÉMA SQLITE REQUIS
// Toutes les tables doivent avoir : id, updated_at, deleted_at
// Le champ updated_at est la clé du système delta
// -------------------------------------------------------
/*
CREATE TABLE ventes (
  id          TEXT PRIMARY KEY,   -- UUID unique
  produit_id  TEXT NOT NULL,
  client_id   TEXT,
  quantite    REAL NOT NULL,
  prix_unit   REAL NOT NULL,
  total       REAL NOT NULL,
  vendeur     TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL,      -- MIS À JOUR à chaque modification
  deleted_at  TEXT                -- Soft delete
);

CREATE TABLE produits (
  id          TEXT PRIMARY KEY,
  nom         TEXT NOT NULL,
  description TEXT,
  prix_achat  REAL,
  prix_vente  REAL NOT NULL,
  categorie   TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL,
  deleted_at  TEXT
);

CREATE TABLE stocks (
  id          TEXT PRIMARY KEY,
  produit_id  TEXT NOT NULL,
  quantite    REAL NOT NULL,
  seuil_alerte REAL DEFAULT 0,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL,
  deleted_at  TEXT
);

CREATE TABLE clients (
  id          TEXT PRIMARY KEY,
  nom         TEXT NOT NULL,
  telephone   TEXT,
  email       TEXT,
  adresse     TEXT,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL,
  deleted_at  TEXT
);

CREATE TABLE depenses (
  id          TEXT PRIMARY KEY,
  description TEXT NOT NULL,
  montant     REAL NOT NULL,
  categorie   TEXT,
  date_depense TEXT NOT NULL,
  created_at  TEXT NOT NULL,
  updated_at  TEXT NOT NULL,
  deleted_at  TEXT
);
*/

// -------------------------------------------------------
// 3. INITIALISATION DANS main.dart
// -------------------------------------------------------

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'drive_sync_service.dart';
import 'sync_manager.dart';

late SyncManager syncManager;

Future<void> initSync(Database db, DeviceType type) async {
  final driveService = DriveSyncService();

  // Connexion Google
  final signedIn = await driveService.signIn();
  if (!signedIn) {
    print('Connexion Google échouée');
    return;
  }

  syncManager = SyncManager(
    driveService: driveService,
    db: db,
    deviceType: type,
    deviceId: type == DeviceType.boutique ? 'boutique_001' : 'proprietaire',
    onDeltaReceived: (delta) {
      // Rafraîchir l'UI quand de nouvelles données arrivent
      print('Nouvelles données reçues de ${delta.deviceId}');
      // Ex: setState(() {}) ou notifier un Provider/Riverpod
    },
  );

  // Premier démarrage du propriétaire : cloner la boutique
  if (type == DeviceType.proprietaire) {
    await syncManager.cloneFromBoutique();
  }

  // Démarrer la sync automatique toutes les 5 min
  syncManager.startAutoSync();
}

// -------------------------------------------------------
// 4. IMPORTANT : updated_at à chaque INSERT / UPDATE
// Toujours mettre à jour updated_at quand tu modifies
// -------------------------------------------------------

Future<void> ajouterVente(Database db, Map<String, dynamic> vente) async {
  final now = DateTime.now().toIso8601String();
  await db.insert('ventes', {
    ...vente,
    'id': vente['id'] ?? _generateUUID(),
    'created_at': now,
    'updated_at': now,   // <-- OBLIGATOIRE pour le delta
  });
}

Future<void> modifierProduit(Database db, String id, Map<String, dynamic> data) async {
  await db.update(
    'produits',
    {
      ...data,
      'updated_at': DateTime.now().toIso8601String(),  // <-- OBLIGATOIRE
    },
    where: 'id = ?',
    whereArgs: [id],
  );
}

// Soft delete (ne jamais supprimer physiquement — sync oblige)
Future<void> supprimerProduit(Database db, String id) async {
  await db.update(
    'produits',
    {'deleted_at': DateTime.now().toIso8601String(), 'updated_at': DateTime.now().toIso8601String()},
    where: 'id = ?',
    whereArgs: [id],
  );
}

String _generateUUID() {
  // Utilise le package uuid: ^4.0.0
  // return const Uuid().v4();
  return DateTime.now().millisecondsSinceEpoch.toString();
}

// -------------------------------------------------------
// 5. BOUTON "SYNC MAINTENANT" dans l'UI
// -------------------------------------------------------
/*
ElevatedButton(
  onPressed: () async {
    await syncManager.syncNow();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Synchronisation terminée')),
    );
  },
  child: const Text('Synchroniser maintenant'),
)
*/

// -------------------------------------------------------
// 6. BOUTON "PUBLIER SNAPSHOT" (boutique, 1 seule fois)
// -------------------------------------------------------
/*
ElevatedButton(
  onPressed: () async {
    await syncManager.publishSnapshot();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Boutique publiée sur Drive')),
    );
  },
  child: const Text('Partager ma boutique'),
)
*/
