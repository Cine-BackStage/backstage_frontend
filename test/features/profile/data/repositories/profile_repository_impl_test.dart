import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:backstage_frontend/features/authentication/data/models/employee_model.dart';
import 'package:backstage_frontend/features/profile/data/datasources/profile_local_datasource.dart';
import 'package:backstage_frontend/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:backstage_frontend/features/profile/data/models/settings_model.dart';
import 'package:backstage_frontend/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:backstage_frontend/features/profile/domain/entities/settings.dart';

class MockProfileLocalDataSource extends Mock implements ProfileLocalDataSource {}
class MockProfileRemoteDataSource extends Mock implements ProfileRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileLocalDataSource mockLocalDataSource;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUpAll(() {
    registerFallbackValue(const SettingsModel(
      language: 'pt_BR',
      theme: 'dark',
      notifications: true,
    ));
  });

  setUp(() {
    mockLocalDataSource = MockProfileLocalDataSource();
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    repository = ProfileRepositoryImpl(
      localDataSource: mockLocalDataSource,
      remoteDataSource: mockRemoteDataSource,
      authLocalDataSource: mockAuthLocalDataSource,
    );
  });

  const tEmployeeModel = EmployeeModel(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: '12345',
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  const tSettingsModel = SettingsModel(
    language: 'en_US',
    theme: 'light',
    notifications: false,
  );

  const tSettings = Settings(
    language: 'en_US',
    theme: 'light',
    notifications: false,
  );

  group('getEmployeeProfile', () {
    test('should return Employee when successful', () async {
      // Arrange
      when(() => mockAuthLocalDataSource.getCachedEmployee())
          .thenAnswer((_) async => tEmployeeModel);

      // Act
      final result = await repository.getEmployeeProfile();

      // Assert
      expect(result, equals(const Right(tEmployeeModel)));
      verify(() => mockAuthLocalDataSource.getCachedEmployee()).called(1);
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Employee not found');
      when(() => mockAuthLocalDataSource.getCachedEmployee()).thenThrow(tException);

      // Act
      final result = await repository.getEmployeeProfile();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockAuthLocalDataSource.getCachedEmployee())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getEmployeeProfile();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getSettings', () {
    test('should return Settings when successful', () async {
      // Arrange
      when(() => mockLocalDataSource.getSettings())
          .thenAnswer((_) async => tSettingsModel);

      // Act
      final result = await repository.getSettings();

      // Assert
      expect(result, equals(const Right(tSettings)));
      verify(() => mockLocalDataSource.getSettings()).called(1);
    });

    test('should return GenericFailure when error occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.getSettings())
          .thenThrow(Exception('Failed to get settings'));

      // Act
      final result = await repository.getSettings();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('updateSettings', () {
    test('should save settings and return success when successful', () async {
      // Arrange
      when(() => mockLocalDataSource.saveSettings(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.updateSettings(tSettings);

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockLocalDataSource.saveSettings(any())).called(1);
    });

    test('should return GenericFailure when error occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.saveSettings(any()))
          .thenThrow(Exception('Failed to save settings'));

      // Act
      final result = await repository.updateSettings(tSettings);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('updatePassword', () {
    const tCurrentPassword = 'oldPassword123';
    const tNewPassword = 'newPassword456';

    test('should change password and return success when successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenAnswer((_) async => {});

      // Act
      final result = await repository.updatePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, equals(const Right(null)));
      verify(() => mockRemoteDataSource.changePassword(
            currentPassword: tCurrentPassword,
            newPassword: tNewPassword,
          )).called(1);
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Invalid current password',
        statusCode: 401,
      );
      when(() => mockRemoteDataSource.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(tException);

      // Act
      final result = await repository.updatePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.changePassword(
            currentPassword: any(named: 'currentPassword'),
            newPassword: any(named: 'newPassword'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.updatePassword(
        currentPassword: tCurrentPassword,
        newPassword: tNewPassword,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });
}
