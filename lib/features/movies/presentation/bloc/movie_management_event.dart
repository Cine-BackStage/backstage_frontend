import 'package:equatable/equatable.dart';
import '../../domain/usecases/movie_usecases.dart';

abstract class MovieManagementEvent extends Equatable {
  const MovieManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoviesRequested extends MovieManagementEvent {
  const LoadMoviesRequested();
}

class RefreshMoviesRequested extends MovieManagementEvent {
  const RefreshMoviesRequested();
}

class CreateMovieRequested extends MovieManagementEvent {
  final CreateMovieParams params;

  const CreateMovieRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

class UpdateMovieRequested extends MovieManagementEvent {
  final UpdateMovieParams params;

  const UpdateMovieRequested({required this.params});

  @override
  List<Object?> get props => [params];
}

class DeleteMovieRequested extends MovieManagementEvent {
  final String movieId;

  const DeleteMovieRequested({required this.movieId});

  @override
  List<Object?> get props => [movieId];
}

class SearchMoviesRequested extends MovieManagementEvent {
  final String query;

  const SearchMoviesRequested({required this.query});

  @override
  List<Object?> get props => [query];
}
