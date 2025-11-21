import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:backstage_frontend/features/pos/data/models/product_model.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_model.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_item_model.dart';
import 'package:backstage_frontend/features/pos/data/models/payment_model.dart';
import 'package:backstage_frontend/features/pos/data/repositories/pos_repository_impl.dart';
import 'package:backstage_frontend/features/pos/domain/entities/payment.dart';

class MockPosRemoteDataSource extends Mock implements PosRemoteDataSource {}

void main() {
  late PosRepositoryImpl repository;
  late MockPosRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(PaymentMethod.cash);
  });

  setUp(() {
    mockRemoteDataSource = MockPosRemoteDataSource();
    repository = PosRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('getProducts', () {
    final tProductModels = [
      ProductModel(
        sku: 'SKU001',
        name: 'Popcorn',
        unitPrice: 15.0,
        category: 'Snacks',
        qtyOnHand: 100,
        reorderLevel: 20,
        isActive: true,
      ),
      ProductModel(
        sku: 'SKU002',
        name: 'Soda',
        unitPrice: 8.0,
        category: 'Beverages',
        qtyOnHand: 50,
        reorderLevel: 10,
        isActive: true,
      ),
    ];

    test('should return list of products when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getProducts())
          .thenAnswer((_) async => tProductModels);

      // Act
      final result = await repository.getProducts();

      // Assert
      verify(() => mockRemoteDataSource.getProducts()).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (products) {
          expect(products.length, 2);
          expect(products[0].sku, 'SKU001');
          expect(products[1].sku, 'SKU002');
        },
      );
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to get products',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getProducts()).thenThrow(tException);

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Failed to get products',
          statusCode: 500,
        ))),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getProducts())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getProducts();

      // Assert
      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (products) => fail('Should not return products'),
      );
    });
  });

  group('createSale', () {
    final tSaleModel = SaleModel(
      id: 'SALE001',
      companyId: 'COMP001',
      cashierCpf: '123.456.789-00',
      buyerCpf: '987.654.321-00',
      createdAt: DateTime(2024, 1, 1),
      status: 'OPEN',
      subtotal: 0.0,
      discountAmount: 0.0,
      grandTotal: 0.0,
      items: [],
      payments: [],
    );

    test('should return Sale when creation is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.createSale(buyerCpf: any(named: 'buyerCpf')))
          .thenAnswer((_) async => tSaleModel);

      // Act
      final result = await repository.createSale(buyerCpf: '987.654.321-00');

      // Assert
      verify(() => mockRemoteDataSource.createSale(buyerCpf: '987.654.321-00'))
          .called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sale) {
          expect(sale.id, 'SALE001');
          expect(sale.buyerCpf, '987.654.321-00');
        },
      );
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to create sale',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.createSale(buyerCpf: any(named: 'buyerCpf')))
          .thenThrow(tException);

      // Act
      final result = await repository.createSale(buyerCpf: '987.654.321-00');

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Failed to create sale',
          statusCode: 500,
        ))),
      );
    });
  });

  group('getSaleById', () {
    final tSaleModel = SaleModel(
      id: 'SALE001',
      companyId: 'COMP001',
      cashierCpf: '123.456.789-00',
      createdAt: DateTime(2024, 1, 1),
      status: 'OPEN',
      subtotal: 50.0,
      discountAmount: 0.0,
      grandTotal: 50.0,
      items: [],
      payments: [],
    );

    test('should return Sale when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getSaleById(any()))
          .thenAnswer((_) async => tSaleModel);

      // Act
      final result = await repository.getSaleById('SALE001');

      // Assert
      verify(() => mockRemoteDataSource.getSaleById('SALE001')).called(1);
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sale) {
          expect(sale.id, 'SALE001');
          expect(sale.status, 'OPEN');
          expect(sale.grandTotal, 50.0);
        },
      );
    });

    test('should return GenericFailure when sale not found', () async {
      // Arrange
      final tException = AppException(
        message: 'Sale not found',
        statusCode: 404,
      );
      when(() => mockRemoteDataSource.getSaleById(any())).thenThrow(tException);

      // Act
      final result = await repository.getSaleById('INVALID');

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Sale not found',
          statusCode: 404,
        ))),
      );
    });
  });

  group('addItemToSale', () {
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

    test('should return SaleItem when addition is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.addItemToSale(
            saleId: any(named: 'saleId'),
            sku: any(named: 'sku'),
            sessionId: any(named: 'sessionId'),
            seatId: any(named: 'seatId'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            unitPrice: any(named: 'unitPrice'),
          )).thenAnswer((_) async => tSaleItemModel);

      // Act
      final result = await repository.addItemToSale(
        saleId: 'SALE001',
        sku: 'SKU001',
        description: 'Popcorn',
        quantity: 2,
        unitPrice: 15.0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (item) {
          expect(item.id, 'ITEM001');
          expect(item.sku, 'SKU001');
        },
      );
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to add item',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.addItemToSale(
            saleId: any(named: 'saleId'),
            sku: any(named: 'sku'),
            sessionId: any(named: 'sessionId'),
            seatId: any(named: 'seatId'),
            description: any(named: 'description'),
            quantity: any(named: 'quantity'),
            unitPrice: any(named: 'unitPrice'),
          )).thenThrow(tException);

      // Act
      final result = await repository.addItemToSale(
        saleId: 'SALE001',
        sku: 'SKU001',
        description: 'Popcorn',
        quantity: 2,
        unitPrice: 15.0,
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(
          message: 'Failed to add item',
          statusCode: 500,
        ))),
      );
    });
  });

  group('removeItemFromSale', () {
    test('should return Right(null) when removal is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.removeItemFromSale(
            saleId: any(named: 'saleId'),
            itemId: any(named: 'itemId'),
          )).thenAnswer((_) async => {});

      // Act
      final result = await repository.removeItemFromSale(
        saleId: 'SALE001',
        itemId: 'ITEM001',
      );

      // Assert
      expect(result, const Right(null));
    });

    test('should return GenericFailure when removal fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to remove item');
      when(() => mockRemoteDataSource.removeItemFromSale(
            saleId: any(named: 'saleId'),
            itemId: any(named: 'itemId'),
          )).thenThrow(tException);

      // Act
      final result = await repository.removeItemFromSale(
        saleId: 'SALE001',
        itemId: 'ITEM001',
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to remove item'))),
      );
    });
  });

  group('validateDiscount', () {
    final tDiscountData = {
      'code': 'DISCOUNT10',
      'discountAmount': 10.0,
      'type': 'PERCENTAGE',
      'value': 10.0,
    };

    test('should return discount data when validation is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.validateDiscount(
            code: any(named: 'code'),
            subtotal: any(named: 'subtotal'),
          )).thenAnswer((_) async => tDiscountData);

      // Act
      final result = await repository.validateDiscount(
        code: 'DISCOUNT10',
        subtotal: 100.0,
      );

      // Assert
      expect(result, Right(tDiscountData));
    });

    test('should return GenericFailure when discount is invalid', () async {
      // Arrange
      final tException = AppException(message: 'Invalid discount code');
      when(() => mockRemoteDataSource.validateDiscount(
            code: any(named: 'code'),
            subtotal: any(named: 'subtotal'),
          )).thenThrow(tException);

      // Act
      final result = await repository.validateDiscount(
        code: 'INVALID',
        subtotal: 100.0,
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Invalid discount code'))),
      );
    });
  });

  group('applyDiscount', () {
    final tSaleModel = SaleModel(
      id: 'SALE001',
      companyId: 'COMP001',
      cashierCpf: '123.456.789-00',
      createdAt: DateTime(2024, 1, 1),
      status: 'OPEN',
      subtotal: 100.0,
      discountAmount: 10.0,
      grandTotal: 90.0,
      discountCode: 'DISCOUNT10',
      items: [],
      payments: [],
    );

    test('should return updated Sale when discount is applied', () async {
      // Arrange
      when(() => mockRemoteDataSource.applyDiscount(
            saleId: any(named: 'saleId'),
            code: any(named: 'code'),
          )).thenAnswer((_) async => tSaleModel);

      // Act
      final result = await repository.applyDiscount(
        saleId: 'SALE001',
        code: 'DISCOUNT10',
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sale) {
          expect(sale.discountAmount, 10.0);
          expect(sale.grandTotal, 90.0);
        },
      );
    });

    test('should return GenericFailure when applying discount fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to apply discount');
      when(() => mockRemoteDataSource.applyDiscount(
            saleId: any(named: 'saleId'),
            code: any(named: 'code'),
          )).thenThrow(tException);

      // Act
      final result = await repository.applyDiscount(
        saleId: 'SALE001',
        code: 'DISCOUNT10',
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to apply discount'))),
      );
    });
  });

  group('addPayment', () {
    final tPaymentModel = PaymentModel(
      id: 'PAY001',
      saleId: 'SALE001',
      method: PaymentMethod.cash,
      amount: 50.0,
      createdAt: DateTime(2024, 1, 1),
    );

    test('should return Payment when addition is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.addPayment(
            saleId: any(named: 'saleId'),
            method: any(named: 'method'),
            amount: any(named: 'amount'),
            authCode: any(named: 'authCode'),
          )).thenAnswer((_) async => tPaymentModel);

      // Act
      final result = await repository.addPayment(
        saleId: 'SALE001',
        method: PaymentMethod.cash,
        amount: 50.0,
      );

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (payment) {
          expect(payment.id, 'PAY001');
          expect(payment.amount, 50.0);
        },
      );
    });

    test('should return GenericFailure when addition fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to add payment');
      when(() => mockRemoteDataSource.addPayment(
            saleId: any(named: 'saleId'),
            method: any(named: 'method'),
            amount: any(named: 'amount'),
            authCode: any(named: 'authCode'),
          )).thenThrow(tException);

      // Act
      final result = await repository.addPayment(
        saleId: 'SALE001',
        method: PaymentMethod.cash,
        amount: 50.0,
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to add payment'))),
      );
    });
  });

  group('removePayment', () {
    test('should return Right(null) when removal is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.removePayment(
            saleId: any(named: 'saleId'),
            paymentId: any(named: 'paymentId'),
          )).thenAnswer((_) async => {});

      // Act
      final result = await repository.removePayment(
        saleId: 'SALE001',
        paymentId: 'PAY001',
      );

      // Assert
      expect(result, const Right(null));
    });

    test('should return GenericFailure when removal fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to remove payment');
      when(() => mockRemoteDataSource.removePayment(
            saleId: any(named: 'saleId'),
            paymentId: any(named: 'paymentId'),
          )).thenThrow(tException);

      // Act
      final result = await repository.removePayment(
        saleId: 'SALE001',
        paymentId: 'PAY001',
      );

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to remove payment'))),
      );
    });
  });

  group('finalizeSale', () {
    final tSaleModel = SaleModel(
      id: 'SALE001',
      companyId: 'COMP001',
      cashierCpf: '123.456.789-00',
      createdAt: DateTime(2024, 1, 1),
      status: 'FINALIZED',
      subtotal: 100.0,
      discountAmount: 0.0,
      grandTotal: 100.0,
      items: [],
      payments: [],
    );

    test('should return finalized Sale when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.finalizeSale(any()))
          .thenAnswer((_) async => tSaleModel);

      // Act
      final result = await repository.finalizeSale('SALE001');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sale) => expect(sale.status, 'FINALIZED'),
      );
    });

    test('should return GenericFailure when finalization fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to finalize sale');
      when(() => mockRemoteDataSource.finalizeSale(any())).thenThrow(tException);

      // Act
      final result = await repository.finalizeSale('SALE001');

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to finalize sale'))),
      );
    });
  });

  group('cancelSale', () {
    final tSaleModel = SaleModel(
      id: 'SALE001',
      companyId: 'COMP001',
      cashierCpf: '123.456.789-00',
      createdAt: DateTime(2024, 1, 1),
      status: 'CANCELED',
      subtotal: 100.0,
      discountAmount: 0.0,
      grandTotal: 100.0,
      items: [],
      payments: [],
    );

    test('should return canceled Sale when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelSale(any()))
          .thenAnswer((_) async => tSaleModel);

      // Act
      final result = await repository.cancelSale('SALE001');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Should not return failure'),
        (sale) => expect(sale.status, 'CANCELED'),
      );
    });

    test('should return GenericFailure when cancellation fails', () async {
      // Arrange
      final tException = AppException(message: 'Failed to cancel sale');
      when(() => mockRemoteDataSource.cancelSale(any())).thenThrow(tException);

      // Act
      final result = await repository.cancelSale('SALE001');

      // Assert
      expect(
        result,
        equals(const Left(GenericFailure(message: 'Failed to cancel sale'))),
      );
    });
  });
}
