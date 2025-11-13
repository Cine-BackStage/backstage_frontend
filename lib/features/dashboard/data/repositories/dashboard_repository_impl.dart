import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Dashboard repository implementation
class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, DashboardStats>> getDashboardStats() async {
    try {
      final dashboardStats = await remoteDataSource.getDashboardStats();
      return Right(dashboardStats);
    } on AppException catch (e) {
      return Left(GenericFailure(
        message: e.message,
        statusCode: e.statusCode,
      ));
    } catch (e) {
      return Left(GenericFailure(
        message: 'Erro ao carregar dashboard: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, DashboardStats>> refreshDashboard() async {
    // For now, refresh is the same as getting stats
    // Could add cache invalidation logic here if needed
    return getDashboardStats();
  }
}
