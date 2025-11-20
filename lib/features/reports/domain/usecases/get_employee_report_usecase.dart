import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/employee_report.dart';
import '../repositories/reports_repository.dart';

/// Get employee report use case interface
abstract class GetEmployeeReportUseCase {
  Future<Either<Failure, EmployeeReport>> call(EmployeeReportParams params);
}

/// Get employee report use case implementation
class GetEmployeeReportUseCaseImpl implements GetEmployeeReportUseCase {
  final ReportsRepository repository;

  GetEmployeeReportUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, EmployeeReport>> call(
    EmployeeReportParams params,
  ) async {
    return await repository.getEmployeeReport(
      startDate: params.startDate,
      endDate: params.endDate,
      employeeCpf: params.employeeCpf,
    );
  }
}

/// Employee report parameters
class EmployeeReportParams {
  final DateTime startDate;
  final DateTime endDate;
  final String? employeeCpf;

  EmployeeReportParams({
    required this.startDate,
    required this.endDate,
    this.employeeCpf,
  });
}
