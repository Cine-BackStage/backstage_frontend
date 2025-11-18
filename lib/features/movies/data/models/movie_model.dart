import '../../domain/entities/movie.dart';

class MovieModel {
  final String id;
  final String title;
  final String? synopsis;
  final int durationMin;
  final String genre;
  final String rating;
  final String? director;
  final String? cast;
  final DateTime? releaseDate;
  final String? posterUrl;
  final String? trailerUrl;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MovieModel({
    required this.id,
    required this.title,
    this.synopsis,
    required this.durationMin,
    required this.genre,
    required this.rating,
    this.director,
    this.cast,
    this.releaseDate,
    this.posterUrl,
    this.trailerUrl,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MovieModel.fromJson(Map<String, dynamic> json) {
    return MovieModel(
      id: json['id'] as String,
      title: json['title'] as String,
      synopsis: json['synopsis'] as String?,
      durationMin: json['durationMin'] as int,
      genre: json['genre'] as String,
      rating: json['rating'] as String,
      director: json['director'] as String?,
      cast: json['cast'] as String?,
      releaseDate: json['releaseDate'] != null
          ? DateTime.parse(json['releaseDate'] as String)
          : null,
      posterUrl: json['posterUrl'] as String?,
      trailerUrl: json['trailerUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'synopsis': synopsis,
      'durationMin': durationMin,
      'genre': genre,
      'rating': rating,
      'director': director,
      'cast': cast,
      'releaseDate': releaseDate?.toIso8601String(),
      'posterUrl': posterUrl,
      'trailerUrl': trailerUrl,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Movie toEntity() {
    return Movie(
      id: id,
      title: title,
      synopsis: synopsis,
      durationMin: durationMin,
      genre: genre,
      rating: rating,
      director: director,
      cast: cast,
      releaseDate: releaseDate,
      posterUrl: posterUrl,
      trailerUrl: trailerUrl,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
