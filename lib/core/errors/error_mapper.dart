import 'package:dio/dio.dart';
import 'failures.dart';

/// Maps Dio exceptions and API errors to specific Failure types
class ErrorMapper {
  /// Convert DioException to appropriate Failure type
  static Failure fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          technicalMessage: error.message,
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          technicalMessage: error.message ?? 'Connection error',
        );

      case DioExceptionType.badResponse:
        return _mapResponseError(error.response);

      case DioExceptionType.cancel:
        return const GenericFailure(
          message: 'Requisição cancelada',
        );

      case DioExceptionType.unknown:
        // Check if it's a network error
        if (error.message?.contains('SocketException') ?? false) {
          return NetworkFailure(
            technicalMessage: error.message,
          );
        }
        return GenericFailure(
          message: 'Erro desconhecido',
          technicalMessage: error.message,
        );

      default:
        return GenericFailure(
          message: 'Erro inesperado',
          technicalMessage: error.message,
        );
    }
  }

  /// Map HTTP response errors to specific Failure types
  static Failure _mapResponseError(Response? response) {
    if (response == null) {
      return const GenericFailure(
        message: 'Resposta inválida do servidor',
      );
    }

    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    // Extract message from response
    String message = 'Erro na requisição';
    String? technicalMessage;

    if (data is Map<String, dynamic>) {
      message = data['message'] as String? ??
                data['error'] as String? ??
                message;
      technicalMessage = data['details'] as String?;
    }

    // Map based on status code
    switch (statusCode) {
      case 400:
        // Check if it's a validation error
        if (data is Map<String, dynamic> && data.containsKey('errors')) {
          final errors = data['errors'];
          Map<String, List<String>>? validationErrors;

          if (errors is Map) {
            validationErrors = {};
            errors.forEach((key, value) {
              if (value is List) {
                validationErrors![key as String] =
                    value.map((e) => e.toString()).toList();
              } else {
                validationErrors![key as String] = [value.toString()];
              }
            });
          }

          return ValidationFailure(
            message: message,
            technicalMessage: technicalMessage,
            validationErrors: validationErrors,
          );
        }
        return ValidationFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 401:
        return UnauthorizedFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 403:
        return ForbiddenFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 404:
        return NotFoundFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 409:
        return ConflictFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 422:
        // Unprocessable entity - typically validation errors
        return ValidationFailure(
          message: message,
          technicalMessage: technicalMessage,
        );

      case 500:
      case 501:
      case 502:
      case 503:
      case 504:
        return ServerFailure(
          message: message,
          technicalMessage: technicalMessage,
          statusCode: statusCode,
        );

      default:
        if (statusCode >= 400 && statusCode < 500) {
          return GenericFailure(
            message: message,
            technicalMessage: technicalMessage,
            statusCode: statusCode,
          );
        } else if (statusCode >= 500) {
          return ServerFailure(
            message: message,
            technicalMessage: technicalMessage,
            statusCode: statusCode,
          );
        }

        return GenericFailure(
          message: message,
          technicalMessage: technicalMessage,
          statusCode: statusCode,
        );
    }
  }

  /// Convert generic exceptions to Failure
  static Failure fromException(dynamic error) {
    if (error is DioException) {
      return fromDioException(error);
    }

    if (error is TypeError || error is FormatException) {
      return DataFailure(
        technicalMessage: error.toString(),
      );
    }

    return GenericFailure(
      message: 'Erro inesperado',
      technicalMessage: error.toString(),
    );
  }
}
