import '../../../../adapters/http/http_client.dart';
import '../../../../core/constants/api_constants.dart';
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

  MoviesRemoteDataSourceImpl(this.client);

  @override
  Future<List<MovieModel>> getMovies() async {
    final response = await client.get(ApiConstants.movies);
    final data = response.data['data'] as List;
    return data.map((json) => MovieModel.fromJson(json)).toList();
  }

  @override
  Future<MovieModel> getMovieById(String movieId) async {
    final response = await client.get(ApiConstants.movieDetails(int.parse(movieId)));
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
    final response = await client.post(
      ApiConstants.movies,
      data: {
        'title': title,
        'durationMin': durationMin,
        'genre': genre,
        'rating': rating,
        if (synopsis != null) 'synopsis': synopsis,
        if (director != null) 'director': director,
        if (cast != null) 'cast': cast,
        if (releaseDate != null) 'releaseDate': releaseDate.toIso8601String(),
        if (posterUrl != null) 'posterUrl': posterUrl,
        if (trailerUrl != null) 'trailerUrl': trailerUrl,
      },
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
    final response = await client.put(
      ApiConstants.movieDetails(int.parse(movieId)),
      data: {
        if (title != null) 'title': title,
        if (durationMin != null) 'durationMin': durationMin,
        if (genre != null) 'genre': genre,
        if (rating != null) 'rating': rating,
        if (synopsis != null) 'synopsis': synopsis,
        if (director != null) 'director': director,
        if (cast != null) 'cast': cast,
        if (releaseDate != null) 'releaseDate': releaseDate.toIso8601String(),
        if (posterUrl != null) 'posterUrl': posterUrl,
        if (trailerUrl != null) 'trailerUrl': trailerUrl,
        if (isActive != null) 'isActive': isActive,
      },
    );
    return MovieModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteMovie(String movieId) async {
    await client.delete(ApiConstants.movieDetails(int.parse(movieId)));
  }
}
