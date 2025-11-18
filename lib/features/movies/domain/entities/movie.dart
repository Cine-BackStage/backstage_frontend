import 'package:equatable/equatable.dart';

class Movie extends Equatable {
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

  const Movie({
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

  @override
  List<Object?> get props => [
        id,
        title,
        synopsis,
        durationMin,
        genre,
        rating,
        director,
        cast,
        releaseDate,
        posterUrl,
        trailerUrl,
        isActive,
        createdAt,
        updatedAt,
      ];
}
