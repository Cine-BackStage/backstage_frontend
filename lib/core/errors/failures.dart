import 'package:equatable/equatable.dart';

/// Base Failure class for all errors in the app
abstract class Failure extends Equatable {
  final String message;
  final String? technicalMessage;
  final int? statusCode;

  const Failure({
    required this.message,
    this.technicalMessage,
    this.statusCode,
  });

  @override
  List<Object?> get props => [message, technicalMessage, statusCode];

  @override
  String toString() =>
      'Failure: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';

  /// Get user-friendly message based on failure type
  String get userMessage => message;

  /// Check if this is a critical error that requires immediate attention
  bool get isCritical => false;
}

/// Generic failure implementation
class GenericFailure extends Failure {
  const GenericFailure({
    required super.message,
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage => 'Ocorreu um erro inesperado. Tente novamente.';
}

/// Network connectivity failure (no internet, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Erro de conexão com a internet',
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage =>
      'Verifique sua conexão com a internet e tente novamente.';
}

/// Server error (5xx status codes)
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Erro no servidor',
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage =>
      'O servidor está temporariamente indisponível. Tente novamente em alguns instantes.';

  @override
  bool get isCritical => true;
}

/// Unauthorized error (401 status code)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'Não autorizado',
    super.technicalMessage,
    super.statusCode = 401,
  });

  @override
  String get userMessage =>
      'Sua sessão expirou. Por favor, faça login novamente.';

  @override
  bool get isCritical => true;
}

/// Forbidden error (403 status code)
class ForbiddenFailure extends Failure {
  const ForbiddenFailure({
    super.message = 'Acesso negado',
    super.technicalMessage,
    super.statusCode = 403,
  });

  @override
  String get userMessage => 'Você não tem permissão para acessar este recurso.';
}

/// Not found error (404 status code)
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'Recurso não encontrado',
    super.technicalMessage,
    super.statusCode = 404,
  });

  @override
  String get userMessage => message;
}

/// Validation error (400 status code with validation details)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? validationErrors;

  const ValidationFailure({
    super.message = 'Dados inválidos',
    super.technicalMessage,
    super.statusCode = 400,
    this.validationErrors,
  });

  @override
  List<Object?> get props => [message, technicalMessage, statusCode, validationErrors];

  @override
  String get userMessage {
    if (validationErrors != null && validationErrors!.isNotEmpty) {
      final firstError = validationErrors!.values.first.first;
      return firstError;
    }
    return message;
  }

  String getAllValidationErrors() {
    if (validationErrors == null || validationErrors!.isEmpty) {
      return message;
    }

    final errors = <String>[];
    validationErrors!.forEach((field, messages) {
      errors.addAll(messages);
    });

    return errors.join('\n');
  }
}

/// Conflict error (409 status code) - e.g., seat already taken
class ConflictFailure extends Failure {
  const ConflictFailure({
    required super.message,
    super.technicalMessage,
    super.statusCode = 409,
  });

  @override
  String get userMessage => message;
}

/// Timeout error
class TimeoutFailure extends Failure {
  const TimeoutFailure({
    super.message = 'Tempo de resposta esgotado',
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage =>
      'A requisição demorou muito para ser processada. Tente novamente.';
}

/// Data parsing/format error
class DataFailure extends Failure {
  const DataFailure({
    super.message = 'Erro ao processar dados',
    super.technicalMessage,
    super.statusCode,
  });

  @override
  String get userMessage =>
      'Ocorreu um erro ao processar os dados. Tente novamente.';
}
