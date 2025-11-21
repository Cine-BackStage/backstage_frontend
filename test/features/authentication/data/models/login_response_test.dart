import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/authentication/data/models/login_response.dart';
import 'package:backstage_frontend/features/authentication/data/models/employee_model.dart';

void main() {
  const tEmployeeModel = EmployeeModel(
    cpf: '123.456.789-00',
    companyId: 'comp-123',
    employeeId: '12345',
    role: 'cashier',
    fullName: 'John Doe',
    email: 'john@example.com',
    isActive: true,
  );

  const tToken = 'test_token_123';

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'token': tToken,
        'employee': {
          'cpf': '123.456.789-00',
          'companyId': 'comp-123',
          'employeeId': '12345',
          'role': 'cashier',
          'fullName': 'John Doe',
          'email': 'john@example.com',
          'isActive': true,
        },
      };

      // Act
      final result = LoginResponse.fromJson(jsonMap);

      // Assert
      expect(result.token, equals(tToken));
      expect(result.employee, equals(tEmployeeModel));
    });
  });
}
