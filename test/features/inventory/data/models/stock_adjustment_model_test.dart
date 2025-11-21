import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:backstage_frontend/features/inventory/domain/entities/stock_adjustment.dart';

void main() {
  final tTimestamp = DateTime(2024, 1, 1, 10, 0);
  final tStockAdjustmentModel = StockAdjustmentModel(
    id: 'adj-1',
    sku: 'SKU001',
    productName: 'Popcorn',
    type: AdjustmentType.addition,
    quantityBefore: 100,
    quantityAfter: 110,
    quantityChanged: 10,
    reason: 'Restock',
    notes: 'New shipment arrived',
    employeeName: 'John Doe',
    timestamp: tTimestamp,
  );

  test('should be a subclass of StockAdjustment entity', () {
    expect(tStockAdjustmentModel, isA<StockAdjustment>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with addition type', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-1',
        'sku': 'SKU001',
        'productName': 'Popcorn',
        'adjustmentType': 'ADDITION',
        'qtyBefore': 100,
        'qtyAfter': 110,
        'qtyChanged': 10,
        'reason': 'Restock',
        'notes': 'New shipment arrived',
        'employeeName': 'John Doe',
        'timestamp': '2024-01-01T10:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tStockAdjustmentModel));
    });

    test('should parse removal adjustment type correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-2',
        'sku': 'SKU002',
        'productName': 'Soda',
        'adjustmentType': 'REMOVAL',
        'qtyBefore': 50,
        'qtyAfter': 40,
        'qtyChanged': -10,
        'reason': 'Damage',
        'employeeName': 'Jane Smith',
        'timestamp': '2024-01-01T11:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.removal));
    });

    test('should parse correction adjustment type correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-3',
        'sku': 'SKU003',
        'productName': 'Candy',
        'adjustmentType': 'CORRECTION',
        'qtyBefore': 75,
        'qtyAfter': 80,
        'qtyChanged': 5,
        'employeeName': 'John Doe',
        'timestamp': '2024-01-01T12:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.correction));
    });

    test('should parse damage adjustment type correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-4',
        'sku': 'SKU004',
        'productName': 'Chips',
        'adjustmentType': 'DAMAGE',
        'qtyBefore': 100,
        'qtyAfter': 95,
        'qtyChanged': -5,
        'reason': 'Damaged package',
        'employeeName': 'Jane Smith',
        'timestamp': '2024-01-01T13:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.damage));
    });

    test('should parse expiry adjustment type correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-5',
        'sku': 'SKU005',
        'productName': 'Milk',
        'adjustmentType': 'EXPIRY',
        'qtyBefore': 20,
        'qtyAfter': 18,
        'qtyChanged': -2,
        'reason': 'Expired',
        'employeeName': 'John Doe',
        'timestamp': '2024-01-01T14:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.expiry));
    });

    test('should parse transfer adjustment type correctly', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-6',
        'sku': 'SKU006',
        'productName': 'Juice',
        'adjustmentType': 'TRANSFER',
        'qtyBefore': 30,
        'qtyAfter': 25,
        'qtyChanged': -5,
        'reason': 'Transferred to another location',
        'employeeName': 'Jane Smith',
        'timestamp': '2024-01-01T15:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.transfer));
    });

    test('should default to correction type for unknown adjustment type', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-7',
        'sku': 'SKU007',
        'productName': 'Water',
        'adjustmentType': 'UNKNOWN_TYPE',
        'qtyBefore': 40,
        'qtyAfter': 45,
        'qtyChanged': 5,
        'employeeName': 'John Doe',
        'timestamp': '2024-01-01T16:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.type, equals(AdjustmentType.correction));
    });

    test('should handle null optional fields', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'adj-8',
        'sku': 'SKU008',
        'productName': 'Cookies',
        'adjustmentType': 'ADDITION',
        'qtyBefore': 60,
        'qtyAfter': 70,
        'qtyChanged': 10,
        'employeeName': 'Jane Smith',
        'timestamp': '2024-01-01T17:00:00.000',
      };

      // Act
      final result = StockAdjustmentModel.fromJson(jsonMap);

      // Assert
      expect(result.reason, isNull);
      expect(result.notes, isNull);
    });
  });
}
