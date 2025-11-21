import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/rooms/data/models/room_model.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';

void main() {
  final tRoomModel = RoomModel(
    id: 'room-123',
    name: 'Test Room',
    capacity: 100,
    roomType: 'TWO_D',
    seatMapId: 'seat-map-1',
    isActive: true,
    createdAt: DateTime(2024, 1, 1),
    updatedAt: DateTime(2024, 1, 2),
    sessionsCount: 5,
  );

  test('should be a valid model', () {
    expect(tRoomModel, isA<RoomModel>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with all fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'room-123',
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'TWO_D',
        'seatMapId': 'seat-map-1',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
        '_count': {
          'sessions': 5,
        },
      };

      // Act
      final result = RoomModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'room-123');
      expect(result.name, 'Test Room');
      expect(result.capacity, 100);
      expect(result.roomType, 'TWO_D');
      expect(result.seatMapId, 'seat-map-1');
      expect(result.isActive, true);
      expect(result.sessionsCount, 5);
    });

    test('should return model with isActive=true when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'room-123',
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'TWO_D',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final result = RoomModel.fromJson(jsonMap);

      // Assert
      expect(result.isActive, true);
    });

    test('should return model with null seatMapId when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'room-123',
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'THREE_D',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final result = RoomModel.fromJson(jsonMap);

      // Assert
      expect(result.seatMapId, null);
    });

    test('should return model with null sessionsCount when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'room-123',
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'EXTREME',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      // Act
      final result = RoomModel.fromJson(jsonMap);

      // Assert
      expect(result.sessionsCount, null);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tRoomModel.toJson();

      // Assert
      final expectedMap = {
        'id': 'room-123',
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'TWO_D',
        'seatMapId': 'seat-map-1',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };
      expect(result, equals(expectedMap));
    });

    test('should include null seatMapId in JSON when it is null', () {
      // Arrange
      final modelWithoutSeatMap = RoomModel(
        id: 'room-123',
        name: 'Test Room',
        capacity: 100,
        roomType: 'TWO_D',
        seatMapId: null,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      );

      // Act
      final result = modelWithoutSeatMap.toJson();

      // Assert
      expect(result['seatMapId'], null);
    });
  });

  group('toEntity', () {
    test('should convert RoomModel to Room entity with all fields', () {
      // Act
      final result = tRoomModel.toEntity();

      // Assert
      expect(result, isA<Room>());
      expect(result.id, 'room-123');
      expect(result.name, 'Test Room');
      expect(result.capacity, 100);
      expect(result.roomType, RoomType.twoD);
      expect(result.seatMapId, 'seat-map-1');
      expect(result.isActive, true);
      expect(result.sessionsCount, 5);
    });

    test('should convert THREE_D roomType correctly', () {
      // Arrange
      final modelThreeD = RoomModel(
        id: 'room-123',
        name: 'Test Room 3D',
        capacity: 120,
        roomType: 'THREE_D',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final result = modelThreeD.toEntity();

      // Assert
      expect(result.roomType, RoomType.threeD);
    });

    test('should convert EXTREME roomType correctly', () {
      // Arrange
      final modelExtreme = RoomModel(
        id: 'room-123',
        name: 'Test Room Extreme',
        capacity: 150,
        roomType: 'EXTREME',
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      // Act
      final result = modelExtreme.toEntity();

      // Assert
      expect(result.roomType, RoomType.extreme);
    });

    test('should handle null optional fields correctly', () {
      // Arrange
      final modelMinimal = RoomModel(
        id: 'room-123',
        name: 'Minimal Room',
        capacity: 80,
        roomType: 'TWO_D',
        seatMapId: null,
        isActive: true,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        sessionsCount: null,
      );

      // Act
      final result = modelMinimal.toEntity();

      // Assert
      expect(result.seatMapId, null);
      expect(result.sessionsCount, null);
    });
  });
}
