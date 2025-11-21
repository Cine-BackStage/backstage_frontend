import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/session.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/get_session_details_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late GetSessionDetailsUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = GetSessionDetailsUseCaseImpl(mockRepository);
  });

  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  const tSessionId = 'session-1';
  final tSession = Session(
    id: tSessionId,
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

  test('should call repository.getSessionDetails with correct sessionId', () async {
    // Arrange
    when(() => mockRepository.getSessionDetails(any()))
        .thenAnswer((_) async => Right(tSession));

    // Act
    await useCase.call(GetSessionDetailsParams(sessionId: tSessionId));

    // Assert
    verify(() => mockRepository.getSessionDetails(tSessionId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Session when call is successful', () async {
    // Arrange
    when(() => mockRepository.getSessionDetails(any()))
        .thenAnswer((_) async => Right(tSession));

    // Act
    final result = await useCase.call(GetSessionDetailsParams(sessionId: tSessionId));

    // Assert
    expect(result, Right(tSession));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Session not found');
    when(() => mockRepository.getSessionDetails(any()))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(GetSessionDetailsParams(sessionId: tSessionId));

    // Assert
    expect(result, Left(tFailure));
  });
}
