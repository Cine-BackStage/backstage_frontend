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

  group('POS Concession Sale Flow Integration Tests', () {
    late MockHttpClient mockHttpClient;
    late MockResponses mockResponses;
    late Dio dio;

    setUp(() async {
      // Reset GetIt service locator
      await GetIt.instance.reset();

      // Create Dio instance
      dio = Dio(
        BaseOptions(
          baseUrl: 'http://localhost:3000',
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      // Setup mock responses
      mockResponses = MockResponses();
      mockHttpClient = MockHttpClient(dio: dio, mockResponses: mockResponses);

      // Initialize dependencies with mocked Dio
      await InjectionContainer.init(dioForTesting: dio);

      // Clear any stored auth data to ensure we start at login screen
      final storage = GetIt.instance<LocalStorage>();
      await storage.clear();
    });

    tearDown(() async {
      mockHttpClient.clearMocks();
      await GetIt.instance.reset();
    });

    testWidgets('Flow 3.1: Initialize POS and load products', (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup dashboard mocks
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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

      // Start app and login
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

      // Wait for dashboard to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to POS
      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      // Verify POS page loaded
      expect(find.text('Ponto de Venda'), findsOneWidget);

      // Verify initialize button is visible
      expect(find.byKey(const Key('initializePosButton')), findsOneWidget);

      // Tap initialize POS button
      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      // Verify products are loaded
      expect(find.byKey(const Key('productGrid')), findsOneWidget);
      expect(find.byKey(const Key('product_POPCORN-L')), findsOneWidget);
      expect(find.byKey(const Key('product_SODA-500')), findsOneWidget);

      // Verify new sale button is visible
      expect(find.byKey(const Key('newSaleButton')), findsOneWidget);
    });

    testWidgets('Flow 3.2: Create new sale and add items to cart', (
      tester,
    ) async {
      // Setup all required mocks
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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

      // Mock create sale endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales',
        const MockResponse(
          data: PosMockResponses.createSaleResponse,
          statusCode: 201,
        ),
      );

      // Mock add item endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/items',
        const MockResponse(
          data: PosMockResponses.addItemResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, and navigate to POS
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      // Initialize POS
      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      // Create new sale
      await tester.tap(find.byKey(const Key('newSaleButton')));
      await tester.pumpAndSettle();

      // Verify shopping cart panel is visible
      expect(find.byKey(const Key('shoppingCartPanel')), findsOneWidget);

      // Add product to cart
      await tester.tap(find.byKey(const Key('product_POPCORN-L')));
      await tester.pumpAndSettle();

      // Verify item appears in cart
      expect(find.byKey(const Key('cartItem_0')), findsOneWidget);

      // Verify total amount is displayed
      expect(find.byKey(const Key('totalAmountText')), findsOneWidget);
    });

    testWidgets('Flow 3.3: Apply valid discount code', (tester) async {
      // Setup all required mocks
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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
        'POST',
        '/api/sales',
        const MockResponse(
          data: PosMockResponses.createSaleResponse,
          statusCode: 201,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/items',
        const MockResponse(
          data: PosMockResponses.addItemResponse,
          statusCode: 200,
        ),
      );

      // Mock discount validation endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales/discount/validate',
        const MockResponse(
          data: PosMockResponses.validateDiscountSuccessResponse,
          statusCode: 200,
        ),
      );

      // Mock apply discount endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/discount',
        const MockResponse(
          data: PosMockResponses.applyDiscountResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, navigate to POS, create sale, add item
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('newSaleButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('product_POPCORN-L')));
      await tester.pumpAndSettle();

      // Wait for item to be added to cart
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make discount button visible
      await tester.ensureVisible(find.byKey(const Key('applyDiscountButton')));
      await tester.pumpAndSettle();

      // Tap apply discount button
      await tester.tap(find.byKey(const Key('applyDiscountButton')));
      await tester.pumpAndSettle();

      // Verify discount dialog appears
      expect(find.byKey(const Key('discountCodeField')), findsOneWidget);

      // Enter discount code
      await tester.enterText(
        find.byKey(const Key('discountCodeField')),
        'PROMO10',
      );

      // Apply discount
      await tester.tap(find.byKey(const Key('validateDiscountButton')));
      await tester.pumpAndSettle();

      // Verify discount was applied (discount code should appear in UI)
      expect(find.textContaining('PROMO10'), findsWidgets);
    });

    testWidgets('Flow 3.4: Add payment and finalize sale', (tester) async {
      // Setup all required mocks
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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
        'POST',
        '/api/sales',
        const MockResponse(
          data: PosMockResponses.createSaleResponse,
          statusCode: 201,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/items',
        const MockResponse(
          data: PosMockResponses.addItemResponse,
          statusCode: 200,
        ),
      );

      // Mock add payment endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/payments',
        const MockResponse(
          data: PosMockResponses.addPaymentResponse,
          statusCode: 200,
        ),
      );

      // Mock finalize sale endpoint
      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/finalize',
        const MockResponse(
          data: PosMockResponses.finalizeSaleResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, navigate to POS, create sale, add item
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('newSaleButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('product_POPCORN-L')));
      await tester.pumpAndSettle();

      // Wait for item to be added to cart
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make payment button visible
      await tester.ensureVisible(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      // Add payment
      await tester.tap(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      // Verify payment dialog appears
      expect(find.byKey(const Key('paymentAmountField')), findsOneWidget);
      expect(find.byKey(const Key('paymentMethodDropdown')), findsOneWidget);

      // Confirm payment
      await tester.tap(find.byKey(const Key('addPaymentConfirmButton')));
      await tester.pumpAndSettle();

      // Wait for payment to be processed
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make finalize button visible
      await tester.ensureVisible(find.byKey(const Key('finalizeSaleButton')));
      await tester.pumpAndSettle();

      // Verify finalize button appears
      expect(find.byKey(const Key('finalizeSaleButton')), findsOneWidget);

      // Finalize sale
      await tester.tap(find.byKey(const Key('finalizeSaleButton')));

      // Wait for sale to finalize and dialog to appear
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Pump a few more times to ensure dialog is fully rendered
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify sale complete dialog appears
      expect(find.byKey(const Key('saleCompleteDialog')), findsOneWidget);
      expect(find.byKey(const Key('saleReceiptNumber')), findsOneWidget);
      expect(find.byKey(const Key('newSaleFromDialogButton')), findsOneWidget);
    });

    testWidgets('Flow 3.5: Start new sale from completion dialog', (
      tester,
    ) async {
      // Setup all required mocks (same as previous test)
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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
        'POST',
        '/api/sales',
        const MockResponse(
          data: PosMockResponses.createSaleResponse,
          statusCode: 201,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/items',
        const MockResponse(
          data: PosMockResponses.addItemResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/payments',
        const MockResponse(
          data: PosMockResponses.addPaymentResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/finalize',
        const MockResponse(
          data: PosMockResponses.finalizeSaleResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, complete a sale
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('newSaleButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('product_POPCORN-L')));
      await tester.pumpAndSettle();

      // Wait for item to be added to cart
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make payment button visible
      await tester.ensureVisible(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('addPaymentConfirmButton')));
      await tester.pumpAndSettle();

      // Wait for payment to be processed
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make finalize button visible
      await tester.ensureVisible(find.byKey(const Key('finalizeSaleButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('finalizeSaleButton')));

      // Wait for sale to finalize and dialog to appear
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Pump a few more times to ensure dialog is fully rendered
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify completion dialog
      expect(find.byKey(const Key('saleCompleteDialog')), findsOneWidget);

      // Start new sale from dialog
      await tester.tap(find.byKey(const Key('newSaleFromDialogButton')));

      // Wait for dialog to close and new sale to be created
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify we're in a new sale with empty cart ready for items
      expect(find.byKey(const Key('productGrid')), findsOneWidget);
      expect(find.byKey(const Key('shoppingCartPanel')), findsOneWidget);
      expect(find.byKey(const Key('cancelSaleButton')), findsOneWidget);
    });

    testWidgets('Flow 3.6: Select session, select seats, and finalize ticket sale', (
      tester,
    ) async {
      // Setup all required mocks
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
        '/api/inventory',
        const MockResponse(
          data: PosMockResponses.productsResponse,
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
        'POST',
        '/api/sales',
        const MockResponse(
          data: PosMockResponses.createSaleResponse,
          statusCode: 201,
        ),
      );

      // Mock session details endpoint (loads session + seats)
      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      // Mock session seats endpoint
      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1/seats',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      // Mock add ticket items to sale
      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/items',
        const MockResponse(
          data: PosMockResponses.addItemResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/payments',
        const MockResponse(
          data: PosMockResponses.addPaymentResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'POST',
        '/api/sales/sale-uuid-123/finalize',
        const MockResponse(
          data: PosMockResponses.finalizeSaleResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, navigate to POS
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

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

      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('initializePosButton')));
      await tester.pumpAndSettle();

      // Create new sale
      await tester.tap(find.byKey(const Key('newSaleButton')));
      await tester.pumpAndSettle();

      // Verify sell tickets button appears
      expect(find.byKey(const Key('sellTicketsButton')), findsOneWidget);

      // Tap sell tickets button
      await tester.tap(find.byKey(const Key('sellTicketsButton')));
      await tester.pumpAndSettle();

      // Verify session selection dialog appears and select a session
      expect(find.byKey(const Key('sessionCard_session-uuid-1')), findsOneWidget);
      await tester.tap(find.byKey(const Key('sessionCard_session-uuid-1')));
      await tester.pumpAndSettle();

      // Wait for seat selection page to load
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify seats are displayed
      expect(find.byKey(const Key('seat_seat-a1')), findsOneWidget);
      expect(find.byKey(const Key('seat_seat-a2')), findsOneWidget);

      // Select two seats
      await tester.tap(find.byKey(const Key('seat_seat-a1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('seat_seat-a2')));
      await tester.pumpAndSettle();

      // Confirm seats and add to cart
      await tester.tap(find.byKey(const Key('confirmSeatsButton')));
      await tester.pumpAndSettle();

      // Verify back at POS with tickets in cart
      expect(find.byKey(const Key('shoppingCartPanel')), findsOneWidget);

      // Wait for items to be added
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to make payment button visible
      await tester.ensureVisible(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      // Add payment
      await tester.tap(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('addPaymentConfirmButton')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Scroll to finalize button
      await tester.ensureVisible(find.byKey(const Key('finalizeSaleButton')));
      await tester.pumpAndSettle();

      // Finalize sale
      await tester.tap(find.byKey(const Key('finalizeSaleButton')));

      // Wait for sale to finalize
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify sale complete dialog appears
      expect(find.byKey(const Key('saleCompleteDialog')), findsOneWidget);
    });
  });
}
