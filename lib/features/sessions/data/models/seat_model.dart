import '../../domain/entities/seat.dart';

class SeatModel extends Seat {
  const SeatModel({
    required super.id,
    required super.seatNumber,
    required super.row,
    required super.column,
    required super.type,
    required super.status,
    required super.price,
    super.isAccessible,
  });

  factory SeatModel.fromJson(Map<String, dynamic> json) {
    return SeatModel(
      id: json['id'] as String,
      seatNumber: json['seatNumber'] as String? ?? json['id'] as String,
      row: json['row'] as String? ?? json['rowLabel'] as String? ?? 'A',
      column: json['column'] as int? ?? json['number'] as int? ?? 1,
      type: json['type'] as String? ?? 'STANDARD',
      status: json['status'] as String,
      price: double.parse(json['price']?.toString() ?? '0'),
      isAccessible: json['isAccessible'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seatNumber': seatNumber,
      'row': row,
      'column': column,
      'type': type,
      'status': status,
      'price': price,
      'isAccessible': isAccessible,
    };
  }

  Seat toEntity() {
    return Seat(
      id: id,
      seatNumber: seatNumber,
      row: row,
      column: column,
      type: type,
      status: status,
      price: price,
      isAccessible: isAccessible,
    );
  }
}
