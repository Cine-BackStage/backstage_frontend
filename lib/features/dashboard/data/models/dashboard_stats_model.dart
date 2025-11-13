import '../../domain/entities/dashboard_stats.dart';
import 'sales_summary_model.dart';
import 'session_summary_model.dart';
import 'inventory_summary_model.dart';

/// Dashboard statistics data model
class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.salesSummary,
    required super.sessionSummary,
    required super.inventorySummary,
    required super.activeCustomers,
    required super.lastUpdated,
  });

  /// Create from JSON (backend response)
  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      salesSummary: SalesSummaryModel.fromJson(
        json['salesSummary'] as Map<String, dynamic>? ?? {},
      ),
      sessionSummary: SessionSummaryModel.fromJson(
        json['sessionSummary'] as Map<String, dynamic>? ?? {},
      ),
      inventorySummary: InventorySummaryModel.fromJson(
        json['inventorySummary'] as Map<String, dynamic>? ?? {},
      ),
      activeCustomers: (json['activeCustomers'] as int?) ?? 0,
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'salesSummary': SalesSummaryModel.fromEntity(salesSummary).toJson(),
      'sessionSummary': SessionSummaryModel.fromEntity(sessionSummary).toJson(),
      'inventorySummary': InventorySummaryModel.fromEntity(inventorySummary).toJson(),
      'activeCustomers': activeCustomers,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create from domain entity
  factory DashboardStatsModel.fromEntity(DashboardStats entity) {
    return DashboardStatsModel(
      salesSummary: entity.salesSummary,
      sessionSummary: entity.sessionSummary,
      inventorySummary: entity.inventorySummary,
      activeCustomers: entity.activeCustomers,
      lastUpdated: entity.lastUpdated,
    );
  }
}
