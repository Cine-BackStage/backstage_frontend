import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/movies/data/models/movie_model.dart';
import 'package:backstage_frontend/features/movies/domain/entities/movie.dart';

void main() {
  final tCreatedAt = DateTime(2024, 1, 1);
  final tUpdatedAt = DateTime(2024, 1, 2);
  final tReleaseDate = DateTime(2024, 6, 15);

  final tMovieModel = MovieModel(
    id: 'movie-123',
    title: 'Test Movie',
    synopsis: 'A great test movie',
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

  test('should be a subclass of Movie entity', () {
    expect(tMovieModel.toEntity(), isA<Movie>());
  });

  group('fromJson', () {
    test('should return a valid model from JSON with all fields', () {
      // Arrange
      final jsonMap = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'synopsis': 'A great test movie',
        'durationMin': 120,
        'genre': 'Action',
        'rating': 'PG-13',
        'director': 'John Director',
        'cast': 'Actor 1, Actor 2',
        'releaseDate': '2024-06-15T00:00:00.000',
        'posterUrl': 'https://example.com/poster.jpg',
        'trailerUrl': 'https://example.com/trailer.mp4',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };

      // Act
      final result = MovieModel.fromJson(jsonMap);

      // Assert
      expect(result.id, 'movie-123');
      expect(result.title, 'Test Movie');
      expect(result.synopsis, 'A great test movie');
      expect(result.durationMin, 120);
      expect(result.genre, 'Action');
      expect(result.rating, 'PG-13');
      expect(result.director, 'John Director');
      expect(result.cast, 'Actor 1, Actor 2');
      expect(result.releaseDate, tReleaseDate);
      expect(result.posterUrl, 'https://example.com/poster.jpg');
      expect(result.trailerUrl, 'https://example.com/trailer.mp4');
      expect(result.isActive, true);
      expect(result.createdAt, tCreatedAt);
      expect(result.updatedAt, tUpdatedAt);
    });

    test('should return model with isActive=true when not provided', () {
      // Arrange
      final jsonMap = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'durationMin': 120,
        'genre': 'Action',
        'rating': 'PG-13',
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };

      // Act
      final result = MovieModel.fromJson(jsonMap);

      // Assert
      expect(result.isActive, true);
    });

    test('should return model with null optional fields when not provided', () {
      // Arrange
      final jsonMap = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'durationMin': 120,
        'genre': 'Action',
        'rating': 'PG-13',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };

      // Act
      final result = MovieModel.fromJson(jsonMap);

      // Assert
      expect(result.synopsis, null);
      expect(result.director, null);
      expect(result.cast, null);
      expect(result.releaseDate, null);
      expect(result.posterUrl, null);
      expect(result.trailerUrl, null);
    });

    test('should handle null releaseDate', () {
      // Arrange
      final jsonMap = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'durationMin': 120,
        'genre': 'Action',
        'rating': 'PG-13',
        'releaseDate': null,
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };

      // Act
      final result = MovieModel.fromJson(jsonMap);

      // Assert
      expect(result.releaseDate, null);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing proper data', () {
      // Act
      final result = tMovieModel.toJson();

      // Assert
      final expectedMap = {
        'id': 'movie-123',
        'title': 'Test Movie',
        'synopsis': 'A great test movie',
        'durationMin': 120,
        'genre': 'Action',
        'rating': 'PG-13',
        'director': 'John Director',
        'cast': 'Actor 1, Actor 2',
        'releaseDate': '2024-06-15T00:00:00.000',
        'posterUrl': 'https://example.com/poster.jpg',
        'trailerUrl': 'https://example.com/trailer.mp4',
        'isActive': true,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-02T00:00:00.000',
      };
      expect(result, equals(expectedMap));
    });

    test('should handle null optional fields', () {
      // Arrange
      final minimalModel = MovieModel(
        id: 'movie-456',
        title: 'Minimal Movie',
        durationMin: 90,
        genre: 'Drama',
        rating: 'PG',
        isActive: true,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Act
      final result = minimalModel.toJson();

      // Assert
      expect(result['synopsis'], null);
      expect(result['director'], null);
      expect(result['cast'], null);
      expect(result['releaseDate'], null);
      expect(result['posterUrl'], null);
      expect(result['trailerUrl'], null);
    });
  });

  group('toEntity', () {
    test('should convert MovieModel to Movie entity', () {
      // Act
      final result = tMovieModel.toEntity();

      // Assert
      expect(result, isA<Movie>());
      expect(result.id, tMovieModel.id);
      expect(result.title, tMovieModel.title);
      expect(result.synopsis, tMovieModel.synopsis);
      expect(result.durationMin, tMovieModel.durationMin);
      expect(result.genre, tMovieModel.genre);
      expect(result.rating, tMovieModel.rating);
      expect(result.director, tMovieModel.director);
      expect(result.cast, tMovieModel.cast);
      expect(result.releaseDate, tMovieModel.releaseDate);
      expect(result.posterUrl, tMovieModel.posterUrl);
      expect(result.trailerUrl, tMovieModel.trailerUrl);
      expect(result.isActive, tMovieModel.isActive);
      expect(result.createdAt, tMovieModel.createdAt);
      expect(result.updatedAt, tMovieModel.updatedAt);
    });

    test('should handle null optional fields when converting to entity', () {
      // Arrange
      final minimalModel = MovieModel(
        id: 'movie-456',
        title: 'Minimal Movie',
        durationMin: 90,
        genre: 'Drama',
        rating: 'PG',
        isActive: true,
        createdAt: tCreatedAt,
        updatedAt: tUpdatedAt,
      );

      // Act
      final result = minimalModel.toEntity();

      // Assert
      expect(result.synopsis, null);
      expect(result.director, null);
      expect(result.cast, null);
      expect(result.releaseDate, null);
      expect(result.posterUrl, null);
      expect(result.trailerUrl, null);
    });
  });

  group('JSON serialization round-trip', () {
    test('should maintain data integrity through fromJson -> toJson', () {
      // Arrange
      final originalJson = {
        'id': 'movie-789',
        'title': 'Round Trip Movie',
        'synopsis': 'Testing serialization',
        'durationMin': 105,
        'genre': 'Comedy',
        'rating': 'PG',
        'director': 'Test Director',
        'cast': 'Actor A, Actor B',
        'releaseDate': '2024-03-20T00:00:00.000',
        'posterUrl': 'https://example.com/test.jpg',
        'trailerUrl': 'https://example.com/test.mp4',
        'isActive': false,
        'createdAt': '2024-01-01T00:00:00.000',
        'updatedAt': '2024-01-03T00:00:00.000',
      };

      // Act
      final model = MovieModel.fromJson(originalJson);
      final resultJson = model.toJson();

      // Assert
      expect(resultJson, equals(originalJson));
    });
  });
}
