import 'package:drift/drift.dart';
import '../database/crm_database.dart';

class ContactRepository {
  final CrmDatabase _db;
  ContactRepository(this._db);

  Stream<List<Contact>> watchAll(String tenantId) {
    return (_db.select(_db.contacts)
          ..where((t) => t.tenantId.equals(tenantId) & t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.fullName)]))
        .watch();
  }

  /// Recherche locale simple (nom, entreprise, téléphone). Passée sur
  /// SQLite LIKE — suffisant pour un carnet de contacts PME ; à remplacer
  /// par une table virtuelle FTS5 si le volume de contacts devient
  /// important (au-delà de quelques milliers).
  Stream<List<Contact>> search(String tenantId, String query) {
    final like = '%$query%';
    return (_db.select(_db.contacts)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.deletedAt.isNull() &
              (t.fullName.like(like) |
                  t.companyName.like(like) |
                  t.phone.like(like) |
                  t.whatsappNumber.like(like))))
        .watch();
  }

  Future<String> upsert(ContactsCompanion contact) async {
    await _db.into(_db.contacts).insertOnConflictUpdate(
          contact.copyWith(dirty: const Value(true), updatedAt: Value(DateTime.now())),
        );
    return contact.id.present ? contact.id.value : '';
  }

  Stream<List<FollowUpReminder>> watchDueReminders(String tenantId) {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return (_db.select(_db.followUpReminders)
          ..where((t) =>
              t.tenantId.equals(tenantId) &
              t.done.equals(false) &
              t.dueAt.isSmallerOrEqualValue(endOfToday) &
              t.deletedAt.isNull())
          ..orderBy([(t) => OrderingTerm(expression: t.dueAt)]))
        .watch();
  }
}
