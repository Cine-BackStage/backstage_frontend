import 'package:dartz/dartz.dart';
import '../errors/auth_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Logout use case
class LogoutUseCase {
  final AuthRepository repository;

  const LogoutUseCase(this.repository);

  Future<Either<AuthException, void>> call() async {
    // TODO: Add analytics event for logout
    // TODO: Clear any cached data
    return await repository.logout();
  }
}
