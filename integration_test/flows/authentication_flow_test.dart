import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:backstage_frontend/adapters/dependency_injection/injection_container.dart';
import 'package:backstage_frontend/main.dart' as app;

import '../mocks/mock_http_client.dart';
import '../helpers/mock_responses.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Authentication Flow Integration Tests', () {
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
    });

    tearDown(() async {
      mockHttpClient.clearMocks();
      await GetIt.instance.reset();
    });

    testWidgets('Flow 1.1: Successful login and logout', (tester) async {
      // Setup mock response for successful login
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.successfulLoginResponse,
          statusCode: 200,
        ),
      );

      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Wait for splash screen to complete (if any)
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);

      // Enter employee ID
      await tester.enterText(
        find.byKey(const Key('employeeIdField')),
        'EMP001',
      );
      await tester.pump();

      // Enter password
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.pump();

      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Verify loading indicator appears
      expect(find.byKey(const Key('loginLoadingIndicator')), findsOneWidget);
      await tester.pumpAndSettle();

      // Wait for navigation to dashboard
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify we navigated to dashboard
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.byKey(const Key('logoutButton')), findsOneWidget);

      // Verify welcome snackbar appeared (it might already be dismissed)
      // Note: Snackbar might not be visible anymore, so we don't strictly test for it

      // Test logout
      await tester.tap(find.byKey(const Key('logoutButton')));
      await tester.pumpAndSettle();

      // Wait for navigation back to login
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify we're back on login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('loginButton')), findsOneWidget);
    });

    testWidgets('Flow 1.2: Login with invalid credentials', (tester) async {
      // Setup mock response for invalid credentials
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.invalidCredentialsResponse,
          statusCode: 401,
        ),
      );

      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);

      // Enter invalid credentials
      await tester.enterText(
        find.byKey(const Key('employeeIdField')),
        'INVALID',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'wrongpassword',
      );
      await tester.pump();

      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Wait for error response
      await tester.pumpAndSettle();

      // Verify we're still on login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);

      // Verify error snackbar appeared
      expect(
        find.textContaining('Erro ao fazer login'),
        findsOneWidget,
        reason: 'Error snackbar should be displayed',
      );
    });

    testWidgets('Flow 1.3: Login with empty fields shows validation errors',
        (tester) async {
      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on the login page
      expect(find.byKey(const Key('loginButton')), findsOneWidget);

      // Tap login button without entering any data
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pumpAndSettle();

      // Verify validation error messages appear
      expect(
        find.textContaining('obrigatório'),
        findsWidgets,
        reason: 'Validation errors should be displayed for empty fields',
      );

      // Verify we're still on login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
    });

    testWidgets('Flow 1.4: Login with server error (500)', (tester) async {
      // Setup mock response for server error
      mockResponses.addResponse(
        'POST',
        '/api/employees/login',
        const MockResponse(
          data: AuthMockResponses.serverErrorResponse,
          statusCode: 500,
        ),
      );

      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter credentials
      await tester.enterText(
        find.byKey(const Key('employeeIdField')),
        'EMP001',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.pump();

      // Tap login button
      await tester.tap(find.byKey(const Key('loginButton')));
      await tester.pump();

      // Wait for error response
      await tester.pumpAndSettle();

      // Verify we're still on login page
      expect(find.byKey(const Key('employeeIdField')), findsOneWidget);

      // Verify error message is displayed
      expect(
        find.textContaining('Erro'),
        findsWidgets,
        reason: 'Error message should be displayed for server error',
      );
    });

    testWidgets('Flow 1.5: Password visibility toggle works', (tester) async {
      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Wait for splash screen
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter password
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'password123',
      );
      await tester.pump();

      // Find the password field
      final passwordField = tester.widget<TextFormField>(
        find.byKey(const Key('passwordField')),
      );

      // Verify password is obscured initially
      expect(passwordField.obscureText, isTrue);

      // Find and tap the visibility toggle icon
      final visibilityIcon = find.descendant(
        of: find.byKey(const Key('passwordField')),
        matching: find.byType(IconButton),
      );
      await tester.tap(visibilityIcon);
      await tester.pump();

      // Get the updated password field
      final updatedPasswordField = tester.widget<TextFormField>(
        find.byKey(const Key('passwordField')),
      );

      // Verify password is now visible
      expect(updatedPasswordField.obscureText, isFalse);
    });
  });
}
