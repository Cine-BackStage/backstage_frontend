import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../repositories/profile_repository.dart';

abstract class GetEmployeeProfileUseCase {
  Future<Either<Failure, Employee>> call(NoParams params);
}

class GetEmployeeProfileUseCaseImpl implements GetEmployeeProfileUseCase {
  final ProfileRepository repository;

  GetEmployeeProfileUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Employee>> call(NoParams params) async {
    return await repository.getEmployeeProfile();
  }
}
