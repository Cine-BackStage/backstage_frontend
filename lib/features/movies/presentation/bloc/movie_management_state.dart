import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie.dart';

abstract class MovieManagementState extends Equatable {
  const MovieManagementState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Movie> movies) loaded,
    required T Function() saving,
    required T Function(Movie movie) saved,
    required T Function() deleting,
    required T Function(String movieId) deleted,
    required T Function(Failure failure) error,
  }) {
    if (this is MovieManagementInitial) return initial();
    if (this is MovieManagementLoading) return loading();
    if (this is MovieManagementLoaded) return loaded((this as MovieManagementLoaded).movies);
    if (this is MovieManagementSaving) return saving();
    if (this is MovieManagementSaved) return saved((this as MovieManagementSaved).movie);
    if (this is MovieManagementDeleting) return deleting();
    if (this is MovieManagementDeleted) return deleted((this as MovieManagementDeleted).movieId);
    if (this is MovieManagementError) return error((this as MovieManagementError).failure);
    throw Exception('Invalid state: $runtimeType');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Movie> movies)? loaded,
    T Function()? saving,
    T Function(Movie movie)? saved,
    T Function()? deleting,
    T Function(String movieId)? deleted,
    T Function(Failure failure)? error,
  }) {
    if (this is MovieManagementInitial && initial != null) return initial();
    if (this is MovieManagementLoading && loading != null) return loading();
    if (this is MovieManagementLoaded && loaded != null) return loaded((this as MovieManagementLoaded).movies);
    if (this is MovieManagementSaving && saving != null) return saving();
    if (this is MovieManagementSaved && saved != null) return saved((this as MovieManagementSaved).movie);
    if (this is MovieManagementDeleting && deleting != null) return deleting();
    if (this is MovieManagementDeleted && deleted != null) return deleted((this as MovieManagementDeleted).movieId);
    if (this is MovieManagementError && error != null) return error((this as MovieManagementError).failure);
    return null;
  }
}

class MovieManagementInitial extends MovieManagementState {
  const MovieManagementInitial();
}

class MovieManagementLoading extends MovieManagementState {
  const MovieManagementLoading();
}

class MovieManagementLoaded extends MovieManagementState {
  final List<Movie> movies;
  const MovieManagementLoaded({required this.movies});
  @override
  List<Object?> get props => [movies];
}

class MovieManagementSaving extends MovieManagementState {
  const MovieManagementSaving();
}

class MovieManagementSaved extends MovieManagementState {
  final Movie movie;
  const MovieManagementSaved({required this.movie});
  @override
  List<Object?> get props => [movie];
}

class MovieManagementDeleting extends MovieManagementState {
  const MovieManagementDeleting();
}

class MovieManagementDeleted extends MovieManagementState {
  final String movieId;
  const MovieManagementDeleted({required this.movieId});
  @override
  List<Object?> get props => [movieId];
}

class MovieManagementError extends MovieManagementState {
  final Failure failure;
  const MovieManagementError({required this.failure});
  @override
  List<Object?> get props => [failure];
  String get message => failure.userMessage;
}
