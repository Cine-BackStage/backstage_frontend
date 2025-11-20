import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/dashboard_stats_model.dart';
import '../models/sales_summary_model.dart';
import '../models/session_summary_model.dart';
import '../models/inventory_summary_model.dart';

/// Dashboard remote data source interface
abstract class DashboardRemoteDataSource {
  Future<DashboardStatsModel> getDashboardStats();
}

/// Dashboard remote data source implementation
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final HttpClient client;

  DashboardRemoteDataSourceImpl(this.client);

  @override
  Future<DashboardStatsModel> getDashboardStats() async {
    try {
      print('[Dashboard Remote] Fetching dashboard stats...');

      // Fetch data from multiple endpoints in parallel
      final results = await Future.wait([
        _getSalesSummary(),
        _getSessionSummary(),
        _getInventorySummary(),
        _getActiveCustomers(),
      ]);

      final salesSummary = results[0] as SalesSummaryModel;
      final sessionSummary = results[1] as SessionSummaryModel;
      final inventorySummary = results[2] as InventorySummaryModel;
      final activeCustomers = results[3] as int;

      final dashboardStats = DashboardStatsModel(
        salesSummary: salesSummary,
        sessionSummary: sessionSummary,
        inventorySummary: inventorySummary,
        activeCustomers: activeCustomers,
        lastUpdated: DateTime.now(),
      );

      print('[Dashboard Remote] Dashboard stats fetched successfully');
      return dashboardStats;
    } catch (e) {
      print('[Dashboard Remote Error] ${e.toString()}');
      if (e is AppException) {
        rethrow;
      }
      throw AppException(
        message: 'Failed to load dashboard stats: ${e.toString()}',
      );
    }
  }

  /// Get sales summary
  Future<SalesSummaryModel> _getSalesSummary() async {
    try {
      final response = await client.get(ApiConstants.salesReportsSummary);

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>? ?? {};
        return SalesSummaryModel.fromJson(data);
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get sales summary',
        );
      }
    } catch (e) {
      print('[Dashboard Remote] Sales summary error: $e');
      // Return empty data on error
      return const SalesSummaryModel(
        todayRevenue: 0.0,
        todayTransactions: 0,
        averageTicketPrice: 0.0,
        weekRevenue: 0.0,
        monthRevenue: 0.0,
        growthPercentage: 0.0,
      );
    }
  }

  /// Get session summary
  Future<SessionSummaryModel> _getSessionSummary() async {
    try {
      // Get today's sessions
      final today = DateTime.now();
      final dateStr = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

      final response = await client.get(
        ApiConstants.sessions,
        queryParameters: {'date': dateStr},
      );

      if (response.data['success'] == true) {
        final sessions = response.data['data'] as List? ?? [];

        // Calculate stats from sessions
        int activeCount = 0;
        int upcomingCount = 0;
        int totalTickets = 0;

        for (final session in sessions) {
          final status = session['status'] as String?;
          if (status == 'IN_PROGRESS') activeCount++;
          if (status == 'SCHEDULED') upcomingCount++;

          final ticketCount = session['ticketsSold'] as int? ?? 0;
          totalTickets += ticketCount;
        }

        return SessionSummaryModel(
          activeSessionsToday: activeCount,
          upcomingSessions: upcomingCount,
          totalSessionsToday: sessions.length,
          averageOccupancy: sessions.isEmpty ? 0.0 : (totalTickets / sessions.length),
          totalTicketsSold: totalTickets,
        );
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get sessions',
        );
      }
    } catch (e) {
      print('[Dashboard Remote] Session summary error: $e');
      // Return empty data on error
      return const SessionSummaryModel(
        activeSessionsToday: 0,
        upcomingSessions: 0,
        totalSessionsToday: 0,
        averageOccupancy: 0.0,
        totalTicketsSold: 0,
      );
    }
  }

  /// Get inventory summary
  Future<InventorySummaryModel> _getInventorySummary() async {
    try {
      // Get low stock items
      final lowStockResponse = await client.get(ApiConstants.inventoryLowStock);
      final lowStockItems = lowStockResponse.data['success'] == true
          ? (lowStockResponse.data['data'] as List? ?? []).length
          : 0;

      // Get expiring items
      final expiringResponse = await client.get(ApiConstants.inventoryExpiring);
      int expiringItems = 0;
      if (expiringResponse.data['success'] == true) {
        final data = expiringResponse.data['data'] as Map<String, dynamic>?;
        if (data != null) {
          final expiringList = data['expiringItems'] as List? ?? [];
          final expiredList = data['expiredItems'] as List? ?? [];
          expiringItems = expiringList.length + expiredList.length;
        }
      }

      // Get all inventory for total value
      final inventoryResponse = await client.get(ApiConstants.inventory);
      double totalValue = 0.0;
      int totalItems = 0;
      int outOfStock = 0;

      if (inventoryResponse.data['success'] == true) {
        final items = inventoryResponse.data['data'] as List? ?? [];
        totalItems = items.length;

        for (final item in items) {
          final qtyValue = item['qtyOnHand'];
          final qty = qtyValue is int ? qtyValue : (qtyValue is String ? int.tryParse(qtyValue) ?? 0 : 0);

          final priceValue = item['unitPrice'];
          final price = priceValue is num
              ? priceValue.toDouble()
              : (priceValue is String ? double.tryParse(priceValue) ?? 0.0 : 0.0);

          totalValue += qty * price;

          if (qty == 0) outOfStock++;
        }
      }

      return InventorySummaryModel(
        lowStockItems: lowStockItems,
        expiringItems: expiringItems,
        totalInventoryValue: totalValue,
        totalItems: totalItems,
        outOfStockItems: outOfStock,
      );
    } catch (e) {
      print('[Dashboard Remote] Inventory summary error: $e');
      // Return empty data on error
      return const InventorySummaryModel(
        lowStockItems: 0,
        expiringItems: 0,
        totalInventoryValue: 0.0,
        totalItems: 0,
        outOfStockItems: 0,
      );
    }
  }

  /// Get active customers count
  Future<int> _getActiveCustomers() async {
    try {
      final response = await client.get(ApiConstants.customers);

      if (response.data['success'] == true) {
        final customers = response.data['data'] as List? ?? [];
        return customers.length;
      } else {
        throw AppException(
          message: response.data['message'] ?? 'Failed to get customers',
        );
      }
    } catch (e) {
      print('[Dashboard Remote] Active customers error: $e');
      return 0;
    }
  }
}
