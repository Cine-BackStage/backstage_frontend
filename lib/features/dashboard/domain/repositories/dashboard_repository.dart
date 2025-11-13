import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/dashboard_stats.dart';

/// Dashboard repository interface
abstract class DashboardRepository {
  /// Get dashboard statistics
  Future<Either<Failure, DashboardStats>> getDashboardStats();

  /// Refresh dashboard data
  Future<Either<Failure, DashboardStats>> refreshDashboard();
}
