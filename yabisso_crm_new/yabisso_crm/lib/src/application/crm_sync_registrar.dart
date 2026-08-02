import 'package:yabisso_sync/yabisso_sync.dart';
import '../data/database/crm_database.dart';

/// Déclare au SDK Yabisso Sync comment répliquer les tables du CRM via YCE.
///
/// - Interactions : append-only (un fait passé ne change jamais) -> insertOnly.
/// - Opportunities.stage : un seul commercial déplace généralement une
///   affaire à la fois -> lastWriteWins suffit ; en cas de double
///   déplacement simultané hors-ligne (rare), le dernier écrase l'autre,
///   mais l'historique reste visible via les Interactions générées.
/// - Contacts : lastWriteWins, avec priorité haute car consultés par
///   quasiment tous les autres modules (Facture, Booking, Marketing...).
class CrmSyncRegistrar {
  static void register(YabissoSync sync, CrmDatabase db) {
    sync.registerTable(
      table: db.contacts,
      priority: SyncPriority.high,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.tags,
      priority: SyncPriority.low,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.contactTags,
      priority: SyncPriority.low,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.opportunities,
      priority: SyncPriority.high,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );

    sync.registerTable(
      table: db.interactions,
      priority: SyncPriority.medium,
      conflictStrategy: ConflictStrategy.insertOnly,
    );

    sync.registerTable(
      table: db.followUpReminders,
      priority: SyncPriority.medium,
      conflictStrategy: ConflictStrategy.lastWriteWins,
    );
  }
}
