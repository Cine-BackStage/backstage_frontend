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

  group('Session Management Flow Integration Tests', () {
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

    testWidgets('Flow 5.1: View sessions list', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Start app and login
      await _loginAndNavigateToManagement(tester);

      // Verify management page loaded
      expect(find.text('Gerenciamento'), findsOneWidget);

      // Wait for sessions to load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify we're on sessions tab (session card should be visible)
      expect(find.byKey(const Key('session_session-uuid-1')), findsOneWidget);

      // Verify create button is available
      expect(find.byKey(const Key('createSessionButton')), findsOneWidget);
    });

    testWidgets('Flow 5.2: Create new session', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'POST',
        '/api/sessions',
        const MockResponse(
          data: PosMockResponses.createSessionResponse,
          statusCode: 201,
        ),
      );

      // After session creation, refresh will fetch updated sessions list
      mockResponses.addResponse(
        'GET',
        '/api/sessions',
        const MockResponse(
          data: {
            'success': true,
            'data': [
              // Original session
              {
                'id': 'session-uuid-1',
                'movieId': 'movie-uuid-1',
                'movieTitle': 'Inception',
                'roomId': 'room-uuid-1',
                'roomName': 'Sala 1',
                'startTime': '2025-12-15T14:00:00Z',
                'endTime': '2025-12-15T16:30:00Z',
                'language': 'Português',
                'subtitles': 'Inglês',
                'format': '2D',
                'basePrice': 35.00,
                'totalSeats': 100,
                'availableSeats': 45,
                'reservedSeats': 10,
                'soldSeats': 45,
                'status': 'SCHEDULED'
              },
              // New session
              {
                'id': 'session-uuid-new',
                'movieId': 'movie-uuid-1',
                'movieTitle': 'Inception',
                'roomId': 'room-uuid-1',
                'roomName': 'Sala 1',
                'startTime': '2025-12-16T20:00:00Z',
                'endTime': '2025-12-16T22:28:00Z',
                'language': 'Português',
                'subtitles': 'Inglês',
                'format': '2D',
                'basePrice': 35.00,
                'totalSeats': 100,
                'availableSeats': 100,
                'status': 'SCHEDULED'
              }
            ]
          },
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Give extra time for movies and rooms blocs to load in background
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap create session button
      await tester.tap(find.byKey(const Key('createSessionButton')));

      // Manually pump to open dialog and wait for data, avoiding infinite animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for blocs to load data - up to 30 seconds
      bool dropdownFound = false;
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('movieDropdown')).evaluate().isNotEmpty) {
          dropdownFound = true;
          break;
        }
      }

      // If still not found, fail with helpful message
      if (!dropdownFound) {
        fail('movieDropdown not found after 30 seconds - blocs may not be loading');
      }

      // Verify session form dialog appears with dropdowns loaded
      expect(find.byKey(const Key('movieDropdown')), findsOneWidget);
      expect(find.byKey(const Key('roomDropdown')), findsOneWidget);

      // Select movie
      await tester.tap(find.byKey(const Key('movieDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Inception (148min)').last);
      await tester.pumpAndSettle();

      // Select room
      await tester.tap(find.byKey(const Key('roomDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sala 1 - 2D (100 assentos)').last);
      await tester.pumpAndSettle();

      // Save session
      await tester.tap(find.byKey(const Key('saveSessionButton')));
      await tester.pumpAndSettle();

      // Wait for success and refresh
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify dialog closed by checking dropdowns are gone
      expect(find.byKey(const Key('movieDropdown')), findsNothing);
    });

    testWidgets('Flow 5.3: Edit existing session', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'PUT',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.updateSessionResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Give extra time for movies and rooms blocs to load in background
      for (int i = 0; i < 30; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Tap edit button on first session
      await tester.tap(find.byKey(const Key('editSession_session-uuid-1')));

      // Manually pump to open dialog and wait for data, avoiding infinite animation
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for blocs to load data - up to 30 seconds
      bool dropdownFound = false;
      for (int i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 500));
        if (find.byKey(const Key('movieDropdown')).evaluate().isNotEmpty) {
          dropdownFound = true;
          break;
        }
      }

      // If still not found, fail with helpful message
      if (!dropdownFound) {
        fail('movieDropdown not found after 30 seconds - blocs may not be loading');
      }

      // Verify edit dialog appears with form fields loaded
      expect(find.byKey(const Key('movieDropdown')), findsOneWidget);
      expect(find.byKey(const Key('roomDropdown')), findsOneWidget);
      expect(find.byKey(const Key('timeField')), findsOneWidget);

      // Change time (tap time field to open picker)
      await tester.tap(find.byKey(const Key('timeField')));
      await tester.pumpAndSettle();

      // Tap OK on time picker to confirm selection
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Save changes
      await tester.tap(find.byKey(const Key('saveSessionButton')));
      await tester.pumpAndSettle();

      // Wait for update to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed by checking dropdowns are gone
      expect(find.byKey(const Key('movieDropdown')), findsNothing);
    });

    testWidgets('Flow 5.4: Delete session', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'DELETE',
        '/api/sessions/session-uuid-1',
        const MockResponse(
          data: PosMockResponses.deleteSessionResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Tap delete button on first session
      await tester.tap(find.byKey(const Key('deleteSession_session-uuid-1')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byKey(const Key('deleteConfirmDialog')), findsOneWidget);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirmDeleteButton')));
      await tester.pumpAndSettle();

      // Wait for delete to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.text('Confirmar Exclusão'), findsNothing);
    });

    testWidgets('Flow 5.5: View movies list', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Movies tab
      await tester.tap(find.byKey(const Key('moviesTab')));
      await tester.pumpAndSettle();

      // Verify movies tab loaded
      expect(find.byKey(const Key('movie_movie-uuid-1')), findsOneWidget);
      expect(find.text('Inception'), findsOneWidget);
      expect(find.byKey(const Key('createMovieButton')), findsOneWidget);
    });

    testWidgets('Flow 5.6: Create new movie', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'POST',
        '/api/movies',
        const MockResponse(
          data: PosMockResponses.createMovieResponse,
          statusCode: 201,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Movies tab
      await tester.tap(find.byKey(const Key('moviesTab')));
      await tester.pumpAndSettle();

      // Tap create movie button
      await tester.tap(find.byKey(const Key('createMovieButton')));
      await tester.pumpAndSettle();

      // Fill in movie form
      await tester.enterText(
        find.byKey(const Key('movieTitleField')),
        'The Dark Knight',
      );
      await tester.enterText(
        find.byKey(const Key('movieDurationField')),
        '152',
      );
      await tester.enterText(
        find.byKey(const Key('movieGenreField')),
        'Action',
      );

      // Select rating - tap dropdown to open
      await tester.tap(find.byKey(const Key('movieRatingDropdown')));
      await tester.pumpAndSettle();

      // Tap the rating option - it should be in the dropdown menu overlay
      await tester.tap(find.text('10 - 10 anos').hitTestable());
      await tester.pumpAndSettle();

      // Save movie
      await tester.tap(find.byKey(const Key('saveMovieButton')));
      await tester.pumpAndSettle();

      // Wait for save to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('movieTitleField')), findsNothing);
    });

    testWidgets('Flow 5.7: Delete movie', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'DELETE',
        '/api/movies/movie-uuid-1',
        const MockResponse(
          data: PosMockResponses.deleteMovieResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Movies tab
      await tester.tap(find.byKey(const Key('moviesTab')));
      await tester.pumpAndSettle();

      // Tap delete button on first movie
      await tester.tap(find.byKey(const Key('deleteMovie_movie-uuid-1')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byKey(const Key('deleteMovieConfirmDialog')), findsOneWidget);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirmDeleteMovieButton')));
      await tester.pumpAndSettle();

      // Wait for delete to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('deleteMovieConfirmDialog')), findsNothing);
    });

    testWidgets('Flow 5.8: View rooms list', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Rooms tab
      await tester.tap(find.byKey(const Key('roomsTab')));
      await tester.pumpAndSettle();

      // Verify rooms tab loaded
      expect(find.byKey(const Key('room_room-uuid-1')), findsOneWidget);
      expect(find.text('Sala 1'), findsOneWidget);
      expect(find.byKey(const Key('createRoomButton')), findsOneWidget);
    });

    testWidgets('Flow 5.9: Create new room', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'POST',
        '/api/rooms',
        const MockResponse(
          data: PosMockResponses.createRoomResponse,
          statusCode: 201,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Rooms tab
      await tester.tap(find.byKey(const Key('roomsTab')));
      await tester.pumpAndSettle();

      // Tap create room button
      await tester.tap(find.byKey(const Key('createRoomButton')));
      await tester.pumpAndSettle();

      // Fill in room form
      await tester.enterText(
        find.byKey(const Key('roomNameField')),
        'Sala 3',
      );

      // Select room type (2D is default, but let's tap it to be explicit)
      await tester.tap(find.byKey(const Key('roomType_TWO_D')));
      await tester.pumpAndSettle();

      // Save room
      await tester.tap(find.byKey(const Key('saveRoomButton')));
      await tester.pumpAndSettle();

      // Wait for save to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('roomNameField')), findsNothing);
    });

    testWidgets('Flow 5.10: Delete room', (tester) async {
      // Setup mocks
      _setupBasicMocks(mockResponses);

      mockResponses.addResponse(
        'DELETE',
        '/api/rooms/room-uuid-1',
        const MockResponse(
          data: PosMockResponses.deleteRoomResponse,
          statusCode: 200,
        ),
      );

      // Login and navigate
      await _loginAndNavigateToManagement(tester);
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Switch to Rooms tab
      await tester.tap(find.byKey(const Key('roomsTab')));
      await tester.pumpAndSettle();

      // Tap delete button on first room
      await tester.tap(find.byKey(const Key('deleteRoom_room-uuid-1')));
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.byKey(const Key('deleteRoomConfirmDialog')), findsOneWidget);
      expect(find.text('Confirmar Exclusão'), findsOneWidget);

      // Confirm deletion
      await tester.tap(find.byKey(const Key('confirmDeleteRoomButton')));
      await tester.pumpAndSettle();

      // Wait for delete to complete
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verify dialog closed
      expect(find.byKey(const Key('deleteRoomConfirmDialog')), findsNothing);
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
      data: DashboardMockResponses.inventoryResponse,
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

Future<void> _loginAndNavigateToManagement(WidgetTester tester) async {
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

  // Navigate to management page by tapping sessions quick action
  await tester.tap(find.byKey(const Key('sessionsQuickAction')));
  await tester.pumpAndSettle();
}
