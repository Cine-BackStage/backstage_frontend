import '../../domain/entities/sales_summary.dart';

/// Sales summary model
class SalesSummaryModel extends SalesSummary {
  const SalesSummaryModel({
    required super.todayRevenue,
    required super.todayTransactions,
    required super.weekRevenue,
    required super.weekTransactions,
    required super.monthRevenue,
    required super.monthTransactions,
    required super.lastMonthRevenue,
    required super.lastMonthTransactions,
    required super.growthPercentage,
  });

  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    // Check if data is nested or flat structure
    if (json.containsKey('today')) {
      // Nested structure
      final today = json['today'] as Map<String, dynamic>? ?? {};
      final week = json['week'] as Map<String, dynamic>? ?? {};
      final month = json['month'] as Map<String, dynamic>? ?? {};
      final lastMonth = json['lastMonth'] as Map<String, dynamic>? ?? {};

      return SalesSummaryModel(
        todayRevenue: (today['revenue'] ?? 0).toDouble(),
        todayTransactions: (today['transactions'] ?? 0) as int,
        weekRevenue: (week['revenue'] ?? 0).toDouble(),
        weekTransactions: (week['transactions'] ?? 0) as int,
        monthRevenue: (month['revenue'] ?? 0).toDouble(),
        monthTransactions: (month['transactions'] ?? 0) as int,
        lastMonthRevenue: (lastMonth['revenue'] ?? 0).toDouble(),
        lastMonthTransactions: (lastMonth['transactions'] ?? 0) as int,
        growthPercentage: (json['growthPercentage'] ?? 0).toDouble(),
      );
    } else {
      // Flat structure from backend
      final todayRevenue = (json['todayRevenue'] ?? 0).toDouble();
      final todayTransactions = (json['todayTransactions'] ?? 0) as int;
      final weekRevenue = (json['weekRevenue'] ?? 0).toDouble();
      final weekTransactions = (json['weekTransactions'] ?? 0) as int;
      final monthRevenue = (json['monthRevenue'] ?? 0).toDouble();
      final monthTransactions = (json['monthTransactions'] ?? 0) as int;
      final lastMonthRevenue = (json['lastMonthRevenue'] ?? 0).toDouble();
      final lastMonthTransactions = (json['lastMonthTransactions'] ?? 0) as int;
      final growthPercentage = (json['growthPercentage'] ?? 0).toDouble();

      print('[SalesSummaryModel] Parsed values:');
      print('  todayRevenue: $todayRevenue, todayTransactions: $todayTransactions');
      print('  weekRevenue: $weekRevenue, weekTransactions: $weekTransactions');
      print('  monthRevenue: $monthRevenue, monthTransactions: $monthTransactions');

      return SalesSummaryModel(
        todayRevenue: todayRevenue,
        todayTransactions: todayTransactions,
        weekRevenue: weekRevenue,
        weekTransactions: weekTransactions,
        monthRevenue: monthRevenue,
        monthTransactions: monthTransactions,
        lastMonthRevenue: lastMonthRevenue,
        lastMonthTransactions: lastMonthTransactions,
        growthPercentage: growthPercentage,
      );
    }
  }
}
