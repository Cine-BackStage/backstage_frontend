import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/data/datasources/sessions_remote_datasource.dart';
import 'package:backstage_frontend/features/sessions/data/models/session_model.dart';
import 'package:backstage_frontend/features/sessions/data/models/seat_model.dart';
import 'package:backstage_frontend/features/sessions/data/models/ticket_model.dart';
import 'package:backstage_frontend/features/sessions/data/repositories/sessions_repository_impl.dart';

class MockSessionsRemoteDataSource extends Mock implements SessionsRemoteDataSource {}

void main() {
  late SessionsRepositoryImpl repository;
  late MockSessionsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockSessionsRemoteDataSource();
    repository = SessionsRepositoryImpl(mockRemoteDataSource);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  final tSessionModel = SessionModel(
    id: 'session-1',
    movieId: 'movie-1',
    movieTitle: 'Test Movie',
    roomId: 'room-1',
    roomName: 'Room 1',
    startTime: tDateTime,
    endTime: tDateTime.add(Duration(hours: 2)),
    language: 'Português',
    subtitles: null,
    format: '2D',
    basePrice: 25.0,
    totalSeats: 100,
    availableSeats: 80,
    reservedSeats: 10,
    soldSeats: 10,
    status: 'SCHEDULED',
  );

  group('getSessions', () {
    test('should return list of sessions when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessions(
            date: any(named: 'date'),
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
          )).thenAnswer((_) async => [tSessionModel]);

      // Act
      final result = await repository.getSessions();

      // Assert
      verify(() => mockRemoteDataSource.getSessions(
            date: null,
            movieId: null,
            roomId: null,
          )).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sessions) {
          expect(sessions.length, 1);
          expect(sessions[0].id, 'session-1');
        },
      );
    });

    test('should return Failure when datasource throws DioException', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessions(
            date: any(named: 'date'),
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
          )).thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
            ),
          ));

      // Act
      final result = await repository.getSessions();

      // Assert
      expect(result.isLeft(), true);
      expect(result, isA<Left<Failure, dynamic>>());
    });

    test('should return Failure when datasource throws generic exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessions(
            date: any(named: 'date'),
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getSessions();

      // Assert
      expect(result.isLeft(), true);
      expect(result, isA<Left<Failure, dynamic>>());
    });
  });

  group('getSessionDetails', () {
    test('should return session when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessionDetails(any()))
          .thenAnswer((_) async => tSessionModel);

      // Act
      final result = await repository.getSessionDetails('session-1');

      // Assert
      verify(() => mockRemoteDataSource.getSessionDetails('session-1')).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) {
          expect(session.id, 'session-1');
          expect(session.movieTitle, 'Test Movie');
          expect(session.status, 'SCHEDULED');
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessionDetails(any()))
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.getSessionDetails('session-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('getSessionSeats', () {
    const tSeatModel = SeatModel(
      id: 'seat-1',
      seatNumber: 'A1',
      row: 'A',
      column: 1,
      type: 'STANDARD',
      status: 'AVAILABLE',
      price: 25.0,
    );

    test('should return list of seats when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessionSeats(any()))
          .thenAnswer((_) async => [tSeatModel]);

      // Act
      final result = await repository.getSessionSeats('session-1');

      // Assert
      verify(() => mockRemoteDataSource.getSessionSeats('session-1')).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (seats) {
          expect(seats.length, 1);
          expect(seats[0].id, 'seat-1');
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSessionSeats(any()))
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.getSessionSeats('session-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('purchaseTickets', () {
    final tTicketModel = TicketModel(
      id: 'ticket-1',
      ticketNumber: 'TKT-001',
      sessionId: 'session-1',
      seatId: 'seat-1',
      seatNumber: 'A1',
      customerCpf: '12345678901',
      price: 25.0,
      status: 'ACTIVE',
      purchasedAt: tDateTime,
    );

    test('should return list of tickets when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.purchaseTickets(
            sessionId: any(named: 'sessionId'),
            seatIds: any(named: 'seatIds'),
            customerCpf: any(named: 'customerCpf'),
            customerName: any(named: 'customerName'),
          )).thenAnswer((_) async => [tTicketModel]);

      // Act
      final result = await repository.purchaseTickets(
        sessionId: 'session-1',
        seatIds: ['seat-1'],
        customerCpf: '12345678901',
        customerName: 'John Doe',
      );

      // Assert
      verify(() => mockRemoteDataSource.purchaseTickets(
            sessionId: 'session-1',
            seatIds: ['seat-1'],
            customerCpf: '12345678901',
            customerName: 'John Doe',
          )).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (tickets) {
          expect(tickets.length, 1);
          expect(tickets[0].id, 'ticket-1');
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.purchaseTickets(
            sessionId: any(named: 'sessionId'),
            seatIds: any(named: 'seatIds'),
            customerCpf: any(named: 'customerCpf'),
            customerName: any(named: 'customerName'),
          )).thenThrow(Exception('Error'));

      // Act
      final result = await repository.purchaseTickets(
        sessionId: 'session-1',
        seatIds: ['seat-1'],
        customerCpf: '12345678901',
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('cancelTicket', () {
    final tTicketModel = TicketModel(
      id: 'ticket-1',
      ticketNumber: 'TKT-001',
      sessionId: 'session-1',
      seatId: 'seat-1',
      seatNumber: 'A1',
      customerCpf: '12345678901',
      price: 25.0,
      status: 'CANCELED',
      purchasedAt: tDateTime,
      canceledAt: tDateTime.add(Duration(minutes: 30)),
    );

    test('should return canceled ticket when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelTicket(any()))
          .thenAnswer((_) async => tTicketModel);

      // Act
      final result = await repository.cancelTicket('ticket-1');

      // Assert
      verify(() => mockRemoteDataSource.cancelTicket('ticket-1')).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (ticket) {
          expect(ticket.id, 'ticket-1');
          expect(ticket.status, 'CANCELED');
          expect(ticket.canceledAt, isNotNull);
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelTicket(any()))
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.cancelTicket('ticket-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('validateTicket', () {
    final tTicketModel = TicketModel(
      id: 'ticket-1',
      ticketNumber: 'TKT-001',
      sessionId: 'session-1',
      seatId: 'seat-1',
      seatNumber: 'A1',
      customerCpf: '12345678901',
      price: 25.0,
      status: 'VALIDATED',
      purchasedAt: tDateTime,
      validatedAt: tDateTime.add(Duration(hours: 1)),
    );

    test('should return validated ticket when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.validateTicket(any()))
          .thenAnswer((_) async => tTicketModel);

      // Act
      final result = await repository.validateTicket('ticket-1');

      // Assert
      verify(() => mockRemoteDataSource.validateTicket('ticket-1')).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (ticket) {
          expect(ticket.id, 'ticket-1');
          expect(ticket.status, 'VALIDATED');
          expect(ticket.validatedAt, isNotNull);
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.validateTicket(any()))
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.validateTicket('ticket-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('createSession', () {
    test('should return created session when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.createSession(
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
            startTime: any(named: 'startTime'),
            basePrice: any(named: 'basePrice'),
          )).thenAnswer((_) async => tSessionModel);

      // Act
      final result = await repository.createSession(
        movieId: 'movie-1',
        roomId: 'room-1',
        startTime: tDateTime,
        basePrice: 25.0,
      );

      // Assert
      verify(() => mockRemoteDataSource.createSession(
            movieId: 'movie-1',
            roomId: 'room-1',
            startTime: tDateTime,
            basePrice: 25.0,
          )).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) {
          expect(session.id, 'session-1');
          expect(session.movieTitle, 'Test Movie');
          expect(session.status, 'SCHEDULED');
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.createSession(
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
            startTime: any(named: 'startTime'),
            basePrice: any(named: 'basePrice'),
          )).thenThrow(Exception('Error'));

      // Act
      final result = await repository.createSession(
        movieId: 'movie-1',
        roomId: 'room-1',
        startTime: tDateTime,
      );

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('updateSession', () {
    test('should return updated session when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateSession(
            sessionId: any(named: 'sessionId'),
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
            startTime: any(named: 'startTime'),
            basePrice: any(named: 'basePrice'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => tSessionModel);

      // Act
      final result = await repository.updateSession(
        sessionId: 'session-1',
        basePrice: 30.0,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateSession(
            sessionId: 'session-1',
            movieId: null,
            roomId: null,
            startTime: null,
            basePrice: 30.0,
            status: null,
          )).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (session) {
          expect(session.id, 'session-1');
          expect(session.movieTitle, 'Test Movie');
          expect(session.status, 'SCHEDULED');
        },
      );
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateSession(
            sessionId: any(named: 'sessionId'),
            movieId: any(named: 'movieId'),
            roomId: any(named: 'roomId'),
            startTime: any(named: 'startTime'),
            basePrice: any(named: 'basePrice'),
            status: any(named: 'status'),
          )).thenThrow(Exception('Error'));

      // Act
      final result = await repository.updateSession(sessionId: 'session-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });

  group('deleteSession', () {
    test('should return Right when datasource call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteSession(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteSession('session-1');

      // Assert
      verify(() => mockRemoteDataSource.deleteSession('session-1')).called(1);
      expect(result, Right(null));
    });

    test('should return Failure when datasource throws exception', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteSession(any()))
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.deleteSession('session-1');

      // Assert
      expect(result.isLeft(), true);
    });
  });
}
