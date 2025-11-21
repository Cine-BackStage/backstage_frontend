# Integration Tests

This directory contains integration tests for the Backstage Cinema frontend application. These tests simulate real user flows with mocked API responses.

## Structure

```
integration_test/
├── flows/                          # Integration test flows
│   └── authentication_flow_test.dart
├── mocks/                          # Mock HTTP client
│   └── mock_http_client.dart
├── helpers/                        # Test helpers and mock data
│   └── mock_responses.dart
└── README.md
```

## Running Integration Tests

### Run all integration tests

```bash
flutter test integration_test/
```

### Run specific flow test

```bash
flutter test integration_test/flows/authentication_flow_test.dart
```

### Run on specific device

```bash
# Android
flutter test integration_test/ -d android

# iOS
flutter test integration_test/ -d ios

# Chrome
flutter test integration_test/ -d chrome
```

## Test Flows

### Flow 1: Authentication Flow

**File:** `flows/authentication_flow_test.dart`

**Tests:**
- ✅ Flow 1.1: Successful login and logout
- ✅ Flow 1.2: Login with invalid credentials
- ✅ Flow 1.3: Login with empty fields shows validation errors
- ✅ Flow 1.4: Login with server error (500)
- ✅ Flow 1.5: Password visibility toggle works

**Coverage:**
- Login page interactions
- Form validation
- API error handling
- Navigation to dashboard
- Logout functionality

## Writing New Integration Tests

### 1. Create test file

Create a new file in `integration_test/flows/` following the naming pattern `<feature>_flow_test.dart`.

### 2. Setup mock responses

Define mock API responses in `helpers/mock_responses.dart`:

```dart
class MyFeatureMockResponses {
  static const successResponse = {
    'success': true,
    'data': {
      // your mock data
    }
  };
}
```

### 3. Write test

```dart
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

  group('My Feature Flow Integration Tests', () {
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
      mockHttpClient = MockHttpClient(
        dio: dio,
        mockResponses: mockResponses,
      );

      await InjectionContainer.init(dioForTesting: dio);
    });

    tearDown() async {
      mockHttpClient.clearMocks();
      await GetIt.instance.reset();
    });

    testWidgets('My test case', (tester) async {
      // Setup mock response
      mockResponses.addResponse(
        'GET',
        '/api/endpoint',
        const MockResponse(
          data: MyFeatureMockResponses.successResponse,
          statusCode: 200,
        ),
      );

      // Start app
      await tester.pumpWidget(const app.BackstageApp());
      await tester.pumpAndSettle();

      // Your test actions...
    });
  });
}
```

## Widget Keys

All interactive widgets should have keys for testing. Keys are defined using the pattern:

```dart
Key('<widgetName><Type>')
```

Examples:
- `Key('loginButton')`
- `Key('employeeIdField')`
- `Key('productList')`
- `Key('product_${sku}')` (for dynamic widgets)

## Best Practices

1. **Always use widget keys** for interactive elements
2. **Mock all API responses** - never make real network calls
3. **Test happy and error paths** - success and failure scenarios
4. **Use pumpAndSettle()** after async operations
5. **Clean up** in tearDown() - reset mocks and GetIt
6. **Test user flows** - not individual widgets
7. **Use meaningful test descriptions** that describe the expected behavior
8. **Group related tests** using `group()`

## Debugging

### Enable verbose logging

```bash
flutter test integration_test/ --verbose
```

### View test output

Mock HTTP requests and responses are logged with emojis:
- 🧪 Mock HTTP Request
- ✅ Mock Response
- ❌ No mock response found / Error

### Common Issues

**Issue:** Test fails with "No mock response found"
**Solution:** Make sure you've added the mock response with the correct HTTP method and path.

**Issue:** Widget not found
**Solution:**
- Add a Key to the widget
- Use `await tester.pumpAndSettle()` to wait for async operations
- Check if the widget is actually rendered (might be conditional)

**Issue:** Navigation doesn't work
**Solution:** Make sure to call `await tester.pumpAndSettle()` after navigation actions.

## CI/CD Integration

Integration tests can be run in CI/CD pipelines:

```yaml
# GitHub Actions example
- name: Run integration tests
  run: flutter test integration_test/
```

## Future Improvements

- [ ] Add more flows (POS, Sessions, Inventory, etc.)
- [ ] Screenshot testing
- [ ] Performance testing
- [ ] Accessibility testing
- [ ] Test report generation
