import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/reports/domain/entities/detailed_sales_report.dart';
import 'package:backstage_frontend/features/reports/domain/repositories/reports_repository.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_detailed_sales_report_usecase.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late GetDetailedSalesReportUseCaseImpl useCase;
  late MockReportsRepository mockRepository;

  setUp(() {
    mockRepository = MockReportsRepository();
    useCase = GetDetailedSalesReportUseCaseImpl(mockRepository);
  });

  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);
  const tGroupBy = 'day';
  const tCashierCpf = '123.456.789-00';

  final tDetailedSalesReport = DetailedSalesReport(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: tGroupBy,
    summary: const ReportSummary(
      totalSales: 100,
      totalRevenue: 5000.0,
      totalDiscount: 250.0,
      averageSaleValue: 50.0,
    ),
    groupedData: const [
      SalesGroupData(
        key: '2024-01-01',
        label: '2024-01-01',
        salesCount: 20,
        revenue: 1000.0,
      ),
    ],
  );

  final tParams = DetailedSalesReportParams(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: tGroupBy,
    cashierCpf: tCashierCpf,
  );

  test('should call repository.getDetailedSalesReport with correct parameters', () async {
    // Arrange
    when(() => mockRepository.getDetailedSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          cashierCpf: any(named: 'cashierCpf'),
        )).thenAnswer((_) async => Right(tDetailedSalesReport));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.getDetailedSalesReport(
          startDate: tStartDate,
          endDate: tEndDate,
          groupBy: tGroupBy,
          cashierCpf: tCashierCpf,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DetailedSalesReport when call is successful', () async {
    // Arrange
    when(() => mockRepository.getDetailedSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          cashierCpf: any(named: 'cashierCpf'),
        )).thenAnswer((_) async => Right(tDetailedSalesReport));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tDetailedSalesReport));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch detailed sales report');
    when(() => mockRepository.getDetailedSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          cashierCpf: any(named: 'cashierCpf'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
