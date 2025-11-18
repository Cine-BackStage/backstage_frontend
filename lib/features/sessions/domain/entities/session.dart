import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String movieId;
  final String movieTitle;
  final String roomId;
  final String roomName;
  final DateTime startTime;
  final DateTime endTime;
  final String language;
  final String? subtitles;
  final String format;
  final double basePrice;
  final int totalSeats;
  final int availableSeats;
  final int reservedSeats;
  final int soldSeats;
  final String status;
  final String? moviePosterUrl;
  final String? movieRating;
  final int? movieDuration;

  const Session({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.roomId,
    required this.roomName,
    required this.startTime,
    required this.endTime,
    required this.language,
    this.subtitles,
    required this.format,
    required this.basePrice,
    required this.totalSeats,
    required this.availableSeats,
    required this.reservedSeats,
    required this.soldSeats,
    required this.status,
    this.moviePosterUrl,
    this.movieRating,
    this.movieDuration,
  });

  // Status checks based on SessionStatus enum: SCHEDULED, IN_PROGRESS, CANCELED, COMPLETED
  bool get isScheduled => status == 'SCHEDULED';
  bool get isInProgress => status == 'IN_PROGRESS';
  bool get isCanceled => status == 'CANCELED';
  bool get isCompleted => status == 'COMPLETED';

  // Availability checks
  bool get canSellTickets => isScheduled && availableSeats > 0;
  bool get isAvailable => availableSeats > 0 && (isScheduled || isInProgress);
  bool get isSoldOut => availableSeats == 0;
  bool get hasStarted => DateTime.now().isAfter(startTime);
  bool get hasEnded => DateTime.now().isAfter(endTime);
  double get occupancyRate => (totalSeats - availableSeats) / totalSeats;

  @override
  List<Object?> get props => [
        id,
        movieId,
        movieTitle,
        roomId,
        roomName,
        startTime,
        endTime,
        language,
        subtitles,
        format,
        basePrice,
        totalSeats,
        availableSeats,
        reservedSeats,
        soldSeats,
        status,
        moviePosterUrl,
        movieRating,
        movieDuration,
      ];
}
