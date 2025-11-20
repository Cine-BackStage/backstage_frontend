import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../../../adapters/storage/local_storage.dart';
import '../../authentication/data/datasources/auth_local_datasource.dart';
import '../data/datasources/profile_local_datasource.dart';
import '../data/datasources/profile_remote_datasource.dart';
import '../data/repositories/profile_repository_impl.dart';
import '../domain/repositories/profile_repository.dart';
import '../domain/usecases/change_password_usecase.dart';
import '../domain/usecases/get_employee_profile_usecase.dart';
import '../domain/usecases/get_settings_usecase.dart';
import '../domain/usecases/update_settings_usecase.dart';
import '../presentation/bloc/profile_bloc.dart';

/// Profile feature dependency injection
class ProfileInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    serviceLocator.registerLazySingleton<ProfileLocalDataSource>(
      () => ProfileLocalDataSourceImpl(
        serviceLocator<LocalStorage>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(
        remoteDataSource: serviceLocator<ProfileRemoteDataSource>(),
        localDataSource: serviceLocator<ProfileLocalDataSource>(),
        authLocalDataSource: serviceLocator<AuthLocalDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetEmployeeProfileUseCase>(
      () => GetEmployeeProfileUseCaseImpl(
        serviceLocator<ProfileRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ChangePasswordUseCase>(
      () => ChangePasswordUseCaseImpl(
        serviceLocator<ProfileRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetSettingsUseCase>(
      () => GetSettingsUseCaseImpl(
        serviceLocator<ProfileRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<UpdateSettingsUseCase>(
      () => UpdateSettingsUseCaseImpl(
        serviceLocator<ProfileRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<ProfileBloc>(
      () => ProfileBloc(
        getEmployeeProfileUseCase: serviceLocator<GetEmployeeProfileUseCase>(),
        changePasswordUseCase: serviceLocator<ChangePasswordUseCase>(),
        getSettingsUseCase: serviceLocator<GetSettingsUseCase>(),
        updateSettingsUseCase: serviceLocator<UpdateSettingsUseCase>(),
      ),
    );
  }
}
