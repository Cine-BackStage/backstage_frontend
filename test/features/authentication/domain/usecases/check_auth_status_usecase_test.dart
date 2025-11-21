import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/check_auth_status_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late CheckAuthStatusUseCaseImpl useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = CheckAuthStatusUseCaseImpl(mockRepository);
  });

  test('should call repository.isAuthenticated', () async {
    // Arrange
    when(() => mockRepository.isAuthenticated())
        .thenAnswer((_) async => const Right(true));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.isAuthenticated()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right(true) when user is authenticated', () async {
    // Arrange
    when(() => mockRepository.isAuthenticated())
        .thenAnswer((_) async => const Right(true));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(true));
  });

  test('should return Right(false) when user is not authenticated', () async {
    // Arrange
    when(() => mockRepository.isAuthenticated())
        .thenAnswer((_) async => const Right(false));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(false));
  });

  test('should return Failure when check fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Check failed');
    when(() => mockRepository.isAuthenticated())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
