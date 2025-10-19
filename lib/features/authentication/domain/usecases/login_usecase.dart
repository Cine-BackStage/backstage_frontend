import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../entities/credentials.dart';
import '../errors/auth_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Login use case
class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<AuthException, User>> call(Credentials credentials) async {
    // TODO: Add input validation before calling repository
    // TODO: Add rate limiting for failed login attempts
    return await repository.login(credentials);
  }
}
