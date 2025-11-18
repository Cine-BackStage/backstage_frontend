import '../../domain/entities/session.dart';

class SessionModel extends Session {
  const SessionModel({
    required super.id,
    required super.movieId,
    required super.movieTitle,
    required super.roomId,
    required super.roomName,
    required super.startTime,
    required super.endTime,
    required super.language,
    required super.subtitles,
    required super.format,
    required super.basePrice,
    required super.totalSeats,
    required super.availableSeats,
    required super.reservedSeats,
    required super.soldSeats,
    required super.status,
    super.moviePosterUrl,
    super.movieRating,
    super.movieDuration,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    try {
      // Extract nested movie data - handle both Map and null cases
      Map<String, dynamic>? movie;
      if (json['movie'] != null && json['movie'] is Map) {
        movie = json['movie'] as Map<String, dynamic>;
      }

      Map<String, dynamic>? room;
      if (json['room'] != null && json['room'] is Map) {
        room = json['room'] as Map<String, dynamic>;
      }

      // Safe parsing helper functions
      String safeString(dynamic value, String fallback) {
        if (value == null) return fallback;
        if (value is String) return value;
        return value.toString();
      }

      int safeInt(dynamic value, int fallback) {
        if (value == null) return fallback;
        if (value is int) return value;
        if (value is String) return int.tryParse(value) ?? fallback;
        if (value is num) return value.toInt();
        return fallback;
      }

      double safeDouble(dynamic value, double fallback) {
        if (value == null) return fallback;
        if (value is double) return value;
        if (value is num) return value.toDouble();
        if (value is String) return double.tryParse(value) ?? fallback;
        return fallback;
      }

      DateTime safeDateTime(dynamic value, DateTime fallback) {
        if (value == null) return fallback;
        if (value is String) {
          final parsed = DateTime.tryParse(value);
          if (parsed != null) return parsed;
        }
        return fallback;
      }

      final now = DateTime.now();

      return SessionModel(
        id: safeString(json['id'], ''),
        movieId: safeString(json['movieId'], ''),
        movieTitle: safeString(movie?['title'], 'Unknown Movie'),
        roomId: safeString(json['roomId'], ''),
        roomName: safeString(room?['name'], 'Unknown Room'),
        startTime: safeDateTime(json['startTime'], now),
        endTime: safeDateTime(json['endTime'], now),
        language: safeString(json['language'], 'Português'),
        subtitles: json['subtitles'] as String?,
        format: safeString(room?['roomType'], '2D'),
        basePrice: safeDouble(json['basePrice'], 0.0),
        totalSeats: safeInt(room?['capacity'], 0),
        availableSeats: safeInt(json['availableSeats'], 0),
        reservedSeats: safeInt(json['reservedSeats'], 0),
        soldSeats: safeInt(json['ticketsSold'], 0),
        status: safeString(json['status'], 'SCHEDULED'),
        moviePosterUrl: movie?['posterUrl'] as String?,
        movieRating: movie?['rating'] as String?,
        movieDuration: movie?['durationMin'] != null
            ? safeInt(movie!['durationMin'], 0)
            : null,
      );
    } catch (e, stackTrace) {
      // Rethrow as FormatException with context for ErrorMapper to handle
      throw FormatException(
        'Failed to parse SessionModel from JSON: $e\nStack: $stackTrace',
        json.toString(),
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'roomId': roomId,
      'roomName': roomName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'language': language,
      'subtitles': subtitles,
      'format': format,
      'basePrice': basePrice,
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'reservedSeats': reservedSeats,
      'soldSeats': soldSeats,
      'status': status,
      'moviePosterUrl': moviePosterUrl,
      'movieRating': movieRating,
      'movieDuration': movieDuration,
    };
  }

  Session toEntity() {
    return Session(
      id: id,
      movieId: movieId,
      movieTitle: movieTitle,
      roomId: roomId,
      roomName: roomName,
      startTime: startTime,
      endTime: endTime,
      language: language,
      subtitles: subtitles,
      format: format,
      basePrice: basePrice,
      totalSeats: totalSeats,
      availableSeats: availableSeats,
      reservedSeats: reservedSeats,
      soldSeats: soldSeats,
      status: status,
      moviePosterUrl: moviePosterUrl,
      movieRating: movieRating,
      movieDuration: movieDuration,
    );
  }
}
