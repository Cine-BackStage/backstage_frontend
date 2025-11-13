import 'employee_model.dart';

/// Login response model
class LoginResponse {
  final String token;
  final EmployeeModel employee;

  LoginResponse({
    required this.token,
    required this.employee,
  });

  /// Create from JSON (backend response)
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String,
      employee: EmployeeModel.fromJson(json['employee'] as Map<String, dynamic>),
    );
  }
}
