import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../../../adapters/storage/local_storage.dart';
import '../data/datasources/auth_local_datasource.dart';
import '../data/datasources/auth_remote_datasource.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/usecases/check_auth_status_usecase.dart';
import '../domain/usecases/get_current_employee_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../presentation/bloc/auth_bloc.dart';

/// Authentication feature dependency injection
class AuthInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    serviceLocator.registerLazySingleton<AuthLocalDataSource>(
      () => AuthLocalDataSourceImpl(
        serviceLocator<LocalStorage>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        remoteDataSource: serviceLocator<AuthRemoteDataSource>(),
        localDataSource: serviceLocator<AuthLocalDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<LoginUseCase>(
      () => LoginUseCaseImpl(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<LogoutUseCase>(
      () => LogoutUseCaseImpl(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CheckAuthStatusUseCase>(
      () => CheckAuthStatusUseCaseImpl(
        serviceLocator<AuthRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetCurrentEmployeeUseCase>(
      () => GetCurrentEmployeeUseCaseImpl(
        serviceLocator<AuthRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<AuthBloc>(
      () => AuthBloc(
        loginUseCase: serviceLocator<LoginUseCase>(),
        logoutUseCase: serviceLocator<LogoutUseCase>(),
        checkAuthStatusUseCase: serviceLocator<CheckAuthStatusUseCase>(),
        getCurrentEmployeeUseCase: serviceLocator<GetCurrentEmployeeUseCase>(),
      ),
    );
  }
}
