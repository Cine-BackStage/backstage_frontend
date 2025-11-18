import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/error_mapper.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/movie.dart';
import '../../domain/repositories/movies_repository.dart';
import '../datasources/movies_remote_datasource.dart';

class MoviesRepositoryImpl implements MoviesRepository {
  final MoviesRemoteDataSource remoteDataSource;

  MoviesRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Movie>>> getMovies() async {
    try {
      final movies = await remoteDataSource.getMovies();
      return Right(movies.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieById(String movieId) async {
    try {
      final movie = await remoteDataSource.getMovieById(movieId);
      return Right(movie.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      final movies = await remoteDataSource.searchMovies(query);
      return Right(movies.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
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
  }) async {
    try {
      final movie = await remoteDataSource.createMovie(
        title: title,
        durationMin: durationMin,
        genre: genre,
        rating: rating,
        synopsis: synopsis,
        director: director,
        cast: cast,
        releaseDate: releaseDate,
        posterUrl: posterUrl,
        trailerUrl: trailerUrl,
      );
      return Right(movie.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
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
  }) async {
    try {
      final movie = await remoteDataSource.updateMovie(
        movieId: movieId,
        title: title,
        durationMin: durationMin,
        genre: genre,
        rating: rating,
        synopsis: synopsis,
        director: director,
        cast: cast,
        releaseDate: releaseDate,
        posterUrl: posterUrl,
        trailerUrl: trailerUrl,
        isActive: isActive,
      );
      return Right(movie.toEntity());
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMovie(String movieId) async {
    try {
      await remoteDataSource.deleteMovie(movieId);
      return const Right(null);
    } on DioException catch (e) {
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      return Left(ErrorMapper.fromException(e));
    }
  }
}
