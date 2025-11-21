import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCaseImpl useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCaseImpl(mockRepository);
  });

  test('should call repository.logout', () async {
    // Arrange
    when(() => mockRepository.logout())
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.logout()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Right(null) when logout is successful', () async {
    // Arrange
    when(() => mockRepository.logout())
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when logout fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Logout failed');
    when(() => mockRepository.logout())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
