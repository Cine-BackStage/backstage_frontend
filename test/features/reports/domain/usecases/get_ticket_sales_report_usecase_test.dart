import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/reports/domain/entities/ticket_sales_report.dart';
import 'package:backstage_frontend/features/reports/domain/repositories/reports_repository.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_ticket_sales_report_usecase.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late GetTicketSalesReportUseCaseImpl useCase;
  late MockReportsRepository mockRepository;

  setUp(() {
    mockRepository = MockReportsRepository();
    useCase = GetTicketSalesReportUseCaseImpl(mockRepository);
  });

  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);
  const tGroupBy = 'day';
  const tMovieId = 'movie-123';
  const tEmployeeCpf = '123.456.789-00';

  final tTicketSalesReport = TicketSalesReport(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: tGroupBy,
    summary: const TicketReportSummary(
      totalTickets: 100,
      totalRevenue: 5000.0,
      averageTicketPrice: 50.0,
      cancelledTickets: 5,
    ),
    groupedData: const [
      TicketGroupData(
        key: '2024-01-01',
        label: '2024-01-01',
        ticketCount: 20,
        revenue: 1000.0,
      ),
    ],
  );

  final tParams = TicketSalesReportParams(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: tGroupBy,
    movieId: tMovieId,
    employeeCpf: tEmployeeCpf,
  );

  test('should call repository.getTicketSalesReport with correct parameters', () async {
    // Arrange
    when(() => mockRepository.getTicketSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          movieId: any(named: 'movieId'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => Right(tTicketSalesReport));

    // Act
    await useCase.call(tParams);

    // Assert
    verify(() => mockRepository.getTicketSalesReport(
          startDate: tStartDate,
          endDate: tEndDate,
          groupBy: tGroupBy,
          movieId: tMovieId,
          employeeCpf: tEmployeeCpf,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return TicketSalesReport when call is successful', () async {
    // Arrange
    when(() => mockRepository.getTicketSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          movieId: any(named: 'movieId'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => Right(tTicketSalesReport));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, Right(tTicketSalesReport));
  });

  test('should return Failure when call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to fetch ticket sales report');
    when(() => mockRepository.getTicketSalesReport(
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          groupBy: any(named: 'groupBy'),
          movieId: any(named: 'movieId'),
          employeeCpf: any(named: 'employeeCpf'),
        )).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(tParams);

    // Assert
    expect(result, const Left(tFailure));
  });
}
