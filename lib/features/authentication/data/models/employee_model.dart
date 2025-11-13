import '../../domain/entities/employee.dart';

/// Employee data model (extends domain entity)
class EmployeeModel extends Employee {
  const EmployeeModel({
    required super.cpf,
    required super.companyId,
    required super.employeeId,
    required super.role,
    required super.fullName,
    required super.email,
    required super.isActive,
  });

  /// Create model from JSON (backend response)
  factory EmployeeModel.fromJson(Map<String, dynamic> json) {
    return EmployeeModel(
      cpf: json['cpf'] as String,
      companyId: json['companyId'] as String,
      employeeId: json['employeeId'] as String,
      role: json['role'] as String,
      fullName: json['fullName'] as String,
      email: json['email'] as String,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  /// Convert model to JSON (for storage)
  Map<String, dynamic> toJson() {
    return {
      'cpf': cpf,
      'companyId': companyId,
      'employeeId': employeeId,
      'role': role,
      'fullName': fullName,
      'email': email,
      'isActive': isActive,
    };
  }

  /// Create model from domain entity
  factory EmployeeModel.fromEntity(Employee employee) {
    return EmployeeModel(
      cpf: employee.cpf,
      companyId: employee.companyId,
      employeeId: employee.employeeId,
      role: employee.role,
      fullName: employee.fullName,
      email: employee.email,
      isActive: employee.isActive,
    );
  }
}
