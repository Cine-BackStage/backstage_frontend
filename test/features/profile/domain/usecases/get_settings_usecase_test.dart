import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/profile/domain/entities/settings.dart';
import 'package:backstage_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/get_settings_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetSettingsUseCaseImpl useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetSettingsUseCaseImpl(mockRepository);
  });

  const tSettings = Settings(
    language: 'pt_BR',
    theme: 'dark',
    notifications: true,
  );

  test('should call repository.getSettings', () async {
    // Arrange
    when(() => mockRepository.getSettings())
        .thenAnswer((_) async => const Right(tSettings));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getSettings()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Settings when settings are retrieved successfully', () async {
    // Arrange
    when(() => mockRepository.getSettings())
        .thenAnswer((_) async => const Right(tSettings));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(tSettings));
  });

  test('should return Failure when settings retrieval fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to get settings');
    when(() => mockRepository.getSettings())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
