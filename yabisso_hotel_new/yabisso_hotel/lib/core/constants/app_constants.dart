/// Rôles utilisateurs de Yabisso Hôtel (écran "Vous êtes connecté en tant que").
enum StaffRole {
  proprietaire,
  manager,
  reception,
  caisse,
  restaurant,
  bar,
  housekeeping,
  maintenance,
  employe,
}

extension StaffRoleLabel on StaffRole {
  String get label {
    switch (this) {
      case StaffRole.proprietaire:
        return 'Propriétaire';
      case StaffRole.manager:
        return 'Manager';
      case StaffRole.reception:
        return 'Réception';
      case StaffRole.caisse:
        return 'Caisse';
      case StaffRole.restaurant:
        return 'Restaurant';
      case StaffRole.bar:
        return 'Bar';
      case StaffRole.housekeeping:
        return 'Housekeeping';
      case StaffRole.maintenance:
        return 'Maintenance';
      case StaffRole.employe:
        return 'Employé';
    }
  }
}

/// Statuts d'une chambre.
enum RoomStatus {
  disponible,
  occupee,
  reservee,
  nettoyage,
  inspection,
  maintenance,
  horsService,
}

extension RoomStatusLabel on RoomStatus {
  String get label {
    switch (this) {
      case RoomStatus.disponible:
        return 'Disponible';
      case RoomStatus.occupee:
        return 'Occupée';
      case RoomStatus.reservee:
        return 'Réservée';
      case RoomStatus.nettoyage:
        return 'Nettoyage';
      case RoomStatus.inspection:
        return 'Inspection';
      case RoomStatus.maintenance:
        return 'Maintenance';
      case RoomStatus.horsService:
        return 'Hors service';
    }
  }
}

/// Statuts d'une commande (restaurant / bar / room service).
enum OrderStatus { nouvelle, acceptee, enPreparation, prete, livree, terminee }

extension OrderStatusLabel on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.nouvelle:
        return 'Nouvelle';
      case OrderStatus.acceptee:
        return 'Acceptée';
      case OrderStatus.enPreparation:
        return 'En préparation';
      case OrderStatus.prete:
        return 'Prête';
      case OrderStatus.livree:
        return 'Livrée';
      case OrderStatus.terminee:
        return 'Terminée';
    }
  }
}

/// Statuts de réservation.
enum ReservationStatus { enAttente, confirmee, annulee }

extension ReservationStatusLabel on ReservationStatus {
  String get label {
    switch (this) {
      case ReservationStatus.enAttente:
        return 'En attente';
      case ReservationStatus.confirmee:
        return 'Confirmée';
      case ReservationStatus.annulee:
        return 'Annulée';
    }
  }
}

/// État de synchronisation offline-first.
enum SyncState { offline, syncing, synced }
