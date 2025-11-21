import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_item_model.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale_item.dart';

void main() {
  final tSaleItemModel = SaleItemModel(
    id: 'ITEM001',
    saleId: 'SALE001',
    sku: 'SKU001',
    description: 'Popcorn',
    quantity: 2,
    unitPrice: 15.0,
    totalPrice: 30.0,
    createdAt: DateTime(2024, 1, 1),
  );

  test('should be a subclass of SaleItem entity', () {
    expect(tSaleItemModel, isA<SaleItem>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with product data', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'ITEM001',
        'saleId': 'SALE001',
        'sku': 'SKU001',
        'description': 'Popcorn',
        'quantity': 2,
        'unitPrice': 15.0,
        'totalPrice': 30.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = SaleItemModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'ITEM001');
      expect(result.saleId, 'SALE001');
      expect(result.sku, 'SKU001');
      expect(result.description, 'Popcorn');
      expect(result.quantity, 2);
      expect(result.unitPrice, 15.0);
      expect(result.totalPrice, 30.0);
    });

    test('should return a valid model from JSON with ticket data', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'ITEM002',
        'saleId': 'SALE001',
        'sessionId': 'SESSION001',
        'seatId': 'SEAT001',
        'description': 'Movie Ticket',
        'quantity': 1,
        'unitPrice': 25.0,
        'totalPrice': 25.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = SaleItemModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'ITEM002');
      expect(result.sessionId, 'SESSION001');
      expect(result.seatId, 'SEAT001');
      expect(result.description, 'Movie Ticket');
      expect(result.sku, isNull);
    });

    test('should calculate totalPrice when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'ITEM003',
        'saleId': 'SALE001',
        'sku': 'SKU002',
        'description': 'Soda',
        'quantity': 3,
        'unitPrice': 8.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = SaleItemModel.fromJson(jsonMap);

      // Assert
      expect(result.totalPrice, 24.0);
    });

    test('should handle string numbers in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'ITEM004',
        'saleId': 'SALE001',
        'sku': 'SKU003',
        'description': 'Candy',
        'quantity': '5',
        'unitPrice': '2.50',
        'totalPrice': '12.50',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = SaleItemModel.fromJson(jsonMap);

      // Assert
      expect(result.quantity, 5);
      expect(result.unitPrice, 2.50);
      expect(result.totalPrice, 12.50);
    });

    test('should use default values when data is missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'ITEM005',
        'saleId': 'SALE001',
        'description': 'Test Item',
      };

      // Act
      final result = SaleItemModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'ITEM005');
      expect(result.saleId, 'SALE001');
      expect(result.description, 'Test Item');
      expect(result.quantity, 1);
      expect(result.unitPrice, 0.0);
      expect(result.totalPrice, 0.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSaleItemModel.toJson();

      // Assert
      expect(result['id'], 'ITEM001');
      expect(result['saleId'], 'SALE001');
      expect(result['sku'], 'SKU001');
      expect(result['description'], 'Popcorn');
      expect(result['quantity'], 2);
      expect(result['unitPrice'], 15.0);
      expect(result['totalPrice'], 30.0);
      expect(result['createdAt'], isNotNull);
    });

    test('should not include sku when null', () {
      // Arrange
      final ticketItem = SaleItemModel(
        id: 'ITEM002',
        saleId: 'SALE001',
        sessionId: 'SESSION001',
        seatId: 'SEAT001',
        description: 'Movie Ticket',
        quantity: 1,
        unitPrice: 25.0,
        totalPrice: 25.0,
        createdAt: DateTime(2024, 1, 1),
      );

      // Act
      final result = ticketItem.toJson();

      // Assert
      expect(result.containsKey('sku'), false);
      expect(result['sessionId'], 'SESSION001');
      expect(result['seatId'], 'SEAT001');
    });

    test('should not include sessionId and seatId when null', () {
      // Act
      final result = tSaleItemModel.toJson();

      // Assert
      expect(result.containsKey('sessionId'), false);
      expect(result.containsKey('seatId'), false);
    });
  });

  group('toEntity', () {
    test('should convert SaleItemModel to SaleItem entity', () {
      // Act
      final result = tSaleItemModel.toEntity();

      // Assert
      expect(result, isA<SaleItem>());
      expect(result.id, 'ITEM001');
      expect(result.saleId, 'SALE001');
      expect(result.sku, 'SKU001');
      expect(result.description, 'Popcorn');
      expect(result.quantity, 2);
      expect(result.unitPrice, 15.0);
      expect(result.totalPrice, 30.0);
    });
  });
}
