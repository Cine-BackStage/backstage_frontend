import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/sales_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/session_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/inventory_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';
import 'package:backstage_frontend/features/dashboard/domain/usecases/refresh_dashboard_usecase.dart';
import 'package:backstage_frontend/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:backstage_frontend/features/dashboard/presentation/bloc/dashboard_event.dart';
import 'package:backstage_frontend/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetDashboardStatsUseCase extends Mock implements GetDashboardStatsUseCase {}
class MockRefreshDashboardUseCase extends Mock implements RefreshDashboardUseCase {}

void main() {
  late DashboardBloc dashboardBloc;
  late MockGetDashboardStatsUseCase mockGetDashboardStatsUseCase;
  late MockRefreshDashboardUseCase mockRefreshDashboardUseCase;

  setUpAll(() {
    registerFallbackValue(NoParams());
  });

  setUp(() {
    mockGetDashboardStatsUseCase = MockGetDashboardStatsUseCase();
    mockRefreshDashboardUseCase = MockRefreshDashboardUseCase();
    dashboardBloc = DashboardBloc(
      getDashboardStatsUseCase: mockGetDashboardStatsUseCase,
      refreshDashboardUseCase: mockRefreshDashboardUseCase,
    );
  });

  tearDown(() {
    dashboardBloc.close();
  });

  final tDashboardStats = DashboardStats(
    salesSummary: const SalesSummary(
      todayRevenue: 1500.0,
      todayTransactions: 25,
      averageTicketPrice: 60.0,
      weekRevenue: 10500.0,
      monthRevenue: 45000.0,
      growthPercentage: 15.5,
    ),
    sessionSummary: const SessionSummary(
      activeSessionsToday: 3,
      upcomingSessions: 5,
      totalSessionsToday: 8,
      averageOccupancy: 75.5,
      totalTicketsSold: 150,
    ),
    inventorySummary: const InventorySummary(
      lowStockItems: 5,
      expiringItems: 3,
      totalInventoryValue: 5000.0,
      totalItems: 50,
      outOfStockItems: 2,
    ),
    activeCustomers: 120,
    lastUpdated: DateTime(2024, 1, 15, 10, 30),
  );

  test('initial state should be DashboardInitial', () {
    expect(dashboardBloc.state, equals(const DashboardInitial()));
  });

  group('LoadDashboardStats', () {
    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardLoaded] when loading is successful',
      build: () {
        when(() => mockGetDashboardStatsUseCase.call(any()))
            .thenAnswer((_) async => Right(tDashboardStats));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const LoadDashboardStats()),
      expect: () => [
        const DashboardLoading(),
        DashboardLoaded(tDashboardStats),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardError] when loading fails',
      build: () {
        when(() => mockGetDashboardStatsUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to load dashboard')));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const LoadDashboardStats()),
      expect: () => [
        const DashboardLoading(),
        const DashboardError('Failed to load dashboard'),
      ],
    );
  });

  group('RefreshDashboard', () {
    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardLoaded] when there is no previous data',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => Right(tDashboardStats));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        const DashboardLoading(),
        DashboardLoaded(tDashboardStats),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardRefreshing, DashboardLoaded] when there is previous data',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => Right(tDashboardStats));
        return dashboardBloc;
      },
      seed: () => DashboardLoaded(tDashboardStats),
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        DashboardRefreshing(tDashboardStats),
        DashboardLoaded(tDashboardStats),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should emit [DashboardLoading, DashboardError] when refresh fails with no previous data',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to refresh')));
        return dashboardBloc;
      },
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        const DashboardLoading(),
        const DashboardError('Failed to refresh'),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should keep previous data when refresh fails with previous data',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => const Left(GenericFailure(message: 'Failed to refresh')));
        return dashboardBloc;
      },
      seed: () => DashboardLoaded(tDashboardStats),
      act: (bloc) => bloc.add(const RefreshDashboard()),
      expect: () => [
        DashboardRefreshing(tDashboardStats),
        DashboardLoaded(tDashboardStats),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'should throttle refresh requests within 2 seconds',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => Right(tDashboardStats));
        return dashboardBloc;
      },
      seed: () => DashboardLoaded(tDashboardStats),
      act: (bloc) async {
        bloc.add(const RefreshDashboard());
        await Future.delayed(const Duration(milliseconds: 100));
        bloc.add(const RefreshDashboard());
      },
      expect: () => [
        DashboardRefreshing(tDashboardStats),
        DashboardLoaded(tDashboardStats),
      ],
      verify: (_) {
        verify(() => mockRefreshDashboardUseCase.call(any())).called(1);
      },
    );

    blocTest<DashboardBloc, DashboardState>(
      'should allow refresh after 2 seconds',
      build: () {
        when(() => mockRefreshDashboardUseCase.call(any()))
            .thenAnswer((_) async => Right(tDashboardStats));
        return dashboardBloc;
      },
      seed: () => DashboardLoaded(tDashboardStats),
      act: (bloc) async {
        bloc.add(const RefreshDashboard());
        await Future.delayed(const Duration(seconds: 3));
        bloc.add(const RefreshDashboard());
      },
      wait: const Duration(seconds: 4),
      expect: () => [
        DashboardRefreshing(tDashboardStats),
        DashboardLoaded(tDashboardStats),
        DashboardRefreshing(tDashboardStats),
        DashboardLoaded(tDashboardStats),
      ],
      verify: (_) {
        verify(() => mockRefreshDashboardUseCase.call(any())).called(2);
      },
    );
  });
}
