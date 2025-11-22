import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:backstage_frontend/adapters/dependency_injection/injection_container.dart';
import 'package:backstage_frontend/adapters/storage/local_storage.dart';
import 'package:backstage_frontend/main.dart' as app;

import '../mocks/mock_http_client.dart';
import '../helpers/mock_responses.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Inventory Management Flow Integration Tests', () {
    late MockHttpClient mockHttpClient;
    late MockResponses mockResponses;
    late Dio dio;

    setUp(() async {
      await GetIt.instance.reset();

      dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:3000',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      mockResponses = MockResponses();
      mockHttpClient = MockHttpClient(dio: dio, mockResponses: mockResponses);

      await InjectionContainer.init(dioForTesting: dio);

      final storage = GetIt.instance<LocalStorage>();
      await storage.clear();
    });

    tearDown(() async {
      mockHttpClient.clearMocks();
      await GetIt.instance.reset();
    });

    testWidgets('Flow 6.1: View inventory list', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Start app and login
      await _loginAndNavigateToInventory(tester);

      // Verify inventory page loaded
      expect(find.text('Inventário'), findsOneWidget);
      expect(find.byKey(const Key('inventorySearchField')), findsOneWidget);

      // Wait for products to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify product list is displayed
      expect(find.byKey(const Key('productList')), findsOneWidget);
      expect(find.byKey(const Key('product_POPCORN-L')), findsOneWidget);
    });

    testWidgets('Flow 6.2: Search products', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/inventory?search=pipoca',
        const MockResponse(
          data: {
            'success': true,
            'data': [
              {
                'sku': 'POPCORN-L',
                'name': 'Pipoca Grande',
                'category': 'FOOD',
                'unitPrice': 18.00,
                'qtyOnHand': 50,
                'reorderLevel': 10,
                'isActive': true,
              }
            ]
          },
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToInventory(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter search query
      await tester.enterText(
        find.byKey(const Key('inventorySearchField')),
        'pipoca',
      );

      // Wait for debounce and search
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      // Verify filtered results
      expect(find.byKey(const Key('product_POPCORN-L')), findsOneWidget);
    });

    testWidgets('Flow 6.3: Filter low stock products', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Login and navigate
      await _loginAndNavigateToInventory(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap low stock filter
      await tester.tap(find.byKey(const Key('lowStockFilterButton')));
      await tester.pumpAndSettle();

      // Verify filter is active (button should be highlighted)
      // The low stock products should be displayed
      expect(find.byKey(const Key('productList')), findsOneWidget);
    });

    testWidgets('Flow 6.4: Create new product', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'POST',
        '/api/inventory',
        const MockResponse(
          data: {
            'success': true,
            'data': {
              'sku': 'CANDY-M',
              'name': 'Chocolate M&M',
              'category': 'CANDY',
              'unitPrice': 12.00,
              'qtyOnHand': 50,
              'reorderLevel': 15,
              'isActive': true,
            }
          },
          statusCode: 201,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToInventory(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap create product button
      await tester.tap(find.byKey(const Key('createProductButton')));
      await tester.pumpAndSettle();

      // Verify create product page opened
      expect(find.text('Adicionar Produto'), findsOneWidget);

      // Fill in product form
      await tester.enterText(
        find.byKey(const Key('productSkuField')),
        'CANDY-M',
      );
      await tester.enterText(
        find.byKey(const Key('productNameField')),
        'Chocolate M&M',
      );
      await tester.enterText(
        find.byKey(const Key('productPriceField')),
        '12.00',
      );
      await tester.enterText(
        find.byKey(const Key('productCategoryField')),
        'CANDY',
      );
      await tester.enterText(
        find.byKey(const Key('productQuantityField')),
        '50',
      );

      // Submit form
      await tester.tap(find.byKey(const Key('submitProductButton')));
      await tester.pumpAndSettle();

      // Wait for navigation back and refresh
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify returned to inventory page
      expect(find.text('Inventário'), findsOneWidget);
    });

    testWidgets('Flow 6.5: Adjust product stock', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'POST',
        '/api/inventory/POPCORN-L/adjust',
        const MockResponse(
          data: {
            'success': true,
            'data': {
              'id': 'adjustment-uuid-1',
              'sku': 'POPCORN-L',
              'delta': 20,
              'previousStock': 50,
              'newStock': 70,
              'reason': 'Reestoque',
              'createdAt': '2024-01-15T11:00:00Z'
            }
          },
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToInventory(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap adjust stock button on first product
      await tester.tap(find.byKey(const Key('adjustStockButton_POPCORN-L')));
      await tester.pumpAndSettle();

      // Verify adjust stock dialog appears
      expect(find.byKey(const Key('adjustStockDialog')), findsOneWidget);

      // Enter new quantity (current is 50, adjust to 70)
      await tester.enterText(
        find.byKey(const Key('adjustQuantityField')),
        '70',
      );

      // Confirm adjustment
      await tester.tap(find.byKey(const Key('confirmAdjustmentButton')));
      await tester.pumpAndSettle();

      // Wait for adjustment to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('adjustStockDialog')), findsNothing);
    });

    testWidgets('Flow 6.6: Delete product', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'PUT',
        '/api/inventory/POPCORN-L/status',
        const MockResponse(
          data: {
            'success': true,
            'message': 'Produto desativado com sucesso'
          },
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToInventory(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap delete button on first product
      await tester.tap(find.byKey(const Key('deleteProductButton_POPCORN-L')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byKey(const Key('deleteProductDialog')), findsOneWidget);
      expect(find.text('Excluir Produto'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirmDeleteProductButton')));
      await tester.pumpAndSettle();

      // Wait for delete to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('deleteProductDialog')), findsNothing);
    });
  });
}

// Helper functions

void _setupBasicMocks(MockResponses mockResponses) {
  mockResponses.addResponse(
    'POST',
    '/api/employees/login',
    const MockResponse(
      data: AuthMockResponses.successfulLoginResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/sales/reports/summary',
    const MockResponse(
      data: DashboardMockResponses.salesSummaryResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/sessions',
    const MockResponse(
      data: DashboardMockResponses.sessionsResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/inventory/alerts/low-stock',
    const MockResponse(
      data: DashboardMockResponses.lowStockResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/inventory/expiring',
    const MockResponse(
      data: DashboardMockResponses.expiringItemsResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/customers',
    const MockResponse(
      data: DashboardMockResponses.customersResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/inventory',
    const MockResponse(
      data: PosMockResponses.productsResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/movies',
    const MockResponse(
      data: PosMockResponses.moviesResponse,
      statusCode: 200,
    ),
  );

  mockResponses.addResponse(
    'GET',
    '/api/rooms',
    const MockResponse(
      data: PosMockResponses.roomsResponse,
      statusCode: 200,
    ),
  );
}

Future<void> _loginAndNavigateToInventory(WidgetTester tester) async {
  await tester.pumpWidget(const app.BackstageApp());
  await tester.pumpAndSettle();
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Login
  await tester.enterText(
    find.byKey(const Key('employeeIdField')),
    'EMP001',
  );
  await tester.enterText(
    find.byKey(const Key('passwordField')),
    'password123',
  );
  await tester.tap(find.byKey(const Key('loginButton')));
  await tester.pumpAndSettle();
  await tester.pumpAndSettle(const Duration(seconds: 1));
  await tester.pumpAndSettle(const Duration(seconds: 2));

  // Navigate to inventory page by tapping inventory quick action
  await tester.tap(find.byKey(const Key('inventoryQuickAction')));
  await tester.pumpAndSettle();
}
