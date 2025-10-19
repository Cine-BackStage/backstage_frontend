import 'package:dartz/dartz.dart';
import '../errors/auth_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Request password reset use case
class RequestPasswordResetUseCase {
  final AuthRepository repository;

  const RequestPasswordResetUseCase(this.repository);

  Future<Either<AuthException, void>> call(String cpf) async {
    // TODO: Add CPF validation
    // TODO: Add rate limiting for password reset requests
    // TODO: Send email/SMS with reset link
    return await repository.requestPasswordReset(cpf);
  }
}
