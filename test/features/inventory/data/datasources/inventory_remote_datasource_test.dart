import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/features/inventory/data/datasources/inventory_remote_datasource.dart';
import 'package:backstage_frontend/features/inventory/data/models/stock_adjustment_model.dart';
import 'package:backstage_frontend/features/pos/data/models/product_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late InventoryRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = InventoryRemoteDataSourceImpl(mockHttpClient);
  });

  final tProductData = {
    'sku': 'SKU001',
    'name': 'Popcorn',
    'unitPrice': 15.0,
    'qtyOnHand': 100,
    'reorderLevel': 20,
    'isActive': true,
    'barcode': '1234567890',
    'food': {
      'category': 'Snacks',
    },
  };

  final tStockAdjustmentData = {
    'id': 'adj-1',
    'sku': 'SKU001',
    'productName': 'Popcorn',
    'adjustmentType': 'ADDITION',
    'qtyBefore': 100,
    'qtyAfter': 110,
    'qtyChanged': 10,
    'reason': 'Restock',
    'notes': 'New shipment',
    'employeeName': 'John Doe',
    'timestamp': '2024-01-01T10:00:00.000',
  };

  group('getInventory', () {
    test('should return list of ProductModel when successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tProductData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getInventory();

      // Assert
      expect(result, isA<List<ProductModel>>());
      expect(result.length, equals(1));
      expect(result[0].sku, equals('SKU001'));
      expect(result[0].name, equals('Popcorn'));
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch inventory',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getInventory(),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when an error occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.getInventory(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getProductDetails', () {
    const tSku = 'SKU001';

    test('should return ProductModel when successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getProductDetails(tSku);

      // Assert
      expect(result, isA<ProductModel>());
      expect(result.sku, equals('SKU001'));
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Product not found',
                },
                statusCode: 404,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getProductDetails(tSku),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('searchProducts', () {
    const tQuery = 'Popcorn';

    test('should return list of ProductModel when search is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tProductData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.searchProducts(tQuery);

      // Assert
      expect(result, isA<List<ProductModel>>());
      expect(result.length, equals(1));
    });

    test('should throw AppException when search fails', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Search failed',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.searchProducts(tQuery),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getLowStockProducts', () {
    final tLowStockProductData = {
      'sku': 'SKU002',
      'name': 'Soda',
      'unitPrice': 8.0,
      'qtyOnHand': 5,
      'reorderLevel': 10,
      'isActive': true,
      'food': {
        'category': 'Beverages',
      },
    };

    test('should return list of low stock ProductModel when successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tLowStockProductData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getLowStockProducts();

      // Assert
      expect(result, isA<List<ProductModel>>());
      expect(result.length, equals(1));
      expect(result[0].qtyOnHand, lessThanOrEqualTo(result[0].reorderLevel));
    });

    test('should filter out products with quantity > reorderLevel', () async {
      // Arrange
      final mixedStockData = [
        tLowStockProductData, // qty 5, reorder 10
        tProductData, // qty 100, reorder 20
      ];
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': mixedStockData,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getLowStockProducts();

      // Assert
      expect(result.length, equals(1));
      expect(result[0].sku, equals('SKU002'));
    });

    test('should throw AppException when request fails', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch low stock products',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getLowStockProducts(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('adjustStock', () {
    const tSku = 'SKU001';
    const tQuantity = 10;
    const tReason = 'Reestoque';
    const tNotes = 'New shipment';

    test('should complete successfully when adjustment succeeds', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.adjustStock(
          sku: tSku,
          quantity: tQuantity,
          reason: tReason,
          notes: tNotes,
        ),
        returnsNormally,
      );
    });

    test('should map frontend reason to backend enum', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.adjustStock(
        sku: tSku,
        quantity: tQuantity,
        reason: 'Reestoque',
        notes: tNotes,
      );

      // Assert
      verify(() => mockHttpClient.post(
            any(),
            data: {
              'delta': tQuantity,
              'reason': 'RESTOCK',
              'notes': tNotes,
            },
          )).called(1);
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Adjustment failed',
                },
                statusCode: 400,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.adjustStock(
          sku: tSku,
          quantity: tQuantity,
          reason: tReason,
          notes: tNotes,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException on DioException', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              data: {'message': 'Server error'},
            ),
          ));

      // Act & Assert
      expect(
        () => dataSource.adjustStock(
          sku: tSku,
          quantity: tQuantity,
          reason: tReason,
          notes: tNotes,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getAdjustmentHistory', () {
    const tSku = 'SKU001';
    const tLimit = 20;

    test('should return list of StockAdjustmentModel when successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [tStockAdjustmentData],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getAdjustmentHistory(
        sku: tSku,
        limit: tLimit,
      );

      // Assert
      expect(result, isA<List<StockAdjustmentModel>>());
      expect(result.length, equals(1));
      expect(result[0].id, equals('adj-1'));
    });

    test('should include sku in query parameters when provided', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getAdjustmentHistory(sku: tSku, limit: tLimit);

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {'limit': tLimit, 'sku': tSku},
          )).called(1);
    });

    test('should not include sku in query parameters when null', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': [],
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getAdjustmentHistory(limit: tLimit);

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {'limit': tLimit},
          )).called(1);
    });

    test('should throw AppException when request fails', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch history',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getAdjustmentHistory(sku: tSku, limit: tLimit),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('createProduct', () {
    const tSku = 'SKU001';
    const tName = 'Popcorn';
    const tUnitPrice = 15.0;
    const tCategory = 'Snacks';
    const tInitialStock = 100;
    const tBarcode = '1234567890';

    test('should return ProductModel when creation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: tCategory,
        initialStock: tInitialStock,
        barcode: tBarcode,
      );

      // Assert
      expect(result, isA<ProductModel>());
      expect(result.sku, equals('SKU001'));
    });

    test('should send correct data for food item', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
        category: 'Snacks',
        initialStock: tInitialStock,
        barcode: tBarcode,
      );

      // Assert
      verify(() => mockHttpClient.post(
            any(),
            data: {
              'sku': tSku,
              'name': tName,
              'unitPrice': tUnitPrice,
              'qtyOnHand': tInitialStock,
              'reorderLevel': 10,
              'itemType': 'food',
              'foodCategory': 'Snacks',
              'barcode': tBarcode,
            },
          )).called(1);
    });

    test('should send correct data for collectable item', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createProduct(
        sku: tSku,
        name: 'Action Figure',
        unitPrice: tUnitPrice,
        category: 'Colecionáveis',
        initialStock: tInitialStock,
      );

      // Assert
      verify(() => mockHttpClient.post(
            any(),
            data: {
              'sku': tSku,
              'name': 'Action Figure',
              'unitPrice': tUnitPrice,
              'qtyOnHand': tInitialStock,
              'reorderLevel': 10,
              'itemType': 'collectable',
              'collectableCategory': 'Colecionáveis',
            },
          )).called(1);
    });

    test('should throw AppException when creation fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Product already exists',
                },
                statusCode: 400,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.createProduct(
          sku: tSku,
          name: tName,
          unitPrice: tUnitPrice,
          category: tCategory,
          initialStock: tInitialStock,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('updateProduct', () {
    const tSku = 'SKU001';
    const tName = 'Updated Popcorn';
    const tUnitPrice = 18.0;

    test('should return ProductModel when update is successful', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.updateProduct(
        sku: tSku,
        name: tName,
        unitPrice: tUnitPrice,
      );

      // Assert
      expect(result, isA<ProductModel>());
    });

    test('should only send provided fields in request', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                  'data': tProductData,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateProduct(
        sku: tSku,
        name: tName,
      );

      // Assert
      verify(() => mockHttpClient.put(
            any(),
            data: {'name': tName},
          )).called(1);
    });

    test('should throw AppException when update fails', () async {
      // Arrange
      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Update failed',
                },
                statusCode: 400,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.updateProduct(sku: tSku, name: tName),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('toggleProductStatus', () {
    const tSku = 'SKU001';

    test('should complete successfully when activating product', () async {
      // Arrange
      when(() => mockHttpClient.patch(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.toggleProductStatus(tSku, true),
        returnsNormally,
      );
    });

    test('should complete successfully when deactivating product', () async {
      // Arrange
      when(() => mockHttpClient.patch(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': true,
                },
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.toggleProductStatus(tSku, false),
        returnsNormally,
      );
    });

    test('should throw AppException when toggle fails', () async {
      // Arrange
      when(() => mockHttpClient.patch(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Toggle failed',
                },
                statusCode: 400,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.toggleProductStatus(tSku, true),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException on DioException', () async {
      // Arrange
      when(() => mockHttpClient.patch(any()))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              requestOptions: RequestOptions(path: ''),
              statusCode: 500,
              data: {'message': 'Server error'},
            ),
          ));

      // Act & Assert
      expect(
        () => dataSource.toggleProductStatus(tSku, true),
        throwsA(isA<AppException>()),
      );
    });
  });
}
