import 'package:dio/dio.dart';
import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/detailed_sales_report_model.dart';
import '../models/employee_report_model.dart';
import '../models/sales_summary_model.dart';
import '../models/ticket_sales_report_model.dart';

/// Reports remote data source interface
abstract class ReportsRemoteDataSource {
  Future<SalesSummaryModel> getSalesSummary();

  Future<DetailedSalesReportModel> getDetailedSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? cashierCpf,
  });

  Future<TicketSalesReportModel> getTicketSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? movieId,
    String? employeeCpf,
  });

  Future<EmployeeReportModel> getEmployeeReport({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeCpf,
  });
}

/// Reports remote data source implementation
class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final HttpClient client;

  ReportsRemoteDataSourceImpl(this.client);

  @override
  Future<SalesSummaryModel> getSalesSummary() async {
    try {
      print('[Reports Remote] Fetching sales summary from ${ApiConstants.salesReportsSummary}');
      final response = await client.get(ApiConstants.salesReportsSummary);

      print('[Reports Remote] Sales summary response status: ${response.statusCode}');
      print('[Reports Remote] Sales summary response data: ${response.data}');

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        print('[Reports Remote] Sales summary data parsed successfully');
        return SalesSummaryModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch sales summary';
        print('[Reports Remote] Sales summary failed: $errorMsg');
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('[Reports Remote] Sales summary DioException: ${e.message}');
      print('[Reports Remote] Sales summary error response: ${e.response?.data}');
      print('[Reports Remote] Sales summary error status: ${e.response?.statusCode}');
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch sales summary',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('[Reports Remote] Sales summary unexpected error: ${e.toString()}');
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<DetailedSalesReportModel> getDetailedSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? cashierCpf,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'groupBy': groupBy,
      };

      if (cashierCpf != null) {
        queryParams['cashierCpf'] = cashierCpf;
      }

      print('[Reports Remote] Fetching detailed sales report from ${ApiConstants.salesReportsDetailed}');
      print('[Reports Remote] Query params: $queryParams');

      final response = await client.get(
        ApiConstants.salesReportsDetailed,
        queryParameters: queryParams,
      );

      print('[Reports Remote] Detailed sales response status: ${response.statusCode}');
      print('[Reports Remote] Detailed sales response data: ${response.data}');

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        print('[Reports Remote] Detailed sales data parsed successfully');
        return DetailedSalesReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch detailed sales report';
        print('[Reports Remote] Detailed sales failed: $errorMsg');
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('[Reports Remote] Detailed sales DioException: ${e.message}');
      print('[Reports Remote] Detailed sales error response: ${e.response?.data}');
      print('[Reports Remote] Detailed sales error status: ${e.response?.statusCode}');
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch detailed sales report',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('[Reports Remote] Detailed sales unexpected error: ${e.toString()}');
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<TicketSalesReportModel> getTicketSalesReport({
    required DateTime startDate,
    required DateTime endDate,
    required String groupBy,
    String? movieId,
    String? employeeCpf,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'groupBy': groupBy,
      };

      if (movieId != null) {
        queryParams['movieId'] = movieId;
      }

      if (employeeCpf != null) {
        queryParams['employeeCpf'] = employeeCpf;
      }

      print('[Reports Remote] Fetching ticket sales report from ${ApiConstants.ticketsReportsSales}');
      print('[Reports Remote] Query params: $queryParams');

      final response = await client.get(
        ApiConstants.ticketsReportsSales,
        queryParameters: queryParams,
      );

      print('[Reports Remote] Ticket sales response status: ${response.statusCode}');
      print('[Reports Remote] Ticket sales response data: ${response.data}');

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        print('[Reports Remote] Ticket sales data parsed successfully');
        return TicketSalesReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch ticket sales report';
        print('[Reports Remote] Ticket sales failed: $errorMsg');
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('[Reports Remote] Ticket sales DioException: ${e.message}');
      print('[Reports Remote] Ticket sales error response: ${e.response?.data}');
      print('[Reports Remote] Ticket sales error status: ${e.response?.statusCode}');
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch ticket sales report',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('[Reports Remote] Ticket sales unexpected error: ${e.toString()}');
      throw AppException(message: e.toString());
    }
  }

  @override
  Future<EmployeeReportModel> getEmployeeReport({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeCpf,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (employeeCpf != null) {
        queryParams['employeeCpf'] = employeeCpf;
      }

      print('[Reports Remote] Fetching employee report from ${ApiConstants.employeeReportsConsolidated}');
      print('[Reports Remote] Query params: $queryParams');

      final response = await client.get(
        ApiConstants.employeeReportsConsolidated,
        queryParameters: queryParams,
      );

      print('[Reports Remote] Employee report response status: ${response.statusCode}');
      print('[Reports Remote] Employee report response data: ${response.data}');

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        print('[Reports Remote] Employee report data parsed successfully');
        return EmployeeReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch employee report';
        print('[Reports Remote] Employee report failed: $errorMsg');
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      print('[Reports Remote] Employee report DioException: ${e.message}');
      print('[Reports Remote] Employee report error response: ${e.response?.data}');
      print('[Reports Remote] Employee report error status: ${e.response?.statusCode}');
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch employee report',
        statusCode: e.response?.statusCode,
      );
    } catch (e) {
      print('[Reports Remote] Employee report unexpected error: ${e.toString()}');
      throw AppException(message: e.toString());
    }
  }
}
