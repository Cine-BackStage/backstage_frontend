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
import 'package:backstage_frontend/features/dashboard/domain/usecases/refresh_dashboard_usecase.dart';

class MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late RefreshDashboardUseCaseImpl useCase;
  late MockDashboardRepository mockRepository;

  setUp(() {
    mockRepository = MockDashboardRepository();
    useCase = RefreshDashboardUseCaseImpl(mockRepository);
  });

  final tDashboardStats = DashboardStats(
    salesSummary: const SalesSummary(
      todayRevenue: 1800.0,
      todayTransactions: 30,
      averageTicketPrice: 60.0,
      weekRevenue: 12000.0,
      monthRevenue: 50000.0,
      growthPercentage: 20.0,
    ),
    sessionSummary: const SessionSummary(
      activeSessionsToday: 4,
      upcomingSessions: 6,
      totalSessionsToday: 10,
      averageOccupancy: 80.0,
      totalTicketsSold: 200,
    ),
    inventorySummary: const InventorySummary(
      lowStockItems: 4,
      expiringItems: 2,
      totalInventoryValue: 5500.0,
      totalItems: 55,
      outOfStockItems: 1,
    ),
    activeCustomers: 150,
    lastUpdated: DateTime(2024, 1, 15, 14, 30),
  );

  test('should call repository.refreshDashboard', () async {
    // Arrange
    when(() => mockRepository.refreshDashboard())
        .thenAnswer((_) async => Right(tDashboardStats));

    // Act
    await useCase.call(NoParams());

    // Assert
    verify(() => mockRepository.refreshDashboard()).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DashboardStats when repository call is successful', () async {
    // Arrange
    when(() => mockRepository.refreshDashboard())
        .thenAnswer((_) async => Right(tDashboardStats));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, Right(tDashboardStats));
  });

  test('should return Failure when repository call fails', () async {
    // Arrange
    const tFailure = GenericFailure(message: 'Failed to refresh dashboard');
    when(() => mockRepository.refreshDashboard())
        .thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.call(NoParams());

    // Assert
    expect(result, const Left(tFailure));
  });
}
