import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../data/datasources/rooms_remote_datasource.dart';
import '../data/repositories/rooms_repository_impl.dart';
import '../domain/repositories/rooms_repository.dart';
import '../domain/usecases/room_usecases.dart';
import '../presentation/bloc/room_management_bloc.dart';

class RoomsInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<RoomsRemoteDataSource>(
      () => RoomsRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<RoomsRepository>(
      () => RoomsRepositoryImpl(
        serviceLocator<RoomsRemoteDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetRoomsUseCase>(
      () => GetRoomsUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetRoomByIdUseCase>(
      () => GetRoomByIdUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CreateRoomUseCase>(
      () => CreateRoomUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<UpdateRoomUseCase>(
      () => UpdateRoomUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<DeleteRoomUseCase>(
      () => DeleteRoomUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ActivateRoomUseCase>(
      () => ActivateRoomUseCaseImpl(
        serviceLocator<RoomsRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<RoomManagementBloc>(
      () => RoomManagementBloc(
        getRoomsUseCase: serviceLocator<GetRoomsUseCase>(),
        createRoomUseCase: serviceLocator<CreateRoomUseCase>(),
        updateRoomUseCase: serviceLocator<UpdateRoomUseCase>(),
        deleteRoomUseCase: serviceLocator<DeleteRoomUseCase>(),
        activateRoomUseCase: serviceLocator<ActivateRoomUseCase>(),
      ),
    );
  }
}
