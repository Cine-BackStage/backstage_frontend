import 'package:equatable/equatable.dart';

/// Inventory summary entity
class InventorySummary extends Equatable {
  final int lowStockItems;
  final int expiringItems;
  final double totalInventoryValue;
  final int totalItems;
  final int outOfStockItems;

  const InventorySummary({
    required this.lowStockItems,
    required this.expiringItems,
    required this.totalInventoryValue,
    required this.totalItems,
    required this.outOfStockItems,
  });

  @override
  List<Object?> get props => [
        lowStockItems,
        expiringItems,
        totalInventoryValue,
        totalItems,
        outOfStockItems,
      ];
}
