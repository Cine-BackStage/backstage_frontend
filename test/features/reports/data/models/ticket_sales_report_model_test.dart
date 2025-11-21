import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/reports/data/models/ticket_sales_report_model.dart';
import 'package:backstage_frontend/features/reports/domain/entities/ticket_sales_report.dart';

void main() {
  final tStartDate = DateTime(2024, 1, 1);
  final tEndDate = DateTime(2024, 1, 31);

  final tTicketSalesReportModel = TicketSalesReportModel(
    startDate: tStartDate,
    endDate: tEndDate,
    groupBy: 'day',
    summary: const TicketReportSummaryModel(
      totalTickets: 100,
      totalRevenue: 5000.0,
      averageTicketPrice: 50.0,
      cancelledTickets: 5,
    ),
    groupedData: const [
      TicketGroupDataModel(
        key: '2024-01-01',
        label: '2024-01-01',
        ticketCount: 20,
        revenue: 1000.0,
      ),
    ],
  );

  test('should be a subclass of TicketSalesReport entity', () {
    expect(tTicketSalesReportModel, isA<TicketSalesReport>());
  });

  group('TicketSalesReportModel.fromJson', () {
    test('should return a valid model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'period': {
          'startDate': '2024-01-01T00:00:00.000',
          'endDate': '2024-01-31T00:00:00.000',
          'groupBy': 'day',
        },
        'summary': {
          'totalTickets': 100,
          'totalRevenue': 5000.0,
          'averageTicketPrice': 50.0,
          'cancelledTickets': 5,
        },
        'groupedData': [
          {
            'date': '2024-01-01',
            'ticketCount': 20,
            'revenue': 1000.0,
          },
        ],
      };

      // Act
      final result = TicketSalesReportModel.fromJson(jsonMap);

      // Assert
      expect(result.startDate, equals(tStartDate));
      expect(result.endDate, equals(tEndDate));
      expect(result.groupBy, equals('day'));
      expect(result.summary.totalTickets, equals(100));
      expect(result.groupedData.length, equals(1));
    });

    test('should handle missing period data with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'summary': {
          'totalTickets': 100,
          'totalRevenue': 5000.0,
        },
        'groupedData': [],
      };

      // Act & Assert
      expect(() => TicketSalesReportModel.fromJson(jsonMap), throwsA(isA<TypeError>()));
    });
  });

  group('TicketReportSummaryModel.fromJson', () {
    test('should return a valid summary model from JSON', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'totalTickets': 100,
        'totalRevenue': 5000.0,
        'averageTicketPrice': 50.0,
        'cancelledTickets': 5,
      };

      // Act
      final result = TicketReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<TicketReportSummary>());
      expect(result.totalTickets, equals(100));
      expect(result.totalRevenue, equals(5000.0));
      expect(result.averageTicketPrice, equals(50.0));
      expect(result.cancelledTickets, equals(5));
    });

    test('should calculate average ticket price when not provided', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'totalTickets': 100,
        'totalRevenue': 5000.0,
      };

      // Act
      final result = TicketReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.averageTicketPrice, equals(50.0));
    });

    test('should get cancelled tickets from ticketsByStatus', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'totalTickets': 100,
        'totalRevenue': 5000.0,
        'ticketsByStatus': {
          'refunded': 10,
          'confirmed': 90,
        },
      };

      // Act
      final result = TicketReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.cancelledTickets, equals(10));
    });

    test('should handle missing values with defaults', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {};

      // Act
      final result = TicketReportSummaryModel.fromJson(jsonMap);

      // Assert
      expect(result.totalTickets, equals(0));
      expect(result.totalRevenue, equals(0.0));
      expect(result.averageTicketPrice, equals(0.0));
      expect(result.cancelledTickets, equals(0));
    });
  });

  group('TicketGroupDataModel.fromJson', () {
    test('should return a valid model from JSON with date grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'date': '2024-01-01',
        'ticketCount': 20,
        'revenue': 1000.0,
      };

      // Act
      final result = TicketGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result, isA<TicketGroupData>());
      expect(result.key, equals('2024-01-01'));
      expect(result.label, equals('2024-01-01'));
      expect(result.ticketCount, equals(20));
      expect(result.revenue, equals(1000.0));
    });

    test('should return a valid model from JSON with movie grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'movieId': 'movie-123',
        'movieTitle': 'Test Movie',
        'ticketCount': 30,
        'revenue': 1500.0,
      };

      // Act
      final result = TicketGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('movie-123'));
      expect(result.label, equals('Test Movie'));
      expect(result.ticketCount, equals(30));
      expect(result.revenue, equals(1500.0));
    });

    test('should return a valid model from JSON with employee grouping', () {
      // Arrange
      final Map<String, dynamic> jsonMap = {
        'employeeCpf': '123.456.789-00',
        'employeeName': 'John Doe',
        'ticketCount': 40,
        'revenue': 2000.0,
      };

      // Act
      final result = TicketGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('123.456.789-00'));
      expect(result.label, equals('John Doe'));
      expect(result.ticketCount, equals(40));
      expect(result.revenue, equals(2000.0));
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
      final result = TicketGroupDataModel.fromJson(jsonMap);

      // Assert
      expect(result.key, equals('test-key'));
      expect(result.label, equals('Test Label'));
      expect(result.ticketCount, equals(25));
      expect(result.revenue, equals(1250.0));
    });
  });
}
