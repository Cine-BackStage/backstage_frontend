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
      print('📚 Repository: Getting all movies');
      final movies = await remoteDataSource.getMovies();
      print('✅ Repository: Fetched ${movies.length} movies');
      return Right(movies.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Repository: DioException getting movies - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Repository: Exception getting movies - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, Movie>> getMovieById(String movieId) async {
    try {
      print('📚 Repository: Getting movie by ID: $movieId');
      final movie = await remoteDataSource.getMovieById(movieId);
      print('✅ Repository: Movie fetched successfully');
      return Right(movie.toEntity());
    } on DioException catch (e) {
      print('❌ Repository: DioException getting movie - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Repository: Exception getting movie - $e');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) async {
    try {
      print('📚 Repository: Searching movies with query: $query');
      final movies = await remoteDataSource.searchMovies(query);
      print('✅ Repository: Found ${movies.length} movies');
      return Right(movies.map((model) => model.toEntity()).toList());
    } on DioException catch (e) {
      print('❌ Repository: DioException searching movies - ${e.message}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Repository: Exception searching movies - $e');
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
      print('📚 Repository: Creating movie: $title');
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
      print('✅ Repository: Movie created successfully');
      return Right(movie.toEntity());
    } on DioException catch (e) {
      print('❌ Repository: DioException creating movie - ${e.message}');
      print('❌ Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e) {
      print('❌ Repository: Exception creating movie - $e');
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
      print('📚 Repository: Updating movie $movieId');
      print('📚 Repository: Update data - title: $title, duration: $durationMin, genre: $genre, rating: $rating, isActive: $isActive');
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
      print('✅ Repository: Movie updated successfully');
      return Right(movie.toEntity());
    } on DioException catch (e) {
      print('❌ Repository: DioException updating movie - ${e.message}');
      print('❌ Repository: Status code: ${e.response?.statusCode}');
      print('❌ Repository: Response data: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Repository: Exception updating movie - $e');
      print('❌ Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }

  @override
  Future<Either<Failure, void>> deleteMovie(String movieId) async {
    try {
      print('📚 Repository: Deleting movie $movieId');
      await remoteDataSource.deleteMovie(movieId);
      print('✅ Repository: Movie deleted successfully');
      return const Right(null);
    } on DioException catch (e) {
      print('❌ Repository: DioException deleting movie - ${e.message}');
      print('❌ Repository: Response: ${e.response?.data}');
      return Left(ErrorMapper.fromDioException(e));
    } catch (e, stackTrace) {
      print('❌ Repository: Exception deleting movie - $e');
      print('❌ Repository: StackTrace: $stackTrace');
      return Left(ErrorMapper.fromException(e));
    }
  }
}
