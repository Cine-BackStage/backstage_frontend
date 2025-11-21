import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/features/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:backstage_frontend/features/sessions/data/models/session_model.dart';
import 'package:backstage_frontend/features/sessions/data/models/seat_model.dart';
import 'package:backstage_frontend/features/sessions/data/models/ticket_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late SessionsRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = SessionsRemoteDataSourceImpl(mockHttpClient);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);

  group('getSessions', () {
    final tSessionData = {
      'id': 'session-1',
      'movieId': 'movie-1',
      'roomId': 'room-1',
      'startTime': tDateTime.toIso8601String(),
      'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
      'language': 'Português',
      'format': '2D',
      'basePrice': 25.0,
      'totalSeats': 100,
      'availableSeats': 80,
      'reservedSeats': 10,
      'ticketsSold': 10,
      'status': 'SCHEDULED',
      'movie': {
        'title': 'Test Movie',
        'posterUrl': 'https://example.com/poster.jpg',
        'rating': 'PG-13',
        'durationMin': 120,
      },
      'room': {
        'name': 'Room 1',
        'capacity': 100,
        'roomType': '2D',
      },
    };

    test('should return list of SessionModel when call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': [tSessionData],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessions();

      // Assert
      expect(result, isA<List<SessionModel>>());
      expect(result.length, 1);
      expect(result[0].id, 'session-1');
    });

    test('should call HttpClient.get with correct endpoint and query parameters', () async {
      // Arrange
      final date = DateTime(2024, 1, 15);
      when(() => mockHttpClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': [tSessionData],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      await dataSource.getSessions(date: date, movieId: 1, roomId: 2);

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).called(1);
    });

    test('should handle empty list response', () async {
      // Arrange
      when(() => mockHttpClient.get(
            any(),
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': [],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessions();

      // Assert
      expect(result, isEmpty);
    });
  });

  group('getSessionDetails', () {
    final tSessionData = {
      'id': 'session-1',
      'movieId': 'movie-1',
      'roomId': 'room-1',
      'startTime': tDateTime.toIso8601String(),
      'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
      'language': 'Português',
      'format': '2D',
      'basePrice': 25.0,
      'totalSeats': 100,
      'availableSeats': 80,
      'reservedSeats': 10,
      'ticketsSold': 10,
      'status': 'SCHEDULED',
      'movie': {
        'title': 'Test Movie',
      },
      'room': {
        'name': 'Room 1',
        'capacity': 100,
        'roomType': '2D',
      },
    };

    test('should return SessionModel when call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': tSessionData,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessionDetails('session-1');

      // Assert
      expect(result, isA<SessionModel>());
      expect(result.id, 'session-1');
    });
  });

  group('getSessionSeats', () {
    final tSeatData = {
      'id': 'seat-1',
      'seatNumber': 'A1',
      'row': 'A',
      'column': 1,
      'type': 'STANDARD',
      'status': 'AVAILABLE',
      'price': 25.0,
      'isAccessible': false,
    };

    test('should return list of SeatModel when response is array', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': [tSeatData],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessionSeats('session-1');

      // Assert
      expect(result, isA<List<SeatModel>>());
      expect(result.length, 1);
      expect(result[0].id, 'seat-1');
    });

    test('should handle nested seats array in response', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': {
                'seats': [tSeatData],
              },
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessionSeats('session-1');

      // Assert
      expect(result, isA<List<SeatModel>>());
      expect(result.length, 1);
    });

    test('should return empty list when data is empty', () async {
      // Arrange
      when(() => mockHttpClient.get(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': [],
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.getSessionSeats('session-1');

      // Assert
      expect(result, isEmpty);
    });
  });

  group('purchaseTickets', () {
    final tTicketData = {
      'id': 'ticket-1',
      'ticketNumber': 'TKT-001',
      'sessionId': 'session-1',
      'seatId': 'seat-1',
      'seatNumber': 'A1',
      'customerCpf': '12345678901',
      'price': 25.0,
      'status': 'ACTIVE',
      'purchasedAt': tDateTime.toIso8601String(),
    };

    test('should return list of TicketModel when purchase is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tTicketData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.purchaseTickets(
        sessionId: 'session-1',
        seatIds: ['seat-1'],
        customerCpf: '12345678901',
        customerName: 'John Doe',
      );

      // Assert
      expect(result, isA<List<TicketModel>>());
      expect(result.length, 1);
      expect(result[0].id, 'ticket-1');
    });

    test('should call HttpClient.post with correct data', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tTicketData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.purchaseTickets(
        sessionId: 'session-1',
        seatIds: ['seat-1', 'seat-2'],
        customerCpf: '12345678901',
        customerName: 'John Doe',
      );

      // Assert
      verify(() => mockHttpClient.post(
            any(),
            data: any(named: 'data'),
          )).called(1);
    });
  });

  group('cancelTicket', () {
    final tTicketData = {
      'id': 'ticket-1',
      'ticketNumber': 'TKT-001',
      'sessionId': 'session-1',
      'seatId': 'seat-1',
      'seatNumber': 'A1',
      'customerCpf': '12345678901',
      'price': 25.0,
      'status': 'CANCELED',
      'purchasedAt': tDateTime.toIso8601String(),
      'canceledAt': tDateTime.add(Duration(minutes: 30)).toIso8601String(),
    };

    test('should return TicketModel when cancel is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': tTicketData,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.cancelTicket('ticket-1');

      // Assert
      expect(result, isA<TicketModel>());
      expect(result.status, 'CANCELED');
    });
  });

  group('validateTicket', () {
    final tTicketData = {
      'id': 'ticket-1',
      'ticketNumber': 'TKT-001',
      'sessionId': 'session-1',
      'seatId': 'seat-1',
      'seatNumber': 'A1',
      'customerCpf': '12345678901',
      'price': 25.0,
      'status': 'VALIDATED',
      'purchasedAt': tDateTime.toIso8601String(),
      'validatedAt': tDateTime.add(Duration(hours: 1)).toIso8601String(),
    };

    test('should return TicketModel when validation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
              'data': tTicketData,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act
      final result = await dataSource.validateTicket('ticket-1');

      // Assert
      expect(result, isA<TicketModel>());
      expect(result.status, 'VALIDATED');
    });
  });

  group('createSession', () {
    final tSessionData = {
      'id': 'session-1',
      'movieId': 'movie-1',
      'roomId': 'room-1',
      'startTime': tDateTime.toIso8601String(),
      'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
      'language': 'Português',
      'format': '2D',
      'basePrice': 25.0,
      'totalSeats': 100,
      'availableSeats': 100,
      'reservedSeats': 0,
      'ticketsSold': 0,
      'status': 'SCHEDULED',
      'movie': {'title': 'Test Movie'},
      'room': {'name': 'Room 1', 'capacity': 100, 'roomType': '2D'},
    };

    test('should return SessionModel when creation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tSessionData,
                },
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createSession(
        movieId: 'movie-1',
        roomId: 'room-1',
        startTime: tDateTime,
        basePrice: 25.0,
      );

      // Assert
      expect(result, isA<SessionModel>());
      expect(result.id, 'session-1');
    });
  });

  group('updateSession', () {
    final tSessionData = {
      'id': 'session-1',
      'movieId': 'movie-1',
      'roomId': 'room-1',
      'startTime': tDateTime.toIso8601String(),
      'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
      'language': 'Português',
      'format': '2D',
      'basePrice': 30.0,
      'totalSeats': 100,
      'availableSeats': 80,
      'reservedSeats': 10,
      'ticketsSold': 10,
      'status': 'IN_PROGRESS',
      'movie': {'title': 'Test Movie'},
      'room': {'name': 'Room 1', 'capacity': 100, 'roomType': '2D'},
    };

    test('should return SessionModel when update is successful', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tSessionData,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.updateSession(
        sessionId: 'session-1',
        basePrice: 30.0,
        status: 'IN_PROGRESS',
      );

      // Assert
      expect(result, isA<SessionModel>());
      expect(result.basePrice, 30.0);
      expect(result.status, 'IN_PROGRESS');
    });
  });

  group('deleteSession', () {
    test('should complete successfully when deletion is successful', () async {
      // Arrange
      when(() => mockHttpClient.delete(any())).thenAnswer((_) async => Response(
            data: {
              'success': true,
            },
            statusCode: 200,
            requestOptions: RequestOptions(path: ''),
          ));

      // Act & Assert
      expect(
        () => dataSource.deleteSession('session-1'),
        returnsNormally,
      );
    });
  });
}
