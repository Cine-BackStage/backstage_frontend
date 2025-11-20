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
    print('📡 Datasource: Getting movie by ID: $movieId');
    final response = await client.get(ApiConstants.movieDetails(movieId));
    print('✅ Datasource: Movie fetched successfully');
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
    print('📡 Datasource: Creating movie with title: $title');
    final response = await client.post(
      ApiConstants.movies,
      data: {
        'title': title,
        'duration_min': durationMin,
        'genre': genre,
        'rating': rating,
        if (synopsis != null && synopsis.isNotEmpty) 'description': synopsis,
        if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
        if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
        'is_active': true,
      },
    );
    print('✅ Datasource: Movie created successfully');
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
    print('📡 Datasource: Updating movie: $movieId');
    print('📡 Datasource: API endpoint: ${ApiConstants.movieDetails(movieId)}');

    final requestData = {
      if (title != null) 'title': title,
      if (durationMin != null) 'duration_min': durationMin,
      if (genre != null) 'genre': genre,
      if (rating != null) 'rating': rating,
      if (synopsis != null && synopsis.isNotEmpty) 'description': synopsis,
      if (releaseDate != null) 'release_date': releaseDate.toIso8601String(),
      if (posterUrl != null && posterUrl.isNotEmpty) 'poster_url': posterUrl,
      if (isActive != null) 'is_active': isActive,
    };

    print('📡 Datasource: Request data: $requestData');

    final response = await client.put(
      ApiConstants.movieDetails(movieId),
      data: requestData,
    );
    print('✅ Datasource: Movie updated successfully');
    return MovieModel.fromJson(response.data['data']);
  }

  @override
  Future<void> deleteMovie(String movieId) async {
    print('📡 Datasource: Deleting movie: $movieId');
    print('📡 Datasource: API endpoint: ${ApiConstants.movieDetails(movieId)}');
    await client.delete(ApiConstants.movieDetails(movieId));
    print('✅ Datasource: Movie deleted successfully');
  }
}
