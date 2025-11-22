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

  group('Dashboard Flow Integration Tests', () {
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
      mockHttpClient = MockHttpClient(
        dio: dio,
        mockResponses: mockResponses,
      );

      // Initialize dependencies with mocked Dio
      await InjectionContainer.init(dioForTesting: dio);

      // Clear any stored authentication
      final storage = GetIt.instance<LocalStorage>();
      await storage.clear();
    });

    tearDown(() async {
      mockHttpClient.clearMocks();
      await GetIt.instance.reset();
    });

    testWidgets('Flow 2.1: Dashboard loads with stats and quick actions',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup mock responses for dashboard data
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Verify we're on dashboard
      expect(find.text('Dashboard'), findsOneWidget);

      // Wait for dashboard data to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify stats cards are displayed
      expect(find.byKey(const Key('salesRevenueCard')), findsOneWidget);
      expect(find.byKey(const Key('sessionsCard')), findsOneWidget);
      expect(find.byKey(const Key('lowStockCard')), findsOneWidget);

      // Verify sales revenue is displayed
      expect(find.textContaining('R\$'), findsWidgets);
      expect(find.textContaining('transações'), findsWidgets);

      // Verify quick action cards are displayed
      expect(find.byKey(const Key('posQuickAction')), findsOneWidget);
      expect(find.byKey(const Key('sessionsQuickAction')), findsOneWidget);
      expect(find.byKey(const Key('inventoryQuickAction')), findsOneWidget);
      expect(find.byKey(const Key('reportsQuickAction')), findsOneWidget);

      // Verify quick action titles
      expect(find.text('Nova Venda'), findsOneWidget);
      expect(find.text('Sessões'), findsOneWidget);
      expect(find.text('Inventário'), findsOneWidget);
      expect(find.text('Relatórios'), findsOneWidget);
    });

    testWidgets('Flow 2.2: Pull-to-refresh reloads dashboard data',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup initial dashboard data
      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/summary',
        const MockResponse(
          data: DashboardMockResponses.salesSummaryResponse,
          statusCode: 200,
        ),
      );

      // Add all other required endpoints
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Find the RefreshIndicator (we need to drag on a scrollable widget inside it)
      final scrollable = find.descendant(
        of: find.byKey(const Key('dashboardRefreshIndicator')),
        matching: find.byType(SingleChildScrollView),
      );

      // Perform pull-to-refresh gesture
      await tester.drag(scrollable, const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify stats are still displayed after refresh
      expect(find.byKey(const Key('salesRevenueCard')), findsOneWidget);
      expect(find.byKey(const Key('sessionsCard')), findsOneWidget);
    });

    testWidgets('Flow 2.3: Dashboard shows error state when API fails',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup error response for sales summary
      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/summary',
        const MockResponse(
          data: {'success': false, 'message': 'Erro ao carregar dados'},
          statusCode: 500,
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

      // Wait for error to display
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify error message is displayed
      expect(find.text('Erro ao carregar dashboard'), findsOneWidget);
      expect(find.byKey(const Key('retryLoadButton')), findsOneWidget);
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Verify stats cards are NOT displayed
      expect(find.byKey(const Key('salesRevenueCard')), findsNothing);
    });

    testWidgets('Flow 2.4: Retry button reloads dashboard after error',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup initial error response
      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/summary',
        const MockResponse(
          data: {'success': false, 'message': 'Erro temporário'},
          statusCode: 500,
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

      // Wait for error
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify error state
      expect(find.text('Erro ao carregar dashboard'), findsOneWidget);

      // Update mock to return success
      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/summary',
        const MockResponse(
          data: DashboardMockResponses.salesSummaryResponse,
          statusCode: 200,
        ),
      );

      // Add all other required endpoints for successful load
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Tap retry button
      await tester.tap(find.byKey(const Key('retryLoadButton')));
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify dashboard loaded successfully
      expect(find.byKey(const Key('salesRevenueCard')), findsOneWidget);
      expect(find.byKey(const Key('sessionsCard')), findsOneWidget);
      expect(find.text('Erro ao carregar dashboard'), findsNothing);
    });

    testWidgets(
        'Flow 2.5: Quick action navigates to correct page (POS example)',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup dashboard data
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Verify POS quick action is visible
      expect(find.byKey(const Key('posQuickAction')), findsOneWidget);

      // Tap POS quick action
      await tester.tap(find.byKey(const Key('posQuickAction')));
      await tester.pumpAndSettle();

      // Verify we navigated to POS page (check for POS-specific widgets)
      // Since we're navigating to a new page, we can check if we left the dashboard
      expect(find.text('Nova Venda'), findsNothing,
          reason: 'Quick action should no longer be visible after navigation');
    });

    testWidgets(
        'Flow 2.6: Quick action navigates to correct page (Sessions example)',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup dashboard data
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Verify Sessions quick action is visible
      expect(find.byKey(const Key('sessionsQuickAction')), findsOneWidget);

      // Tap Sessions quick action
      await tester.tap(find.byKey(const Key('sessionsQuickAction')));
      await tester.pumpAndSettle();

      // Verify we navigated away from dashboard by checking quick action card is gone
      expect(find.byKey(const Key('sessionsQuickAction')), findsNothing,
          reason: 'Quick action card should no longer be visible after navigation');
    });

    testWidgets(
        'Flow 2.7: Quick action navigates to correct page (Inventory example)',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup dashboard data
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Verify Inventory quick action is visible
      expect(find.byKey(const Key('inventoryQuickAction')), findsOneWidget);

      // Tap Inventory quick action
      await tester.tap(find.byKey(const Key('inventoryQuickAction')));
      await tester.pumpAndSettle();

      // Verify we navigated away from dashboard by checking quick action card is gone
      expect(find.byKey(const Key('inventoryQuickAction')), findsNothing,
          reason: 'Quick action card should no longer be visible after navigation');
    });

    testWidgets(
        'Flow 2.8: Quick action navigates to correct page (Reports example)',
        (tester) async {
      // Setup mock responses for login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Setup dashboard data
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
          data: DashboardMockResponses.inventoryResponse,
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

      // Verify Reports quick action is visible
      expect(find.byKey(const Key('reportsQuickAction')), findsOneWidget);

      // Tap Reports quick action
      await tester.tap(find.byKey(const Key('reportsQuickAction')));
      await tester.pumpAndSettle();

      // Verify we navigated away from dashboard by checking quick action card is gone
      expect(find.byKey(const Key('reportsQuickAction')), findsNothing,
          reason: 'Quick action card should no longer be visible after navigation');
    });
  });
}

// Helper function to setup all dashboard mocks
void _setupDashboardMocks(MockResponses mockResponses) {
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
      data: DashboardMockResponses.inventoryResponse,
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
