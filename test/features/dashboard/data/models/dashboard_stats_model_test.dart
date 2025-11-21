import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/dashboard/data/models/dashboard_stats_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/session_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/data/models/inventory_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/dashboard_stats.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 15, 10, 30);
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
    lastUpdated: tDateTime,
  );

  test('should be a subclass of DashboardStats entity', () {
    expect(tDashboardStatsModel, isA<DashboardStats>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'salesSummary': {
          'todayRevenue': 1500.0,
          'todayTransactions': 25,
          'averageTicketPrice': 60.0,
          'weekRevenue': 10500.0,
          'monthRevenue': 45000.0,
          'growthPercentage': 15.5,
        },
        'sessionSummary': {
          'activeSessionsToday': 3,
          'upcomingSessions': 5,
          'totalSessionsToday': 8,
          'averageOccupancy': 75.5,
          'totalTicketsSold': 150,
        },
        'inventorySummary': {
          'lowStockItems': 5,
          'expiringItems': 3,
          'totalInventoryValue': 5000.0,
          'totalItems': 50,
          'outOfStockItems': 2,
        },
        'activeCustomers': 120,
        'lastUpdated': tDateTime.toIso8601String(),
      };

      // Act
      final result = DashboardStatsModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tDashboardStatsModel));
    });

    test('should return model with default values when nested objects are missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'activeCustomers': 120,
      };

      // Act
      final result = DashboardStatsModel.fromJson(jsonMap);

      // Assert
      expect(result.activeCustomers, 120);
      expect(result.salesSummary.todayRevenue, 0.0);
      expect(result.sessionSummary.activeSessionsToday, 0);
      expect(result.inventorySummary.lowStockItems, 0);
    });

    test('should handle missing lastUpdated field', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'salesSummary': <String, dynamic>{},
        'sessionSummary': <String, dynamic>{},
        'inventorySummary': <String, dynamic>{},
        'activeCustomers': 120,
      };

      // Act
      final result = DashboardStatsModel.fromJson(jsonMap);

      // Assert
      expect(result.lastUpdated, isA<DateTime>());
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tDashboardStatsModel.toJson();

      // Assert
      expect(result['salesSummary'], isA<Map<String, dynamic>>());
      expect(result['sessionSummary'], isA<Map<String, dynamic>>());
      expect(result['inventorySummary'], isA<Map<String, dynamic>>());
      expect(result['activeCustomers'], 120);
      expect(result['lastUpdated'], tDateTime.toIso8601String());

      expect(result['salesSummary']['todayRevenue'], 1500.0);
      expect(result['sessionSummary']['activeSessionsToday'], 3);
      expect(result['inventorySummary']['lowStockItems'], 5);
    });
  });

  group('fromEntity', () {
    test('should convert DashboardStats entity to DashboardStatsModel', () {
      // Arrange
      final tDashboardStats = DashboardStats(
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
        lastUpdated: tDateTime,
      );

      // Act
      final result = DashboardStatsModel.fromEntity(tDashboardStats);

      // Assert
      expect(result, equals(tDashboardStatsModel));
    });
  });
}
