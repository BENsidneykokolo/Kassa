import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

class Room extends Equatable {
  final String id;
  final String number;
  final String type; // Simple, Double, Suite, Deluxe...
  final int floor;
  final double pricePerNight;
  final RoomStatus status;
  final String? photoUrl;
  final String? currentGuestId;
  final List<String> amenities;

  const Room({
    required this.id,
    required this.number,
    required this.type,
    required this.floor,
    required this.pricePerNight,
    required this.status,
    this.photoUrl,
    this.currentGuestId,
    this.amenities = const [],
  });

  Room copyWith({RoomStatus? status, String? currentGuestId}) {
    return Room(
      id: id,
      number: number,
      type: type,
      floor: floor,
      pricePerNight: pricePerNight,
      status: status ?? this.status,
      photoUrl: photoUrl,
      currentGuestId: currentGuestId ?? this.currentGuestId,
      amenities: amenities,
    );
  }

  @override
  List<Object?> get props => [id, number, type, floor, pricePerNight, status, currentGuestId];
}
