import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Logout use case interface
abstract class LogoutUseCase {
  Future<Either<Failure, void>> call(NoParams params);
}

/// Logout use case implementation
class LogoutUseCaseImpl implements LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}
