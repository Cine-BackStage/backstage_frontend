import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/employee.dart';
import '../repositories/auth_repository.dart';

/// Get current employee use case interface
abstract class GetCurrentEmployeeUseCase {
  Future<Either<Failure, Employee>> call(NoParams params);
}

/// Get current employee use case implementation
class GetCurrentEmployeeUseCaseImpl implements GetCurrentEmployeeUseCase {
  final AuthRepository repository;

  GetCurrentEmployeeUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Employee>> call(NoParams params) async {
    return await repository.getCurrentEmployee();
  }
}
