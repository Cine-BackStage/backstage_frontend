/// Base authentication exception
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

/// Invalid credentials exception
class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException() : super('CPF ou senha inválidos');
}

/// Token expired exception
class TokenExpiredException extends AuthException {
  const TokenExpiredException() : super('Sessão expirada. Por favor, faça login novamente.');
}

/// User not found exception
class UserNotFoundException extends AuthException {
  const UserNotFoundException() : super('Usuário não encontrado');
}

/// Network exception
class NetworkException extends AuthException {
  const NetworkException() : super('Erro de conexão. Verifique sua internet.');
}
