import 'package:dio/dio.dart';
import '../helpers/mock_responses.dart';

/// Mock HTTP client for integration tests
/// Intercepts Dio requests and returns predefined mock responses
class MockHttpClient {
  final Dio dio;
  final MockResponses mockResponses;

  MockHttpClient({required this.dio, required this.mockResponses}) {
    _setupInterceptor();
  }

  void _setupInterceptor() {
    dio.interceptors.clear();
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          print('🧪 Mock HTTP Request: ${options.method} ${options.path}');
          print('   Data: ${options.data}');

          final mockResponse = mockResponses.getResponse(
            options.method,
            options.path,
          );

          if (mockResponse != null) {
            print('✅ Mock Response: ${mockResponse.statusCode}');
            print('   Data: ${mockResponse.data}');

            // Return mock response
            handler.resolve(
              Response(
                requestOptions: options,
                data: mockResponse.data,
                statusCode: mockResponse.statusCode,
                statusMessage: mockResponse.statusMessage,
              ),
            );
          } else {
            print('❌ No mock response found for: ${options.method} ${options.path}');
            handler.reject(
              DioException(
                requestOptions: options,
                error: 'No mock response configured for: ${options.method} ${options.path}',
                type: DioExceptionType.unknown,
              ),
            );
          }
        },
        onError: (error, handler) {
          print('❌ Mock HTTP Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  /// Clear all mock responses
  void clearMocks() {
    mockResponses.clear();
  }

  /// Add a mock response
  void addMockResponse(String method, String path, MockResponse response) {
    mockResponses.addResponse(method, path, response);
  }
}
