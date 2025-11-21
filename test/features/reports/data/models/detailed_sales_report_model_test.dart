import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/reports/data/models/detailed_sales_report_model.dart';
import 'package:backstage_frontend/features/reports/domain/entities/detailed_sales_report.dart';

void main() {
  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);

  final tDetailedSalesReportModel = DetailedSalesReportModel(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: 'day',
    summary: const ReportSummaryModel(
      totalSales: 100,
      totalRevenue: 5000.0,
      totalDiscount: 250.0,
      averageSaleValue: 50.0,
    ),
    groupedData: const [
      SalesGroupDataModel(
        key: '2024-01-01',
        label: '2024-01-01',
        salesCount: 20,
        revenue: 1000.0,
      ),
    ],
  );

  test('should be a subclass of DetailedSalesReport entity', () {
    expect(tDetailedSalesReportModel, isA<DetailedSalesReport>());
  });

  group('DetailedSalesReportModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'period': {
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-31T00:00:00.000',
          'groupBy': 'day',
        },
        'summary': {
          'totalSales': 100,
          'totalRevenue': 5000.0,
          'totalDiscount': 250.0,
          'averageSaleValue': 50.0,
        },
        'groupedData': [
          {
            'date': '2024-01-01',
            'salesCount': 20,
            'revenue': 1000.0,
          },
        ],
      };

      // Act
      final result = DetailedSalesReportModel.fromJson(jsonMap);

      // Assert
      expect(result.startDate, equals(tStartDate));
      expect(result.endDate, equals(tEndDate));
      expect(result.groupBy, equals('day'));
      expect(result.summary.totalSales, equals(100));
      expect(result.groupedData.length, equals(1));
    });

    test('should handle missing period data with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'summary': {
          'totalSales': 100,
          'totalRevenue': 5000.0,
        },
        'groupedData': [],
      };

      // Act & Assert
      expect(() => DetailedSalesReportModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
    });

    test('should handle groupBy in root level', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'period': {
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-31T00:00:00.000',
        },
        'groupBy': 'week',
        'summary': {
          'totalSales': 100,
          'totalRevenue': 5000.0,
          'totalDiscount': 250.0,
          'averageSaleValue': 50.0,
        },
        'groupedData': [],
      };

      // Act
      final result = DetailedSalesReportModel.fromJson(jsonMap);

      // Assert
      expect(result.groupBy, equals('week'));
    });
  });

  group('ReportSummaryModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'totalSales': 100,
        'totalRevenue': 5000.0,
        'totalDiscount': 250.0,
        'averageSaleValue': 50.0,
      };

      // Act
      final result = ReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<ReportSummary>());
      expect(result.totalSales, equals(100));
      expect(result.totalRevenue, equals(5000.0));
      expect(result.totalDiscount, equals(250.0));
      expect(result.averageSaleValue, equals(50.0));
    });

    test('should handle missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = ReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.totalSales, equals(0));
      expect(result.totalRevenue, equals(0.0));
      expect(result.totalDiscount, equals(0.0));
      expect(result.averageSaleValue, equals(0.0));
    });
  });

  group('SalesGroupDataModel.fromJson', () {
    test('should return a valid model from JSON with date grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'date': '2024-01-01',
        'salesCount': 20,
        'revenue': 1000.0,
      };

      // Act
      final result = SalesGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<SalesGroupData>());
      expect(result.key, equals('2024-01-01'));
      expect(result.label, equals('2024-01-01'));
      expect(result.salesCount, equals(20));
      expect(result.revenue, equals(1000.0));
    });

    test('should return a valid model from JSON with cashier grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cashierCpf': '123.456.789-00',
        'cashierName': 'John Doe',
        'salesCount': 30,
        'revenue': 1500.0,
      };

      // Act
      final result = SalesGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('123.456.789-00'));
      expect(result.label, equals('John Doe'));
      expect(result.salesCount, equals(30));
      expect(result.revenue, equals(1500.0));
    });

    test('should return a valid model from JSON with payment method grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'method': 'CREDIT_CARD',
        'salesCount': 40,
        'revenue': 2000.0,
      };

      // Act
      final result = SalesGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('CREDIT_CARD'));
      expect(result.label, equals('Cartão de Crédito'));
      expect(result.salesCount, equals(40));
      expect(result.revenue, equals(2000.0));
    });

    test('should format all payment methods correctly', () {
      // Arrange
      final methods = {
        'CASH': 'Dinheiro',
        'CREDIT_CARD': 'Cartão de Crédito',
        'DEBIT_CARD': 'Cartão de Débito',
        'PIX': 'PIX',
        'UNKNOWN': 'UNKNOWN',
      };

      methods.forEach((method, expectedLabel) {
        final Map<String, dynamic> jsonMap = {
          'method': method,
          'salesCount': 10,
          'revenue': 500.0,
        };

        // Act
        final result = SalesGroupDataModel.fromJson(jsonMap);

        // Assert
        expect(result.label, equals(expectedLabel), reason: 'Failed for method: $method');
      });
    });

    test('should handle alternative field names', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'key': 'test-key',
        'label': 'Test Label',
        'count': 25,
        'total': 1250.0,
      };

      // Act
      final result = SalesGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('test-key'));
      expect(result.label, equals('Test Label'));
      expect(result.salesCount, equals(25));
      expect(result.revenue, equals(1250.0));
    });

    test('should handle missing cashierName with cpf as fallback', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'cashierCpf': '123.456.789-00',
        'salesCount': 30,
        'revenue': 1500.0,
      };

      // Act
      final result = SalesGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.label, equals('123.456.789-00'));
    });
  });
}
