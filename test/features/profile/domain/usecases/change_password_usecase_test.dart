import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/change_password_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late ChangePasswordUseCaseImpl useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = ChangePasswordUseCaseImpl(mockRepository);
  });

  const tCurrentPassword = 'oldPassword123';
  const tNewPassword = 'newPassword456';

  test('should call repository.updatePassword with correct parameters', () async {
    // Arrange
    when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    await useCase.call(ChangePasswordParams(
      currentPassword: tCurrentPassword,
      newPassword: tNewPassword,
    ));

    // Assert
    verify(() => mockRepository.updatePassword(
          currentPassword: tCurrentPassword,
          newPassword: tNewPassword,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return success when password is changed successfully', () async {
    // Arrange
    when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => const Right(null));

    // Act
    final result = await useCase.call(ChangePasswordParams(
      currentPassword: tCurrentPassword,
      newPassword: tNewPassword,
    ));

    // Assert
    expect(result, const Right(null));
  });

  test('should return Failure when password change fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Invalid current password');
    when(() => mockRepository.updatePassword(
          currentPassword: any(named: 'currentPassword'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(ChangePasswordParams(
      currentPassword: tCurrentPassword,
      newPassword: tNewPassword,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
