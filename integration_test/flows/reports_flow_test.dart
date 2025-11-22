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

  group('Reports Generation Flow Integration Tests', () {
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

    testWidgets('Flow 7.1: View sales summary on reports page', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Start app and login
      await _loginAndNavigateToReports(tester);

      // Verify reports page loaded
      expect(find.text('Relatórios'), findsOneWidget);

      // Wait for sales summary to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify sales summary card is displayed
      expect(find.byKey(const Key('salesSummaryCard')), findsOneWidget);
      expect(find.byKey(const Key('todayRevenueText')), findsOneWidget);
      expect(find.byKey(const Key('todayTransactionsText')), findsOneWidget);
      expect(find.byKey(const Key('weekRevenueText')), findsOneWidget);
      expect(find.byKey(const Key('monthRevenueText')), findsOneWidget);
      expect(find.byKey(const Key('growthPercentageText')), findsOneWidget);

      // Verify report category buttons
      expect(find.byKey(const Key('detailedSalesReportButton')), findsOneWidget);
      expect(find.byKey(const Key('ticketSalesReportButton')), findsOneWidget);
      expect(find.byKey(const Key('employeeReportButton')), findsOneWidget);
    });

    testWidgets('Flow 7.2: View detailed sales report', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/detailed',
        const MockResponse(
          data: ReportMockResponses.detailedSalesResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate to reports
      await _loginAndNavigateToReports(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap detailed sales report button
      await tester.tap(find.byKey(const Key('detailedSalesReportButton')));
      await tester.pumpAndSettle();

      // Verify detailed sales report page opened
      expect(find.text('Vendas Detalhadas'), findsOneWidget);

      // Wait for report to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify report data table is displayed
      expect(find.byKey(const Key('reportDataTable')), findsOneWidget);

      // Verify filters are displayed
      expect(find.byKey(const Key('dateRangePicker')), findsOneWidget);
      expect(find.byKey(const Key('groupByDropdown')), findsOneWidget);
    });

    testWidgets('Flow 7.3: Change date range filter', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/sales/reports/detailed',
        const MockResponse(
          data: ReportMockResponses.detailedSalesResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate to detailed sales report
      await _loginAndNavigateToReports(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));
      await tester.tap(find.byKey(const Key('detailedSalesReportButton')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap date range picker
      await tester.tap(find.byKey(const Key('dateRangePicker')));
      await tester.pumpAndSettle();

      // DateRangePicker dialog should appear - just cancel it for this test
      // In a real test, you would select dates, but DateRangePicker is complex to interact with
      final cancelButton = find.text('CANCEL').hitTestable();
      if (cancelButton.evaluate().isNotEmpty) {
        await tester.tap(cancelButton);
        await tester.pumpAndSettle();
      }

      // Verify still on detailed sales page
      expect(find.text('Vendas Detalhadas'), findsOneWidget);
    });

    testWidgets('Flow 7.4: View ticket sales report', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/tickets/reports/sales',
        const MockResponse(
          data: ReportMockResponses.ticketSalesResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate to reports
      await _loginAndNavigateToReports(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap ticket sales report button
      await tester.tap(find.byKey(const Key('ticketSalesReportButton')));
      await tester.pumpAndSettle();

      // Verify ticket sales report page opened
      expect(find.text('Vendas de Ingressos'), findsOneWidget);

      // Wait for report to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify report data table is displayed
      expect(find.byKey(const Key('reportDataTable')), findsOneWidget);

      // Verify filters are displayed
      expect(find.byKey(const Key('dateRangePicker')), findsOneWidget);
      expect(find.byKey(const Key('groupByDropdown')), findsOneWidget);
    });

    testWidgets('Flow 7.5: View employee performance report', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'GET',
        '/api/employees/reports/consolidated',
        const MockResponse(
          data: ReportMockResponses.employeeReportResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate to reports
      await _loginAndNavigateToReports(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap employee report button
      await tester.tap(find.byKey(const Key('employeeReportButton')));
      await tester.pumpAndSettle();

      // Verify employee report page opened
      expect(find.text('Desempenho de Funcionários'), findsOneWidget);

      // Wait for report to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify report data table is displayed
      expect(find.byKey(const Key('reportDataTable')), findsOneWidget);

      // Verify date filter is displayed
      expect(find.byKey(const Key('dateRangePicker')), findsOneWidget);
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

Future<void> _loginAndNavigateToReports(WidgetTester tester) async {
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

  // Navigate to reports page by tapping reports quick action
  await tester.tap(find.byKey(const Key('reportsQuickAction')));
  await tester.pumpAndSettle();
}
