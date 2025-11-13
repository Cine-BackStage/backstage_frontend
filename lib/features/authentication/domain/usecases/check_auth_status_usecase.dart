import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

/// Check authentication status use case interface
abstract class CheckAuthStatusUseCase {
  Future<Either<Failure, bool>> call(NoParams params);
}

/// Check authentication status use case implementation
class CheckAuthStatusUseCaseImpl implements CheckAuthStatusUseCase {
  final AuthRepository repository;

  CheckAuthStatusUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, bool>> call(NoParams params) async {
    return await repository.isAuthenticated();
  }
}
