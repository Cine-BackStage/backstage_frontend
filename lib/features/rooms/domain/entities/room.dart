import 'package:equatable/equatable.dart';

enum RoomType {
  twoD('TWO_D', '2D'),
  threeD('THREE_D', '3D'),
  extreme('EXTREME', 'Extreme');

  final String value;
  final String label;

  const RoomType(this.value, this.label);

  static RoomType fromValue(String value) {
    return RoomType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => RoomType.twoD,
    );
  }
}

class Room extends Equatable {
  final String id;
  final String name;
  final int capacity;
  final RoomType roomType;
  final String? seatMapId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? sessionsCount;

  const Room({
    required this.id,
    required this.name,
    required this.capacity,
    required this.roomType,
    this.seatMapId,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.sessionsCount,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        capacity,
        roomType,
        seatMapId,
        isActive,
        createdAt,
        updatedAt,
        sessionsCount,
      ];

  Room copyWith({
    String? id,
    String? name,
    int? capacity,
    RoomType? roomType,
    String? seatMapId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? sessionsCount,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      roomType: roomType ?? this.roomType,
      seatMapId: seatMapId ?? this.seatMapId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      sessionsCount: sessionsCount ?? this.sessionsCount,
    );
  }
}
