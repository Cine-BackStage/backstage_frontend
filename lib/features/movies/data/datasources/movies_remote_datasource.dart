import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/services/logger_service.dart';
import '../models/movie_model.dart';

abstract class MoviesRemoteDataSource {
  Future<List<MovieModel>> getMovies();
  Future<MovieModel> getMovieById(String movieId);
  Future<List<MovieModel>> searchMovies(String query);
  Future<MovieModel> createMovie({
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
  Future<MovieModel> updateMovie({
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
  Future<void> deleteMovie(String movieId);
}

class MoviesRemoteDataSourceImpl implements MoviesRemoteDataSource {
  final HttpClient client;
  final logger = LoggerService();

  MoviesRemoteDataSourceImpl(this.client);

  @override
  Future<List<MovieModel>> getMovies() async {
    final response = await client.get(ApiConstants.movies);
    final data = response.data['data'] as List;
    return data.map((json) => MovieModel.fromJson(json)).toList();
  }

  @override
  Future<MovieModel> getMovieById(String movieId) async {
    logger.logDataSourceRequest('MoviesDataSource', 'getMovieById', {'movieId': movieId});
    final response = await client.get(ApiConstants.movieDetails(movieId));
    return MovieModel.fromJson(response.data['data']);
  }

  @override
  Future<List<MovieModel>> searchMovies(String query) async {
    final response = await client.get(
      ApiConstants.moviesSearch,
      queryParameters: {'q': query},
    );
    final data = response.data['data'] as List;
    return data.map((json) => MovieModel.fromJson(json)).toList();
  }

  @override
  Future<MovieModel> createMovie({
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
    final requestData = {
      'title': title,
      'duration_min': durationMin,
      'genre': genre,
      'rating': rating,
      if (synopsis != null && synopsis.isNotEmpty) 'description': synopsis,
      if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
      if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
      'is_active': true,
    };
    logger.logDataSourceRequest('MoviesDataSource', 'createMovie', requestData);
    final response = await client.post(
      ApiConstants.movies,
      data: requestData,
    );
    return MovieModel.fromJson(response.data['data']);
  }

  @override
  Future<MovieModel> updateMovie({
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
    final requestData = {
      'movieId': movieId,
      if (title != null) 'title': title,
      if (durationMin != null) 'duration_min': durationMin,
      if (genre != null) 'genre': genre,
      if (rating != null) 'rating': rating,
      if (synopsis != null && synopsis.isNotEmpty) 'description': synopsis,
      if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
      if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
      if (isActive != null) 'is_active': isActive,
    };

    logger.logDataSourceRequest('MoviesDataSource', 'updateMovie', requestData);

    final response = await client.put(
      ApiConstants.movieDetails(movieId),
      data: requestData,
    );
    return MovieModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteMovie(String movieId) async {
    logger.logDataSourceRequest('MoviesDataSource', 'deleteMovie', {'movieId': movieId});
    await client.delete(ApiConstants.movieDetails(movieId));
  }
}
