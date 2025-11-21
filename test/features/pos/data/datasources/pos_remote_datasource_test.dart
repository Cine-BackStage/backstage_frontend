import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/features/pos/data/datasources/pos_remote_datasource.dart';
import 'package:backstage_frontend/features/pos/data/models/product_model.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_model.dart';
import 'package:backstage_frontend/features/pos/data/models/sale_item_model.dart';
import 'package:backstage_frontend/features/pos/data/models/payment_model.dart';
import 'package:backstage_frontend/features/pos/domain/entities/payment.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late PosRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(PaymentMethod.cash);
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = PosRemoteDataSourceImpl(mockHttpClient);
  });

  group('getProducts', () {
    final tProductsData = {
      'success': true,
      'data': [
        {
          'sku': 'SKU001',
          'name': 'Popcorn',
          'unitPrice': 15.0,
          'qtyOnHand': 100,
          'reorderLevel': 20,
          'isActive': true,
          'food': {
            'category': 'Snacks',
          },
        },
        {
          'sku': 'SKU002',
          'name': 'Soda',
          'unitPrice': 8.0,
          'qtyOnHand': 50,
          'reorderLevel': 10,
          'isActive': true,
          'food': {
            'category': 'Beverages',
          },
        },
      ],
    };

    test('should return List<ProductModel> when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: tProductsData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getProducts();

      // Assert
      expect(result, isA<List<ProductModel>>());
      expect(result.length, 2);
      expect(result[0].sku, 'SKU001');
      expect(result[0].name, 'Popcorn');
      expect(result[1].sku, 'SKU002');
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to get products',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getProducts(),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when an error occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => dataSource.getProducts(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('createSale', () {
    final tSaleData = {
      'success': true,
      'data': {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'buyerCpf': '987.654.321-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': 0.0,
        'discountAmount': 0.0,
        'grandTotal': 0.0,
        'items': [],
        'payments': [],
      },
    };

    test('should return SaleModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createSale(buyerCpf: '987.654.321-00');

      // Assert
      expect(result, isA<SaleModel>());
      expect(result.id, 'SALE001');
      expect(result.buyerCpf, '987.654.321-00');
      expect(result.status, 'OPEN');
    });

    test('should create sale without buyerCpf', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createSale();

      // Assert
      expect(result, isA<SaleModel>());
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to create sale',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.createSale(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getSaleById', () {
    final tSaleData = {
      'success': true,
      'data': {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': 50.0,
        'discountAmount': 0.0,
        'grandTotal': 50.0,
        'items': [],
        'payments': [],
      },
    };

    test('should return SaleModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: tSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getSaleById('SALE001');

      // Assert
      expect(result, isA<SaleModel>());
      expect(result.id, 'SALE001');
      expect(result.subtotal, 50.0);
    });

    test('should throw AppException when sale not found', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Sale not found',
                },
                statusCode: 404,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getSaleById('INVALID'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('addItemToSale', () {
    final tItemData = {
      'success': true,
      'data': {
        'id': 'ITEM001',
        'saleId': 'SALE001',
        'sku': 'SKU001',
        'description': 'Popcorn',
        'quantity': 2,
        'unitPrice': 15.0,
        'totalPrice': 30.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      },
    };

    test('should return SaleItemModel when adding product item', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tItemData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.addItemToSale(
        saleId: 'SALE001',
        sku: 'SKU001',
        description: 'Popcorn',
        quantity: 2,
        unitPrice: 15.0,
      );

      // Assert
      expect(result, isA<SaleItemModel>());
      expect(result.id, 'ITEM001');
      expect(result.sku, 'SKU001');
      expect(result.quantity, 2);
    });

    test('should return SaleItemModel when adding ticket item', () async {
      // Arrange
      final tTicketData = {
        'success': true,
        'data': {
          'id': 'ITEM002',
          'saleId': 'SALE001',
          'sessionId': 'SESSION001',
          'seatId': 'SEAT001',
          'description': 'Movie Ticket',
          'quantity': 1,
          'unitPrice': 25.0,
          'totalPrice': 25.0,
          'createdAt': '2024-01-01T00:00:00.000Z',
        },
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tTicketData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.addItemToSale(
        saleId: 'SALE001',
        sessionId: 'SESSION001',
        seatId: 'SEAT001',
        description: 'Movie Ticket',
        quantity: 1,
        unitPrice: 25.0,
      );

      // Assert
      expect(result, isA<SaleItemModel>());
      expect(result.sessionId, 'SESSION001');
      expect(result.seatId, 'SEAT001');
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to add item',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.addItemToSale(
          saleId: 'SALE001',
          sku: 'SKU001',
          description: 'Popcorn',
          quantity: 2,
          unitPrice: 15.0,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException with status code on DioException', () async {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 409,
          data: {'message': 'Insufficient stock'},
        ),
      );

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenThrow(dioError);

      // Act & Assert
      expect(
        () => dataSource.addItemToSale(
          saleId: 'SALE001',
          sku: 'SKU001',
          description: 'Popcorn',
          quantity: 2,
          unitPrice: 15.0,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('removeItemFromSale', () {
    test('should complete successfully when item is removed', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {'success': true},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        dataSource.removeItemFromSale(
          saleId: 'SALE001',
          itemId: 'ITEM001',
        ),
        completes,
      );
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to remove item',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.removeItemFromSale(
          saleId: 'SALE001',
          itemId: 'ITEM001',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('validateDiscount', () {
    final tDiscountData = {
      'success': true,
      'data': {
        'code': 'DISCOUNT10',
        'discountAmount': 10.0,
        'type': 'PERCENTAGE',
        'value': 10.0,
      },
    };

    test('should return discount data when validation is successful', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tDiscountData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.validateDiscount(
        code: 'DISCOUNT10',
        subtotal: 100.0,
      );

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['code'], 'DISCOUNT10');
      expect(result['discountAmount'], 10.0);
    });

    test('should throw AppException when discount code is invalid', () async {
      // Arrange
      final dioError = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
          data: {'message': 'Invalid discount code'},
        ),
      );

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenThrow(dioError);

      // Act & Assert
      expect(
        () => dataSource.validateDiscount(
          code: 'INVALID',
          subtotal: 100.0,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('applyDiscount', () {
    final tSaleData = {
      'success': true,
      'data': {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'OPEN',
        'subtotal': 100.0,
        'discountAmount': 10.0,
        'grandTotal': 90.0,
        'discountCode': 'DISCOUNT10',
        'items': [],
        'payments': [],
      },
    };

    test('should return updated SaleModel when discount is applied', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.applyDiscount(
        saleId: 'SALE001',
        code: 'DISCOUNT10',
      );

      // Assert
      expect(result, isA<SaleModel>());
      expect(result.discountAmount, 10.0);
      expect(result.discountCode, 'DISCOUNT10');
      expect(result.grandTotal, 90.0);
    });

    test('should throw AppException when applying discount fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to apply discount',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.applyDiscount(
          saleId: 'SALE001',
          code: 'DISCOUNT10',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('addPayment', () {
    final tPaymentData = {
      'success': true,
      'data': {
        'id': 'PAY001',
        'saleId': 'SALE001',
        'method': 'CASH',
        'amount': 50.0,
        'createdAt': '2024-01-01T00:00:00.000Z',
      },
    };

    test('should return PaymentModel when payment is added', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tPaymentData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.addPayment(
        saleId: 'SALE001',
        method: PaymentMethod.cash,
        amount: 50.0,
      );

      // Assert
      expect(result, isA<PaymentModel>());
      expect(result.id, 'PAY001');
      expect(result.method, PaymentMethod.cash);
      expect(result.amount, 50.0);
    });

    test('should include authCode for card payments', () async {
      // Arrange
      final tCardPaymentData = {
        'success': true,
        'data': {
          'id': 'PAY002',
          'saleId': 'SALE001',
          'method': 'CARD',
          'amount': 100.0,
          'authCode': 'AUTH123456',
          'createdAt': '2024-01-01T00:00:00.000Z',
        },
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: tCardPaymentData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.addPayment(
        saleId: 'SALE001',
        method: PaymentMethod.card,
        amount: 100.0,
        authCode: 'AUTH123456',
      );

      // Assert
      expect(result.authCode, 'AUTH123456');
    });

    test('should throw AppException when adding payment fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to add payment',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.addPayment(
          saleId: 'SALE001',
          method: PaymentMethod.cash,
          amount: 50.0,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('removePayment', () {
    test('should complete successfully when payment is removed', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {'success': true},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        dataSource.removePayment(
          saleId: 'SALE001',
          paymentId: 'PAY001',
        ),
        completes,
      );
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to remove payment',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.removePayment(
          saleId: 'SALE001',
          paymentId: 'PAY001',
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('finalizeSale', () {
    final tFinalizedSaleData = {
      'success': true,
      'data': {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'FINALIZED',
        'subtotal': 100.0,
        'discountAmount': 0.0,
        'grandTotal': 100.0,
        'items': [],
        'payments': [],
      },
    };

    test('should return finalized SaleModel', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: tFinalizedSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.finalizeSale('SALE001');

      // Assert
      expect(result, isA<SaleModel>());
      expect(result.id, 'SALE001');
      expect(result.status, 'FINALIZED');
    });

    test('should throw AppException when finalization fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to finalize sale',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.finalizeSale('SALE001'),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('cancelSale', () {
    final tCanceledSaleData = {
      'success': true,
      'data': {
        'id': 'SALE001',
        'companyId': 'COMP001',
        'cashierCpf': '123.456.789-00',
        'createdAt': '2024-01-01T00:00:00.000Z',
        'status': 'CANCELED',
        'subtotal': 100.0,
        'discountAmount': 0.0,
        'grandTotal': 100.0,
        'items': [],
        'payments': [],
      },
    };

    test('should return canceled SaleModel', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: tCanceledSaleData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.cancelSale('SALE001');

      // Assert
      expect(result, isA<SaleModel>());
      expect(result.id, 'SALE001');
      expect(result.status, 'CANCELED');
    });

    test('should throw AppException when cancellation fails', () async {
      // Arrange
      when(() => mockHttpClient.post(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to cancel sale',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.cancelSale('SALE001'),
        throwsA(isA<AppException>()),
      );
    });
  });
}
