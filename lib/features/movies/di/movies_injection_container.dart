import '../../../adapters/dependency_injection/service_locator.dart';
import '../../../adapters/http/http_client.dart';
import '../data/datasources/movies_remote_datasource.dart';
import '../data/repositories/movies_repository_impl.dart';
import '../domain/repositories/movies_repository.dart';
import '../domain/usecases/movie_usecases.dart';
import '../presentation/bloc/movie_management_bloc.dart';

class MoviesInjectionContainer {
  static Future<void> init() async {
    // Data sources
    serviceLocator.registerLazySingleton<MoviesRemoteDataSource>(
      () => MoviesRemoteDataSourceImpl(
        serviceLocator<HttpClient>(),
      ),
    );

    // Repository
    serviceLocator.registerLazySingleton<MoviesRepository>(
      () => MoviesRepositoryImpl(
        serviceLocator<MoviesRemoteDataSource>(),
      ),
    );

    // Use cases
    serviceLocator.registerLazySingleton<GetMoviesUseCase>(
      () => GetMoviesUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<GetMovieByIdUseCase>(
      () => GetMovieByIdUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<SearchMoviesUseCase>(
      () => SearchMoviesUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<CreateMovieUseCase>(
      () => CreateMovieUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<UpdateMovieUseCase>(
      () => UpdateMovieUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    serviceLocator.registerLazySingleton<DeleteMovieUseCase>(
      () => DeleteMovieUseCaseImpl(
        serviceLocator<MoviesRepository>(),
      ),
    );

    // BLoC
    serviceLocator.registerFactory<MovieManagementBloc>(
      () => MovieManagementBloc(
        getMoviesUseCase: serviceLocator<GetMoviesUseCase>(),
        createMovieUseCase: serviceLocator<CreateMovieUseCase>(),
        updateMovieUseCase: serviceLocator<UpdateMovieUseCase>(),
        deleteMovieUseCase: serviceLocator<DeleteMovieUseCase>(),
        searchMoviesUseCase: serviceLocator<SearchMoviesUseCase>(),
      ),
    );
  }
}
