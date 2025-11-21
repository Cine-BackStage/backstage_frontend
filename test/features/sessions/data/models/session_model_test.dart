import 'package:flutter_test/flutter_test.dart';
import 'package:backstage_frontend/features/sessions/data/models/session_model.dart';
import 'package:backstage_frontend/features/sessions/domain/entities/session.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 15, 10, 0);
  final tSessionModel = SessionModel(
    id: 'session-1',
    movieId: 'movie-1',
    movieTitle: 'Test Movie',
    roomId: 'room-1',
    roomName: 'Room 1',
    startTime: tDateTime,
    endTime: tDateTime.add(Duration(hours: 2)),
    language: 'Português',
    subtitles: null,
    format: '2D',
    basePrice: 25.0,
    totalSeats: 100,
    availableSeats: 80,
    reservedSeats: 10,
    soldSeats: 10,
    status: 'SCHEDULED',
    moviePosterUrl: 'https://example.com/poster.jpg',
    movieRating: 'PG-13',
    movieDuration: 120,
  );

  test('should be a subclass of Session entity', () {
    // Assert
    expect(tSessionModel, isA<Session>());
  });

  group('fromJson', () {
    test('should return a valid SessionModel from JSON', () {
      // Arrange
      final json = {
        'id': 'session-1',
        'movieId': 'movie-1',
        'roomId': 'room-1',
        'startTime': tDateTime.toIso8601String(),
        'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
        'language': 'Português',
        'basePrice': 25.0,
        'availableSeats': 80,
        'reservedSeats': 10,
        'ticketsSold': 10,
        'status': 'SCHEDULED',
        'movie': {
          'title': 'Test Movie',
          'posterUrl': 'https://example.com/poster.jpg',
          'rating': 'PG-13',
          'durationMin': 120,
        },
        'room': {
          'name': 'Room 1',
          'capacity': 100,
          'roomType': '2D',
        },
      };

      // Act
      final result = SessionModel.fromJson(json);

      // Assert
      expect(result, isA<SessionModel>());
      expect(result.id, 'session-1');
      expect(result.movieId, 'movie-1');
      expect(result.movieTitle, 'Test Movie');
      expect(result.roomId, 'room-1');
      expect(result.roomName, 'Room 1');
      expect(result.basePrice, 25.0);
      expect(result.status, 'SCHEDULED');
    });

    test('should handle missing nested movie data', () {
      // Arrange
      final json = {
        'id': 'session-1',
        'movieId': 'movie-1',
        'roomId': 'room-1',
        'startTime': tDateTime.toIso8601String(),
        'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
        'language': 'Português',
        'basePrice': 25.0,
        'availableSeats': 80,
        'reservedSeats': 10,
        'ticketsSold': 10,
        'status': 'SCHEDULED',
        'room': {
          'name': 'Room 1',
          'capacity': 100,
          'roomType': '2D',
        },
      };

      // Act
      final result = SessionModel.fromJson(json);

      // Assert
      expect(result.movieTitle, 'Unknown Movie');
    });

    test('should handle missing nested room data', () {
      // Arrange
      final json = {
        'id': 'session-1',
        'movieId': 'movie-1',
        'roomId': 'room-1',
        'startTime': tDateTime.toIso8601String(),
        'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
        'language': 'Português',
        'basePrice': 25.0,
        'availableSeats': 80,
        'reservedSeats': 10,
        'ticketsSold': 10,
        'status': 'SCHEDULED',
        'movie': {
          'title': 'Test Movie',
        },
      };

      // Act
      final result = SessionModel.fromJson(json);

      // Assert
      expect(result.roomName, 'Unknown Room');
      expect(result.totalSeats, 0);
    });

    test('should handle nullable fields', () {
      // Arrange
      final json = {
        'id': 'session-1',
        'movieId': 'movie-1',
        'roomId': 'room-1',
        'startTime': tDateTime.toIso8601String(),
        'endTime': tDateTime.add(Duration(hours: 2)).toIso8601String(),
        'language': 'Português',
        'basePrice': 25.0,
        'availableSeats': 80,
        'reservedSeats': 10,
        'ticketsSold': 10,
        'status': 'SCHEDULED',
        'movie': {
          'title': 'Test Movie',
        },
        'room': {
          'name': 'Room 1',
          'capacity': 100,
          'roomType': '2D',
        },
      };

      // Act
      final result = SessionModel.fromJson(json);

      // Assert
      expect(result.moviePosterUrl, isNull);
      expect(result.movieRating, isNull);
      expect(result.subtitles, isNull);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () {
      // Act
      final result = tSessionModel.toJson();

      // Assert
      expect(result, isA<Map<String, dynamic>>());
      expect(result['id'], 'session-1');
      expect(result['movieId'], 'movie-1');
      expect(result['movieTitle'], 'Test Movie');
      expect(result['roomId'], 'room-1');
      expect(result['roomName'], 'Room 1');
      expect(result['basePrice'], 25.0);
      expect(result['status'], 'SCHEDULED');
    });
  });

  group('toEntity', () {
    test('should return a Session entity with the same data', () {
      // Act
      final result = tSessionModel.toEntity();

      // Assert
      expect(result, isA<Session>());
      expect(result.id, tSessionModel.id);
      expect(result.movieId, tSessionModel.movieId);
      expect(result.movieTitle, tSessionModel.movieTitle);
      expect(result.roomId, tSessionModel.roomId);
      expect(result.roomName, tSessionModel.roomName);
      expect(result.basePrice, tSessionModel.basePrice);
    });
  });
}
