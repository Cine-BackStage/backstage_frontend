import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/rooms/data/datasources/rooms_remote_datasource.dart';
import 'package:backstage_frontend/features/rooms/data/models/room_model.dart';
import 'package:backstage_frontend/features/rooms/data/repositories/rooms_repository_impl.dart';
import 'package:backstage_frontend/features/rooms/domain/entities/room.dart';

class MockRoomsRemoteDataSource extends Mock implements RoomsRemoteDataSource {}

void main() {
  late RoomsRepositoryImpl repository;
  late MockRoomsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockRoomsRemoteDataSource();
    repository = RoomsRepositoryImpl(mockRemoteDataSource);
  });

  final tRoomModels = [
    RoomModel(
      id: 'room-1',
      name: 'Room 1',
      capacity: 100,
      roomType: 'TWO_D',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
    RoomModel(
      id: 'room-2',
      name: 'Room 2',
      capacity: 150,
      roomType: 'THREE_D',
      isActive: true,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    ),
  ];

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

  group('getRooms', () {
    test('should return list of rooms when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms())
          .thenAnswer((_) async => tRoomModels);

      // Act
      final result = await repository.getRooms();

      // Assert
      verify(() => mockRemoteDataSource.getRooms()).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (rooms) {
          expect(rooms.length, 2);
          expect(rooms[0], isA<Room>());
          expect(rooms[0].id, 'room-1');
          expect(rooms[1].id, 'room-2');
        },
      );
    });

    test('should call remote datasource with isActive filter', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms(isActive: any(named: 'isActive')))
          .thenAnswer((_) async => tRoomModels);

      // Act
      await repository.getRooms(isActive: true);

      // Assert
      verify(() => mockRemoteDataSource.getRooms(isActive: true)).called(1);
    });

    test('should call remote datasource with roomType filter', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms(roomType: any(named: 'roomType')))
          .thenAnswer((_) async => tRoomModels);

      // Act
      await repository.getRooms(roomType: RoomType.twoD);

      // Assert
      verify(() => mockRemoteDataSource.getRooms(roomType: 'TWO_D')).called(1);
    });

    test('should call remote datasource with both filters', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms(
            isActive: any(named: 'isActive'),
            roomType: any(named: 'roomType'),
          )).thenAnswer((_) async => tRoomModels);

      // Act
      await repository.getRooms(isActive: true, roomType: RoomType.threeD);

      // Assert
      verify(() => mockRemoteDataSource.getRooms(
            isActive: true,
            roomType: 'THREE_D',
          )).called(1);
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms()).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 500,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Server error',
      ));

      // Act
      final result = await repository.getRooms();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRooms())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getRooms();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('getRoomById', () {
    const tRoomId = 'room-123';

    test('should return Room when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRoomById(any()))
          .thenAnswer((_) async => tRoomModel);

      // Act
      final result = await repository.getRoomById(tRoomId);

      // Assert
      verify(() => mockRemoteDataSource.getRoomById(tRoomId)).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (room) {
          expect(room, isA<Room>());
          expect(room.id, tRoomId);
          expect(room.name, 'Test Room');
          expect(room.roomType, RoomType.twoD);
        },
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRoomById(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Room not found',
      ));

      // Act
      final result = await repository.getRoomById(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getRoomById(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getRoomById(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('createRoom', () {
    test('should return Room when creation is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.createRoom(
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
            roomType: any(named: 'roomType'),
            seatMapId: any(named: 'seatMapId'),
          )).thenAnswer((_) async => tRoomModel);

      // Act
      final result = await repository.createRoom(
        name: 'Test Room',
        capacity: 100,
        roomType: RoomType.twoD,
        seatMapId: 'seat-map-1',
      );

      // Assert
      verify(() => mockRemoteDataSource.createRoom(
            name: 'Test Room',
            capacity: 100,
            roomType: 'TWO_D',
            seatMapId: 'seat-map-1',
          )).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (room) {
          expect(room, isA<Room>());
          expect(room.name, 'Test Room');
          expect(room.capacity, 100);
          expect(room.roomType, RoomType.twoD);
        },
      );
    });

    test('should convert RoomType enum to string value', () async {
      // Arrange
      when(() => mockRemoteDataSource.createRoom(
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
            roomType: any(named: 'roomType'),
          )).thenAnswer((_) async => tRoomModel);

      // Act
      await repository.createRoom(
        name: 'Test Room',
        capacity: 100,
        roomType: RoomType.extreme,
      );

      // Assert
      verify(() => mockRemoteDataSource.createRoom(
            name: 'Test Room',
            capacity: 100,
            roomType: 'EXTREME',
          )).called(1);
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.createRoom(
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
            roomType: any(named: 'roomType'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Room already exists',
      ));

      // Act
      final result = await repository.createRoom(
        name: 'Test Room',
        capacity: 100,
        roomType: RoomType.twoD,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.createRoom(
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
            roomType: any(named: 'roomType'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.createRoom(
        name: 'Test Room',
        capacity: 100,
        roomType: RoomType.twoD,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('updateRoom', () {
    const tRoomId = 'room-123';

    test('should return updated Room when update is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateRoom(
            roomId: any(named: 'roomId'),
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
          )).thenAnswer((_) async => tRoomModel);

      // Act
      final result = await repository.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
        capacity: 150,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateRoom(
            roomId: tRoomId,
            name: 'Updated Room',
            capacity: 150,
          )).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (room) {
          expect(room, isA<Room>());
          expect(room.id, tRoomId);
        },
      );
    });

    test('should convert RoomType enum to string value when provided', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateRoom(
            roomId: any(named: 'roomId'),
            roomType: any(named: 'roomType'),
          )).thenAnswer((_) async => tRoomModel);

      // Act
      await repository.updateRoom(
        roomId: tRoomId,
        roomType: RoomType.threeD,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateRoom(
            roomId: tRoomId,
            roomType: 'THREE_D',
          )).called(1);
    });

    test('should pass all parameters when provided', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateRoom(
            roomId: any(named: 'roomId'),
            name: any(named: 'name'),
            capacity: any(named: 'capacity'),
            roomType: any(named: 'roomType'),
            seatMapId: any(named: 'seatMapId'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => tRoomModel);

      // Act
      await repository.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
        capacity: 150,
        roomType: RoomType.extreme,
        seatMapId: 'seat-map-2',
        isActive: false,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateRoom(
            roomId: tRoomId,
            name: 'Updated Room',
            capacity: 150,
            roomType: 'EXTREME',
            seatMapId: 'seat-map-2',
            isActive: false,
          )).called(1);
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateRoom(
            roomId: any(named: 'roomId'),
            name: any(named: 'name'),
          )).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Room not found',
      ));

      // Act
      final result = await repository.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateRoom(
            roomId: any(named: 'roomId'),
            name: any(named: 'name'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('deleteRoom', () {
    const tRoomId = 'room-123';

    test('should return Right(null) when soft delete is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteRoom(any(), permanent: any(named: 'permanent')))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteRoom(tRoomId);

      // Assert
      verify(() => mockRemoteDataSource.deleteRoom(tRoomId, permanent: false)).called(1);
      expect(result, const Right(null));
    });

    test('should return Right(null) when permanent delete is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteRoom(any(), permanent: any(named: 'permanent')))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteRoom(tRoomId, permanent: true);

      // Assert
      verify(() => mockRemoteDataSource.deleteRoom(tRoomId, permanent: true)).called(1);
      expect(result, const Right(null));
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteRoom(any(), permanent: any(named: 'permanent')))
          .thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 409,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Cannot delete room with active sessions',
      ));

      // Act
      final result = await repository.deleteRoom(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteRoom(any(), permanent: any(named: 'permanent')))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.deleteRoom(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });

  group('activateRoom', () {
    const tRoomId = 'room-123';

    test('should return activated Room when activation is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.activateRoom(any()))
          .thenAnswer((_) async => tRoomModel);

      // Act
      final result = await repository.activateRoom(tRoomId);

      // Assert
      verify(() => mockRemoteDataSource.activateRoom(tRoomId)).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Expected Right but got Left'),
        (room) {
          expect(room, isA<Room>());
          expect(room.id, tRoomId);
          expect(room.isActive, true);
        },
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.activateRoom(any())).thenThrow(DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          statusCode: 404,
          requestOptions: RequestOptions(path: ''),
        ),
        message: 'Room not found',
      ));

      // Act
      final result = await repository.activateRoom(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });

    test('should return Failure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.activateRoom(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.activateRoom(tRoomId);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<Failure>());
    });
  });
}
