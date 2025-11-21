import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/profile/domain/entities/settings.dart';
import 'package:backstage_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/update_settings_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late UpdateSettingsUseCaseImpl useCase;
  late MockProfileRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const Settings(
      language: 'pt_BR',
      theme: 'dark',
      notifications: true,
    ));
  });

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = UpdateSettingsUseCaseImpl(mockRepository);
  });

  const tSettings = Settings(
    language: 'en_US',
    theme: 'light',
    notifications: false,
  );

  test('should call repository.updateSettings with correct parameters', () async {
    // Arrange
    when(() => mockRepository.updateSettings(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(UpdateSettingsParams(settings: tSettings));

    // Assert
    verify(() => mockRepository.updateSettings(tSettings)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return success when settings are updated successfully', () async {
    // Arrange
    when(() => mockRepository.updateSettings(any()))
        .thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(UpdateSettingsParams(settings: tSettings));

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when settings update fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to update settings');
    when(() => mockRepository.updateSettings(any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(UpdateSettingsParams(settings: tSettings));

    // Assert
    expect(result, const Left(tFailure));
  });
}
