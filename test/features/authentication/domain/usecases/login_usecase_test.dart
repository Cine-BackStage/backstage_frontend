import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';
import 'package:backstage_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCaseImpl useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCaseImpl(mockRepository);
  });

  const tEmployeeId = '12345';
  const tPassword = 'password123';
  const tEmployee = Employee(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: tEmployeeId,
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  test('should call repository.login with correct parameters', () async {
    // Arrange
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    await useCase.call(LoginParams(
      employeeId: tEmployeeId,
      password: tPassword,
    ));

    // Assert
    verify(() => mockRepository.login(tEmployeeId, tPassword)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Employee when login is successful', () async {
    // Arrange
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    final result = await useCase.call(LoginParams(
      employeeId: tEmployeeId,
      password: tPassword,
    ));

    // Assert
    expect(result, const Right(tEmployee));
  });

  test('should return Failure when login fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Login failed');
    when(() => mockRepository.login(any(), any()))
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(LoginParams(
      employeeId: tEmployeeId,
      password: tPassword,
    ));

    // Assert
    expect(result, const Left(tFailure));
  });
}
