import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../dashboard/presentation/bloc/dashboard_event.dart';
import '../../domain/usecases/adjust_stock_usecase.dart';
import '../../domain/usecases/create_product_usecase.dart';
import '../../domain/usecases/get_adjustment_history_usecase.dart';
import '../../domain/usecases/get_inventory_usecase.dart';
import '../../domain/usecases/get_low_stock_usecase.dart';
import '../../domain/usecases/get_product_details_usecase.dart';
import '../../domain/usecases/search_products_usecase.dart';
import '../../domain/usecases/toggle_product_status_usecase.dart';
import '../../domain/usecases/update_product_usecase.dart';
import 'inventory_event.dart';
import 'inventory_state.dart';

/// Inventory BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final GetInventoryUseCase getInventoryUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetLowStockUseCase getLowStockUseCase;
  final GetProductDetailsUseCase getProductDetailsUseCase;
  final AdjustStockUseCase adjustStockUseCase;
  final GetAdjustmentHistoryUseCase getAdjustmentHistoryUseCase;
  final CreateProductUseCase createProductUseCase;
  final UpdateProductUseCase updateProductUseCase;
  final ToggleProductStatusUseCase toggleProductStatusUseCase;

  InventoryBloc({
    required this.getInventoryUseCase,
    required this.searchProductsUseCase,
    required this.getLowStockUseCase,
    required this.getProductDetailsUseCase,
    required this.adjustStockUseCase,
    required this.getAdjustmentHistoryUseCase,
    required this.createProductUseCase,
    required this.updateProductUseCase,
    required this.toggleProductStatusUseCase,
  }) : super(const InventoryInitial()) {
    on<LoadInventoryRequested>(_onLoadInventoryRequested);
    on<SearchProductsRequested>(_onSearchProductsRequested);
    on<FilterLowStockRequested>(_onFilterLowStockRequested);
    on<FilterExpiringSoonRequested>(_onFilterExpiringSoonRequested);
    on<ClearFiltersRequested>(_onClearFiltersRequested);
    on<LoadProductDetailsRequested>(_onLoadProductDetailsRequested);
    on<AdjustStockRequested>(_onAdjustStockRequested);
    on<LoadAdjustmentHistoryRequested>(_onLoadAdjustmentHistoryRequested);
    on<CreateProductRequested>(_onCreateProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<ToggleProductStatusRequested>(_onToggleProductStatusRequested);
  }

  Future<void> _onLoadInventoryRequested(
    LoadInventoryRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await getInventoryUseCase(const NoParams());

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(InventoryLoaded(products)),
    );
  }

  Future<void> _onSearchProductsRequested(
    SearchProductsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await searchProductsUseCase(
      SearchProductsParams(query: event.query),
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(InventoryLoaded(products)),
    );
  }

  Future<void> _onFilterLowStockRequested(
    FilterLowStockRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final result = await getLowStockUseCase(const NoParams());

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (products) => emit(InventoryLoaded(products)),
    );
  }

  Future<void> _onFilterExpiringSoonRequested(
    FilterExpiringSoonRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    // Get all inventory and filter on client side for expiring products
    final result = await getInventoryUseCase(const NoParams());

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (allProducts) {
        // Filter products that are expiring soon (within 7 days) or expired
        final expiringProducts = allProducts.where((p) {
          return p.isExpiringSoon || p.isExpired;
        }).toList();
        emit(InventoryLoaded(expiringProducts));
      },
    );
  }

  Future<void> _onClearFiltersRequested(
    ClearFiltersRequested event,
    Emitter<InventoryState> emit,
  ) async {
    add(const LoadInventoryRequested());
  }

  Future<void> _onLoadProductDetailsRequested(
    LoadProductDetailsRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(const InventoryLoading());

    final productResult = await getProductDetailsUseCase(
      GetProductDetailsParams(sku: event.sku),
    );

    await productResult.fold(
      (failure) async => emit(InventoryError(failure.message)),
      (product) async {
        final historyResult = await getAdjustmentHistoryUseCase(
          GetAdjustmentHistoryParams(sku: event.sku, limit: 20),
        );

        historyResult.fold(
          (failure) => emit(InventoryError(failure.message)),
          (adjustments) => emit(InventoryProductDetails(
            product: product,
            adjustments: adjustments,
          )),
        );
      },
    );
  }

  Future<void> _onAdjustStockRequested(
    AdjustStockRequested event,
    Emitter<InventoryState> emit,
  ) async {
    print('[Inventory BLoC] Adjust stock requested - SKU: ${event.sku}, Quantity: ${event.quantity}, Reason: ${event.reason}');

    final result = await adjustStockUseCase(
      AdjustStockParams(
        sku: event.sku,
        quantity: event.quantity,
        reason: event.reason,
        notes: event.notes,
      ),
    );

    result.fold(
      (failure) {
        print('[Inventory BLoC Error] Stock adjustment failed: ${failure.message}');
        emit(InventoryError(failure.message));
      },
      (_) {
        print('[Inventory BLoC] Stock adjustment successful, reloading inventory');

        // Reload inventory after adjustment
        add(const LoadInventoryRequested());

        // Refresh dashboard to update alerts and low stock count
        try {
          serviceLocator<DashboardBloc>().add(const RefreshDashboard());
          print('[Inventory BLoC] Dashboard refresh triggered');
        } catch (e) {
          print('[Inventory BLoC] Could not refresh dashboard: $e');
        }
      },
    );
  }

  Future<void> _onLoadAdjustmentHistoryRequested(
    LoadAdjustmentHistoryRequested event,
    Emitter<InventoryState> emit,
  ) async {
    // This is handled within LoadProductDetailsRequested
    // Can be used for standalone history viewing if needed
  }

  Future<void> _onCreateProductRequested(
    CreateProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await createProductUseCase(
      CreateProductParams(
        sku: event.sku,
        name: event.name,
        unitPrice: event.unitPrice,
        category: event.category,
        initialStock: event.initialStock,
        barcode: event.barcode,
      ),
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) {
        // Reload inventory after creation
        add(const LoadInventoryRequested());
      },
    );
  }

  Future<void> _onUpdateProductRequested(
    UpdateProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await updateProductUseCase(
      UpdateProductParams(
        sku: event.sku,
        name: event.name,
        unitPrice: event.unitPrice,
        category: event.category,
        barcode: event.barcode,
      ),
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) {
        // Reload product details after update
        add(LoadProductDetailsRequested(event.sku));
      },
    );
  }

  Future<void> _onToggleProductStatusRequested(
    ToggleProductStatusRequested event,
    Emitter<InventoryState> emit,
  ) async {
    final result = await toggleProductStatusUseCase(
      ToggleProductStatusParams(
        sku: event.sku,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) => emit(InventoryError(failure.message)),
      (_) {
        // Reload inventory after status change
        add(const LoadInventoryRequested());
      },
    );
  }
}
