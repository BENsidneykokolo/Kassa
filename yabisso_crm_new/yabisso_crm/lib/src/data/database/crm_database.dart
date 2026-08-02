import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

part 'crm_database.g.dart';

/// Colonnes communes à toutes les tables synchronisables — même pattern que
/// Yabisso Stock / Kassa, pour rester cohérent dans tout le monorepo.
mixin SyncColumns on Table {
  TextColumn get id => text().clientDefault(() => const Uuid().v4())();
  TextColumn get tenantId => text()();
  BoolColumn get dirty => boolean().withDefault(const Constant(true))();
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

// ---------------------------------------------------------------------------
// CONTACTS — fusionne particuliers et entreprises clientes/prospects.
// Un contact peut aussi être un client Kassa/Facture/Booking : le lien se
// fait par `linkedCatalogCustomerId` (FK logique vers le client partagé).
// ---------------------------------------------------------------------------
class Contacts extends Table with SyncColumns {
  TextColumn get type => text()(); // ContactType.name
  TextColumn get fullName => text()();
  TextColumn get companyName => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get whatsappNumber => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get source => text().nullable()(); // ContactSource.name
  TextColumn get linkedCustomerId =>
      text().nullable()(); // FK logique -> client Kassa/Facture/Booking
  TextColumn get assignedToEmployeeId => text().nullable()(); // commercial responsable
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// TAGS / SEGMENTS — pour cibler des campagnes Marketing/SMS/WhatsApp.
// ---------------------------------------------------------------------------
class Tags extends Table with SyncColumns {
  TextColumn get name => text()();
  TextColumn get color => text().withDefault(const Constant('#4C6FFF'))();

  @override
  Set<Column> get primaryKey => {id};
}

class ContactTags extends Table with SyncColumns {
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// OPPORTUNITÉS — une ligne = une affaire en cours dans le pipeline.
// ---------------------------------------------------------------------------
class Opportunities extends Table with SyncColumns {
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get title => text()();
  RealColumn get estimatedValue => real().withDefault(const Constant(0))();
  TextColumn get stage => text()(); // OpportunityStage.name
  DateTimeColumn get expectedCloseDate => dateTime().nullable()();
  TextColumn get assignedToEmployeeId => text().nullable()();
  TextColumn get lostReason => text().nullable()(); // renseigné si stage == perdu
  IntColumn get pipelinePosition =>
      integer().withDefault(const Constant(0))(); // ordre dans la colonne kanban

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// INTERACTIONS — journal 360° d'un contact. Certaines lignes sont créées
// manuellement (appel, visite, note), d'autres remontent automatiquement
// depuis d'autres modules (achat Kassa, réservation Booking, message
// WhatsApp) via des adaptateurs côté application (voir crm_service.dart).
// ---------------------------------------------------------------------------
class Interactions extends Table with SyncColumns {
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get opportunityId =>
      text().nullable().references(Opportunities, #id)();
  TextColumn get type => text()(); // InteractionType.name
  TextColumn get summary => text()();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get createdByEmployeeId => text().nullable()();
  TextColumn get externalRef =>
      text().nullable()(); // id de vente/facture/réservation source si auto-généré

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// RAPPELS DE SUIVI — "recontacter ce prospect le 5 août".
// ---------------------------------------------------------------------------
class FollowUpReminders extends Table with SyncColumns {
  TextColumn get contactId => text().references(Contacts, #id)();
  TextColumn get opportunityId =>
      text().nullable().references(Opportunities, #id)();
  TextColumn get note => text()();
  DateTimeColumn get dueAt => dateTime()();
  BoolColumn get done => boolean().withDefault(const Constant(false))();
  TextColumn get assignedToEmployeeId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Contacts,
    Tags,
    ContactTags,
    Opportunities,
    Interactions,
    FollowUpReminders,
  ],
)
class CrmDatabase extends _$CrmDatabase {
  CrmDatabase(super.e);

  @override
  int get schemaVersion => 1;
}
