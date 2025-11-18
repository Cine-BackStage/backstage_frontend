import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/movie.dart';
import '../repositories/movies_repository.dart';

// ============================================================================
// Get Movies UseCase
// ============================================================================
abstract class GetMoviesUseCase {
  Future<Either<Failure, List<Movie>>> call();
}

class GetMoviesUseCaseImpl implements GetMoviesUseCase {
  final MoviesRepository repository;

  GetMoviesUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Movie>>> call() async {
    return await repository.getMovies();
  }
}

// ============================================================================
// Get Movie By ID UseCase
// ============================================================================
abstract class GetMovieByIdUseCase {
  Future<Either<Failure, Movie>> call(String movieId);
}

class GetMovieByIdUseCaseImpl implements GetMovieByIdUseCase {
  final MoviesRepository repository;

  GetMovieByIdUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Movie>> call(String movieId) async {
    return await repository.getMovieById(movieId);
  }
}

// ============================================================================
// Search Movies UseCase
// ============================================================================
abstract class SearchMoviesUseCase {
  Future<Either<Failure, List<Movie>>> call(String query);
}

class SearchMoviesUseCaseImpl implements SearchMoviesUseCase {
  final MoviesRepository repository;

  SearchMoviesUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, List<Movie>>> call(String query) async {
    return await repository.searchMovies(query);
  }
}

// ============================================================================
// Create Movie UseCase
// ============================================================================
class CreateMovieParams {
  final String title;
  final int durationMin;
  final String genre;
  final String rating;
  final String? synopsis;
  final String? director;
  final String? cast;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? trailerUrl;

  CreateMovieParams({
    required this.title,
    required this.durationMin,
    required this.genre,
    required this.rating,
    this.synopsis,
    this.director,
    this.cast,
    this.releaseDate,
    this.posterUrl,
    this.trailerUrl,
  });
}

abstract class CreateMovieUseCase {
  Future<Either<Failure, Movie>> call(CreateMovieParams params);
}

class CreateMovieUseCaseImpl implements CreateMovieUseCase {
  final MoviesRepository repository;

  CreateMovieUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Movie>> call(CreateMovieParams params) async {
    return await repository.createMovie(
      title: params.title,
      durationMin: params.durationMin,
      genre: params.genre,
      rating: params.rating,
      synopsis: params.synopsis,
      director: params.director,
      cast: params.cast,
      releaseDate: params.releaseDate,
      posterUrl: params.posterUrl,
      trailerUrl: params.trailerUrl,
    );
  }
}

// ============================================================================
// Update Movie UseCase
// ============================================================================
class UpdateMovieParams {
  final String movieId;
  final String? title;
  final int? durationMin;
  final String? genre;
  final String? rating;
  final String? synopsis;
  final String? director;
  final String? cast;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? trailerUrl;
  final bool? isActive;

  UpdateMovieParams({
    required this.movieId,
    this.title,
    this.durationMin,
    this.genre,
    this.rating,
    this.synopsis,
    this.director,
    this.cast,
    this.releaseDate,
    this.posterUrl,
    this.trailerUrl,
    this.isActive,
  });
}

abstract class UpdateMovieUseCase {
  Future<Either<Failure, Movie>> call(UpdateMovieParams params);
}

class UpdateMovieUseCaseImpl implements UpdateMovieUseCase {
  final MoviesRepository repository;

  UpdateMovieUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, Movie>> call(UpdateMovieParams params) async {
    return await repository.updateMovie(
      movieId: params.movieId,
      title: params.title,
      durationMin: params.durationMin,
      genre: params.genre,
      rating: params.rating,
      synopsis: params.synopsis,
      director: params.director,
      cast: params.cast,
      releaseDate: params.releaseDate,
      posterUrl: params.posterUrl,
      trailerUrl: params.trailerUrl,
      isActive: params.isActive,
    );
  }
}

// ============================================================================
// Delete Movie UseCase
// ============================================================================
abstract class DeleteMovieUseCase {
  Future<Either<Failure, void>> call(String movieId);
}

class DeleteMovieUseCaseImpl implements DeleteMovieUseCase {
  final MoviesRepository repository;

  DeleteMovieUseCaseImpl(this.repository);

  @override
  Future<Either<Failure, void>> call(String movieId) async {
    return await repository.deleteMovie(movieId);
  }
}
