import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../data/database/crm_database.dart';
import '../domain/enums.dart';

/// Service métier central du CRM. Toute écriture passe par ici (jamais
/// d'INSERT direct depuis l'UI) pour que la logique de journalisation
/// automatique (voir les méthodes `logXxx`) reste cohérente et que d'autres
/// modules puissent l'appeler sans dupliquer la logique.
class CrmService {
  final CrmDatabase _db;
  final _uuid = const Uuid();
  CrmService(this._db);

  // ---------------------------------------------------------------------
  // OPPORTUNITÉS — création et déplacement dans le pipeline (kanban)
  // ---------------------------------------------------------------------
  Future<String> createOpportunity({
    required String tenantId,
    required String contactId,
    required String title,
    double estimatedValue = 0,
    DateTime? expectedCloseDate,
    String? assignedToEmployeeId,
  }) async {
    final id = _uuid.v4();
    await _db.into(_db.opportunities).insert(
          OpportunitiesCompanion.insert(
            id: Value(id),
            tenantId: tenantId,
            contactId: contactId,
            title: title,
            estimatedValue: Value(estimatedValue),
            stage: OpportunityStage.nouveau.name,
            expectedCloseDate: Value(expectedCloseDate),
            assignedToEmployeeId: Value(assignedToEmployeeId),
          ),
        );
    return id;
  }

  /// Déplace une opportunité vers une nouvelle étape (glisser-déposer dans
  /// le kanban). Journalise automatiquement le changement comme interaction
  /// pour garder une trace dans la fiche 360° du contact.
  Future<void> moveStage({
    required String opportunityId,
    required OpportunityStage newStage,
    String? lostReason,
    String? employeeId,
  }) async {
    final opp = await (_db.select(_db.opportunities)
          ..where((t) => t.id.equals(opportunityId)))
        .getSingle();

    await (_db.update(_db.opportunities)..where((t) => t.id.equals(opportunityId)))
        .write(OpportunitiesCompanion(
      stage: Value(newStage.name),
      lostReason: Value(newStage == OpportunityStage.perdu ? lostReason : null),
      dirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));

    await _logInteraction(
      tenantId: opp.tenantId,
      contactId: opp.contactId,
      opportunityId: opportunityId,
      type: InteractionType.note,
      summary: 'Opportunité "${opp.title}" déplacée vers "${newStage.label}"',
      employeeId: employeeId,
    );
  }

  // ---------------------------------------------------------------------
  // INTERACTIONS — journalisation manuelle (appel, visite, réunion, note)
  // ---------------------------------------------------------------------
  Future<void> logManualInteraction({
    required String tenantId,
    required String contactId,
    String? opportunityId,
    required InteractionType type,
    required String summary,
    String? employeeId,
  }) {
    return _logInteraction(
      tenantId: tenantId,
      contactId: contactId,
      opportunityId: opportunityId,
      type: type,
      summary: summary,
      employeeId: employeeId,
    );
  }

  // ---------------------------------------------------------------------
  // ADAPTATEURS CROSS-MODULE — appelés par les AUTRES apps Yabisso pour
  // alimenter automatiquement la fiche 360° sans que l'utilisateur ait à
  // ressaisir quoi que ce soit.
  // ---------------------------------------------------------------------

  /// À appeler par Yabisso Facture/Kassa après une vente pour lier
  /// automatiquement l'achat au contact CRM correspondant (recherché par
  /// `linkedCustomerId`, ou créé à la volée si le client n'existait pas
  /// encore côté CRM).
  Future<void> logPurchase({
    required String tenantId,
    required String linkedCustomerId,
    required String customerFullName,
    required double amount,
    required String saleExternalRef,
  }) async {
    final contactId = await _findOrCreateContactByCustomerId(
      tenantId: tenantId,
      linkedCustomerId: linkedCustomerId,
      fullName: customerFullName,
    );
    await _logInteraction(
      tenantId: tenantId,
      contactId: contactId,
      type: InteractionType.achat,
      summary: 'Achat de ${amount.toStringAsFixed(0)} FCFA',
      externalRef: saleExternalRef,
    );
  }

  /// À appeler par Yabisso Booking après une réservation confirmée.
  Future<void> logReservation({
    required String tenantId,
    required String linkedCustomerId,
    required String customerFullName,
    required String reservationSummary,
    required String reservationExternalRef,
  }) async {
    final contactId = await _findOrCreateContactByCustomerId(
      tenantId: tenantId,
      linkedCustomerId: linkedCustomerId,
      fullName: customerFullName,
    );
    await _logInteraction(
      tenantId: tenantId,
      contactId: contactId,
      type: InteractionType.reservation,
      summary: reservationSummary,
      externalRef: reservationExternalRef,
    );
  }

  /// À appeler par Yabisso WhatsApp/SMS à chaque message échangé, pour que
  /// l'historique de conversation apparaisse aussi dans la fiche CRM.
  Future<void> logMessage({
    required String tenantId,
    required String contactId,
    required InteractionType channel, // whatsapp ou sms
    required String summary,
    required String messageExternalRef,
  }) {
    return _logInteraction(
      tenantId: tenantId,
      contactId: contactId,
      type: channel,
      summary: summary,
      externalRef: messageExternalRef,
    );
  }

  // ---------------------------------------------------------------------
  // RAPPELS
  // ---------------------------------------------------------------------
  Future<void> scheduleFollowUp({
    required String tenantId,
    required String contactId,
    String? opportunityId,
    required String note,
    required DateTime dueAt,
    String? assignedToEmployeeId,
  }) async {
    await _db.into(_db.followUpReminders).insert(
          FollowUpRemindersCompanion.insert(
            id: Value(_uuid.v4()),
            tenantId: tenantId,
            contactId: contactId,
            opportunityId: Value(opportunityId),
            note: note,
            dueAt: dueAt,
            assignedToEmployeeId: Value(assignedToEmployeeId),
          ),
        );
  }

  Future<void> markReminderDone(String reminderId) async {
    await (_db.update(_db.followUpReminders)..where((t) => t.id.equals(reminderId)))
        .write(FollowUpRemindersCompanion(
      done: const Value(true),
      dirty: const Value(true),
      updatedAt: Value(DateTime.now()),
    ));
  }

  // ---------------------------------------------------------------------
  // Internes
  // ---------------------------------------------------------------------
  Future<String> _findOrCreateContactByCustomerId({
    required String tenantId,
    required String linkedCustomerId,
    required String fullName,
  }) async {
    final existing = await (_db.select(_db.contacts)
          ..where((t) =>
              t.tenantId.equals(tenantId) & t.linkedCustomerId.equals(linkedCustomerId))
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing.id;

    final id = _uuid.v4();
    await _db.into(_db.contacts).insert(
          ContactsCompanion.insert(
            id: Value(id),
            tenantId: tenantId,
            type: ContactType.particulier.name,
            fullName: fullName,
            linkedCustomerId: Value(linkedCustomerId),
          ),
        );
    return id;
  }

  Future<void> _logInteraction({
    required String tenantId,
    required String contactId,
    String? opportunityId,
    required InteractionType type,
    required String summary,
    String? employeeId,
    String? externalRef,
  }) async {
    await _db.into(_db.interactions).insert(
          InteractionsCompanion.insert(
            id: Value(_uuid.v4()),
            tenantId: tenantId,
            contactId: contactId,
            opportunityId: Value(opportunityId),
            type: type.name,
            summary: summary,
            occurredAt: DateTime.now(),
            createdByEmployeeId: Value(employeeId),
            externalRef: Value(externalRef),
          ),
        );
  }
}
