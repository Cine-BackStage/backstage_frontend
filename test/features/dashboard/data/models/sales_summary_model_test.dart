import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/dashboard/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/sales_summary.dart';

void main() {
  const tSalesSummaryModel = SalesSummaryModel(
    todayRevenue: 1500.0,
    todayTransactions: 25,
    averageTicketPrice: 60.0,
    weekRevenue: 10500.0,
    monthRevenue: 45000.0,
    growthPercentage: 15.5,
  );

  test('should be a subclass of SalesSummary entity', () {
    expect(tSalesSummaryModel, isA<SalesSummary>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'todayRevenue': 1500.0,
        'todayTransactions': 25,
        'averageTicketPrice': 60.0,
        'weekRevenue': 10500.0,
        'monthRevenue': 45000.0,
        'growthPercentage': 15.5,
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tSalesSummaryModel));
    });

    test('should return model with default values when fields are missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.todayRevenue, 0.0);
      expect(result.todayTransactions, 0);
      expect(result.averageTicketPrice, 0.0);
      expect(result.weekRevenue, 0.0);
      expect(result.monthRevenue, 0.0);
      expect(result.growthPercentage, 0.0);
    });

    test('should handle integer values for double fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'todayRevenue': 1500,
        'todayTransactions': 25,
        'averageTicketPrice': 60,
        'weekRevenue': 10500,
        'monthRevenue': 45000,
        'growthPercentage': 15,
      };

      // Act
      final result = SalesSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.todayRevenue, 1500.0);
      expect(result.averageTicketPrice, 60.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSalesSummaryModel.toJson();

      // Assert
      final expectedMap = {
        'todayRevenue': 1500.0,
        'todayTransactions': 25,
        'averageTicketPrice': 60.0,
        'weekRevenue': 10500.0,
        'monthRevenue': 45000.0,
        'growthPercentage': 15.5,
      };
      expect(result, equals(expectedMap));
    });
  });

  group('fromEntity', () {
    test('should convert SalesSummary entity to SalesSummaryModel', () {
      // Arrange
      const tSalesSummary = SalesSummary(
        todayRevenue: 1500.0,
        todayTransactions: 25,
        averageTicketPrice: 60.0,
        weekRevenue: 10500.0,
        monthRevenue: 45000.0,
        growthPercentage: 15.5,
      );

      // Act
      final result = SalesSummaryModel.fromEntity(tSalesSummary);

      // Assert
      expect(result, equals(tSalesSummaryModel));
    });
  });
}
