import 'package:equatable/equatable.dart';

/// Reports events
abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Load sales summary
class LoadSalesSummary extends ReportsEvent {
  const LoadSalesSummary();
}

/// Load detailed sales report
class LoadDetailedSalesReport extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final String? cashierCpf;

  const LoadDetailedSalesReport({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    this.cashierCpf,
  });

  @override
  List<Object?> get props => [startDate, endDate, groupBy, cashierCpf];
}

/// Load ticket sales report
class LoadTicketSalesReport extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String groupBy;
  final String? movieId;
  final String? employeeCpf;

  const LoadTicketSalesReport({
    required this.startDate,
    required this.endDate,
    required this.groupBy,
    this.movieId,
    this.employeeCpf,
  });

  @override
  List<Object?> get props => [startDate, endDate, groupBy, movieId, employeeCpf];
}

/// Load employee report
class LoadEmployeeReport extends ReportsEvent {
  final DateTime startDate;
  final DateTime endDate;
  final String? employeeCpf;

  const LoadEmployeeReport({
    required this.startDate,
    required this.endDate,
    this.employeeCpf,
  });

  @override
  List<Object?> get props => [startDate, endDate, employeeCpf];
}

/// Reset reports state
class ResetReportsState extends ReportsEvent {
  const ResetReportsState();
}
