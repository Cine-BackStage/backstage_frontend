import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:backstage_frontend/core/errors/failures.dart';
import 'package:backstage_frontend/features/movies/data/datasources/movies_remote_datasource.dart';
import 'package:backstage_frontend/features/movies/data/models/movie_model.dart';
import 'package:backstage_frontend/features/movies/data/repositories/movies_repository_impl.dart';

class MockMoviesRemoteDataSource extends Mock implements MoviesRemoteDataSource {}

void main() {
  late MoviesRepositoryImpl repository;
  late MockMoviesRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockMoviesRemoteDataSource();
    repository = MoviesRepositoryImpl(mockRemoteDataSource);
  });

  final tCreatedAt = DateTime(2024, 1, 1);
  final tUpdatedAt = DateTime(2024, 1, 2);
  final tReleaseDate = DateTime(2024, 6, 15);

  final tMovieModel = MovieModel(
    id: 'movie-123',
    title: 'Test Movie',
    synopsis: 'A great movie',
    durationMin: 120,
    genre: 'Action',
    rating: 'PG-13',
    director: 'John Director',
    cast: 'Actor 1, Actor 2',
    releaseDate: tReleaseDate,
    posterUrl: 'https://example.com/poster.jpg',
    trailerUrl: 'https://example.com/trailer.mp4',
    isActive: true,
    createdAt: tCreatedAt,
    updatedAt: tUpdatedAt,
  );

  group('getMovies', () {
    test('should return list of Movie entities when call is successful', () async {
      // Arrange
      final tMovieModels = [tMovieModel];
      when(() => mockRemoteDataSource.getMovies())
          .thenAnswer((_) async => tMovieModels);

      // Act
      final result = await repository.getMovies();

      // Assert
      verify(() => mockRemoteDataSource.getMovies()).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should return Right'),
        (movies) {
          expect(movies.length, 1);
          expect(movies.first.id, tMovieModel.id);
          expect(movies.first.title, tMovieModel.title);
        },
      );
    });

    test('should return empty list when no movies exist', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMovies())
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.getMovies();

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (movies) => expect(movies, isEmpty),
      );
    });

    test('should return ServerFailure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timeout',
      );
      when(() => mockRemoteDataSource.getMovies()).thenThrow(dioException);

      // Act
      final result = await repository.getMovies();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMovies())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getMovies();

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('getMovieById', () {
    const tMovieId = 'movie-123';

    test('should return Movie entity when call is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMovieById(any()))
          .thenAnswer((_) async => tMovieModel);

      // Act
      final result = await repository.getMovieById(tMovieId);

      // Assert
      verify(() => mockRemoteDataSource.getMovieById(tMovieId)).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should return Right'),
        (movie) {
          expect(movie.id, tMovieModel.id);
          expect(movie.title, tMovieModel.title);
        },
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      when(() => mockRemoteDataSource.getMovieById(any())).thenThrow(dioException);

      // Act
      final result = await repository.getMovieById(tMovieId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.getMovieById(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.getMovieById(tMovieId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('searchMovies', () {
    const tQuery = 'action';

    test('should return list of Movie entities when search is successful', () async {
      // Arrange
      final tMovieModels = [tMovieModel];
      when(() => mockRemoteDataSource.searchMovies(any()))
          .thenAnswer((_) async => tMovieModels);

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      verify(() => mockRemoteDataSource.searchMovies(tQuery)).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should return Right'),
        (movies) {
          expect(movies.length, 1);
          expect(movies.first.id, tMovieModel.id);
        },
      );
    });

    test('should return empty list when no movies match query', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchMovies(any()))
          .thenAnswer((_) async => []);

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      result.fold(
        (failure) => fail('Should return Right'),
        (movies) => expect(movies, isEmpty),
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        type: DioExceptionType.connectionTimeout,
      );
      when(() => mockRemoteDataSource.searchMovies(any())).thenThrow(dioException);

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.searchMovies(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.searchMovies(tQuery);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('createMovie', () {
    test('should return Movie entity when creation is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.createMovie(
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
          )).thenAnswer((_) async => tMovieModel);

      // Act
      final result = await repository.createMovie(
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
      verify(() => mockRemoteDataSource.createMovie(
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
          )).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should return Right'),
        (movie) {
          expect(movie.id, tMovieModel.id);
          expect(movie.title, tMovieModel.title);
        },
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 400,
        ),
      );
      when(() => mockRemoteDataSource.createMovie(
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
          )).thenThrow(dioException);

      // Act
      final result = await repository.createMovie(
        title: 'Test Movie',
        durationMin: 120,
        genre: 'Action',
        rating: 'PG-13',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.createMovie(
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.createMovie(
        title: 'Test Movie',
        durationMin: 120,
        genre: 'Action',
        rating: 'PG-13',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('updateMovie', () {
    const tMovieId = 'movie-123';

    test('should return updated Movie entity when update is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateMovie(
            movieId: any(named: 'movieId'),
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
            isActive: any(named: 'isActive'),
          )).thenAnswer((_) async => tMovieModel);

      // Act
      final result = await repository.updateMovie(
        movieId: tMovieId,
        title: 'Updated Movie',
        durationMin: 130,
        genre: 'Thriller',
        rating: 'R',
        synopsis: 'Updated synopsis',
        director: 'New Director',
        cast: 'New Actor 1, New Actor 2',
        releaseDate: tReleaseDate,
        posterUrl: 'https://example.com/new-poster.jpg',
        trailerUrl: 'https://example.com/new-trailer.mp4',
        isActive: false,
      );

      // Assert
      verify(() => mockRemoteDataSource.updateMovie(
            movieId: tMovieId,
            title: 'Updated Movie',
            durationMin: 130,
            genre: 'Thriller',
            rating: 'R',
            synopsis: 'Updated synopsis',
            director: 'New Director',
            cast: 'New Actor 1, New Actor 2',
            releaseDate: tReleaseDate,
            posterUrl: 'https://example.com/new-poster.jpg',
            trailerUrl: 'https://example.com/new-trailer.mp4',
            isActive: false,
          )).called(1);
      expect(result, isA<Right>());
      result.fold(
        (failure) => fail('Should return Right'),
        (movie) {
          expect(movie.id, tMovieModel.id);
          expect(movie.title, tMovieModel.title);
        },
      );
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      when(() => mockRemoteDataSource.updateMovie(
            movieId: any(named: 'movieId'),
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
            isActive: any(named: 'isActive'),
          )).thenThrow(dioException);

      // Act
      final result = await repository.updateMovie(
        movieId: tMovieId,
        title: 'Updated Movie',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.updateMovie(
            movieId: any(named: 'movieId'),
            title: any(named: 'title'),
            durationMin: any(named: 'durationMin'),
            genre: any(named: 'genre'),
            rating: any(named: 'rating'),
            synopsis: any(named: 'synopsis'),
            director: any(named: 'director'),
            cast: any(named: 'cast'),
            releaseDate: any(named: 'releaseDate'),
            posterUrl: any(named: 'posterUrl'),
            trailerUrl: any(named: 'trailerUrl'),
            isActive: any(named: 'isActive'),
          )).thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.updateMovie(
        movieId: tMovieId,
        title: 'Updated Movie',
      );

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });

  group('deleteMovie', () {
    const tMovieId = 'movie-123';

    test('should return Right when deletion is successful', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteMovie(any()))
          .thenAnswer((_) async => {});

      // Act
      final result = await repository.deleteMovie(tMovieId);

      // Assert
      verify(() => mockRemoteDataSource.deleteMovie(tMovieId)).called(1);
      expect(result, const Right(null));
    });

    test('should return Failure when DioException occurs', () async {
      // Arrange
      final dioException = DioException(
        requestOptions: RequestOptions(path: ''),
        response: Response(
          requestOptions: RequestOptions(path: ''),
          statusCode: 404,
        ),
      );
      when(() => mockRemoteDataSource.deleteMovie(any())).thenThrow(dioException);

      // Act
      final result = await repository.deleteMovie(tMovieId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('Should return Left'),
      );
    });

    test('should return GenericFailure when unexpected error occurs', () async {
      // Arrange
      when(() => mockRemoteDataSource.deleteMovie(any()))
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await repository.deleteMovie(tMovieId);

      // Assert
      expect(result, isA<Left>());
      result.fold(
        (failure) => expect(failure, isA<GenericFailure>()),
        (_) => fail('Should return Left'),
      );
    });
  });
}
