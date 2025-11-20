import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/settings.dart';
import '../repositories/profile_repository.dart';

abstract class GetSettingsUseCase {
  Future<Either<Failure, Settings>> call(NoParams params);
}

class GetSettingsUseCaseImpl implements GetSettingsUseCase {
  final ProfileRepository repository;

  GetSettingsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Settings>> call(NoParams params) async {
    return await repository.getSettings();
  }
}
