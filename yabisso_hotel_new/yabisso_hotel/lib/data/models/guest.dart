import 'package:equatable/equatable.dart';

class Guest extends Equatable {
  final String id;
  final String fullName;
  final String phone;
  final String? email;
  final String? idDocumentNumber;
  final int stayCount;
  final double totalSpent;
  final int loyaltyPoints;

  const Guest({
    required this.id,
    required this.fullName,
    required this.phone,
    this.email,
    this.idDocumentNumber,
    this.stayCount = 0,
    this.totalSpent = 0,
    this.loyaltyPoints = 0,
  });

  @override
  List<Object?> get props => [id, fullName, phone];
}
