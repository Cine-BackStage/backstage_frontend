import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/reports/data/models/employee_report_model.dart';
import 'package:backstage_frontend/features/reports/domain/entities/employee_report.dart';

void main() {
  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);

  final tEmployeeReportModel = EmployeeReportModel(
    startDate: tStartDate,
    endDate: tEndDate,
    employees: const [
      EmployeePerformanceModel(
        cpf: '123.456.789-00',
        name: 'John Doe',
        role: 'CASHIER',
        salesCount: 50,
        totalRevenue: 2500.0,
        averageSaleValue: 50.0,
        hoursWorked: 160,
        performance: 85.5,
      ),
    ],
    summary: const EmployeeReportSummaryModel(
      totalEmployees: 5,
      activeCashiers: 3,
      averageRevenue: 2000.0,
      totalRevenue: 10000.0,
    ),
  );

  test('should be a subclass of EmployeeReport entity', () {
    expect(tEmployeeReportModel, isA<EmployeeReport>());
  });

  group('EmployeeReportModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'period': {
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-31T00:00:00.000',
        },
        'employees': [
          {
            'cpf': '123.456.789-00',
            'name': 'John Doe',
            'role': 'CASHIER',
            'salesCount': 50,
            'totalRevenue': 2500.0,
            'averageSaleValue': 50.0,
            'hoursWorked': 160,
            'performance': 85.5,
          },
        ],
        'summary': {
          'totalEmployees': 5,
          'activeCashiers': 3,
          'averageRevenue': 2000.0,
          'totalRevenue': 10000.0,
        },
      };

      // Act
      final result = EmployeeReportModel.fromJson(jsonMap);

      // Assert
      expect(result.startDate, equals(tStartDate));
      expect(result.endDate, equals(tEndDate));
      expect(result.employees.length, equals(1));
      expect(result.summary.totalEmployees, equals(5));
    });

    test('should handle missing period data', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'employees': [],
        'summary': {
          'totalEmployees': 0,
          'activeCashiers': 0,
          'averageRevenue': 0.0,
          'totalRevenue': 0.0,
        },
      };

      // Act & Assert
      expect(() => EmployeeReportModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
    });

    test('should handle empty employees list', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'period': {
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-31T00:00:00.000',
        },
        'employees': [],
        'summary': {
          'totalEmployees': 0,
          'activeCashiers': 0,
          'averageRevenue': 0.0,
          'totalRevenue': 0.0,
        },
      };

      // Act
      final result = EmployeeReportModel.fromJson(jsonMap);

      // Assert
      expect(result.employees.length, equals(0));
    });
  });

  group('EmployeePerformanceModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
        'name': 'John Doe',
        'role': 'CASHIER',
        'salesCount': 50,
        'totalRevenue': 2500.0,
        'averageSaleValue': 50.0,
        'hoursWorked': 160,
        'performance': 85.5,
      };

      // Act
      final result = EmployeePerformanceModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<EmployeePerformance>());
      expect(result.cpf, equals('123.456.789-00'));
      expect(result.name, equals('John Doe'));
      expect(result.role, equals('CASHIER'));
      expect(result.salesCount, equals(50));
      expect(result.totalRevenue, equals(2500.0));
      expect(result.averageSaleValue, equals(50.0));
      expect(result.hoursWorked, equals(160));
      expect(result.performance, equals(85.5));
    });

    test('should handle alternative field name "fullName"', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
        'fullName': 'Jane Smith',
        'salesCount': 30,
        'totalRevenue': 1500.0,
        'averageSaleValue': 50.0,
        'hoursWorked': 120,
        'performance': 90.0,
      };

      // Act
      final result = EmployeePerformanceModel.fromJson(jsonMap);

      // Assert
      expect(result.name, equals('Jane Smith'));
    });

    test('should handle alternative field name "revenue"', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
        'name': 'John Doe',
        'salesCount': 50,
        'revenue': 2500.0,
        'averageSaleValue': 50.0,
        'hoursWorked': 160,
        'performance': 85.5,
      };

      // Act
      final result = EmployeePerformanceModel.fromJson(jsonMap);

      // Assert
      expect(result.totalRevenue, equals(2500.0));
    });

    test('should handle missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cpf': '123.456.789-00',
      };

      // Act
      final result = EmployeePerformanceModel.fromJson(jsonMap);

      // Assert
      expect(result.name, equals('Unknown'));
      expect(result.role, equals('CASHIER'));
      expect(result.salesCount, equals(0));
      expect(result.totalRevenue, equals(0.0));
      expect(result.averageSaleValue, equals(0.0));
      expect(result.hoursWorked, equals(0));
      expect(result.performance, equals(0.0));
    });
  });

  group('EmployeeReportSummaryModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'totalEmployees': 5,
        'activeCashiers': 3,
        'averageRevenue': 2000.0,
        'totalRevenue': 10000.0,
      };

      // Act
      final result = EmployeeReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<EmployeeReportSummary>());
      expect(result.totalEmployees, equals(5));
      expect(result.activeCashiers, equals(3));
      expect(result.averageRevenue, equals(2000.0));
      expect(result.totalRevenue, equals(10000.0));
    });

    test('should handle missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = EmployeeReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.totalEmployees, equals(0));
      expect(result.activeCashiers, equals(0));
      expect(result.averageRevenue, equals(0.0));
      expect(result.totalRevenue, equals(0.0));
    });
  });
}
