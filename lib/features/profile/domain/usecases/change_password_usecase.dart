import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/profile_repository.dart';

abstract class ChangePasswordUseCase {
  Future<Either<Failure, void>> call(ChangePasswordParams params);
}

class ChangePasswordUseCaseImpl implements ChangePasswordUseCase {
  final ProfileRepository repository;

  ChangePasswordUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(ChangePasswordParams params) async {
    return await repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class ChangePasswordParams {
  final String currentPassword;
  final String newPassword;

  ChangePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });
}
