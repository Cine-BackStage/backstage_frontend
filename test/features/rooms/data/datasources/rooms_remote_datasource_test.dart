import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/constants/api_constants.dart';
import 'package:backstage_frontend/features/rooms/data/datasources/rooms_remote_datasource.dart';
import 'package:backstage_frontend/features/rooms/data/models/room_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late RoomsRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = RoomsRemoteDataSourceImpl(mockHttpClient);
  });

  group('getRooms', () {
    final tRoomsData = {
      'success': true,
      'data': [
        {
          'id': 'room-1',
          'name': 'Room 1',
          'capacity': 100,
          'roomType': 'TWO_D',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        },
        {
          'id': 'room-2',
          'name': 'Room 2',
          'capacity': 150,
          'roomType': 'THREE_D',
          'isActive': true,
          'createdAt': '2024-01-01T00:00:00.000Z',
          'updatedAt': '2024-01-01T00:00:00.000Z',
        },
      ],
    };

    test('should return list of RoomModel when call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tRoomsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getRooms();

      // Assert
      expect(result, isA<List<RoomModel>>());
      expect(result.length, 2);
      expect(result[0].id, 'room-1');
      expect(result[1].id, 'room-2');
    });

    test('should call HttpClient.get with correct endpoint and no query params', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tRoomsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getRooms();

      // Assert
      verify(() => mockHttpClient.get(ApiConstants.rooms, queryParameters: null)).called(1);
    });

    test('should call HttpClient.get with isActive query param', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tRoomsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getRooms(isActive: true);

      // Assert
      verify(() => mockHttpClient.get(
            ApiConstants.rooms,
            queryParameters: {'isActive': 'true'},
          )).called(1);
    });

    test('should call HttpClient.get with roomType query param', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tRoomsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getRooms(roomType: 'TWO_D');

      // Assert
      verify(() => mockHttpClient.get(
            ApiConstants.rooms,
            queryParameters: {'roomType': 'TWO_D'},
          )).called(1);
    });

    test('should call HttpClient.get with both query params', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tRoomsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getRooms(isActive: false, roomType: 'THREE_D');

      // Assert
      verify(() => mockHttpClient.get(
            ApiConstants.rooms,
            queryParameters: {'isActive': 'false', 'roomType': 'THREE_D'},
          )).called(1);
    });

    test('should throw exception when call fails', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Network error',
          ));

      // Act & Assert
      expect(() => dataSource.getRooms(), throwsA(isA<DioException>()));
    });
  });

  group('getRoomById', () {
    const tRoomId = 'room-123';
    final tRoomData = {
      'success': true,
      'data': {
        'id': tRoomId,
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
      },
    };

    test('should return RoomModel when call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getRoomById(tRoomId);

      // Assert
      expect(result, isA<RoomModel>());
      expect(result.id, tRoomId);
      expect(result.name, 'Test Room');
      expect(result.sessionsCount, 5);
    });

    test('should call HttpClient.get with correct endpoint', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getRoomById(tRoomId);

      // Assert
      verify(() => mockHttpClient.get(ApiConstants.roomDetails(tRoomId))).called(1);
    });

    test('should throw exception when room not found', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              statusCode: 404,
              requestOptions: RequestOptions(path: ''),
            ),
          ));

      // Act & Assert
      expect(() => dataSource.getRoomById(tRoomId), throwsA(isA<DioException>()));
    });
  });

  group('createRoom', () {
    final tRoomData = {
      'success': true,
      'data': {
        'id': 'room-new',
        'name': 'New Room',
        'capacity': 120,
        'roomType': 'THREE_D',
        'seatMapId': 'seat-map-2',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-01T00:00:00.000Z',
      },
    };

    test('should return RoomModel when creation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createRoom(
        name: 'New Room',
        capacity: 120,
        roomType: 'THREE_D',
        seatMapId: 'seat-map-2',
      );

      // Assert
      expect(result, isA<RoomModel>());
      expect(result.id, 'room-new');
      expect(result.name, 'New Room');
    });

    test('should call HttpClient.post with all parameters', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createRoom(
        name: 'New Room',
        capacity: 120,
        roomType: 'THREE_D',
        seatMapId: 'seat-map-2',
      );

      // Assert
      verify(() => mockHttpClient.post(
            ApiConstants.rooms,
            data: {
              'name': 'New Room',
              'capacity': 120,
              'roomType': 'THREE_D',
              'seatMapId': 'seat-map-2',
            },
          )).called(1);
    });

    test('should call HttpClient.post without seatMapId when not provided', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createRoom(
        name: 'New Room',
        capacity: 120,
        roomType: 'THREE_D',
      );

      // Assert
      verify(() => mockHttpClient.post(
            ApiConstants.rooms,
            data: {
              'name': 'New Room',
              'capacity': 120,
              'roomType': 'THREE_D',
            },
          )).called(1);
    });

    test('should throw exception when creation fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Creation failed',
          ));

      // Act & Assert
      expect(
        () => dataSource.createRoom(
          name: 'New Room',
          capacity: 120,
          roomType: 'THREE_D',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('updateRoom', () {
    const tRoomId = 'room-123';
    final tRoomData = {
      'success': true,
      'data': {
        'id': tRoomId,
        'name': 'Updated Room',
        'capacity': 150,
        'roomType': 'EXTREME',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      },
    };

    test('should return updated RoomModel when update is successful', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
        capacity: 150,
      );

      // Assert
      expect(result, isA<RoomModel>());
      expect(result.id, tRoomId);
      expect(result.name, 'Updated Room');
    });

    test('should call HttpClient.put with all provided parameters', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
        capacity: 150,
        roomType: 'EXTREME',
        seatMapId: 'seat-map-3',
        isActive: false,
      );

      // Assert
      verify(() => mockHttpClient.put(
            ApiConstants.roomDetails(tRoomId),
            data: {
              'name': 'Updated Room',
              'capacity': 150,
              'roomType': 'EXTREME',
              'seatMapId': 'seat-map-3',
              'isActive': false,
            },
          )).called(1);
    });

    test('should call HttpClient.put with only provided parameters', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateRoom(
        roomId: tRoomId,
        name: 'Updated Room',
      );

      // Assert
      verify(() => mockHttpClient.put(
            ApiConstants.roomDetails(tRoomId),
            data: {
              'name': 'Updated Room',
            },
          )).called(1);
    });

    test('should throw exception when update fails', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Update failed',
          ));

      // Act & Assert
      expect(
        () => dataSource.updateRoom(
          roomId: tRoomId,
          name: 'Updated Room',
        ),
        throwsA(isA<DioException>()),
      );
    });
  });

  group('deleteRoom', () {
    const tRoomId = 'room-123';

    test('should complete successfully when soft delete succeeds', () async {
      // Arrange
      when(() => mockHttpClient.delete(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.deleteRoom(tRoomId);

      // Assert
      verify(() => mockHttpClient.delete(
            ApiConstants.roomDetails(tRoomId),
            queryParameters: null,
          )).called(1);
    });

    test('should call HttpClient.delete with permanent query param', () async {
      // Arrange
      when(() => mockHttpClient.delete(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                statusCode: 204,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.deleteRoom(tRoomId, permanent: true);

      // Assert
      verify(() => mockHttpClient.delete(
            ApiConstants.roomDetails(tRoomId),
            queryParameters: {'permanent': 'true'},
          )).called(1);
    });

    test('should throw exception when delete fails', () async {
      // Arrange
      when(() => mockHttpClient.delete(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Delete failed',
          ));

      // Act & Assert
      expect(() => dataSource.deleteRoom(tRoomId), throwsA(isA<DioException>()));
    });
  });

  group('activateRoom', () {
    const tRoomId = 'room-123';
    final tRoomData = {
      'success': true,
      'data': {
        'id': tRoomId,
        'name': 'Test Room',
        'capacity': 100,
        'roomType': 'TWO_D',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      },
    };

    test('should return activated RoomModel when activation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.activateRoom(tRoomId);

      // Assert
      expect(result, isA<RoomModel>());
      expect(result.id, tRoomId);
      expect(result.isActive, true);
    });

    test('should call HttpClient.post with correct endpoint', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: tRoomData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.activateRoom(tRoomId);

      // Assert
      verify(() => mockHttpClient.post(ApiConstants.roomActivate(tRoomId))).called(1);
    });

    test('should throw exception when activation fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            message: 'Activation failed',
          ));

      // Act & Assert
      expect(() => dataSource.activateRoom(tRoomId), throwsA(isA<DioException>()));
    });
  });
}
