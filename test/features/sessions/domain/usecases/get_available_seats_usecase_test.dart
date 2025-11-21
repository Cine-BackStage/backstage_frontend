import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/seat.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/get_available_seats_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late GetAvailableSeatsUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = GetAvailableSeatsUseCaseImpl(mockRepository);
  });

  const tSessionId = 'session-1';
  const tSeat = Seat(
    id: 'seat-1',
    seatNumber: 'A1',
    row: 'A',
    column: 1,
    type: 'STANDARD',
    status: 'AVAILABLE',
    price: 25.0,
  );

  test('should call repository.getSessionSeats with correct sessionId', () async {
    // Arrange
    when(() => mockRepository.getSessionSeats(any()))
        .thenAnswer((_) async => Right([tSeat]));

    // Act
    await useCase.call(GetAvailableSeatsParams(sessionId: tSessionId));

    // Assert
    verify(() => mockRepository.getSessionSeats(tSessionId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return list of seats when call is successful', () async {
    // Arrange
    final tSeatsList = [tSeat];
    when(() => mockRepository.getSessionSeats(any()))
        .thenAnswer((_) async => Right(tSeatsList));

    // Act
    final result = await useCase.call(GetAvailableSeatsParams(sessionId: tSessionId));

    // Assert
    expect(result, Right(tSeatsList));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to load seats');
    when(() => mockRepository.getSessionSeats(any()))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(GetAvailableSeatsParams(sessionId: tSessionId));

    // Assert
    expect(result, Left(tFailure));
  });
}
