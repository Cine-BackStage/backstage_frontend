import 'package:dio/dio.dart';
import '../storage/local_storage.dart' hide StorageKeys;
import '../../core/constants/storage_keys.dart';

/// HTTP client adapter for Backstage Cinema
class HttpClient {
  late final Dio _dio;
  final LocalStorage _storage;

  HttpClient({
    required LocalStorage storage,
    String baseUrl = 'http://localhost:3000',
  }) : _storage = storage {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authentication token to all requests
          final token = _storage.getString(StorageKeys.authToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          print('🌐 HTTP Request: ${options.method} ${options.baseUrl}${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('✅ HTTP Response: ${response.statusCode} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          print('❌ HTTP Error: ${error.response?.statusCode} ${error.requestOptions.path} - ${error.message}');

          // Handle 401 Unauthorized - token expired
          if (error.response?.statusCode == 401) {
            // Clear auth data
            await _storage.remove(StorageKeys.authToken);
            await _storage.remove(StorageKeys.userCpf);
            await _storage.remove(StorageKeys.userName);
            await _storage.remove(StorageKeys.userRole);
            await _storage.remove(StorageKeys.employeeId);
            await _storage.remove(StorageKeys.companyId);

            // This will be handled by the auth bloc listening to token changes
          }

          return handler.next(error);
        },
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}
