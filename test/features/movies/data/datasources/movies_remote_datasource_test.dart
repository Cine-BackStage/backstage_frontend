import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/adapters/http/http_client.dart';
import 'package:backstage_frontend/core/constants/api_constants.dart';
import 'package:backstage_frontend/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:backstage_frontend/features/movies/data/models/movie_model.dart';

class MockHttpClient extends Mock implements HttpClient {}

void main() {
  late MoviesRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = MoviesRemoteDataSourceImpl(mockHttpClient);
  });

  final tMovieData = {
    'id': 'movie-123',
    'title': 'Test Movie',
    'synopsis': 'A great movie',
    'durationMin': 120,
    'genre': 'Action',
    'rating': 'PG-13',
    'director': 'John Director',
    'cast': 'Actor 1, Actor 2',
    'releaseDate': '2024-06-15T00:00:00.000Z',
    'posterUrl': 'https://example.com/poster.jpg',
    'trailerUrl': 'https://example.com/trailer.mp4',
    'isActive': true,
    'createdAt': '2024-01-01T00:00:00.000Z',
    'updatedAt': '2024-01-02T00:00:00.000Z',
  };

  group('getMovies', () {
    test('should return list of MovieModel when the call is successful', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': [tMovieData],
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getMovies();

      // Assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'movie-123');
      expect(result.first.title, 'Test Movie');
      verify(() => mockHttpClient.get(ApiConstants.movies)).called(1);
    });

    test('should return empty list when no movies exist', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': [],
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getMovies();

      // Assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 0);
    });

    test('should return multiple movies', () async {
      // Arrange
      final movie2Data = {
        'id': 'movie-456',
        'title': 'Test Movie 2',
        'durationMin': 90,
        'genre': 'Comedy',
        'rating': 'PG',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000Z',
        'updatedAt': '2024-01-02T00:00:00.000Z',
      };

      final responseData = {
        'success': true,
        'data': [tMovieData, movie2Data],
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getMovies();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'movie-123');
      expect(result[1].id, 'movie-456');
    });
  });

  group('getMovieById', () {
    const tMovieId = 'movie-123';

    test('should return MovieModel when the call is successful', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.get(any()))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.getMovieById(tMovieId);

      // Assert
      expect(result, isA<MovieModel>());
      expect(result.id, 'movie-123');
      expect(result.title, 'Test Movie');
      verify(() => mockHttpClient.get(ApiConstants.movieDetails(tMovieId))).called(1);
    });
  });

  group('searchMovies', () {
    const tQuery = 'action';

    test('should return list of MovieModel when search is successful', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': [tMovieData],
      };

      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.searchMovies(tQuery);

      // Assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 1);
      expect(result.first.id, 'movie-123');
      verify(() => mockHttpClient.get(
            ApiConstants.moviesSearch,
            queryParameters: {'q': tQuery},
          )).called(1);
    });

    test('should return empty list when no movies match query', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': [],
      };

      when(() => mockHttpClient.get(any(), queryParameters: any(named: 'queryParameters')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.searchMovies(tQuery);

      // Assert
      expect(result, isA<List<MovieModel>>());
      expect(result.length, 0);
    });
  });

  group('createMovie', () {
    final tReleaseDate = DateTime(2024, 6, 15);

    test('should return MovieModel when creation is successful', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.createMovie(
        title: 'Test Movie',
        durationMin: 120,
        genre: 'Action',
        rating: 'PG-13',
        synopsis: 'A great movie',
        director: 'John Director',
        cast: 'Actor 1, Actor 2',
        releaseDate: tReleaseDate,
        posterUrl: 'https://example.com/poster.jpg',
        trailerUrl: 'https://example.com/trailer.mp4',
      );

      // Assert
      expect(result, isA<MovieModel>());
      expect(result.id, 'movie-123');
      expect(result.title, 'Test Movie');
      verify(() => mockHttpClient.post(
            ApiConstants.movies,
            data: any(named: 'data'),
          )).called(1);
    });

    test('should send correct request data with all fields', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createMovie(
        title: 'Test Movie',
        durationMin: 120,
        genre: 'Action',
        rating: 'PG-13',
        synopsis: 'A great movie',
        releaseDate: tReleaseDate,
        posterUrl: 'https://example.com/poster.jpg',
      );

      // Assert
      final captured = verify(() => mockHttpClient.post(
            ApiConstants.movies,
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData['title'], 'Test Movie');
      expect(requestData['duration_min'], 120);
      expect(requestData['genre'], 'Action');
      expect(requestData['rating'], 'PG-13');
      expect(requestData['description'], 'A great movie');
      expect(requestData['release_date'], tReleaseDate.toIso8601String());
      expect(requestData['poster_url'], 'https://example.com/poster.jpg');
      expect(requestData['is_active'], true);
    });

    test('should not include optional fields when they are null', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createMovie(
        title: 'Minimal Movie',
        durationMin: 90,
        genre: 'Drama',
        rating: 'PG',
      );

      // Assert
      final captured = verify(() => mockHttpClient.post(
            ApiConstants.movies,
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData.containsKey('description'), false);
      expect(requestData.containsKey('release_date'), false);
      expect(requestData.containsKey('poster_url'), false);
    });

    test('should not include empty synopsis', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.post(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 201,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.createMovie(
        title: 'Test Movie',
        durationMin: 120,
        genre: 'Action',
        rating: 'PG-13',
        synopsis: '',
      );

      // Assert
      final captured = verify(() => mockHttpClient.post(
            ApiConstants.movies,
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData.containsKey('description'), false);
    });
  });

  group('updateMovie', () {
    const tMovieId = 'movie-123';
    final tReleaseDate = DateTime(2024, 6, 15);

    test('should return updated MovieModel when update is successful', () async {
      // Arrange
      final updatedMovieData = {
        ...tMovieData,
        'title': 'Updated Movie',
      };

      final responseData = {
        'success': true,
        'data': updatedMovieData,
      };

      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      final result = await dataSource.updateMovie(
        movieId: tMovieId,
        title: 'Updated Movie',
        durationMin: 130,
        genre: 'Thriller',
        rating: 'R',
        synopsis: 'Updated synopsis',
        releaseDate: tReleaseDate,
        posterUrl: 'https://example.com/new-poster.jpg',
        isActive: false,
      );

      // Assert
      expect(result, isA<MovieModel>());
      expect(result.title, 'Updated Movie');
      verify(() => mockHttpClient.put(
            ApiConstants.movieDetails(tMovieId),
            data: any(named: 'data'),
          )).called(1);
    });

    test('should send correct request data with all fields', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateMovie(
        movieId: tMovieId,
        title: 'Updated Movie',
        durationMin: 130,
        genre: 'Thriller',
        rating: 'R',
        synopsis: 'Updated synopsis',
        releaseDate: tReleaseDate,
        posterUrl: 'https://example.com/new-poster.jpg',
        isActive: false,
      );

      // Assert
      final captured = verify(() => mockHttpClient.put(
            ApiConstants.movieDetails(tMovieId),
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData['movieId'], tMovieId);
      expect(requestData['title'], 'Updated Movie');
      expect(requestData['duration_min'], 130);
      expect(requestData['genre'], 'Thriller');
      expect(requestData['rating'], 'R');
      expect(requestData['description'], 'Updated synopsis');
      expect(requestData['release_date'], tReleaseDate.toIso8601String());
      expect(requestData['poster_url'], 'https://example.com/new-poster.jpg');
      expect(requestData['is_active'], false);
    });

    test('should only include non-null fields in request', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateMovie(
        movieId: tMovieId,
        title: 'Updated Title',
      );

      // Assert
      final captured = verify(() => mockHttpClient.put(
            ApiConstants.movieDetails(tMovieId),
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData['movieId'], tMovieId);
      expect(requestData['title'], 'Updated Title');
      expect(requestData.containsKey('duration_min'), false);
      expect(requestData.containsKey('genre'), false);
      expect(requestData.containsKey('rating'), false);
    });

    test('should not include empty synopsis', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateMovie(
        movieId: tMovieId,
        synopsis: '',
      );

      // Assert
      final captured = verify(() => mockHttpClient.put(
            ApiConstants.movieDetails(tMovieId),
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData.containsKey('description'), false);
    });

    test('should not include empty posterUrl', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': tMovieData,
      };

      when(() => mockHttpClient.put(any(), data: any(named: 'data')))
          .thenAnswer((_) async => Response(
                data: responseData,
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.updateMovie(
        movieId: tMovieId,
        posterUrl: '',
      );

      // Assert
      final captured = verify(() => mockHttpClient.put(
            ApiConstants.movieDetails(tMovieId),
            data: captureAny(named: 'data'),
          )).captured;

      final requestData = captured.first as Map<String, dynamic>;
      expect(requestData.containsKey('poster_url'), false);
    });
  });

  group('deleteMovie', () {
    const tMovieId = 'movie-123';

    test('should complete successfully when deletion is successful', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {'success': true},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.deleteMovie(tMovieId);

      // Assert
      verify(() => mockHttpClient.delete(ApiConstants.movieDetails(tMovieId))).called(1);
    });

    test('should call delete with correct endpoint', () async {
      // Arrange
      when(() => mockHttpClient.delete(any()))
          .thenAnswer((_) async => Response(
                data: {'success': true},
                statusCode: 200,
                requestOptions: RequestOptions(path: ''),
              ));

      // Act
      await dataSource.deleteMovie(tMovieId);

      // Assert
      verify(() => mockHttpClient.delete(ApiConstants.movieDetails(tMovieId))).called(1);
      verifyNoMoreInteractions(mockHttpClient);
    });
  });
}
