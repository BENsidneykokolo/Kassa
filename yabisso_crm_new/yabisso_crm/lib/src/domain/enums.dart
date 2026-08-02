/// Type de contact CRM.
enum ContactType { particulier, entreprise }

/// Origine d'un contact — utile pour mesurer quels canaux ramènent des
/// prospects (important pour Yabisso Marketing en aval).
enum ContactSource {
  visiteSpontanee,
  whatsapp,
  appelTelephonique,
  recommandation,
  reseauxSociaux,
  siteWeb,
  salon,
  autre,
}

extension ContactSourceX on ContactSource {
  String get label {
    switch (this) {
      case ContactSource.visiteSpontanee:
        return 'Visite spontanée';
      case ContactSource.whatsapp:
        return 'WhatsApp';
      case ContactSource.appelTelephonique:
        return 'Appel téléphonique';
      case ContactSource.recommandation:
        return 'Recommandation';
      case ContactSource.reseauxSociaux:
        return 'Réseaux sociaux';
      case ContactSource.siteWeb:
        return 'Site web';
      case ContactSource.salon:
        return 'Salon / événement';
      case ContactSource.autre:
        return 'Autre';
    }
  }
}

/// Étape du pipeline commercial. Ordre = ordre d'affichage des colonnes
/// kanban. Volontairement simple et fixe pour la V1 — une version
/// ultérieure pourra rendre les étapes configurables par entreprise.
enum OpportunityStage {
  nouveau,
  qualifie,
  propositionEnvoyee,
  negociation,
  gagne,
  perdu,
}

extension OpportunityStageX on OpportunityStage {
  String get label {
    switch (this) {
      case OpportunityStage.nouveau:
        return 'Nouveau';
      case OpportunityStage.qualifie:
        return 'Qualifié';
      case OpportunityStage.propositionEnvoyee:
        return 'Proposition envoyée';
      case OpportunityStage.negociation:
        return 'Négociation';
      case OpportunityStage.gagne:
        return 'Gagné';
      case OpportunityStage.perdu:
        return 'Perdu';
    }
  }

  bool get isClosed => this == OpportunityStage.gagne || this == OpportunityStage.perdu;
}

/// Type d'interaction loguée sur la fiche 360° d'un contact.
enum InteractionType {
  appel,
  whatsapp,
  sms,
  email,
  visite,
  reunion,
  achat, // remontée automatique depuis Kassa/Facture
  reservation, // remontée automatique depuis Booking
  note,
}

extension InteractionTypeX on InteractionType {
  String get label {
    switch (this) {
      case InteractionType.appel:
        return 'Appel';
      case InteractionType.whatsapp:
        return 'WhatsApp';
      case InteractionType.sms:
        return 'SMS';
      case InteractionType.email:
        return 'E-mail';
      case InteractionType.visite:
        return 'Visite';
      case InteractionType.reunion:
        return 'Réunion';
      case InteractionType.achat:
        return 'Achat';
      case InteractionType.reservation:
        return 'Réservation';
      case InteractionType.note:
        return 'Note';
    }
  }
}
