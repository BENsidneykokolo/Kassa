import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

enum OrderSource { restaurant, bar, roomService }

class OrderLine extends Equatable {
  final String productName;
  final int quantity;
  final double unitPrice;

  const OrderLine({required this.productName, required this.quantity, required this.unitPrice});

  double get total => quantity * unitPrice;

  @override
  List<Object?> get props => [productName, quantity, unitPrice];
}

class HotelOrder extends Equatable {
  final String id;
  final OrderSource source;
  final String? roomNumber;
  final String? guestName;
  final DateTime createdAt;
  final List<OrderLine> lines;
  final OrderStatus status;

  const HotelOrder({
    required this.id,
    required this.source,
    required this.createdAt,
    required this.lines,
    required this.status,
    this.roomNumber,
    this.guestName,
  });

  double get total => lines.fold(0, (sum, l) => sum + l.total);

  @override
  List<Object?> get props => [id, source, status, createdAt];
}
