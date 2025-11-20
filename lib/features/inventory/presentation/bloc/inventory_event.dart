import 'package:equatable/equatable.dart';

/// Inventory events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();

  @override
  List<Object?> get props => [];
}

/// Load inventory products
class LoadInventoryRequested extends InventoryEvent {
  const LoadInventoryRequested();
}

/// Search products
class SearchProductsRequested extends InventoryEvent {
  final String query;

  const SearchProductsRequested(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter by low stock
class FilterLowStockRequested extends InventoryEvent {
  const FilterLowStockRequested();
}

/// Filter by expiring soon
class FilterExpiringSoonRequested extends InventoryEvent {
  const FilterExpiringSoonRequested();
}

/// Clear filters
class ClearFiltersRequested extends InventoryEvent {
  const ClearFiltersRequested();
}

/// Load product details
class LoadProductDetailsRequested extends InventoryEvent {
  final String sku;

  const LoadProductDetailsRequested(this.sku);

  @override
  List<Object?> get props => [sku];
}

/// Adjust stock
class AdjustStockRequested extends InventoryEvent {
  final String sku;
  final int quantity;
  final String reason;
  final String? notes;

  const AdjustStockRequested({
    required this.sku,
    required this.quantity,
    required this.reason,
    this.notes,
  });

  @override
  List<Object?> get props => [sku, quantity, reason, notes];
}

/// Load adjustment history
class LoadAdjustmentHistoryRequested extends InventoryEvent {
  final String? sku;
  final int limit;

  const LoadAdjustmentHistoryRequested({
    this.sku,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [sku, limit];
}

/// Create product
class CreateProductRequested extends InventoryEvent {
  final String sku;
  final String name;
  final double unitPrice;
  final String category;
  final int initialStock;
  final String? barcode;

  const CreateProductRequested({
    required this.sku,
    required this.name,
    required this.unitPrice,
    required this.category,
    required this.initialStock,
    this.barcode,
  });

  @override
  List<Object?> get props => [sku, name, unitPrice, category, initialStock, barcode];
}

/// Update product
class UpdateProductRequested extends InventoryEvent {
  final String sku;
  final String? name;
  final double? unitPrice;
  final String? category;
  final String? barcode;

  const UpdateProductRequested({
    required this.sku,
    this.name,
    this.unitPrice,
    this.category,
    this.barcode,
  });

  @override
  List<Object?> get props => [sku, name, unitPrice, category, barcode];
}

/// Toggle product status
class ToggleProductStatusRequested extends InventoryEvent {
  final String sku;
  final bool isActive;

  const ToggleProductStatusRequested({
    required this.sku,
    required this.isActive,
  });

  @override
  List<Object?> get props => [sku, isActive];
}
