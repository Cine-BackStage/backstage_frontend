import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/constants/api_constants.dart';
import 'package:backstage_frontend/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:backstage_frontend/features/dashboard/data/models/dashboard_stats_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late DashboardRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = DashboardRemoteDataSourceImpl(mockHttpClient);
  });

  final tSalesResponseData = {
    'success': true,
    'data': {
      'todayRevenue': 1500.0,
      'todayTransactions': 25,
      'averageTicketPrice': 60.0,
      'weekRevenue': 10500.0,
      'monthRevenue': 45000.0,
      'growthPercentage': 15.5,
    },
  };

  final tSessionsResponseData = {
    'success': true,
    'data': [
      {
        'status': 'IN_PROGRESS',
        'ticketsSold': 50,
      },
      {
        'status': 'SCHEDULED',
        'ticketsSold': 30,
      },
      {
        'status': 'SCHEDULED',
        'ticketsSold': 40,
      },
    ],
  };

  final tLowStockResponseData = {
    'success': true,
    'data': [
      {'id': '1', 'name': 'Item 1'},
      {'id': '2', 'name': 'Item 2'},
      {'id': '3', 'name': 'Item 3'},
    ],
  };

  final tExpiringResponseData = {
    'success': true,
    'data': {
      'expiringItems': [
        {'id': '1', 'name': 'Expiring Item 1'},
      ],
      'expiredItems': [
        {'id': '2', 'name': 'Expired Item 1'},
      ],
    },
  };

  final tInventoryResponseData = {
    'success': true,
    'data': [
      {'qtyOnHand': 10, 'unitPrice': 100.0},
      {'qtyOnHand': 0, 'unitPrice': 50.0},
      {'qtyOnHand': '5', 'unitPrice': '75.5'},
    ],
  };

  final tCustomersResponseData = {
    'success': true,
    'data': [
      {'id': '1', 'name': 'Customer 1'},
      {'id': '2', 'name': 'Customer 2'},
    ],
  };

  group('getDashboardStats', () {
    test('should return DashboardStatsModel when all API calls are successful', () async {
      // Arrange - Mock all the different endpoints
      when(() => mockHttpClient.get(ApiConstants.salesReportsSummary))
          .thenAnswer((_) async => Response(
                data: tSalesResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(
            ApiConstants.sessions,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
                data: tSessionsResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryLowStock))
          .thenAnswer((_) async => Response(
                data: tLowStockResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryExpiring))
          .thenAnswer((_) async => Response(
                data: tExpiringResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventory))
          .thenAnswer((_) async => Response(
                data: tInventoryResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.customers))
          .thenAnswer((_) async => Response(
                data: tCustomersResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getDashboardStats();

      // Assert
      expect(result, isA<DashboardStatsModel>());
      expect(result.salesSummary.todayRevenue, 1500.0);
      expect(result.sessionSummary.activeSessionsToday, 1);
      expect(result.sessionSummary.upcomingSessions, 2);
      expect(result.inventorySummary.lowStockItems, 3);
      expect(result.inventorySummary.expiringItems, 2);
      expect(result.inventorySummary.outOfStockItems, 1);
      expect(result.activeCustomers, 2);
    });

    test('should return empty sales data when sales API fails', () async {
      // Arrange
      when(() => mockHttpClient.get(ApiConstants.salesReportsSummary))
          .thenAnswer((_) async => Response(
                data: {'success': false, 'message': 'Sales API error'},
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(
            ApiConstants.sessions,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
                data: tSessionsResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryLowStock))
          .thenAnswer((_) async => Response(
                data: tLowStockResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryExpiring))
          .thenAnswer((_) async => Response(
                data: tExpiringResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventory))
          .thenAnswer((_) async => Response(
                data: tInventoryResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.customers))
          .thenAnswer((_) async => Response(
                data: tCustomersResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getDashboardStats();

      // Assert
      expect(result, isA<DashboardStatsModel>());
      expect(result.salesSummary.todayRevenue, 0.0);
      expect(result.salesSummary.todayTransactions, 0);
    });

    test('should return empty session data when sessions API fails', () async {
      // Arrange
      when(() => mockHttpClient.get(ApiConstants.salesReportsSummary))
          .thenAnswer((_) async => Response(
                data: tSalesResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(
            ApiConstants.sessions,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
                data: {'success': false, 'message': 'Sessions API error'},
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryLowStock))
          .thenAnswer((_) async => Response(
                data: tLowStockResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryExpiring))
          .thenAnswer((_) async => Response(
                data: tExpiringResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventory))
          .thenAnswer((_) async => Response(
                data: tInventoryResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.customers))
          .thenAnswer((_) async => Response(
                data: tCustomersResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getDashboardStats();

      // Assert
      expect(result, isA<DashboardStatsModel>());
      expect(result.sessionSummary.activeSessionsToday, 0);
      expect(result.sessionSummary.upcomingSessions, 0);
    });

    test('should return zero active customers when customers API fails', () async {
      // Arrange
      when(() => mockHttpClient.get(ApiConstants.salesReportsSummary))
          .thenAnswer((_) async => Response(
                data: tSalesResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(
            ApiConstants.sessions,
            queryParameters: any(named: 'queryParameters'),
          )).thenAnswer((_) async => Response(
                data: tSessionsResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryLowStock))
          .thenAnswer((_) async => Response(
                data: tLowStockResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventoryExpiring))
          .thenAnswer((_) async => Response(
                data: tExpiringResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.inventory))
          .thenAnswer((_) async => Response(
                data: tInventoryResponseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      when(() => mockHttpClient.get(ApiConstants.customers))
          .thenAnswer((_) async => Response(
                data: {'success': false, 'message': 'Customers API error'},
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getDashboardStats();

      // Assert
      expect(result, isA<DashboardStatsModel>());
      expect(result.activeCustomers, 0);
    });

    test('should return empty data when all APIs fail gracefully', () async {
      // Arrange - All APIs fail but are caught by internal error handling
      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Network error'));

      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(Exception('Network error'));

      // Act
      final result = await dataSource.getDashboardStats();

      // Assert - Should return empty/default data instead of throwing
      expect(result, isA<DashboardStatsModel>());
      expect(result.salesSummary.todayRevenue, 0.0);
      expect(result.sessionSummary.activeSessionsToday, 0);
      expect(result.inventorySummary.lowStockItems, 0);
      expect(result.activeCustomers, 0);
    });
  });
}
