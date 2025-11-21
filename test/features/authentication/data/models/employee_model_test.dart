import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/authentication/data/models/employee_model.dart';
import 'package:backstage_frontend/features/authentication/domain/entities/employee.dart';

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

  test('should be a subclass of Employee entity', () {
    expect(tEmployeeModel, isA<Employee>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
        'companyId': 'comp-123',
        'employeeId': '12345',
        'role': 'cashier',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'isActive': true,
      };

      // Act
      final result = EmployeeModel.fromJson(jsonMap);

      // Assert
      expect(result, equals(tEmployeeModel));
    });

    test('should return model with isActive=true when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
        'companyId': 'comp-123',
        'employeeId': '12345',
        'role': 'cashier',
        'fullName': 'John Doe',
        'email': 'john@example.com',
      };

      // Act
      final result = EmployeeModel.fromJson(jsonMap);

      // Assert
      expect(result.isActive, true);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tEmployeeModel.toJson();

      // Assert
      final expectedMap = {
        'cpf': '123.456.789-00',
        'companyId': 'comp-123',
        'employeeId': '12345',
        'role': 'cashier',
        'fullName': 'John Doe',
        'email': 'john@example.com',
        'isActive': true,
      };
      expect(result, equals(expectedMap));
    });
  });

  group('fromEntity', () {
    test('should convert Employee entity to EmployeeModel', () {
      // Arrange
      const tEmployee = Employee(
        cpf: '123.456.789-00',
        companyId: 'comp-123',
        employeeId: '12345',
        role: 'cashier',
        fullName: 'John Doe',
        email: 'john@example.com',
        isActive: true,
      );

      // Act
      final result = EmployeeModel.fromEntity(tEmployee);

      // Assert
      expect(result, equals(tEmployeeModel));
    });
  });
}
