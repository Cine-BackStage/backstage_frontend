import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:backstage_frontend/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:backstage_frontend/features/authentication/data/models/employee_model.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_request.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_response.dart';
import 'package:backstage_frontend/features/authentication/data/repositories/auth_repository_impl.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

const tEmployeeId = '12345';
const tPassword = 'password123';
const tToken = 'test_token_123';
const tEmployeeModel = EmployeeModel(
  cpf: '123.456.789-00',
  companyId: 'comp-123',
  employeeId: tEmployeeId,
  role: 'cashier',
  fullName: 'John Doe',
  email: 'john@example.com',
  isActive: true,
);

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(LoginRequest(employeeId: '', password: ''));
    registerFallbackValue(tEmployeeModel);
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('login', () {
    final tLoginResponse = LoginResponse(
      token: tToken,
      employee: tEmployeeModel,
    );

    test('should cache token and employee when login is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any()))
          .thenAnswer((_) async => tLoginResponse);
      when(() => mockLocalDataSource.cacheToken(any()))
          .thenAnswer((_) async => {});
      when(() => mockLocalDataSource.cacheEmployee(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.login(tEmployeeId, tPassword);

      // Assert
      verify(() => mockRemoteDataSource.login(any())).called(1);
      verify(() => mockLocalDataSource.cacheToken(tToken)).called(1);
      verify(() => mockLocalDataSource.cacheEmployee(tEmployeeModel)).called(1);
      expect(result, equals(const Right(tEmployeeModel)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Invalid credentials',
        statusCode: 401,
      );
      when(() => mockRemoteDataSource.login(any())).thenThrow(tException);

      // Act
      final result = await repository.login(tEmployeeId, tPassword);

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Invalid credentials',
          statusCode: 401,
        ))),
      );
      verifyNever(() => mockLocalDataSource.cacheToken(any()));
      verifyNever(() => mockLocalDataSource.cacheEmployee(any()));
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.login(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.login(tEmployeeId, tPassword);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('logout', () {
    test('should clear auth data when logout is successful', () async {
      // Arrange
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.logout();

      // Assert
      verify(() => mockLocalDataSource.clearAuthData()).called(1);
      expect(result, equals(const Right(null)));
    });

    test('should return GenericFailure when error occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.clearAuthData())
          .thenThrow(Exception('Clear failed'));

      // Act
      final result = await repository.logout();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('isAuthenticated', () {
    test('should return true when token exists', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedToken())
          .thenAnswer((_) async => tToken);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, equals(const Right(true)));
    });

    test('should return false when token is null', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedToken())
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, equals(const Right(false)));
    });

    test('should return false when token is empty', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedToken())
          .thenAnswer((_) async => '');

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, equals(const Right(false)));
    });

    test('should return false when error occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedToken())
          .thenThrow(Exception('Error'));

      // Act
      final result = await repository.isAuthenticated();

      // Assert
      expect(result, equals(const Right(false)));
    });
  });

  group('getCurrentEmployee', () {
    test('should return Employee when successful', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedEmployee())
          .thenAnswer((_) async => tEmployeeModel);

      // Act
      final result = await repository.getCurrentEmployee();

      // Assert
      expect(result, equals(const Right(tEmployeeModel)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Employee not found');
      when(() => mockLocalDataSource.getCachedEmployee()).thenThrow(tException);

      // Act
      final result = await repository.getCurrentEmployee();

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Employee not found'))),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockLocalDataSource.getCachedEmployee())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getCurrentEmployee();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });
}
