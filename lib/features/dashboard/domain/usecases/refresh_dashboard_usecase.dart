import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/dashboard_stats.dart';
import '../repositories/dashboard_repository.dart';

/// Refresh dashboard use case interface
abstract class RefreshDashboardUseCase {
  Future<Either<Failure, DashboardStats>> call(NoParams params);
}

/// Refresh dashboard use case implementation
class RefreshDashboardUseCaseImpl implements RefreshDashboardUseCase {
  final DashboardRepository repository;

  RefreshDashboardUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, DashboardStats>> call(NoParams params) async {
    return await repository.refreshDashboard();
  }
}
