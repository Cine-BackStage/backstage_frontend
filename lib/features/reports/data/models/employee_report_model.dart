import '../../domain/entities/employee_report.dart';

/// Employee report model
class EmployeeReportModel extends EmployeeReport {
  const EmployeeReportModel({
    required super.startDate,
    required super.endDate,
    required super.employees,
    required super.summary,
  });

  factory EmployeeReportModel.fromJson(Map<String, dynamic> json) {
    final period = json['period'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final employeesJson = json['employees'] as List? ?? [];

    return EmployeeReportModel(
      startDate: DateTime.parse(period['startDate'] as String),
      endDate: DateTime.parse(period['endDate'] as String),
      employees: employeesJson
          .map((item) => EmployeePerformanceModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      summary: EmployeeReportSummaryModel.fromJson(summaryJson),
    );
  }
}

/// Employee performance model
class EmployeePerformanceModel extends EmployeePerformance {
  const EmployeePerformanceModel({
    required super.cpf,
    required super.name,
    required super.role,
    required super.salesCount,
    required super.totalRevenue,
    required super.averageSaleValue,
    required super.hoursWorked,
    required super.performance,
  });

  factory EmployeePerformanceModel.fromJson(Map<String, dynamic> json) {
    return EmployeePerformanceModel(
      cpf: json['cpf'] as String,
      name: json['name'] as String? ?? json['fullName'] as String? ?? 'Unknown',
      role: json['role'] as String? ?? 'CASHIER',
      salesCount: (json['salesCount'] ?? 0) as int,
      totalRevenue: (json['totalRevenue'] ?? json['revenue'] ?? 0).toDouble(),
      averageSaleValue: (json['averageSaleValue'] ?? 0).toDouble(),
      hoursWorked: (json['hoursWorked'] ?? 0) as int,
      performance: (json['performance'] ?? 0).toDouble(),
    );
  }
}

/// Employee report summary model
class EmployeeReportSummaryModel extends EmployeeReportSummary {
  const EmployeeReportSummaryModel({
    required super.totalEmployees,
    required super.activeCashiers,
    required super.averageRevenue,
    required super.totalRevenue,
  });

  factory EmployeeReportSummaryModel.fromJson(Map<String, dynamic> json) {
    return EmployeeReportSummaryModel(
      totalEmployees: (json['totalEmployees'] ?? 0) as int,
      activeCashiers: (json['activeCashiers'] ?? 0) as int,
      averageRevenue: (json['averageRevenue'] ?? 0).toDouble(),
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}
