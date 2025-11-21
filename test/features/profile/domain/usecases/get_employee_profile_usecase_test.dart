import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';
import 'package:backstage_frontend/features/profile/domain/repositories/profile_repository.dart';
import 'package:backstage_frontend/features/profile/domain/usecases/get_employee_profile_usecase.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetEmployeeProfileUseCaseImpl useCase;
  late MockProfileRepository mockRepository;

  setUp(() {
    mockRepository = MockProfileRepository();
    useCase = GetEmployeeProfileUseCaseImpl(mockRepository);
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

  test('should call repository.getEmployeeProfile', () async {
    // Arrange
    when(() => mockRepository.getEmployeeProfile())
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getEmployeeProfile()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return Employee when profile is retrieved successfully', () async {
    // Arrange
    when(() => mockRepository.getEmployeeProfile())
        .thenAnswer((_) async => const Right(tEmployee));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Right(tEmployee));
  });

  test('should return Failure when profile retrieval fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to get profile');
    when(() => mockRepository.getEmployeeProfile())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
