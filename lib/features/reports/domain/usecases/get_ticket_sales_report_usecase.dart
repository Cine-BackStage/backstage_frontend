import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ticket_sales_report.dart';
import '../repositories/reports_repository.dart';

/// Get ticket sales report use case interface
abstract class GetTicketSalesReportUseCase {
  Future<Either<Failure, TicketSalesReport>> call(TicketSalesReportParams params);
}

/// Get ticket sales report use case implementation
class GetTicketSalesReportUseCaseImpl implements GetTicketSalesReportUseCase {
  final ReportsRepository repository;

  GetTicketSalesReportUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, TicketSalesReport>> call(
    TicketSalesReportParams params,
  ) async {
    return await repository.getTicketSalesReport(
      startDate: params.startDate,
      endDate: params.endDate,
      groupBy: params.groupBy,
      movieId: params.movieId,
      employeeCpf: params.employeeCpf,
    );
  }
}

/// Ticket sales report parameters
class TicketSalesReportParams {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final String? movieId;
  final String? employeeCpf;

  TicketSalesReportParams({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    this.movieId,
    this.employeeCpf,
  });
}
