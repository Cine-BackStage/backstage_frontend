import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../data/datasources/pos_remote_datasource.dart';
import '../data/repositories/pos_repository_impl.dart';
import '../domain/repositories/pos_repository.dart';
import '../domain/usecases/pos_usecases.dart';
import '../presentation/bloc/pos_bloc.dart';

/// POS feature dependency injection
class PosInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<PosRemoteDataSource>(
      () => PosRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<PosRepository>(
      () => PosRepositoryImpl(
        remoteDataSource: serviceLocator<PosRemoteDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetProductsUseCase>(
      () => GetProductsUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CreateSaleUseCase>(
      () => CreateSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetSaleUseCase>(
      () => GetSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<AddItemToSaleUseCase>(
      () => AddItemToSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<RemoveItemFromSaleUseCase>(
      () => RemoveItemFromSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ValidateDiscountUseCase>(
      () => ValidateDiscountUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ApplyDiscountUseCase>(
      () => ApplyDiscountUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<AddPaymentUseCase>(
      () => AddPaymentUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<RemovePaymentUseCase>(
      () => RemovePaymentUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<FinalizeSaleUseCase>(
      () => FinalizeSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CancelSaleUseCase>(
      () => CancelSaleUseCaseImpl(
        serviceLocator<PosRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<PosBloc>(
      () => PosBloc(
        getProductsUseCase: serviceLocator<GetProductsUseCase>(),
        createSaleUseCase: serviceLocator<CreateSaleUseCase>(),
        getSaleUseCase: serviceLocator<GetSaleUseCase>(),
        addItemToSaleUseCase: serviceLocator<AddItemToSaleUseCase>(),
        removeItemFromSaleUseCase: serviceLocator<RemoveItemFromSaleUseCase>(),
        validateDiscountUseCase: serviceLocator<ValidateDiscountUseCase>(),
        applyDiscountUseCase: serviceLocator<ApplyDiscountUseCase>(),
        addPaymentUseCase: serviceLocator<AddPaymentUseCase>(),
        removePaymentUseCase: serviceLocator<RemovePaymentUseCase>(),
        finalizeSaleUseCase: serviceLocator<FinalizeSaleUseCase>(),
        cancelSaleUseCase: serviceLocator<CancelSaleUseCase>(),
      ),
    );
  }
}
