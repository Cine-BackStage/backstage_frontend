import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/dashboard/data/models/inventory_summary_model.dart';
import 'package:backstage_frontend/features/dashboard/domain/entities/inventory_summary.dart';

void main() {
  const tInventorySummaryModel = InventorySummaryModel(
    lowStockItems: 5,
    expiringItems: 3,
    totalInventoryValue: 5000.0,
    totalItems: 50,
    outOfStockItems: 2,
  );

  test('should be a subclass of InventorySummary entity', () {
    expect(tInventorySummaryModel, isA<InventorySummary>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'lowStockItems': 5,
        'expiringItems': 3,
        'totalInventoryValue': 5000.0,
        'totalItems': 50,
        'outOfStockItems': 2,
      };

      // Act
      final result = InventorySummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tInventorySummaryModel));
    });

    test('should return model with default values when fields are missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = InventorySummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.lowStockItems, 0);
      expect(result.expiringItems, 0);
      expect(result.totalInventoryValue, 0.0);
      expect(result.totalItems, 0);
      expect(result.outOfStockItems, 0);
    });

    test('should handle integer values for double fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'lowStockItems': 5,
        'expiringItems': 3,
        'totalInventoryValue': 5000,
        'totalItems': 50,
        'outOfStockItems': 2,
      };

      // Act
      final result = InventorySummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.totalInventoryValue, 5000.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tInventorySummaryModel.toJson();

      // Assert
      final expectedMap = {
        'lowStockItems': 5,
        'expiringItems': 3,
        'totalInventoryValue': 5000.0,
        'totalItems': 50,
        'outOfStockItems': 2,
      };
      expect(result, equals(expectedMap));
    });
  });

  group('fromEntity', () {
    test('should convert InventorySummary entity to InventorySummaryModel', () {
      // Arrange
      const tInventorySummary = InventorySummary(
        lowStockItems: 5,
        expiringItems: 3,
        totalInventoryValue: 5000.0,
        totalItems: 50,
        outOfStockItems: 2,
      );

      // Act
      final result = InventorySummaryModel.fromEntity(tInventorySummary);

      // Assert
      expect(result, equals(tInventorySummaryModel));
    });
  });
}
