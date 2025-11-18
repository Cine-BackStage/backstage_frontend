import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/movie.dart';

abstract class MoviesRepository {
  Future<Either<Failure, List<Movie>>> getMovies();
  Future<Either<Failure, Movie>> getMovieById(String movieId);
  Future<Either<Failure, List<Movie>>> searchMovies(String query);

  Future<Either<Failure, Movie>> createMovie({
    required String title,
    required int durationMin,
    required String genre,
    required String rating,
    String? synopsis,
    String? director,
    String? cast,
    DateTime? releaseDate,
    String? posterUrl,
    String? trailerUrl,
  });

  Future<Either<Failure, Movie>> updateMovie({
    required String movieId,
    String? title,
    int? durationMin,
    String? genre,
    String? rating,
    String? synopsis,
    String? director,
    String? cast,
    DateTime? releaseDate,
    String? posterUrl,
    String? trailerUrl,
    bool? isActive,
  });

  Future<Either<Failure, void>> deleteMovie(String movieId);
}
