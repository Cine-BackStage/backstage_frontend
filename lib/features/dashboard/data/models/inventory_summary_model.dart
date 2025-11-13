import '../../domain/entities/inventory_summary.dart';

/// Inventory summary data model
class InventorySummaryModel extends InventorySummary {
  const InventorySummaryModel({
    required super.lowStockItems,
    required super.expiringItems,
    required super.totalInventoryValue,
    required super.totalItems,
    required super.outOfStockItems,
  });

  /// Create from JSON (backend response)
  factory InventorySummaryModel.fromJson(Map<String, dynamic> json) {
    return InventorySummaryModel(
      lowStockItems: (json['lowStockItems'] as int?) ?? 0,
      expiringItems: (json['expiringItems'] as int?) ?? 0,
      totalInventoryValue: (json['totalInventoryValue'] as num?)?.toDouble() ?? 0.0,
      totalItems: (json['totalItems'] as int?) ?? 0,
      outOfStockItems: (json['outOfStockItems'] as int?) ?? 0,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'lowStockItems': lowStockItems,
      'expiringItems': expiringItems,
      'totalInventoryValue': totalInventoryValue,
      'totalItems': totalItems,
      'outOfStockItems': outOfStockItems,
    };
  }

  /// Create from domain entity
  factory InventorySummaryModel.fromEntity(InventorySummary entity) {
    return InventorySummaryModel(
      lowStockItems: entity.lowStockItems,
      expiringItems: entity.expiringItems,
      totalInventoryValue: entity.totalInventoryValue,
      totalItems: entity.totalItems,
      outOfStockItems: entity.outOfStockItems,
    );
  }
}
