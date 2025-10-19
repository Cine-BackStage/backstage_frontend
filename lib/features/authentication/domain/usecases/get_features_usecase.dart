import 'package:dartz/dartz.dart';
import '../entities/feature_info.dart';
import '../errors/auth_exceptions.dart';
import '../repositories/auth_repository.dart';

/// Get features for carousel use case
class GetFeaturesUseCase {
  final AuthRepository repository;

  const GetFeaturesUseCase(this.repository);

  Future<Either<AuthException, List<FeatureInfo>>> call() async {
    // TODO: Add caching for features list
    // TODO: Add feature flags to dynamically show/hide features
    return await repository.getFeatures();
  }
}
