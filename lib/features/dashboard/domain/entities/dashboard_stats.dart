import 'package:equatable/equatable.dart';
import 'sales_summary.dart';
import 'session_summary.dart';
import 'inventory_summary.dart';

/// Dashboard statistics entity
class DashboardStats extends Equatable {
  final SalesSummary salesSummary;
  final SessionSummary sessionSummary;
  final InventorySummary inventorySummary;
  final int activeCustomers;
  final DateTime lastUpdated;

  const DashboardStats({
    required this.salesSummary,
    required this.sessionSummary,
    required this.inventorySummary,
    required this.activeCustomers,
    required this.lastUpdated,
  });

  @override
  List<Object?> get props => [
        salesSummary,
        sessionSummary,
        inventorySummary,
        activeCustomers,
        lastUpdated,
      ];
}
