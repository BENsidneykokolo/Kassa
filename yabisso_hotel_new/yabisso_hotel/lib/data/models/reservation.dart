import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class Reservation extends Equatable {
  final String id;
  final String guestId;
  final String guestName;
  final String roomId;
  final String roomNumber;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guestsCount;
  final ReservationStatus status;
  final bool breakfastIncluded;
  final double deposit;
  final double totalAmount;

  const Reservation({
    required this.id,
    required this.guestId,
    required this.guestName,
    required this.roomId,
    required this.roomNumber,
    required this.checkIn,
    required this.checkOut,
    required this.status,
    this.guestsCount = 1,
    this.breakfastIncluded = false,
    this.deposit = 0,
    this.totalAmount = 0,
  });

  @override
  List<Object?> get props => [id, guestId, roomId, checkIn, checkOut, status];
}
