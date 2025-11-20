import 'package:equatable/equatable.dart';
import '../../domain/entities/detailed_sales_report.dart';
import '../../domain/entities/employee_report.dart';
import '../../domain/entities/sales_summary.dart';
import '../../domain/entities/ticket_sales_report.dart';

/// Reports state
abstract class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];

  /// Pattern matching method
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(SalesSummary summary) salesSummaryLoaded,
    required T Function(DetailedSalesReport report) detailedSalesLoaded,
    required T Function(TicketSalesReport report) ticketSalesLoaded,
    required T Function(EmployeeReport report) employeeReportLoaded,
    required T Function(String message) error,
  }) {
    if (this is ReportsInitial) {
      return initial();
    } else if (this is ReportsLoading) {
      return loading();
    } else if (this is SalesSummaryLoaded) {
      return salesSummaryLoaded((this as SalesSummaryLoaded).summary);
    } else if (this is DetailedSalesLoaded) {
      return detailedSalesLoaded((this as DetailedSalesLoaded).report);
    } else if (this is TicketSalesLoaded) {
      return ticketSalesLoaded((this as TicketSalesLoaded).report);
    } else if (this is EmployeeReportLoaded) {
      return employeeReportLoaded((this as EmployeeReportLoaded).report);
    } else if (this is ReportsError) {
      return error((this as ReportsError).message);
    }
    throw Exception('Unknown ReportsState: $this');
  }

  /// Pattern matching with nullable return
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(SalesSummary summary)? salesSummaryLoaded,
    T Function(DetailedSalesReport report)? detailedSalesLoaded,
    T Function(TicketSalesReport report)? ticketSalesLoaded,
    T Function(EmployeeReport report)? employeeReportLoaded,
    T Function(String message)? error,
  }) {
    if (this is ReportsInitial && initial != null) {
      return initial();
    } else if (this is ReportsLoading && loading != null) {
      return loading();
    } else if (this is SalesSummaryLoaded && salesSummaryLoaded != null) {
      return salesSummaryLoaded((this as SalesSummaryLoaded).summary);
    } else if (this is DetailedSalesLoaded && detailedSalesLoaded != null) {
      return detailedSalesLoaded((this as DetailedSalesLoaded).report);
    } else if (this is TicketSalesLoaded && ticketSalesLoaded != null) {
      return ticketSalesLoaded((this as TicketSalesLoaded).report);
    } else if (this is EmployeeReportLoaded && employeeReportLoaded != null) {
      return employeeReportLoaded((this as EmployeeReportLoaded).report);
    } else if (this is ReportsError && error != null) {
      return error((this as ReportsError).message);
    }
    return null;
  }

  /// Pattern matching with default case
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(SalesSummary summary)? salesSummaryLoaded,
    T Function(DetailedSalesReport report)? detailedSalesLoaded,
    T Function(TicketSalesReport report)? ticketSalesLoaded,
    T Function(EmployeeReport report)? employeeReportLoaded,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is ReportsInitial && initial != null) {
      return initial();
    } else if (this is ReportsLoading && loading != null) {
      return loading();
    } else if (this is SalesSummaryLoaded && salesSummaryLoaded != null) {
      return salesSummaryLoaded((this as SalesSummaryLoaded).summary);
    } else if (this is DetailedSalesLoaded && detailedSalesLoaded != null) {
      return detailedSalesLoaded((this as DetailedSalesLoaded).report);
    } else if (this is TicketSalesLoaded && ticketSalesLoaded != null) {
      return ticketSalesLoaded((this as TicketSalesLoaded).report);
    } else if (this is EmployeeReportLoaded && employeeReportLoaded != null) {
      return employeeReportLoaded((this as EmployeeReportLoaded).report);
    } else if (this is ReportsError && error != null) {
      return error((this as ReportsError).message);
    }
    return orElse();
  }
}

/// Initial state
class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

/// Loading state
class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

/// Sales summary loaded
class SalesSummaryLoaded extends ReportsState {
  final SalesSummary summary;

  const SalesSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Detailed sales report loaded
class DetailedSalesLoaded extends ReportsState {
  final DetailedSalesReport report;

  const DetailedSalesLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Ticket sales report loaded
class TicketSalesLoaded extends ReportsState {
  final TicketSalesReport report;

  const TicketSalesLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Employee report loaded
class EmployeeReportLoaded extends ReportsState {
  final EmployeeReport report;

  const EmployeeReportLoaded(this.report);

  @override
  List<Object?> get props => [report];
}

/// Error state
class ReportsError extends ReportsState {
  final String message;

  const ReportsError(this.message);

  @override
  List<Object?> get props => [message];
}
