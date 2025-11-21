import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/storage/local_storage.dart' hide StorageKeys;
import 'package:backstage_frontend/core/constants/storage_keys.dart';
import 'package:backstage_frontend/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:backstage_frontend/features/authentication/data/models/employee_model.dart';

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late AuthLocalDataSourceImpl dataSource;
  late MockLocalStorage mockStorage;

  setUp(() {
    mockStorage = MockLocalStorage();
    dataSource = AuthLocalDataSourceImpl(mockStorage);
  });

  const tToken = 'test_token_123';
  const tEmployeeModel = EmployeeModel(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: '12345',
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  group('cacheToken', () {
    test('should call LocalStorage to cache token', () async {
      // Arrange
      when(() => mockStorage.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheToken(tToken);

      // Assert
      verify(() => mockStorage.setString(StorageKeys.authToken, tToken))
          .called(1);
    });
  });

  group('getCachedToken', () {
    test('should return cached token from LocalStorage', () async {
      // Arrange
      when(() => mockStorage.getString(any())).thenReturn(tToken);

      // Act
      final result = await dataSource.getCachedToken();

      // Assert
      expect(result, equals(tToken));
      verify(() => mockStorage.getString(StorageKeys.authToken)).called(1);
    });

    test('should return null when no token is cached', () async {
      // Arrange
      when(() => mockStorage.getString(any())).thenReturn(null);

      // Act
      final result = await dataSource.getCachedToken();

      // Assert
      expect(result, null);
    });
  });

  group('cacheEmployee', () {
    test('should call LocalStorage to cache employee data', () async {
      // Arrange
      when(() => mockStorage.setString(any(), any()))
          .thenAnswer((_) async => true);

      // Act
      await dataSource.cacheEmployee(tEmployeeModel);

      // Assert
      verify(() => mockStorage.setString(StorageKeys.userCpf, tEmployeeModel.cpf))
          .called(1);
      verify(() => mockStorage.setString(StorageKeys.userName, tEmployeeModel.fullName))
          .called(1);
      verify(() => mockStorage.setString(StorageKeys.userRole, tEmployeeModel.role))
          .called(1);
      verify(() => mockStorage.setString(StorageKeys.userEmail, tEmployeeModel.email))
          .called(1);
      verify(() => mockStorage.setString(StorageKeys.employeeId, tEmployeeModel.employeeId))
          .called(1);
      verify(() => mockStorage.setString(StorageKeys.companyId, tEmployeeModel.companyId))
          .called(1);
      verify(() => mockStorage.setString('cached_employee', any())).called(1);
    });
  });

  group('getCachedEmployee', () {
    test('should return cached employee from LocalStorage', () async {
      // Arrange
      const employeeJson = '{"cpf":"123.456.789-00","companyId":"comp-123","employeeId":"12345","role":"cashier","fullName":"John Doe","email":"john@example.com","isActive":true}';
      when(() => mockStorage.getString('cached_employee'))
          .thenReturn(employeeJson);

      // Act
      final result = await dataSource.getCachedEmployee();

      // Assert
      expect(result, equals(tEmployeeModel));
    });

    test('should throw AppException when no employee is cached', () async {
      // Arrange
      when(() => mockStorage.getString('cached_employee')).thenReturn(null);

      // Act & Assert
      expect(
        () => dataSource.getCachedEmployee(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('clearAuthData', () {
    test('should clear all auth data from LocalStorage', () async {
      // Arrange
      when(() => mockStorage.remove(any())).thenAnswer((_) async => true);

      // Act
      await dataSource.clearAuthData();

      // Assert
      verify(() => mockStorage.remove(StorageKeys.authToken)).called(1);
      verify(() => mockStorage.remove(StorageKeys.userCpf)).called(1);
      verify(() => mockStorage.remove(StorageKeys.userName)).called(1);
      verify(() => mockStorage.remove(StorageKeys.userRole)).called(1);
      verify(() => mockStorage.remove(StorageKeys.userEmail)).called(1);
      verify(() => mockStorage.remove(StorageKeys.employeeId)).called(1);
      verify(() => mockStorage.remove(StorageKeys.companyId)).called(1);
      verify(() => mockStorage.remove('cached_employee')).called(1);
    });
  });
}
