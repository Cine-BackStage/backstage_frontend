import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/sessions/domain/repositories/sessions_repository.dart';
import 'package:backstage_frontend/features/sessions/domain/usecases/delete_session_usecase.dart';

class MockSessionsRepository extends Mock implements SessionsRepository {}

void main() {
  late DeleteSessionUseCaseImpl useCase;
  late MockSessionsRepository mockRepository;

  setUp(() {
    mockRepository = MockSessionsRepository();
    useCase = DeleteSessionUseCaseImpl(mockRepository);
  });

  const tSessionId = 'session-1';

  test('should call repository.deleteSession with correct sessionId', () async {
    // Arrange
    when(() => mockRepository.deleteSession(any()))
        .thenAnswer((_) async => Right(null));

    // Act
    await useCase.call(DeleteSessionParams(sessionId: tSessionId));

    // Assert
    verify(() => mockRepository.deleteSession(tSessionId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right when deletion is successful', () async {
    // Arrange
    when(() => mockRepository.deleteSession(any()))
        .thenAnswer((_) async => Right(null));

    // Act
    final result = await useCase.call(DeleteSessionParams(sessionId: tSessionId));

    // Assert
    expect(result, Right(null));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    final tFailure = GenericFailure(message: 'Failed to delete session');
    when(() => mockRepository.deleteSession(any()))
        .thenAnswer((_) async => Left(tFailure));

    // Act
    final result = await useCase.call(DeleteSessionParams(sessionId: tSessionId));

    // Assert
    expect(result, Left(tFailure));
  });
}
