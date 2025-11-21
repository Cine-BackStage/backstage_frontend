import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/reports/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/reports/domain/entities/sales_summary.dart';

void main() {
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

  test('should be a subclass of SalesSummary entity', () {
    expect(tSalesSummaryModel, isA<SalesSummary>());
  });

  group('fromJson', () {
    test('should return a valid model from flat JSON structure', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'todayRevenue': 1000.0,
        'todayTransactions': 10,
        'weekRevenue': 5000.0,
        'weekTransactions': 50,
        'monthRevenue': 20000.0,
        'monthTransactions': 200,
        'lastMonthRevenue': 18000.0,
        'lastMonthTransactions': 180,
        'growthPercentage': 11.11,
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tSalesSummaryModel));
    });

    test('should return a valid model from nested JSON structure', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'today': {
          'revenue': 1000.0,
          'transactions': 10,
        },
        'week': {
          'revenue': 5000.0,
          'transactions': 50,
        },
        'month': {
          'revenue': 20000.0,
          'transactions': 200,
        },
        'lastMonth': {
          'revenue': 18000.0,
          'transactions': 180,
        },
        'growthPercentage': 11.11,
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tSalesSummaryModel));
    });

    test('should handle missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'todayRevenue': 1000.0,
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.todayRevenue, equals(1000.0));
      expect(result.todayTransactions, equals(0));
      expect(result.weekRevenue, equals(0.0));
      expect(result.growthPercentage, equals(0.0));
    });

    test('should handle nested structure with missing values', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'today': {
          'revenue': 1000.0,
        },
        'week': {},
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.todayRevenue, equals(1000.0));
      expect(result.todayTransactions, equals(0));
      expect(result.weekRevenue, equals(0.0));
      expect(result.weekTransactions, equals(0));
    });
  });
}
