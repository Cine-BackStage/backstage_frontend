import '../../../adapters/dependency_injection/service_locator.dart';
import '../data/datasources/inventory_remote_datasource.dart';
import '../data/repositories/inventory_repository_impl.dart';
import '../domain/repositories/inventory_repository.dart';
import '../domain/usecases/adjust_stock_usecase.dart';
import '../domain/usecases/create_product_usecase.dart';
import '../domain/usecases/get_adjustment_history_usecase.dart';
import '../domain/usecases/get_inventory_usecase.dart';
import '../domain/usecases/get_low_stock_usecase.dart';
import '../domain/usecases/get_product_details_usecase.dart';
import '../domain/usecases/search_products_usecase.dart';
import '../domain/usecases/toggle_product_status_usecase.dart';
import '../domain/usecases/update_product_usecase.dart';
import '../presentation/bloc/inventory_bloc.dart';

/// Inventory injection container
class InventoryInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<InventoryRemoteDataSource>(
      () => InventoryRemoteDataSourceImpl(serviceLocator()),
    );

    // Repositories
    serviceLocator.registerLazySingleton<InventoryRepository>(
      () => InventoryRepositoryImpl(serviceLocator()),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetInventoryUseCase>(
      () => GetInventoryUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<SearchProductsUseCase>(
      () => SearchProductsUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetLowStockUseCase>(
      () => GetLowStockUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetProductDetailsUseCase>(
      () => GetProductDetailsUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<AdjustStockUseCase>(
      () => AdjustStockUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<GetAdjustmentHistoryUseCase>(
      () => GetAdjustmentHistoryUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<CreateProductUseCase>(
      () => CreateProductUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<UpdateProductUseCase>(
      () => UpdateProductUseCaseImpl(serviceLocator()),
    );

    serviceLocator.registerLazySingleton<ToggleProductStatusUseCase>(
      () => ToggleProductStatusUseCaseImpl(serviceLocator()),
    );

    // BLoC
    serviceLocator.registerFactory<InventoryBloc>(
      () => InventoryBloc(
        getInventoryUseCase: serviceLocator(),
        searchProductsUseCase: serviceLocator(),
        getLowStockUseCase: serviceLocator(),
        getProductDetailsUseCase: serviceLocator(),
        adjustStockUseCase: serviceLocator(),
        getAdjustmentHistoryUseCase: serviceLocator(),
        createProductUseCase: serviceLocator(),
        updateProductUseCase: serviceLocator(),
        toggleProductStatusUseCase: serviceLocator(),
      ),
    );
  }
}
