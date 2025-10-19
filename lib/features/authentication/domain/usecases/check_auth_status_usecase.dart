import 'package:dartz/dartz.dart';
import '../entities/user.dart';
import '../errors/auth_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Check authentication status use case
class CheckAuthStatusUseCase {
  final AuthRepository repository;

  const CheckAuthStatusUseCase(this.repository);

  Future<Either<AuthException, User?>> call() async {
    // TODO: Add token refresh logic if token is about to expire
    return await repository.checkAuthStatus();
  }
}
