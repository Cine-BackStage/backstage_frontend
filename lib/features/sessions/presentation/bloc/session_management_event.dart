import 'package:equatable/equatable.dart';

abstract class SessionManagementEvent extends Equatable {
  const SessionManagementEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllSessionsRequested extends SessionManagementEvent {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? movieId;
  final String? roomId;
  final String? status;

  const LoadAllSessionsRequested({
    this.startDate,
    this.endDate,
    this.movieId,
    this.roomId,
    this.status,
  });

  @override
  List<Object?> get props => [startDate, endDate, movieId, roomId, status];
}

class CreateSessionRequested extends SessionManagementEvent {
  final String movieId;
  final String roomId;
  final DateTime startTime;
  final double? basePrice;

  const CreateSessionRequested({
    required this.movieId,
    required this.roomId,
    required this.startTime,
    this.basePrice,
  });

  @override
  List<Object?> get props => [movieId, roomId, startTime, basePrice];
}

class UpdateSessionRequested extends SessionManagementEvent {
  final String sessionId;
  final String? movieId;
  final String? roomId;
  final DateTime? startTime;
  final double? basePrice;
  final String? status;

  const UpdateSessionRequested({
    required this.sessionId,
    this.movieId,
    this.roomId,
    this.startTime,
    this.basePrice,
    this.status,
  });

  @override
  List<Object?> get props =>
      [sessionId, movieId, roomId, startTime, basePrice, status];
}

class DeleteSessionRequested extends SessionManagementEvent {
  final String sessionId;

  const DeleteSessionRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class RefreshSessionsListRequested extends SessionManagementEvent {
  const RefreshSessionsListRequested();
}
