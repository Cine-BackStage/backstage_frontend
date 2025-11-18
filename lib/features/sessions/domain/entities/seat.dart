import 'package:equatable/equatable.dart';

class Seat extends Equatable {
  final String id;
  final String seatNumber;
  final String row;
  final int column;
  final String type; // STANDARD, VIP, WHEELCHAIR
  final String status; // AVAILABLE, RESERVED, SOLD, BLOCKED
  final double price;
  final bool isAccessible;

  const Seat({
    required this.id,
    required this.seatNumber,
    required this.row,
    required this.column,
    required this.type,
    required this.status,
    required this.price,
    this.isAccessible = false,
  });

  bool get isAvailable => status == 'AVAILABLE';
  bool get isReserved => status == 'RESERVED';
  bool get isSold => status == 'SOLD';
  bool get isBlocked => status == 'BLOCKED';
  bool get isSelectable => isAvailable || isReserved;

  @override
  List<Object?> get props => [
        id,
        seatNumber,
        row,
        column,
        type,
        status,
        price,
        isAccessible,
      ];
}
