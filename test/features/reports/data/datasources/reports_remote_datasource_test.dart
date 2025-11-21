import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/errors/exceptions.dart';
import 'package:backstage_frontend/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:backstage_frontend/features/reports/data/models/detailed_sales_report_model.dart';
import 'package:backstage_frontend/features/reports/data/models/employee_report_model.dart';
import 'package:backstage_frontend/features/reports/data/models/sales_summary_model.dart';
import 'package:backstage_frontend/features/reports/data/models/ticket_sales_report_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late ReportsRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ReportsRemoteDataSourceImpl(mockHttpClient);
  });

  group('getSalesSummary', () {
    final tSalesSummaryData = {
      'success': true,
      'data': {
        'todayRevenue': 1000.0,
        'todayTransactions': 10,
        'weekRevenue': 5000.0,
        'weekTransactions': 50,
        'monthRevenue': 20000.0,
        'monthTransactions': 200,
        'lastMonthRevenue': 18000.0,
        'lastMonthTransactions': 180,
        'growthPercentage': 11.11,
      },
    };

    test('should return SalesSummaryModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: tSalesSummaryData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getSalesSummary();

      // Assert
      expect(result, isA<SalesSummaryModel>());
      expect(result.todayRevenue, equals(1000.0));
      expect(result.todayTransactions, equals(10));
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch sales summary',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getSalesSummary(),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when DioException occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              data: {'message': 'Network error'},
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
          ));

      // Act & Assert
      expect(
        () => dataSource.getSalesSummary(),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when unexpected error occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => dataSource.getSalesSummary(),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getDetailedSalesReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tGroupBy = 'day';
    const tCashierCpf = '123.456.789-00';

    final tDetailedSalesReportData = {
      'success': true,
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

    test('should return DetailedSalesReportModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tDetailedSalesReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        cashierCpf: tCashierCpf,
      );

      // Assert
      expect(result, isA<DetailedSalesReportModel>());
      expect(result.summary.totalSales, equals(100));
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
              'groupBy': tGroupBy,
              'cashierCpf': tCashierCpf,
            },
          )).called(1);
    });

    test('should not include cashierCpf in query params when null', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tDetailedSalesReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getDetailedSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
      );

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
              'groupBy': tGroupBy,
            },
          )).called(1);
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch detailed sales report',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getDetailedSalesReport(
          startDate: tStartDate,
          endDate: tEndDate,
          groupBy: tGroupBy,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when DioException occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              data: {'message': 'Network error'},
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
          ));

      // Act & Assert
      expect(
        () => dataSource.getDetailedSalesReport(
          startDate: tStartDate,
          endDate: tEndDate,
          groupBy: tGroupBy,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getTicketSalesReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tGroupBy = 'day';
    const tMovieId = 'movie-123';
    const tEmployeeCpf = '123.456.789-00';

    final tTicketSalesReportData = {
      'success': true,
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

    test('should return TicketSalesReportModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tTicketSalesReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
        movieId: tMovieId,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<TicketSalesReportModel>());
      expect(result.summary.totalTickets, equals(100));
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
              'groupBy': tGroupBy,
              'movieId': tMovieId,
              'employeeCpf': tEmployeeCpf,
            },
          )).called(1);
    });

    test('should not include optional params in query when null', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tTicketSalesReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getTicketSalesReport(
        startDate: tStartDate,
        endDate: tEndDate,
        groupBy: tGroupBy,
      );

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
              'groupBy': tGroupBy,
            },
          )).called(1);
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch ticket sales report',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getTicketSalesReport(
          startDate: tStartDate,
          endDate: tEndDate,
          groupBy: tGroupBy,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });

  group('getEmployeeReport', () {
    final tStartDate = DateTime(2024, 1, 1);
    final tEndDate = DateTime(2024, 1, 31);
    const tEmployeeCpf = '123.456.789-00';

    final tEmployeeReportData = {
      'success': true,
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

    test('should return EmployeeReportModel when the call is successful', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tEmployeeReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
        employeeCpf: tEmployeeCpf,
      );

      // Assert
      expect(result, isA<EmployeeReportModel>());
      expect(result.employees.length, equals(1));
      expect(result.summary.totalEmployees, equals(5));
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
              'employeeCpf': tEmployeeCpf,
            },
          )).called(1);
    });

    test('should not include employeeCpf in query params when null', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: tEmployeeReportData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.getEmployeeReport(
        startDate: tStartDate,
        endDate: tEndDate,
      );

      // Assert
      verify(() => mockHttpClient.get(
            any(),
            queryParameters: {
              'startDate': tStartDate.toIso8601String(),
              'endDate': tEndDate.toIso8601String(),
            },
          )).called(1);
    });

    test('should throw AppException when success is false', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: {
                  'success': false,
                  'message': 'Failed to fetch employee report',
                },
                statusCode: 500,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act & Assert
      expect(
        () => dataSource.getEmployeeReport(
          startDate: tStartDate,
          endDate: tEndDate,
        ),
        throwsA(isA<AppException>()),
      );
    });

    test('should throw AppException when DioException occurs', () async {
      // Arrange
      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenThrow(DioException(
            requestOptions: RequestOptions(path: ''),
            response: Response(
              data: {'message': 'Network error'},
              statusCode: 500,
              requestOptions: RequestOptions(path: ''),
            ),
          ));

      // Act & Assert
      expect(
        () => dataSource.getEmployeeReport(
          startDate: tStartDate,
          endDate: tEndDate,
        ),
        throwsA(isA<AppException>()),
      );
    });
  });
}
