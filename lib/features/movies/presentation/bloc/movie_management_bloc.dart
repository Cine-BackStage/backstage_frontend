import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/movie_usecases.dart';
import 'movie_management_event.dart';
import 'movie_management_state.dart';

class MovieManagementBloc extends Bloc<MovieManagementEvent, MovieManagementState> {
  final GetMoviesUseCase getMoviesUseCase;
  final CreateMovieUseCase createMovieUseCase;
  final UpdateMovieUseCase updateMovieUseCase;
  final DeleteMovieUseCase deleteMovieUseCase;
  final SearchMoviesUseCase searchMoviesUseCase;

  MovieManagementBloc({
    required this.getMoviesUseCase,
    required this.createMovieUseCase,
    required this.updateMovieUseCase,
    required this.deleteMovieUseCase,
    required this.searchMoviesUseCase,
  }) : super(const MovieManagementInitial()) {
    on<LoadMoviesRequested>(_onLoadMoviesRequested);
    on<RefreshMoviesRequested>(_onRefreshMoviesRequested);
    on<CreateMovieRequested>(_onCreateMovieRequested);
    on<UpdateMovieRequested>(_onUpdateMovieRequested);
    on<DeleteMovieRequested>(_onDeleteMovieRequested);
    on<SearchMoviesRequested>(_onSearchMoviesRequested);
  }

  Future<void> _onLoadMoviesRequested(
    LoadMoviesRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    emit(const MovieManagementLoading());

    final result = await getMoviesUseCase();

    result.fold(
      (failure) => emit(MovieManagementError(failure: failure)),
      (movies) => emit(MovieManagementLoaded(movies: movies)),
    );
  }

  Future<void> _onRefreshMoviesRequested(
    RefreshMoviesRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    final result = await getMoviesUseCase();

    result.fold(
      (failure) => emit(MovieManagementError(failure: failure)),
      (movies) => emit(MovieManagementLoaded(movies: movies)),
    );
  }

  Future<void> _onCreateMovieRequested(
    CreateMovieRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    emit(const MovieManagementSaving());

    final result = await createMovieUseCase(event.params);

    result.fold(
      (failure) => emit(MovieManagementError(failure: failure)),
      (movie) => emit(MovieManagementSaved(movie: movie)),
    );
  }

  Future<void> _onUpdateMovieRequested(
    UpdateMovieRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    print('🔄 Movie bloc: Updating movie ${event.params.movieId}');
    emit(const MovieManagementSaving());

    final result = await updateMovieUseCase(event.params);

    result.fold(
      (failure) {
        print('❌ Movie bloc: Update failed - ${failure.userMessage}');
        emit(MovieManagementError(failure: failure));
      },
      (movie) {
        print('✅ Movie bloc: Update successful');
        emit(MovieManagementSaved(movie: movie));
      },
    );
  }

  Future<void> _onDeleteMovieRequested(
    DeleteMovieRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    print('🗑️ Movie bloc: Deleting movie ${event.movieId}');
    emit(const MovieManagementDeleting());

    final result = await deleteMovieUseCase(event.movieId);

    result.fold(
      (failure) {
        print('❌ Movie bloc: Delete failed - ${failure.userMessage}');
        emit(MovieManagementError(failure: failure));
      },
      (_) {
        print('✅ Movie bloc: Delete successful');
        emit(MovieManagementDeleted(movieId: event.movieId));
      },
    );
  }

  Future<void> _onSearchMoviesRequested(
    SearchMoviesRequested event,
    Emitter<MovieManagementState> emit,
  ) async {
    emit(const MovieManagementLoading());

    final result = await searchMoviesUseCase(event.query);

    result.fold(
      (failure) => emit(MovieManagementError(failure: failure)),
      (movies) => emit(MovieManagementLoaded(movies: movies)),
    );
  }
}
