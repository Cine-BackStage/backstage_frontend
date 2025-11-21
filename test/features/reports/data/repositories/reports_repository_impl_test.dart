import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:backstage_frontend/features/reports/data/models/detailed_sales_report_model.dart';
import 'package:backstage_frontend/features/reports/data/models/employee_report_model.dart';
import 'package:backstage_frontend/features/reports/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/reports/data/models/ticket_sales_report_model.dart';
import 'package:backstage_frontend/features/reports/data/repositories/reports_repository_impl.dart';

class MockReportsRemoteDataSource extends Mock implements ReportsRemoteDataSource {}

void main() {
  late ReportsRepositoryImpl repository;
  late MockReportsRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockReportsRemoteDataSource();
    repository = ReportsRepositoryImpl(mockRemoteDataSource);
  });

  group('getSalesSummary', () {
    const tSalesSummaryModel = SalesSummaryModel(
      todayRevenue: 1000.0,
      todayTransactions: 10,
      weekRevenue: 5000.0,
      weekTransactions: 50,
      monthRevenue: 20000.0,
      monthTransactions: 200,
      lastMonthRevenue: 18000.0,
      lastMonthTransactions: 180,
      growthPercentage: 11.11,
    );

    test('should return SalesSummary when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSalesSummary())
          .thenAnswer((_) async => tSalesSummaryModel);

      // Act
      final result = await repository.getSalesSummary();

      // Assert
      verify(() => mockRemoteDataSource.getSalesSummary()).called(1);
      expect(result, equals(const Right(tSalesSummaryModel)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to fetch sales summary',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getSalesSummary()).thenThrow(tException);

      // Act
      final result = await repository.getSalesSummary();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<GenericFailure>());
          expect(failure.message, equals('Failed to fetch sales summary'));
        },
        (_) => fail('Should return failure'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSalesSummary())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getSalesSummary();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getDetailedSalesReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tGroupBy = 'day';
    const tCashierCpf = '123.456.789-00';

    final tDetailedSalesReportModel = DetailedSalesReportModel(
      startDate: tStartDate,
      endDate: tEndDate,
      groupBy: tGroupBy,
      summary: const ReportSummaryModel(
        totalSales: 100,
        totalRevenue: 5000.0,
        totalDiscount: 250.0,
        averageSaleValue: 50.0,
      ),
      groupedData: const [
        SalesGroupDataModel(
          key: '2024-01-01',
          label: '2024-01-01',
          salesCount: 20,
          revenue: 1000.0,
        ),
      ],
    );

    test('should return DetailedSalesReport when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDetailedSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            cashierCpf: any(named: 'cashierCpf'),
          )).thenAnswer((_) async => tDetailedSalesReportModel);

      // Act
      final result = await repository.getDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        cashierCpf: tCashierCpf,
      );

      // Assert
      verify(() => mockRemoteDataSource.getDetailedSalesReport(
            startDate: tStartDate,
            endDate: tEndDate,
            groupBy: tGroupBy,
            cashierCpf: tCashierCpf,
          )).called(1);
      expect(result, Right(tDetailedSalesReportModel));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to fetch detailed sales report',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getDetailedSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            cashierCpf: any(named: 'cashierCpf'),
          )).thenThrow(tException);

      // Act
      final result = await repository.getDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        cashierCpf: tCashierCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDetailedSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            cashierCpf: any(named: 'cashierCpf'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        cashierCpf: tCashierCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getTicketSalesReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tGroupBy = 'day';
    const tMovieId = 'movie-123';
    const tEmployeeCpf = '123.456.789-00';

    final tTicketSalesReportModel = TicketSalesReportModel(
      startDate: tStartDate,
      endDate: tEndDate,
      groupBy: tGroupBy,
      summary: const TicketReportSummaryModel(
        totalTickets: 100,
        totalRevenue: 5000.0,
        averageTicketPrice: 50.0,
        cancelledTickets: 5,
      ),
      groupedData: const [
        TicketGroupDataModel(
          key: '2024-01-01',
          label: '2024-01-01',
          ticketCount: 20,
          revenue: 1000.0,
        ),
      ],
    );

    test('should return TicketSalesReport when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTicketSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            movieId: any(named: 'movieId'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenAnswer((_) async => tTicketSalesReportModel);

      // Act
      final result = await repository.getTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        movieId: tMovieId,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      verify(() => mockRemoteDataSource.getTicketSalesReport(
            startDate: tStartDate,
            endDate: tEndDate,
            groupBy: tGroupBy,
            movieId: tMovieId,
            employeeCpf: tEmployeeCpf,
          )).called(1);
      expect(result, Right(tTicketSalesReportModel));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to fetch ticket sales report',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getTicketSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            movieId: any(named: 'movieId'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenThrow(tException);

      // Act
      final result = await repository.getTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        movieId: tMovieId,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTicketSalesReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            groupBy: any(named: 'groupBy'),
            movieId: any(named: 'movieId'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        movieId: tMovieId,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getEmployeeReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tEmployeeCpf = '123.456.789-00';

    final tEmployeeReportModel = EmployeeReportModel(
      startDate: tStartDate,
      endDate: tEndDate,
      employees: const [
        EmployeePerformanceModel(
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
      summary: const EmployeeReportSummaryModel(
        totalEmployees: 5,
        activeCashiers: 3,
        averageRevenue: 2000.0,
        totalRevenue: 10000.0,
      ),
    );

    test('should return EmployeeReport when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getEmployeeReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenAnswer((_) async => tEmployeeReportModel);

      // Act
      final result = await repository.getEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      verify(() => mockRemoteDataSource.getEmployeeReport(
            startDate: tStartDate,
            endDate: tEndDate,
            employeeCpf: tEmployeeCpf,
          )).called(1);
      expect(result, Right(tEmployeeReportModel));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to fetch employee report',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getEmployeeReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenThrow(tException);

      // Act
      final result = await repository.getEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getEmployeeReport(
            startDate: any(named: 'startDate'),
            endDate: any(named: 'endDate'),
            employeeCpf: any(named: 'employeeCpf'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });
}
