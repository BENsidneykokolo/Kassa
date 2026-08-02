import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Badge de statut coloré, réutilisé pour chambres, commandes, réservations,
/// présence employé, tickets maintenance, etc.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({super.key, required this.label, required this.color});

  factory StatusBadge.room(RoomStatus status) {
    final Color color;
    switch (status) {
      case RoomStatus.disponible:
        color = AppColors.roomAvailable;
      case RoomStatus.occupee:
        color = AppColors.roomOccupied;
      case RoomStatus.reservee:
        color = AppColors.roomReserved;
      case RoomStatus.nettoyage:
        color = AppColors.roomCleaning;
      case RoomStatus.inspection:
        color = AppColors.roomInspection;
      case RoomStatus.maintenance:
        color = AppColors.roomMaintenance;
      case RoomStatus.horsService:
        color = AppColors.roomOutOfService;
    }
    return StatusBadge(label: status.label, color: color);
  }

  factory StatusBadge.order(OrderStatus status) {
    final Color color;
    switch (status) {
      case OrderStatus.nouvelle:
        color = AppColors.info;
      case OrderStatus.acceptee:
        color = AppColors.primaryLight;
      case OrderStatus.enPreparation:
        color = AppColors.warning;
      case OrderStatus.prete:
        color = AppColors.success;
      case OrderStatus.livree:
        color = AppColors.roomMaintenance;
      case OrderStatus.terminee:
        color = AppColors.textSecondary;
    }
    return StatusBadge(label: status.label, color: color);
  }

  factory StatusBadge.reservation(ReservationStatus status) {
    final Color color;
    switch (status) {
      case ReservationStatus.enAttente:
        color = AppColors.warning;
      case ReservationStatus.confirmee:
        color = AppColors.success;
      case ReservationStatus.annulee:
        color = AppColors.danger;
    }
    return StatusBadge(label: status.label, color: color);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}
