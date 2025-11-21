import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_model.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_item_model.dart';
import 'package:backstage_frontend/features/pos/data/models/payment_model.dart';
import 'package:backstage_frontend/features/pos/domain/entities/sale.dart';

void main() {
  final tSaleModel = SaleModel(
    id: 'SALE001',
    companyId: 'COMP001',
    cashierCpf: '123.456.789-00',
    buyerCpf: '987.654.321-00',
    createdAt: DateTime(2024, 1, 1),
    status: 'OPEN',
    subtotal: 100.0,
    discountAmount: 10.0,
    grandTotal: 90.0,
    items: [],
    payments: [],
    discountCode: 'DISCOUNT10',
  );

  test('should be a subclass of Sale entity', () {
    expect(tSaleModel, isA<Sale>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'buyerCpf': '987.654.321-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': 100.0,
        'discountAmount': 10.0,
        'grandTotal': 90.0,
        'items': [],
        'payments': [],
        'discountCode': 'DISCOUNT10',
      };

      // Act
      final result = SaleModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'SALE001');
      expect(result.companyId, 'COMP001');
      expect(result.cashierCpf, '123.456.789-00');
      expect(result.buyerCpf, '987.654.321-00');
      expect(result.status, 'OPEN');
      expect(result.subtotal, 100.0);
      expect(result.discountAmount, 10.0);
      expect(result.grandTotal, 90.0);
      expect(result.discountCode, 'DISCOUNT10');
    });

    test('should parse items and payments from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': 50.0,
        'discountAmount': 0.0,
        'grandTotal': 50.0,
        'items': [
          {
            'id': 'ITEM001',
            'saleId': 'SALE001',
            'sku': 'SKU001',
            'description': 'Popcorn',
            'quantity': 2,
            'unitPrice': 15.0,
            'totalPrice': 30.0,
            'createdAt': '2024-01-01T00:00:00.000Z',
          },
        ],
        'payments': [
          {
            'id': 'PAY001',
            'saleId': 'SALE001',
            'method': 'CASH',
            'amount': 50.0,
            'createdAt': '2024-01-01T00:00:00.000Z',
          },
        ],
      };

      // Act
      final result = SaleModel.fromJson(jsonMap);

      // Assert
      expect(result.items.length, 1);
      expect(result.items[0], isA<SaleItemModel>());
      expect(result.items[0].sku, 'SKU001');
      expect(result.payments.length, 1);
      expect(result.payments[0], isA<PaymentModel>());
      expect(result.payments[0].amount, 50.0);
    });

    test('should calculate subtotal from items when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'discountAmount': 0.0,
        'grandTotal': 45.0,
        'items': [
          {
            'id': 'ITEM001',
            'saleId': 'SALE001',
            'sku': 'SKU001',
            'description': 'Popcorn',
            'quantity': 2,
            'unitPrice': 15.0,
            'totalPrice': 30.0,
            'createdAt': '2024-01-01T00:00:00.000Z',
          },
          {
            'id': 'ITEM002',
            'saleId': 'SALE001',
            'sku': 'SKU002',
            'description': 'Soda',
            'quantity': 1,
            'unitPrice': 15.0,
            'totalPrice': 15.0,
            'createdAt': '2024-01-01T00:00:00.000Z',
          },
        ],
        'payments': [],
      };

      // Act
      final result = SaleModel.fromJson(jsonMap);

      // Assert
      expect(result.subtotal, 45.0);
    });

    test('should handle string numbers in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': '100.0',
        'discountAmount': '10.0',
        'grandTotal': '90.0',
        'items': [],
        'payments': [],
      };

      // Act
      final result = SaleModel.fromJson(jsonMap);

      // Assert
      expect(result.subtotal, 100.0);
      expect(result.discountAmount, 10.0);
      expect(result.grandTotal, 90.0);
    });

    test('should use default values when data is missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
      };

      // Act
      final result = SaleModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'SALE001');
      expect(result.status, 'OPEN');
      expect(result.subtotal, 0.0);
      expect(result.discountAmount, 0.0);
      expect(result.grandTotal, 0.0);
      expect(result.items, isEmpty);
      expect(result.payments, isEmpty);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tSaleModel.toJson();

      // Assert
      expect(result['id'], 'SALE001');
      expect(result['companyId'], 'COMP001');
      expect(result['cashierCpf'], '123.456.789-00');
      expect(result['buyerCpf'], '987.654.321-00');
      expect(result['status'], 'OPEN');
      expect(result['subtotal'], 100.0);
      expect(result['discountAmount'], 10.0);
      expect(result['grandTotal'], 90.0);
      expect(result['discountCode'], 'DISCOUNT10');
      expect(result['items'], isA<List>());
      expect(result['payments'], isA<List>());
    });

    test('should not include buyerCpf when null', () {
      // Arrange
      final saleWithoutBuyer = SaleModel(
        id: 'SALE002',
        companyId: 'COMP001',
        cashierCpf: '123.456.789-00',
        createdAt: DateTime(2024, 1, 1),
        status: 'OPEN',
        subtotal: 0.0,
        discountAmount: 0.0,
        grandTotal: 0.0,
        items: [],
        payments: [],
      );

      // Act
      final result = saleWithoutBuyer.toJson();

      // Assert
      expect(result.containsKey('buyerCpf'), false);
    });

    test('should not include discountCode when null', () {
      // Arrange
      final saleWithoutDiscount = SaleModel(
        id: 'SALE003',
        companyId: 'COMP001',
        cashierCpf: '123.456.789-00',
        createdAt: DateTime(2024, 1, 1),
        status: 'OPEN',
        subtotal: 100.0,
        discountAmount: 0.0,
        grandTotal: 100.0,
        items: [],
        payments: [],
      );

      // Act
      final result = saleWithoutDiscount.toJson();

      // Assert
      expect(result.containsKey('discountCode'), false);
    });
  });

  group('toEntity', () {
    test('should convert SaleModel to Sale entity', () {
      // Act
      final result = tSaleModel.toEntity();

      // Assert
      expect(result, isA<Sale>());
      expect(result.id, 'SALE001');
      expect(result.companyId, 'COMP001');
      expect(result.cashierCpf, '123.456.789-00');
      expect(result.buyerCpf, '987.654.321-00');
      expect(result.status, 'OPEN');
      expect(result.subtotal, 100.0);
      expect(result.discountAmount, 10.0);
      expect(result.grandTotal, 90.0);
    });
  });
}
