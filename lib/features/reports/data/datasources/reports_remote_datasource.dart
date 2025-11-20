import 'package:dio/dio.dart';
import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/logger_service.dart';
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
  final logger = LoggerService();

  ReportsRemoteDataSourceImpl(this.client);

  @override
  Future<SalesSummaryModel> getSalesSummary() async {
    try {
      logger.logDataSourceRequest('ReportsDataSource', 'getSalesSummary', null);
      final response = await client.get(ApiConstants.salesReportsSummary);

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        return SalesSummaryModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch sales summary';
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getSalesSummary', e, stackTrace);
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch sales summary',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getSalesSummary', e, stackTrace);
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

      logger.logDataSourceRequest('ReportsDataSource', 'getDetailedSalesReport', queryParams);

      final response = await client.get(
        ApiConstants.salesReportsDetailed,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        return DetailedSalesReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch detailed sales report';
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getDetailedSalesReport', e, stackTrace);
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch detailed sales report',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getDetailedSalesReport', e, stackTrace);
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

      logger.logDataSourceRequest('ReportsDataSource', 'getTicketSalesReport', queryParams);

      final response = await client.get(
        ApiConstants.ticketsReportsSales,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        return TicketSalesReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch ticket sales report';
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getTicketSalesReport', e, stackTrace);
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch ticket sales report',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getTicketSalesReport', e, stackTrace);
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

      logger.logDataSourceRequest('ReportsDataSource', 'getEmployeeReport', queryParams);

      final response = await client.get(
        ApiConstants.employeeReportsConsolidated,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        // The backend returns data directly in the response, not nested under 'data'
        final data = response.data as Map<String, dynamic>;
        return EmployeeReportModel.fromJson(data);
      } else {
        final errorMsg = response.data['message'] ?? 'Failed to fetch employee report';
        throw AppException(
          message: errorMsg,
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getEmployeeReport', e, stackTrace);
      throw AppException(
        message: e.response?.data['message'] ?? e.message ?? 'Failed to fetch employee report',
        statusCode: e.response?.statusCode,
      );
    } catch (e, stackTrace) {
      logger.logDataSourceError('ReportsDataSource', 'getEmployeeReport', e, stackTrace);
      throw AppException(message: e.toString());
    }
  }
}
