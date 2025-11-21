import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/session.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/update_session_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late UpdateSessionUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = UpdateSessionUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  const tSessionId = 'session-1';
  const tMovieId = 'movie-1';
  const tRoomId = 'room-1';
  const tBasePrice = 30.0;
  const tStatus = 'IN_PROGRESS';
  final tSession = Session(
    id: tSessionId,
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
    availableSeats: 80,
    reservedSeats: 10,
    soldSeats: 10,
    status: tStatus,
  );

  test('should call repository.updateSession with correct parameters', () async {
    // Arrange
    when(() => mockRepository.updateSession(
          sessionId: any(named: 'sessionId'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    await useCase.call(UpdateSessionParams(
      sessionId: tSessionId,
      movieId: tMovieId,
      roomId: tRoomId,
      startTime: tDateTime,
      basePrice: tBasePrice,
      status: tStatus,
    ));

    // Assert
    verify(() => mockRepository.updateSession(
          sessionId: tSessionId,
          movieId: tMovieId,
          roomId: tRoomId,
          startTime: tDateTime,
          basePrice: tBasePrice,
          status: tStatus,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return updated Session when call is successful', () async {
    // Arrange
    when(() => mockRepository.updateSession(
          sessionId: any(named: 'sessionId'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    final result = await useCase.call(UpdateSessionParams(
      sessionId: tSessionId,
      basePrice: tBasePrice,
    ));

    // Assert
    expect(result, Right(tSession));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to update session');
    when(() => mockRepository.updateSession(
          sessionId: any(named: 'sessionId'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(UpdateSessionParams(
      sessionId: tSessionId,
      status: tStatus,
    ));

    // Assert
    expect(result, Left(tFailure));
  });

  test('should call repository with only sessionId when other params are null', () async {
    // Arrange
    when(() => mockRepository.updateSession(
          sessionId: any(named: 'sessionId'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
          startTime: any(named: 'startTime'),
          basePrice: any(named: 'basePrice'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => Right(tSession));

    // Act
    await useCase.call(UpdateSessionParams(sessionId: tSessionId));

    // Assert
    verify(() => mockRepository.updateSession(
          sessionId: tSessionId,
          movieId: null,
          roomId: null,
          startTime: null,
          basePrice: null,
          status: null,
        )).called(1);
  });
}
