import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';
import 'package:backstage_frontend/features/authentication/domain/repositories/auth_repository.dart';
import 'package:backstage_frontend/features/authentication/domain/usecases/get_current_employee_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentEmployeeUseCaseImpl useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentEmployeeUseCaseImpl(mockRepository);
  });

  const tEmployee = Employee(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: '12345',
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  test('should call repository.getCurrentEmployee', () async {
    // Arrange
    when(() => mockRepository.getCurrentEmployee())
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getCurrentEmployee()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Employee when successful', () async {
    // Arrange
    when(() => mockRepository.getCurrentEmployee())
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(tEmployee));
  });

  test('should return Failure when getting employee fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Employee not found');
    when(() => mockRepository.getCurrentEmployee())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
