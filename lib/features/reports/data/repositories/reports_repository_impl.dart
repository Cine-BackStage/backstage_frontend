import 'package:dartz/dartz.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/detailed_sales_report.dart';
import '../../domain/entities/employee_report.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/ticket_sales_report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../datasources/reports_remote_datasource.dart';

/// Reports repository implementation
class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, SalesSummary>> getSalesSummary() async {
    try {
      final summary = await remoteDataSource.getSalesSummary();
      return Right(summary);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, DetailedSalesReport>> getDetailedSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? cashierCpf,
  }) async {
    try {
      final report = await remoteDataSource.getDetailedSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
        cashierCpf: cashierCpf,
      );
      return Right(report);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, TicketSalesReport>> getTicketSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? movieId,
    String? employeeCpf,
  }) async {
    try {
      final report = await remoteDataSource.getTicketSalesReport(
        startDate: startDate,
        endDate: endDate,
        groupBy: groupBy,
        movieId: movieId,
        employeeCpf: employeeCpf,
      );
      return Right(report);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, EmployeeReport>> getEmployeeReport({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeCpf,
  }) async {
    try {
      final report = await remoteDataSource.getEmployeeReport(
        startDate: startDate,
        endDate: endDate,
        employeeCpf: employeeCpf,
      );
      return Right(report);
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
