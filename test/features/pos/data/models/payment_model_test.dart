import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/pos/data/models/payment_model.dart';
import 'package:backstage_frontend/features/pos/domain/entities/payment.dart';

void main() {
  final tPaymentModel = PaymentModel(
    id: 'PAY001',
    saleId: 'SALE001',
    method: PaymentMethod.cash,
    amount: 50.0,
    authCode: null,
    createdAt: DateTime(2024, 1, 1),
  );

  test('should be a subclass of Payment entity', () {
    expect(tPaymentModel, isA<Payment>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON for cash payment', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY001',
        'saleId': 'SALE001',
        'method': 'CASH',
        'amount': 50.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'PAY001');
      expect(result.saleId, 'SALE001');
      expect(result.method, PaymentMethod.cash);
      expect(result.amount, 50.0);
      expect(result.authCode, isNull);
    });

    test('should return a valid model from JSON for card payment', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY002',
        'saleId': 'SALE001',
        'method': 'CARD',
        'amount': 100.0,
        'authCode': 'AUTH123456',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'PAY002');
      expect(result.method, PaymentMethod.card);
      expect(result.amount, 100.0);
      expect(result.authCode, 'AUTH123456');
    });

    test('should return a valid model from JSON for other payment', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY003',
        'saleId': 'SALE001',
        'method': 'OTHER',
        'amount': 75.0,
        'authCode': 'AUTH789012',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.method, PaymentMethod.other);
      expect(result.authCode, 'AUTH789012');
    });

    test('should return a valid model from JSON for pix payment', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY004',
        'saleId': 'SALE001',
        'method': 'PIX',
        'amount': 60.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.method, PaymentMethod.pix);
    });

    test('should handle string numbers in JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY005',
        'saleId': 'SALE001',
        'method': 'CASH',
        'amount': '45.50',
        'createdAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.amount, 45.50);
    });

    test('should use default values when data is missing', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'PAY006',
        'saleId': 'SALE001',
      };

      // Act
      final result = PaymentModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'PAY006');
      expect(result.saleId, 'SALE001');
      expect(result.method, PaymentMethod.cash);
      expect(result.amount, 0.0);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data for cash payment', () {
      // Act
      final result = tPaymentModel.toJson();

      // Assert
      expect(result['id'], 'PAY001');
      expect(result['saleId'], 'SALE001');
      expect(result['method'], 'CASH');
      expect(result['amount'], 50.0);
      expect(result['createdAt'], isNotNull);
    });

    test('should include authCode when present', () {
      // Arrange
      final cardPayment = PaymentModel(
        id: 'PAY002',
        saleId: 'SALE001',
        method: PaymentMethod.card,
        amount: 100.0,
        authCode: 'AUTH123456',
        createdAt: DateTime(2024, 1, 1),
      );

      // Act
      final result = cardPayment.toJson();

      // Assert
      expect(result['authCode'], 'AUTH123456');
    });

    test('should not include authCode when null', () {
      // Act
      final result = tPaymentModel.toJson();

      // Assert
      expect(result.containsKey('authCode'), false);
    });

    test('should correctly serialize all payment methods', () {
      // Test cash
      var payment = PaymentModel(
        id: 'PAY1',
        saleId: 'SALE001',
        method: PaymentMethod.cash,
        amount: 10.0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(payment.toJson()['method'], 'CASH');

      // Test card
      payment = PaymentModel(
        id: 'PAY2',
        saleId: 'SALE001',
        method: PaymentMethod.card,
        amount: 10.0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(payment.toJson()['method'], 'CARD');

      // Test pix
      payment = PaymentModel(
        id: 'PAY3',
        saleId: 'SALE001',
        method: PaymentMethod.pix,
        amount: 10.0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(payment.toJson()['method'], 'PIX');

      // Test other
      payment = PaymentModel(
        id: 'PAY4',
        saleId: 'SALE001',
        method: PaymentMethod.other,
        amount: 10.0,
        createdAt: DateTime(2024, 1, 1),
      );
      expect(payment.toJson()['method'], 'OTHER');
    });
  });

  group('toEntity', () {
    test('should convert PaymentModel to Payment entity', () {
      // Act
      final result = tPaymentModel.toEntity();

      // Assert
      expect(result, isA<Payment>());
      expect(result.id, 'PAY001');
      expect(result.saleId, 'SALE001');
      expect(result.method, PaymentMethod.cash);
      expect(result.amount, 50.0);
      expect(result.authCode, isNull);
    });
  });
}
