import 'package:equatable/equatable.dart';

/// Employee performance report entity
class EmployeeReport extends Equatable {
  final DateTime startDate;
  final DateTime endDate;
  final List<EmployeePerformance> employees;
  final EmployeeReportSummary summary;

  const EmployeeReport({
    required this.startDate,
    required this.endDate,
    required this.employees,
    required this.summary,
  });

  @override
  List<Object?> get props => [startDate, endDate, employees, summary];
}

/// Individual employee performance
class EmployeePerformance extends Equatable {
  final String cpf;
  final String name;
  final String role;
  final int salesCount;
  final double totalRevenue;
  final double averageSaleValue;
  final int hoursWorked;
  final double performance;

  const EmployeePerformance({
    required this.cpf,
    required this.name,
    required this.role,
    required this.salesCount,
    required this.totalRevenue,
    required this.averageSaleValue,
    required this.hoursWorked,
    required this.performance,
  });

  @override
  List<Object?> get props => [
        cpf,
        name,
        role,
        salesCount,
        totalRevenue,
        averageSaleValue,
        hoursWorked,
        performance,
      ];
}

/// Employee report summary
class EmployeeReportSummary extends Equatable {
  final int totalEmployees;
  final int activeCashiers;
  final double averageRevenue;
  final double totalRevenue;

  const EmployeeReportSummary({
    required this.totalEmployees,
    required this.activeCashiers,
    required this.averageRevenue,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        totalEmployees,
        activeCashiers,
        averageRevenue,
        totalRevenue,
      ];
}
