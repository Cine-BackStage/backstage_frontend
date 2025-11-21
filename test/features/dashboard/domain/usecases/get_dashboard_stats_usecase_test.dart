import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/core/usecases/usecase.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/sales_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/session_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/inventory_summary.dart';
import 'package:backstage_frontend/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:backstage_frontend/features/dashboard/domain/usecases/get_dashboard_stats_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late GetDashboardStatsUseCaseImpl useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = GetDashboardStatsUseCaseImpl(mockRepository);
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

  test('should call repository.getDashboardStats', () async {
    // Arrange
    when(() => mockRepository.getDashboardStats())
        .thenAnswer((_) async => Right(tDashboardStats));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.getDashboardStats()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DashboardStats when repository call is successful', () async {
    // Arrange
    when(() => mockRepository.getDashboardStats())
        .thenAnswer((_) async => Right(tDashboardStats));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, Right(tDashboardStats));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to load dashboard stats');
    when(() => mockRepository.getDashboardStats())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
