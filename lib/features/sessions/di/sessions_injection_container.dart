import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../data/datasources/sessions_remote_datasource.dart';
import '../data/repositories/sessions_repository_impl.dart';
import '../domain/repositories/sessions_repository.dart';
import '../domain/usecases/calculate_ticket_price_usecase.dart';
import '../domain/usecases/cancel_ticket_usecase.dart';
import '../domain/usecases/deselect_seat_usecase.dart';
import '../domain/usecases/get_available_seats_usecase.dart';
import '../domain/usecases/get_session_details_usecase.dart';
import '../domain/usecases/get_sessions_usecase.dart';
import '../domain/usecases/purchase_tickets_usecase.dart';
import '../domain/usecases/select_seat_usecase.dart';
import '../domain/usecases/validate_ticket_usecase.dart';
import '../domain/usecases/create_session_usecase.dart';
import '../domain/usecases/update_session_usecase.dart';
import '../domain/usecases/delete_session_usecase.dart';
import '../presentation/bloc/sessions_bloc.dart';
import '../presentation/bloc/session_management_bloc.dart';

class SessionsInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<SessionsRemoteDataSource>(
      () => SessionsRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<SessionsRepository>(
      () => SessionsRepositoryImpl(
        serviceLocator<SessionsRemoteDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetSessionsUseCase>(
      () => GetSessionsUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetSessionDetailsUseCase>(
      () => GetSessionDetailsUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetAvailableSeatsUseCase>(
      () => GetAvailableSeatsUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SelectSeatUseCase>(
      () => SelectSeatUseCaseImpl(),
    );

    serviceLocator.registerLazySingleton<DeselectSeatUseCase>(
      () => DeselectSeatUseCaseImpl(),
    );

    serviceLocator.registerLazySingleton<CalculateTicketPriceUseCase>(
      () => CalculateTicketPriceUseCaseImpl(),
    );

    serviceLocator.registerLazySingleton<PurchaseTicketsUseCase>(
      () => PurchaseTicketsUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CancelTicketUseCase>(
      () => CancelTicketUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<ValidateTicketUseCase>(
      () => ValidateTicketUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CreateSessionUseCase>(
      () => CreateSessionUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<UpdateSessionUseCase>(
      () => UpdateSessionUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<DeleteSessionUseCase>(
      () => DeleteSessionUseCaseImpl(
        serviceLocator<SessionsRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<SessionsBloc>(
      () => SessionsBloc(
        getSessionsUseCase: serviceLocator<GetSessionsUseCase>(),
        getSessionDetailsUseCase: serviceLocator<GetSessionDetailsUseCase>(),
        getAvailableSeatsUseCase: serviceLocator<GetAvailableSeatsUseCase>(),
        selectSeatUseCase: serviceLocator<SelectSeatUseCase>(),
        deselectSeatUseCase: serviceLocator<DeselectSeatUseCase>(),
        calculateTicketPriceUseCase:
            serviceLocator<CalculateTicketPriceUseCase>(),
        purchaseTicketsUseCase: serviceLocator<PurchaseTicketsUseCase>(),
        cancelTicketUseCase: serviceLocator<CancelTicketUseCase>(),
        validateTicketUseCase: serviceLocator<ValidateTicketUseCase>(),
      ),
    );

    serviceLocator.registerFactory<SessionManagementBloc>(
      () => SessionManagementBloc(
        getSessionsUseCase: serviceLocator<GetSessionsUseCase>(),
        createSessionUseCase: serviceLocator<CreateSessionUseCase>(),
        updateSessionUseCase: serviceLocator<UpdateSessionUseCase>(),
        deleteSessionUseCase: serviceLocator<DeleteSessionUseCase>(),
      ),
    );
  }
}
