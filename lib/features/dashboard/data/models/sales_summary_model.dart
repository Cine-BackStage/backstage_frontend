import '../../domain/entities/sales_summary.dart';

/// Sales summary data model
class SalesSummaryModel extends SalesSummary {
  const SalesSummaryModel({
    required super.todayRevenue,
    required super.todayTransactions,
    required super.averageTicketPrice,
    required super.weekRevenue,
    required super.monthRevenue,
    required super.growthPercentage,
  });

  /// Create from JSON (backend response)
  factory SalesSummaryModel.fromJson(Map<String, dynamic> json) {
    return SalesSummaryModel(
      todayRevenue: (json['todayRevenue'] as num?)?.toDouble() ?? 0.0,
      todayTransactions: (json['todayTransactions'] as int?) ?? 0,
      averageTicketPrice: (json['averageTicketPrice'] as num?)?.toDouble() ?? 0.0,
      weekRevenue: (json['weekRevenue'] as num?)?.toDouble() ?? 0.0,
      monthRevenue: (json['monthRevenue'] as num?)?.toDouble() ?? 0.0,
      growthPercentage: (json['growthPercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'todayRevenue': todayRevenue,
      'todayTransactions': todayTransactions,
      'averageTicketPrice': averageTicketPrice,
      'weekRevenue': weekRevenue,
      'monthRevenue': monthRevenue,
      'growthPercentage': growthPercentage,
    };
  }

  /// Create from domain entity
  factory SalesSummaryModel.fromEntity(SalesSummary entity) {
    return SalesSummaryModel(
      todayRevenue: entity.todayRevenue,
      todayTransactions: entity.todayTransactions,
      averageTicketPrice: entity.averageTicketPrice,
      weekRevenue: entity.weekRevenue,
      monthRevenue: entity.monthRevenue,
      growthPercentage: entity.growthPercentage,
    );
  }
}
