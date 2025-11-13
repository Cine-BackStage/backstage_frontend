/// Login request model
class LoginRequest {
  final String employeeId;
  final String password;

  LoginRequest({
    required this.employeeId,
    required this.password,
  });

  /// Convert to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'password': password,
    };
  }
}
