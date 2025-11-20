import 'package:equatable/equatable.dart';
import '../../../pos/domain/entities/product.dart';
import '../../domain/entities/stock_adjustment.dart';

/// Inventory state
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];

  /// Pattern matching method
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Product> products) loaded,
    required T Function(Product product, List<StockAdjustment> adjustments) productDetails,
    required T Function(String message) error,
  }) {
    if (this is InventoryInitial) {
      return initial();
    } else if (this is InventoryLoading) {
      return loading();
    } else if (this is InventoryLoaded) {
      return loaded((this as InventoryLoaded).products);
    } else if (this is InventoryProductDetails) {
      final state = this as InventoryProductDetails;
      return productDetails(state.product, state.adjustments);
    } else if (this is InventoryError) {
      return error((this as InventoryError).message);
    }
    throw Exception('Unknown InventoryState: $this');
  }

  /// Pattern matching with nullable return
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Product> products)? loaded,
    T Function(Product product, List<StockAdjustment> adjustments)? productDetails,
    T Function(String message)? error,
  }) {
    if (this is InventoryInitial && initial != null) {
      return initial();
    } else if (this is InventoryLoading && loading != null) {
      return loading();
    } else if (this is InventoryLoaded && loaded != null) {
      return loaded((this as InventoryLoaded).products);
    } else if (this is InventoryProductDetails && productDetails != null) {
      final state = this as InventoryProductDetails;
      return productDetails(state.product, state.adjustments);
    } else if (this is InventoryError && error != null) {
      return error((this as InventoryError).message);
    }
    return null;
  }

  /// Pattern matching with default case
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Product> products)? loaded,
    T Function(Product product, List<StockAdjustment> adjustments)? productDetails,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    if (this is InventoryInitial && initial != null) {
      return initial();
    } else if (this is InventoryLoading && loading != null) {
      return loading();
    } else if (this is InventoryLoaded && loaded != null) {
      return loaded((this as InventoryLoaded).products);
    } else if (this is InventoryProductDetails && productDetails != null) {
      final state = this as InventoryProductDetails;
      return productDetails(state.product, state.adjustments);
    } else if (this is InventoryError && error != null) {
      return error((this as InventoryError).message);
    }
    return orElse();
  }
}

/// Initial state
class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

/// Loading state
class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

/// Loaded state with products
class InventoryLoaded extends InventoryState {
  final List<Product> products;

  const InventoryLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Product details state
class InventoryProductDetails extends InventoryState {
  final Product product;
  final List<StockAdjustment> adjustments;

  const InventoryProductDetails({
    required this.product,
    required this.adjustments,
  });

  @override
  List<Object?> get props => [product, adjustments];
}

/// Error state
class InventoryError extends InventoryState {
  final String message;

  const InventoryError(this.message);

  @override
  List<Object?> get props => [message];
}
