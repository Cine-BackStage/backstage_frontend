import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee.dart';
import '../repositories/auth_repository.dart';

/// Login use case interface
abstract class LoginUseCase {
  Future<Either<Failure, Employee>> call(LoginParams params);
}

/// Login use case implementation
class LoginUseCaseImpl implements LoginUseCase {
  final AuthRepository repository;

  LoginUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Employee>> call(LoginParams params) async {
    return await repository.login(params.employeeId, params.password);
  }
}

/// Login parameters
class LoginParams {
  final String employeeId;
  final String password;

  LoginParams({
    required this.employeeId,
    required this.password,
  });
}
