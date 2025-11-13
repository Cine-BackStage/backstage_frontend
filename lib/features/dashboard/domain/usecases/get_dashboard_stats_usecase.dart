import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Get dashboard statistics use case interface
abstract class GetDashboardStatsUseCase {
  Future<Either<Failure, DashboardStats>> call(NoParams params);
}

/// Get dashboard statistics use case implementation
class GetDashboardStatsUseCaseImpl implements GetDashboardStatsUseCase {
  final DashboardRepository repository;

  GetDashboardStatsUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.getDashboardStats();
  }
}
