import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/sales_summary.dart';
import '../entities/detailed_sales_report.dart';
import '../entities/ticket_sales_report.dart';
import '../entities/employee_report.dart';

/// Reports repository interface
abstract class ReportsRepository {
  /// Get sales summary (today, week, month)
  Future<Either<Failure, SalesSummary>> getSalesSummary();

  /// Get detailed sales report with filters
  Future<Either<Failure, DetailedSalesReport>> getDetailedSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? cashierCpf,
  });

  /// Get ticket sales report
  Future<Either<Failure, TicketSalesReport>> getTicketSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? movieId,
    String? employeeCpf,
  });

  /// Get employee performance report
  Future<Either<Failure, EmployeeReport>> getEmployeeReport({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeCpf,
  });
}
