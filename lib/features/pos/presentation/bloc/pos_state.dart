import 'package:equatable/equatable.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/sale.dart';

/// POS state base class
abstract class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];

  /// Pattern matching - all cases required
  T when<T>({
    required T Function() initial,
    required T Function() loadingProducts,
    required T Function(List<Product> products) productsLoaded,
    required T Function(Sale sale, List<Product> products, String discountCode) saleInProgress,
    required T Function(Sale sale, List<Product> products) processingPayment,
    required T Function(Sale sale) saleCompleted,
    required T Function(String message, List<Product>? products, Sale? sale) error,
  }) {
    final state = this;
    if (state is PosInitial) {
      return initial();
    } else if (state is PosLoadingProducts) {
      return loadingProducts();
    } else if (state is PosProductsLoaded) {
      return productsLoaded(state.products);
    } else if (state is PosSaleInProgress) {
      return saleInProgress(state.sale, state.products, state.discountCode);
    } else if (state is PosProcessingPayment) {
      return processingPayment(state.sale, state.products);
    } else if (state is PosSaleCompleted) {
      return saleCompleted(state.sale);
    } else if (state is PosError) {
      return error(state.message, state.products, state.sale);
    }
    throw Exception('Unknown state: $state');
  }

  /// Pattern matching - returns null if no match
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loadingProducts,
    T Function(List<Product> products)? productsLoaded,
    T Function(Sale sale, List<Product> products, String discountCode)? saleInProgress,
    T Function(Sale sale, List<Product> products)? processingPayment,
    T Function(Sale sale)? saleCompleted,
    T Function(String message, List<Product>? products, Sale? sale)? error,
  }) {
    final state = this;
    if (state is PosInitial && initial != null) {
      return initial();
    } else if (state is PosLoadingProducts && loadingProducts != null) {
      return loadingProducts();
    } else if (state is PosProductsLoaded && productsLoaded != null) {
      return productsLoaded(state.products);
    } else if (state is PosSaleInProgress && saleInProgress != null) {
      return saleInProgress(state.sale, state.products, state.discountCode);
    } else if (state is PosProcessingPayment && processingPayment != null) {
      return processingPayment(state.sale, state.products);
    } else if (state is PosSaleCompleted && saleCompleted != null) {
      return saleCompleted(state.sale);
    } else if (state is PosError && error != null) {
      return error(state.message, state.products, state.sale);
    }
    return null;
  }

  /// Pattern matching - with default orElse callback
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loadingProducts,
    T Function(List<Product> products)? productsLoaded,
    T Function(Sale sale, List<Product> products, String discountCode)? saleInProgress,
    T Function(Sale sale, List<Product> products)? processingPayment,
    T Function(Sale sale)? saleCompleted,
    T Function(String message, List<Product>? products, Sale? sale)? error,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is PosInitial && initial != null) {
      return initial();
    } else if (state is PosLoadingProducts && loadingProducts != null) {
      return loadingProducts();
    } else if (state is PosProductsLoaded && productsLoaded != null) {
      return productsLoaded(state.products);
    } else if (state is PosSaleInProgress && saleInProgress != null) {
      return saleInProgress(state.sale, state.products, state.discountCode);
    } else if (state is PosProcessingPayment && processingPayment != null) {
      return processingPayment(state.sale, state.products);
    } else if (state is PosSaleCompleted && saleCompleted != null) {
      return saleCompleted(state.sale);
    } else if (state is PosError && error != null) {
      return error(state.message, state.products, state.sale);
    }
    return orElse();
  }
}

/// Initial state
class PosInitial extends PosState {
  const PosInitial();
}

/// Loading products
class PosLoadingProducts extends PosState {
  const PosLoadingProducts();
}

/// Products loaded, no active sale
class PosProductsLoaded extends PosState {
  final List<Product> products;

  const PosProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Sale in progress with items in cart
class PosSaleInProgress extends PosState {
  final Sale sale;
  final List<Product> products;
  final String discountCode;

  const PosSaleInProgress({
    required this.sale,
    required this.products,
    this.discountCode = '',
  });

  @override
  List<Object?> get props => [sale, products, discountCode];
}

/// Processing payment
class PosProcessingPayment extends PosState {
  final Sale sale;
  final List<Product> products;

  const PosProcessingPayment({
    required this.sale,
    required this.products,
  });

  @override
  List<Object?> get props => [sale, products];
}

/// Sale completed successfully
class PosSaleCompleted extends PosState {
  final Sale sale;

  const PosSaleCompleted(this.sale);

  @override
  List<Object?> get props => [sale];
}

/// Error state
class PosError extends PosState {
  final String message;
  final List<Product>? products;
  final Sale? sale;

  const PosError({
    required this.message,
    this.products,
    this.sale,
  });

  @override
  List<Object?> get props => [message, products, sale];
}
