import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/settings.dart';
import '../repositories/profile_repository.dart';

abstract class UpdateSettingsUseCase {
  Future<Either<Failure, void>> call(UpdateSettingsParams params);
}

class UpdateSettingsUseCaseImpl implements UpdateSettingsUseCase {
  final ProfileRepository repository;

  UpdateSettingsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateSettingsParams params) async {
    return await repository.updateSettings(params.settings);
  }
}

class UpdateSettingsParams {
  final Settings settings;

  UpdateSettingsParams({required this.settings});
}
