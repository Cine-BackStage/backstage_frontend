import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/storage/local_storage.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/check_auth_status_usecase.dart';
import '../domain/usecases/request_password_reset_usecase.dart';
import '../domain/usecases/get_features_usecase.dart';

/// Authentication Module Dependency Injection Container
/// Registers all authentication-related dependencies
class AuthInjectionContainer {
  static Future<void> init() async {
    // Data Sources
    serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(),
    );
    serviceLocator.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(serviceLocator<LocalStorage>()),
    );

    // Repository
    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: serviceLocator<AuthRemoteDataSource>(),
        localDataSource: serviceLocator<AuthLocalDataSource>(),
      ),
    );

    // Use Cases
    serviceLocator.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(serviceLocator<AuthRepository>()),
    );
    serviceLocator.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCase(serviceLocator<AuthRepository>()),
    );
    serviceLocator.registerLazySingleton<CheckAuthStatusUseCase>(
      () => CheckAuthStatusUseCase(serviceLocator<AuthRepository>()),
    );
    serviceLocator.registerLazySingleton<RequestPasswordResetUseCase>(
      () => RequestPasswordResetUseCase(serviceLocator<AuthRepository>()),
    );
    serviceLocator.registerLazySingleton<GetFeaturesUseCase>(
      () => GetFeaturesUseCase(serviceLocator<AuthRepository>()),
    );
  }
}
