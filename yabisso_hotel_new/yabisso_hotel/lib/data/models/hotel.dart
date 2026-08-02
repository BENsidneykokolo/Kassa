import 'package:equatable/equatable.dart';

class HotelProfile extends Equatable {
  final String id;
  final String name;
  final String city;
  final String country;
  final int roomCount;
  final int floorCount;

  const HotelProfile({
    required this.id,
    required this.name,
    required this.city,
    required this.country,
    required this.roomCount,
    required this.floorCount,
  });

  @override
  List<Object?> get props => [id, name];
}
