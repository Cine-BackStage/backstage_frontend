import 'package:flutter/foundation.dart';

class LoggerService {
  static final LoggerService _instance = LoggerService._internal();

  factory LoggerService() => _instance;

  LoggerService._internal();

  void logDataSourceRequest(String dataSource, String method, Map<String, dynamic>? data) {
    if (kDebugMode) {
      print('[$dataSource] REQUEST: $method ${data != null ? '- Data: $data' : ''}');
    }
  }

  void logDataSourceResponse(String dataSource, String method, dynamic response) {
    if (kDebugMode) {
      print('[$dataSource] RESPONSE: $method - ${response.toString()}');
    }
  }

  void logDataSourceError(String dataSource, String method, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('[$dataSource] ERROR: $method - $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }

  void logException(String context, Object error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      print('EXCEPTION [$context]: $error');
      if (stackTrace != null) {
        print('StackTrace: $stackTrace');
      }
    }
  }
}
