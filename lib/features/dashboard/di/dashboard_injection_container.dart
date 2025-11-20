import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../data/datasources/dashboard_remote_datasource.dart';
import '../data/repositories/dashboard_repository_impl.dart';
import '../domain/repositories/dashboard_repository.dart';
import '../domain/usecases/get_dashboard_stats_usecase.dart';
import '../domain/usecases/refresh_dashboard_usecase.dart';
import '../presentation/bloc/dashboard_bloc.dart';

/// Dashboard feature dependency injection
class DashboardInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<DashboardRemoteDataSource>(
      () => DashboardRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<DashboardRepository>(
      () => DashboardRepositoryImpl(
        remoteDataSource: serviceLocator<DashboardRemoteDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetDashboardStatsUseCase>(
      () => GetDashboardStatsUseCaseImpl(
        serviceLocator<DashboardRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<RefreshDashboardUseCase>(
      () => RefreshDashboardUseCaseImpl(
        serviceLocator<DashboardRepository>(),
      ),
    );

    // BLoC - Using LazySingleton so it can be accessed across the app
    serviceLocator.registerLazySingleton<DashboardBloc>(
      () => DashboardBloc(
        getDashboardStatsUseCase: serviceLocator<GetDashboardStatsUseCase>(),
        refreshDashboardUseCase: serviceLocator<RefreshDashboardUseCase>(),
      ),
    );
  }
}
