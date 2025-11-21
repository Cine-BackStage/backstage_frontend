import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/reports/domain/entities/employee_report.dart';
import 'package:backstage_frontend/features/reports/domain/repositories/reports_repository.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_employee_report_usecase.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late GetEmployeeReportUseCaseImpl useCase;
  late MockReportsRepository mockRepository;

  setUp(() {
    mockRepository = MockReportsRepository();
    useCase = GetEmployeeReportUseCaseImpl(mockRepository);
  });

  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);
  const tEmployeeCpf = '123.456.789-00';

  final tEmployeeReport = EmployeeReport(
    startDate: tStartDate,
    endDate: tEndDate,
    employees: const [
      EmployeePerformance(
        cpf: '123.456.789-00',
        name: 'John Doe',
        role: 'CASHIER',
        salesCount: 50,
        totalRevenue: 2500.0,
        averageSaleValue: 50.0,
        hoursWorked: 160,
        performance: 85.5,
      ),
    ],
    summary: const EmployeeReportSummary(
      totalEmployees: 5,
      activeCashiers: 3,
      averageRevenue: 2000.0,
      totalRevenue: 10000.0,
    ),
  );

  final tParams = EmployeeReportParams(
    startDate: tStartDate,
    endDate: tEndDate,
    employeeCpf: tEmployeeCpf,
  );

  test('should call repository.getEmployeeReport with correct parameters', () async {
    // Arrange
    when(() => mockRepository.getEmployeeReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => Right(tEmployeeReport));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.getEmployeeReport(
          startDate: tStartDate,
          endDate: tEndDate,
          employeeCpf: tEmployeeCpf,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return EmployeeReport when call is successful', () async {
    // Arrange
    when(() => mockRepository.getEmployeeReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => Right(tEmployeeReport));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tEmployeeReport));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch employee report');
    when(() => mockRepository.getEmployeeReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
