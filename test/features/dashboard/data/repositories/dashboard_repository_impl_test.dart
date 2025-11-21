import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:backstage_frontend/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/session_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/inventory_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/data/repositories/dashboard_repository_impl.dart';

class MockDashboardRemoteDataSource extends Mock implements DashboardRemoteDataSource {}

void main() {
  late DashboardRepositoryImpl repository;
  late MockDashboardRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockDashboardRemoteDataSource();
    repository = DashboardRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
    );
  });

  final tDashboardStatsModel = DashboardStatsModel(
    salesSummary: const SalesSummaryModel(
      todayRevenue: 1500.0,
      todayTransactions: 25,
      averageTicketPrice: 60.0,
      weekRevenue: 10500.0,
      monthRevenue: 45000.0,
      growthPercentage: 15.5,
    ),
    sessionSummary: const SessionSummaryModel(
      activeSessionsToday: 3,
      upcomingSessions: 5,
      totalSessionsToday: 8,
      averageOccupancy: 75.5,
      totalTicketsSold: 150,
    ),
    inventorySummary: const InventorySummaryModel(
      lowStockItems: 5,
      expiringItems: 3,
      totalInventoryValue: 5000.0,
      totalItems: 50,
      outOfStockItems: 2,
    ),
    activeCustomers: 120,
    lastUpdated: DateTime(2024, 1, 15, 10, 30),
  );

  group('getDashboardStats', () {
    test('should return DashboardStats when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenAnswer((_) async => tDashboardStatsModel);

      // Act
      final result = await repository.getDashboardStats();

      // Assert
      verify(() => mockRemoteDataSource.getDashboardStats()).called(1);
      expect(result, equals(Right(tDashboardStatsModel)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to load dashboard stats',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getDashboardStats()).thenThrow(tException);

      // Act
      final result = await repository.getDashboardStats();

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Failed to load dashboard stats',
          statusCode: 500,
        ))),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getDashboardStats();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<GenericFailure>());
          expect(failure.message, contains('Erro ao carregar dashboard'));
        },
        (_) => fail('Should return Left'),
      );
    });
  });

  group('refreshDashboard', () {
    test('should return DashboardStats when remote data source call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenAnswer((_) async => tDashboardStatsModel);

      // Act
      final result = await repository.refreshDashboard();

      // Assert
      verify(() => mockRemoteDataSource.getDashboardStats()).called(1);
      expect(result, equals(Right(tDashboardStatsModel)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to refresh dashboard',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getDashboardStats()).thenThrow(tException);

      // Act
      final result = await repository.refreshDashboard();

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Failed to refresh dashboard',
          statusCode: 500,
        ))),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.refreshDashboard();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) {
          expect(failure, isA<GenericFailure>());
          expect(failure.message, contains('Erro ao carregar dashboard'));
        },
        (_) => fail('Should return Left'),
      );
    });

    test('should call getDashboardStats internally (refresh is same as get)', () async {
      // Arrange
      when(() => mockRemoteDataSource.getDashboardStats())
          .thenAnswer((_) async => tDashboardStatsModel);

      // Act
      await repository.refreshDashboard();

      // Assert
      verify(() => mockRemoteDataSource.getDashboardStats()).called(1);
    });
  });
}
