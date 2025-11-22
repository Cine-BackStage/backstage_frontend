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

  group('POS Ticket Sale Flow Integration Tests', () {
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

    testWidgets('Flow 4.1: View available sessions for ticket sales', (
      tester,
    ) async {
      // Setup mock responses for login and dashboard
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
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to POS
      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      // Initialize POS
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

      // Wait for dialog to load sessions
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify session selection dialog appears with session card
      expect(find.text('Selecione uma Sessão'), findsOneWidget);
      expect(find.byKey(const Key('sessionCard_session-uuid-1')), findsOneWidget);
    });

    testWidgets('Flow 4.2: Select session and view seat map', (
      tester,
    ) async {
      // Setup all required mocks
      _setupBasicMocks(mockResponses);

      // Mock session details endpoint
      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1/seats',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      // Start app, login, create sale
      await _loginAndCreateSale(tester);

      // Tap sell tickets button
      await tester.tap(find.byKey(const Key('sellTicketsButton')));
      await tester.pumpAndSettle();

      // Wait for dialog to load sessions
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Select session
      await tester.tap(find.byKey(const Key('sessionCard_session-uuid-1')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify seat selection page loaded with seats
      expect(find.text('Seleção de Assentos'), findsOneWidget);
      expect(find.byKey(const Key('seat_seat-a1')), findsOneWidget);
      expect(find.byKey(const Key('seat_seat-a2')), findsOneWidget);
    });

    testWidgets('Flow 4.3: Select seats and add tickets to cart', (
      tester,
    ) async {
      // Setup all required mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1/seats',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
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

      // Start app, login, create sale
      await _loginAndCreateSale(tester);

      // Open ticket sales
      await tester.tap(find.byKey(const Key('sellTicketsButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sessionCard_session-uuid-1')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Select two seats
      await tester.tap(find.byKey(const Key('seat_seat-a1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('seat_seat-a2')));
      await tester.pumpAndSettle();

      // Confirm selection
      await tester.tap(find.byKey(const Key('confirmSeatsButton')));
      await tester.pumpAndSettle();

      // Verify back at POS with tickets in cart
      expect(find.byKey(const Key('shoppingCartPanel')), findsOneWidget);
    });

    testWidgets('Flow 4.4: Complete ticket sale with payment', (
      tester,
    ) async {
      // Setup all required mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
        ),
      );

      mockResponses.addResponse(
        'GET',
        '/api/sessions/session-uuid-1/seats',
        const MockResponse(
          data: PosMockResponses.getSessionSeatsResponse,
          statusCode: 200,
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

      // Start app, login, create sale, select tickets
      await _loginAndCreateSale(tester);
      await tester.tap(find.byKey(const Key('sellTicketsButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('sessionCard_session-uuid-1')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Select seats
      await tester.tap(find.byKey(const Key('seat_seat-a1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('seat_seat-a2')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('confirmSeatsButton')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Add payment
      await tester.ensureVisible(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addPaymentButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('addPaymentConfirmButton')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Finalize sale
      await tester.ensureVisible(find.byKey(const Key('finalizeSaleButton')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('finalizeSaleButton')));

      // Wait for finalization
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      for (int i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify sale completed
      expect(find.byKey(const Key('saleCompleteDialog')), findsOneWidget);
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
}

Future<void> _loginAndCreateSale(WidgetTester tester) async {
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
}
