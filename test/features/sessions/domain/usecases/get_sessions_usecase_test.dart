import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/session.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/get_sessions_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late GetSessionsUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = GetSessionsUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  final tSession = Session(
    id: 'session-1',
    movieId: 'movie-1',
    movieTitle: 'Test Movie',
    roomId: 'room-1',
    roomName: 'Room 1',
    startTime: tDateTime,
    endTime: tDateTime.add(Duration(hours: 2)),
    language: 'Português',
    format: '2D',
    basePrice: 25.0,
    totalSeats: 100,
    availableSeats: 80,
    reservedSeats: 10,
    soldSeats: 10,
    status: 'SCHEDULED',
  );

  test('should call repository.getSessions with correct parameters', () async {
    // Arrange
    when(() => mockRepository.getSessions(
          date: any(named: 'date'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) async => Right([tSession]));

    // Act
    await useCase.call(GetSessionsParams(
      date: tDateTime,
      movieId: 1,
      roomId: 2,
    ));

    // Assert
    verify(() => mockRepository.getSessions(
          date: tDateTime,
          movieId: 1,
          roomId: 2,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of sessions when call is successful', () async {
    // Arrange
    final tSessionsList = [tSession];
    when(() => mockRepository.getSessions(
          date: any(named: 'date'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) async => Right(tSessionsList));

    // Act
    final result = await useCase.call(GetSessionsParams());

    // Assert
    expect(result, Right(tSessionsList));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to load sessions');
    when(() => mockRepository.getSessions(
          date: any(named: 'date'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(GetSessionsParams());

    // Assert
    expect(result, Left(tFailure));
  });

  test('should call repository with null parameters when not provided', () async {
    // Arrange
    when(() => mockRepository.getSessions(
          date: any(named: 'date'),
          movieId: any(named: 'movieId'),
          roomId: any(named: 'roomId'),
        )).thenAnswer((_) async => Right([tSession]));

    // Act
    await useCase.call(GetSessionsParams());

    // Assert
    verify(() => mockRepository.getSessions(
          date: null,
          movieId: null,
          roomId: null,
        )).called(1);
  });
}
