import '../../domain/entities/room.dart';

class RoomModel {
  final String id;
  final String name;
  final int capacity;
  final String roomType;
  final String? seatMapId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? sessionsCount;

  RoomModel({
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

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      roomType: json['roomType'] as String,
      seatMapId: json['seatMapId'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      sessionsCount: json['_count']?['sessions'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'capacity': capacity,
      'roomType': roomType,
      'seatMapId': seatMapId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Room toEntity() {
    return Room(
      id: id,
      name: name,
      capacity: capacity,
      roomType: RoomType.fromValue(roomType),
      seatMapId: seatMapId,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      sessionsCount: sessionsCount,
    );
  }
}
