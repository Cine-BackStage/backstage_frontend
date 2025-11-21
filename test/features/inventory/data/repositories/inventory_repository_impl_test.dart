import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:backstage_frontend/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:backstage_frontend/features/inventory/data/repositories/inventory_repository_impl.dart';
import 'package:backstage_frontend/features/inventory/domain/entities/stock_adjustment.dart';
import 'package:backstage_frontend/features/pos/data/models/product_model.dart';

class MockInventoryRemoteDataSource extends Mock implements InventoryRemoteDataSource {}

void main() {
  late InventoryRepositoryImpl repository;
  late MockInventoryRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockInventoryRemoteDataSource();
    repository = InventoryRepositoryImpl(mockRemoteDataSource);
  });

  const tProductModel1 = ProductModel(
    sku: 'SKU001',
    name: 'Popcorn',
    unitPrice: 15.0,
    category: 'Snacks',
    qtyOnHand: 100,
    reorderLevel: 20,
    barcode: '1234567890',
    isActive: true,
  );

  const tProductModel2 = ProductModel(
    sku: 'SKU002',
    name: 'Soda',
    unitPrice: 8.0,
    category: 'Beverages',
    qtyOnHand: 50,
    reorderLevel: 10,
    isActive: true,
  );

  const tProducts = [tProductModel1, tProductModel2];

  final tAdjustmentModel = StockAdjustmentModel(
    id: 'adj-1',
    sku: 'SKU001',
    productName: 'Popcorn',
    type: AdjustmentType.addition,
    quantityBefore: 100,
    quantityAfter: 110,
    quantityChanged: 10,
    reason: 'Restock',
    notes: 'New shipment',
    employeeName: 'John Doe',
    timestamp: DateTime(2024, 1, 1, 10, 0),
  );

  group('getInventory', () {
    test('should return list of Products when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getInventory())
          .thenAnswer((_) async => tProducts);

      // Act
      final result = await repository.getInventory();

      // Assert
      verify(() => mockRemoteDataSource.getInventory()).called(1);
      expect(result, equals(const Right(tProducts)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Failed to fetch inventory',
        statusCode: 500,
      );
      when(() => mockRemoteDataSource.getInventory()).thenThrow(tException);

      // Act
      final result = await repository.getInventory();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getInventory())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getInventory();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getProductDetails', () {
    const tSku = 'SKU001';

    test('should return Product when remote datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getProductDetails(any()))
          .thenAnswer((_) async => tProductModel1);

      // Act
      final result = await repository.getProductDetails(tSku);

      // Assert
      verify(() => mockRemoteDataSource.getProductDetails(tSku)).called(1);
      expect(result, equals(const Right(tProductModel1)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Product not found',
        statusCode: 404,
      );
      when(() => mockRemoteDataSource.getProductDetails(any()))
          .thenThrow(tException);

      // Act
      final result = await repository.getProductDetails(tSku);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('searchProducts', () {
    const tQuery = 'Popcorn';

    test('should return list of Products when search succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchProducts(any()))
          .thenAnswer((_) async => [tProductModel1]);

      // Act
      final result = await repository.searchProducts(tQuery);

      // Assert
      verify(() => mockRemoteDataSource.searchProducts(tQuery)).called(1);
      expect(result, isA<Right>());
      final products = (result as Right).value as List;
      expect(products.length, equals(1));
      expect(products[0], equals(tProductModel1));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Search failed');
      when(() => mockRemoteDataSource.searchProducts(any()))
          .thenThrow(tException);

      // Act
      final result = await repository.searchProducts(tQuery);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getLowStockProducts', () {
    test('should return list of low stock Products when datasource succeeds', () async {
      // Arrange
      const tLowStockProduct = ProductModel(
        sku: 'SKU003',
        name: 'Candy',
        unitPrice: 5.0,
        category: 'Snacks',
        qtyOnHand: 5,
        reorderLevel: 20,
        isActive: true,
      );
      when(() => mockRemoteDataSource.getLowStockProducts())
          .thenAnswer((_) async => [tLowStockProduct]);

      // Act
      final result = await repository.getLowStockProducts();

      // Assert
      verify(() => mockRemoteDataSource.getLowStockProducts()).called(1);
      expect(result, isA<Right>());
      final products = (result as Right).value as List;
      expect(products.length, equals(1));
      expect(products[0], equals(tLowStockProduct));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Failed to fetch low stock');
      when(() => mockRemoteDataSource.getLowStockProducts())
          .thenThrow(tException);

      // Act
      final result = await repository.getLowStockProducts();

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('adjustStock', () {
    const tSku = 'SKU001';
    const tQuantity = 10;
    const tReason = 'Reestoque';
    const tNotes = 'New shipment';

    test('should return success when datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.adjustStock(
            sku: any(named: 'sku'),
            quantity: any(named: 'quantity'),
            reason: any(named: 'reason'),
            notes: any(named: 'notes'),
          )).thenAnswer((_) async => {});

      // Act
      final result = await repository.adjustStock(
        sku: tSku,
        quantity: tQuantity,
        reason: tReason,
        notes: tNotes,
      );

      // Assert
      verify(() => mockRemoteDataSource.adjustStock(
            sku: tSku,
            quantity: tQuantity,
            reason: tReason,
            notes: tNotes,
          )).called(1);
      expect(result, equals(const Right(null)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Adjustment failed',
        statusCode: 400,
      );
      when(() => mockRemoteDataSource.adjustStock(
            sku: any(named: 'sku'),
            quantity: any(named: 'quantity'),
            reason: any(named: 'reason'),
            notes: any(named: 'notes'),
          )).thenThrow(tException);

      // Act
      final result = await repository.adjustStock(
        sku: tSku,
        quantity: tQuantity,
        reason: tReason,
        notes: tNotes,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('getAdjustmentHistory', () {
    const tSku = 'SKU001';
    const tLimit = 20;

    test('should return list of StockAdjustments when datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.getAdjustmentHistory(
            sku: any(named: 'sku'),
            limit: any(named: 'limit'),
          )).thenAnswer((_) async => [tAdjustmentModel]);

      // Act
      final result = await repository.getAdjustmentHistory(
        sku: tSku,
        limit: tLimit,
      );

      // Assert
      verify(() => mockRemoteDataSource.getAdjustmentHistory(
            sku: tSku,
            limit: tLimit,
          )).called(1);
      expect(result, isA<Right>());
      final adjustments = (result as Right).value as List;
      expect(adjustments.length, equals(1));
      expect(adjustments[0], equals(tAdjustmentModel));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Failed to fetch history');
      when(() => mockRemoteDataSource.getAdjustmentHistory(
            sku: any(named: 'sku'),
            limit: any(named: 'limit'),
          )).thenThrow(tException);

      // Act
      final result = await repository.getAdjustmentHistory(
        sku: tSku,
        limit: tLimit,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('createProduct', () {
    const tSku = 'SKU001';
    const tName = 'Popcorn';
    const tUnitPrice = 15.0;
    const tCategory = 'Snacks';
    const tInitialStock = 100;
    const tBarcode = '1234567890';

    test('should return Product when datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.createProduct(
            sku: any(named: 'sku'),
            name: any(named: 'name'),
            unitPrice: any(named: 'unitPrice'),
            category: any(named: 'category'),
            initialStock: any(named: 'initialStock'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((_) async => tProductModel1);

      // Act
      final result = await repository.createProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: tCategory,
        initialStock: tInitialStock,
        barcode: tBarcode,
      );

      // Assert
      verify(() => mockRemoteDataSource.createProduct(
            sku: tSku,
            name: tName,
            unitPrice: tUnitPrice,
            category: tCategory,
            initialStock: tInitialStock,
            barcode: tBarcode,
          )).called(1);
      expect(result, equals(const Right(tProductModel1)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Product already exists',
        statusCode: 400,
      );
      when(() => mockRemoteDataSource.createProduct(
            sku: any(named: 'sku'),
            name: any(named: 'name'),
            unitPrice: any(named: 'unitPrice'),
            category: any(named: 'category'),
            initialStock: any(named: 'initialStock'),
            barcode: any(named: 'barcode'),
          )).thenThrow(tException);

      // Act
      final result = await repository.createProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: tCategory,
        initialStock: tInitialStock,
        barcode: tBarcode,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('updateProduct', () {
    const tSku = 'SKU001';
    const tName = 'Updated Popcorn';
    const tUnitPrice = 18.0;

    test('should return Product when datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateProduct(
            sku: any(named: 'sku'),
            name: any(named: 'name'),
            unitPrice: any(named: 'unitPrice'),
            category: any(named: 'category'),
            barcode: any(named: 'barcode'),
          )).thenAnswer((_) async => tProductModel1);

      // Act
      final result = await repository.updateProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateProduct(
            sku: tSku,
            name: tName,
            unitPrice: tUnitPrice,
            category: null,
            barcode: null,
          )).called(1);
      expect(result, equals(const Right(tProductModel1)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(message: 'Update failed');
      when(() => mockRemoteDataSource.updateProduct(
            sku: any(named: 'sku'),
            name: any(named: 'name'),
            unitPrice: any(named: 'unitPrice'),
            category: any(named: 'category'),
            barcode: any(named: 'barcode'),
          )).thenThrow(tException);

      // Act
      final result = await repository.updateProduct(
        sku: tSku,
        name: tName,
      );

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });

  group('toggleProductStatus', () {
    const tSku = 'SKU001';
    const tIsActive = false;

    test('should return success when datasource succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.toggleProductStatus(any(), any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.toggleProductStatus(tSku, tIsActive);

      // Assert
      verify(() => mockRemoteDataSource.toggleProductStatus(tSku, tIsActive))
          .called(1);
      expect(result, equals(const Right(null)));
    });

    test('should return GenericFailure when AppException occurs', () async {
      // Arrange
      final tException = AppException(
        message: 'Toggle failed',
        statusCode: 400,
      );
      when(() => mockRemoteDataSource.toggleProductStatus(any(), any()))
          .thenThrow(tException);

      // Act
      final result = await repository.toggleProductStatus(tSku, tIsActive);

      // Assert
      expect(result, isA<Left>());
      expect((result as Left).value, isA<GenericFailure>());
    });
  });
}
