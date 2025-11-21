import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/reports/domain/entities/detailed_sales_report.dart';
import 'package:backstage_frontend/features/reports/domain/entities/employee_report.dart';
import 'package:backstage_frontend/features/reports/domain/entities/sales_summary.dart';
import 'package:backstage_frontend/features/reports/domain/entities/ticket_sales_report.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_detailed_sales_report_usecase.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_employee_report_usecase.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_sales_summary_usecase.dart';
import 'package:backstage_frontend/features/reports/domain/usecases/get_ticket_sales_report_usecase.dart';
import 'package:backstage_frontend/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:backstage_frontend/features/reports/presentation/bloc/reports_event.dart';
import 'package:backstage_frontend/features/reports/presentation/bloc/reports_state.dart';

class MockGetSalesSummaryUseCase extends Mock implements GetSalesSummaryUseCase {}
class MockGetDetailedSalesReportUseCase extends Mock implements GetDetailedSalesReportUseCase {}
class MockGetTicketSalesReportUseCase extends Mock implements GetTicketSalesReportUseCase {}
class MockGetEmployeeReportUseCase extends Mock implements GetEmployeeReportUseCase {}

void main() {
  late ReportsBloc reportsBloc;
  late MockGetSalesSummaryUseCase mockGetSalesSummaryUseCase;
  late MockGetDetailedSalesReportUseCase mockGetDetailedSalesReportUseCase;
  late MockGetTicketSalesReportUseCase mockGetTicketSalesReportUseCase;
  late MockGetEmployeeReportUseCase mockGetEmployeeReportUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
    registerFallbackValue(DetailedSalesReportParams(
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
      groupBy: 'day',
    ));
    registerFallbackValue(TicketSalesReportParams(
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
      groupBy: 'day',
    ));
    registerFallbackValue(EmployeeReportParams(
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 1, 31),
    ));
  });

  setUp(() {
    mockGetSalesSummaryUseCase = MockGetSalesSummaryUseCase();
    mockGetDetailedSalesReportUseCase = MockGetDetailedSalesReportUseCase();
    mockGetTicketSalesReportUseCase = MockGetTicketSalesReportUseCase();
    mockGetEmployeeReportUseCase = MockGetEmployeeReportUseCase();
    reportsBloc = ReportsBloc(
      getSalesSummaryUseCase: mockGetSalesSummaryUseCase,
      getDetailedSalesReportUseCase: mockGetDetailedSalesReportUseCase,
      getTicketSalesReportUseCase: mockGetTicketSalesReportUseCase,
      getEmployeeReportUseCase: mockGetEmployeeReportUseCase,
    );
  });

  tearDown(() {
    reportsBloc.close();
  });

  const tSalesSummary = SalesSummary(
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

  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);

  final tDetailedSalesReport = DetailedSalesReport(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: 'day',
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

  final tTicketSalesReport = TicketSalesReport(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: 'day',
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

  test('initial state should be ReportsInitial', () {
    expect(reportsBloc.state, equals(const ReportsInitial()));
  });

  group('LoadSalesSummary', () {
    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, SalesSummaryLoaded] when loading sales summary is successful',
      build: () {
        when(() => mockGetSalesSummaryUseCase.call(any()))
            .thenAnswer((_) async => const Right(tSalesSummary));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(const LoadSalesSummary()),
      expect: () => [
        const ReportsLoading(),
        const SalesSummaryLoaded(tSalesSummary),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, ReportsError] when loading sales summary fails',
      build: () {
        when(() => mockGetSalesSummaryUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to fetch sales summary')));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(const LoadSalesSummary()),
      expect: () => [
        const ReportsLoading(),
        const ReportsError('Failed to fetch sales summary'),
      ],
    );
  });

  group('LoadDetailedSalesReport', () {
    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, DetailedSalesLoaded] when loading detailed sales report is successful',
      build: () {
        when(() => mockGetDetailedSalesReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tDetailedSalesReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
      )),
      expect: () => [
        const ReportsLoading(),
        DetailedSalesLoaded(tDetailedSalesReport),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, ReportsError] when loading detailed sales report fails',
      build: () {
        when(() => mockGetDetailedSalesReportUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to fetch detailed sales report')));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
      )),
      expect: () => [
        const ReportsLoading(),
        const ReportsError('Failed to fetch detailed sales report'),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should call use case with correct parameters including optional cashierCpf',
      build: () {
        when(() => mockGetDetailedSalesReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tDetailedSalesReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
        cashierCpf: '123.456.789-00',
      )),
      verify: (_) {
        verify(() => mockGetDetailedSalesReportUseCase.call(any())).called(1);
      },
    );
  });

  group('LoadTicketSalesReport', () {
    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, TicketSalesLoaded] when loading ticket sales report is successful',
      build: () {
        when(() => mockGetTicketSalesReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tTicketSalesReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
      )),
      expect: () => [
        const ReportsLoading(),
        TicketSalesLoaded(tTicketSalesReport),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, ReportsError] when loading ticket sales report fails',
      build: () {
        when(() => mockGetTicketSalesReportUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to fetch ticket sales report')));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
      )),
      expect: () => [
        const ReportsLoading(),
        const ReportsError('Failed to fetch ticket sales report'),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should call use case with correct parameters including optional fields',
      build: () {
        when(() => mockGetTicketSalesReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tTicketSalesReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: 'day',
        movieId: 'movie-123',
        employeeCpf: '123.456.789-00',
      )),
      verify: (_) {
        verify(() => mockGetTicketSalesReportUseCase.call(any())).called(1);
      },
    );
  });

  group('LoadEmployeeReport', () {
    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, EmployeeReportLoaded] when loading employee report is successful',
      build: () {
        when(() => mockGetEmployeeReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tEmployeeReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
      )),
      expect: () => [
        const ReportsLoading(),
        EmployeeReportLoaded(tEmployeeReport),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsLoading, ReportsError] when loading employee report fails',
      build: () {
        when(() => mockGetEmployeeReportUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to fetch employee report')));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
      )),
      expect: () => [
        const ReportsLoading(),
        const ReportsError('Failed to fetch employee report'),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should call use case with correct parameters including optional employeeCpf',
      build: () {
        when(() => mockGetEmployeeReportUseCase.call(any()))
            .thenAnswer((_) async => Right(tEmployeeReport));
        return reportsBloc;
      },
      act: (bloc) => bloc.add(LoadEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
        employeeCpf: '123.456.789-00',
      )),
      verify: (_) {
        verify(() => mockGetEmployeeReportUseCase.call(any())).called(1);
      },
    );
  });

  group('ResetReportsState', () {
    blocTest<ReportsBloc, ReportsState>(
      'should emit [ReportsInitial] when reset is requested',
      build: () => reportsBloc,
      seed: () => const ReportsError('Some error'),
      act: (bloc) => bloc.add(const ResetReportsState()),
      expect: () => [
        const ReportsInitial(),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'should reset from any state to initial',
      build: () => reportsBloc,
      seed: () => const SalesSummaryLoaded(tSalesSummary),
      act: (bloc) => bloc.add(const ResetReportsState()),
      expect: () => [
        const ReportsInitial(),
      ],
    );
  });
}
