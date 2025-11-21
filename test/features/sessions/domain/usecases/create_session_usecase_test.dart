import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/session.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/create_session_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late CreateSessionUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = CreateSessionUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  const tMovieId = 'movie-1';
  const tRoomId = 'room-1';
  const tBasePrice = 25.0;
  final tSession = Session(
    id: 'session-1',
    movieId: tMovieId,
    movieTitle: 'Test Movie',
    roomId: tRoomId,
    roomName: 'Room 1',
    startTime: tDateTime,
    endTime: tDateTime.add(Duration(hours: 2)),
    language: 'Português',
    format: '2D',
    basePrice: tBasePrice,
    totalSeats: 100,
    availableSeats: 100,
    reservedSeats: 0,
    soldSeats: 0,
    status: 'SCHEDULED',
  );

  test('should call repository.createSession with correct parameters', () async {
    // Arrange
    when(() => mockRepository.createSession(
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    await useCase.call(CreateSessionParams(
      movieId: tMovieId,
      roomId: tRoomId,
      startTime: tDateTime,
      basePrice: tBasePrice,
    ));

    // Assert
    verify(() => mockRepository.createSession(
          movieId: tMovieId,
          roomId: tRoomId,
          startTime: tDateTime,
          basePrice: tBasePrice,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Session when creation is successful', () async {
    // Arrange
    when(() => mockRepository.createSession(
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    final result = await useCase.call(CreateSessionParams(
      movieId: tMovieId,
      roomId: tRoomId,
      startTime: tDateTime,
      basePrice: tBasePrice,
    ));

    // Assert
    expect(result, Right(tSession));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to create session');
    when(() => mockRepository.createSession(
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
        )).thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(CreateSessionParams(
      movieId: tMovieId,
      roomId: tRoomId,
      startTime: tDateTime,
      basePrice: tBasePrice,
    ));

    // Assert
    expect(result, Left(tFailure));
  });

  test('should call repository with null basePrice when not provided', () async {
    // Arrange
    when(() => mockRepository.createSession(
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    await useCase.call(CreateSessionParams(
      movieId: tMovieId,
      roomId: tRoomId,
      startTime: tDateTime,
    ));

    // Assert
    verify(() => mockRepository.createSession(
          movieId: tMovieId,
          roomId: tRoomId,
          startTime: tDateTime,
          basePrice: null,
        )).called(1);
  });
}
