import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/detailed_sales_report.dart';
import '../repositories/reports_repository.dart';

/// Get detailed sales report use case interface
abstract class GetDetailedSalesReportUseCase {
  Future<Either<Failure, DetailedSalesReport>> call(DetailedSalesReportParams params);
}

/// Get detailed sales report use case implementation
class GetDetailedSalesReportUseCaseImpl implements GetDetailedSalesReportUseCase {
  final ReportsRepository repository;

  GetDetailedSalesReportUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, DetailedSalesReport>> call(
    DetailedSalesReportParams params,
  ) async {
    return await repository.getDetailedSalesReport(
      startDate: params.startDate,
      endDate: params.endDate,
      groupBy: params.groupBy,
      cashierCpf: params.cashierCpf,
    );
  }
}

/// Detailed sales report parameters
class DetailedSalesReportParams {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final String? cashierCpf;

  DetailedSalesReportParams({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    this.cashierCpf,
  });
}
