import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/pos/data/models/product_model.dart';
import 'package:backstage_frontend/features/pos/domain/entities/product.dart';

void main() {
  final tProductModel = ProductModel(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    barcode: '1234567890',
    isActive: true,
    expiryDate: DateTime(2025, 12, 31),
  );

  test('should be a subclass of Product entity', () {
    expect(tProductModel, isA<Product>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with food data', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'sku': 'SKU001',
        'name': 'Popcorn',
        'unitPrice': 15.0,
        'qtyOnHand': 100,
        'reorderLevel': 20,
        'barcode': '1234567890',
        'isActive': true,
        'food': {
          'category': 'Snacks',
          'expiryDate': '2025-12-31T00:00:00.000Z',
        },
      };

      // Act
      final result = ProductModel.fromJson(jsonMap);

      // Assert
      expect(result.sku, 'SKU001');
      expect(result.name, 'Popcorn');
      expect(result.unitPrice, 15.0);
      expect(result.category, 'Snacks');
      expect(result.qtyOnHand, 100);
      expect(result.reorderLevel, 20);
      expect(result.barcode, '1234567890');
      expect(result.isActive, true);
      expect(result.expiryDate, isNotNull);
    });

    test('should return a valid model from JSON with collectable data', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'sku': 'SKU002',
        'name': 'Action Figure',
        'unitPrice': 50.0,
        'qtyOnHand': 20,
        'reorderLevel': 5,
        'isActive': true,
        'collectable': {
          'type': 'Figure',
        },
      };

      // Act
      final result = ProductModel.fromJson(jsonMap);

      // Assert
      expect(result.sku, 'SKU002');
      expect(result.name, 'Action Figure');
      expect(result.category, 'Collectables');
      expect(result.expiryDate, isNull);
    });

    test('should handle string numbers in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'sku': 'SKU003',
        'name': 'Soda',
        'unitPrice': '8.50',
        'qtyOnHand': '50',
        'reorderLevel': '10',
        'isActive': true,
        'food': {
          'category': 'Beverages',
        },
      };

      // Act
      final result = ProductModel.fromJson(jsonMap);

      // Assert
      expect(result.unitPrice, 8.50);
      expect(result.qtyOnHand, 50);
      expect(result.reorderLevel, 10);
    });

    test('should use default values when data is missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'sku': 'SKU004',
      };

      // Act
      final result = ProductModel.fromJson(jsonMap);

      // Assert
      expect(result.sku, 'SKU004');
      expect(result.name, 'Unknown Product');
      expect(result.unitPrice, 0.0);
      expect(result.category, 'Other');
      expect(result.qtyOnHand, 0);
      expect(result.reorderLevel, 0);
      expect(result.isActive, true);
    });

    test('should handle invalid expiry date gracefully', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'sku': 'SKU005',
        'name': 'Test Product',
        'unitPrice': 10.0,
        'qtyOnHand': 10,
        'reorderLevel': 5,
        'food': {
          'category': 'Snacks',
          'expiryDate': 'invalid-date',
        },
      };

      // Act
      final result = ProductModel.fromJson(jsonMap);

      // Assert
      expect(result.expiryDate, isNull);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tProductModel.toJson();

      // Assert
      expect(result['sku'], 'SKU001');
      expect(result['name'], 'Popcorn');
      expect(result['unitPrice'], 15.0);
      expect(result['category'], 'Snacks');
      expect(result['qtyOnHand'], 100);
      expect(result['reorderLevel'], 20);
      expect(result['barcode'], '1234567890');
      expect(result['isActive'], true);
      expect(result['expiryDate'], isNotNull);
    });

    test('should not include expiryDate when null', () {
      // Arrange
      final productWithoutExpiry = ProductModel(
        sku: 'SKU002',
        name: 'Test',
        unitPrice: 10.0,
        category: 'Test',
        qtyOnHand: 10,
        reorderLevel: 5,
        isActive: true,
      );

      // Act
      final result = productWithoutExpiry.toJson();

      // Assert
      expect(result.containsKey('expiryDate'), false);
    });
  });

  group('toEntity', () {
    test('should convert ProductModel to Product entity', () {
      // Act
      final result = tProductModel.toEntity();

      // Assert
      expect(result, isA<Product>());
      expect(result.sku, 'SKU001');
      expect(result.name, 'Popcorn');
      expect(result.unitPrice, 15.0);
      expect(result.category, 'Snacks');
      expect(result.qtyOnHand, 100);
      expect(result.reorderLevel, 20);
    });
  });
}
