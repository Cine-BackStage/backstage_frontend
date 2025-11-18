import 'package:equatable/equatable.dart';

abstract class SessionsEvent extends Equatable {
  const SessionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSessionsRequested extends SessionsEvent {
  final DateTime? date;
  final int? movieId;
  final int? roomId;

  const LoadSessionsRequested({
    this.date,
    this.movieId,
    this.roomId,
  });

  @override
  List<Object?> get props => [date, movieId, roomId];
}

class SessionDetailsRequested extends SessionsEvent {
  final String sessionId;

  const SessionDetailsRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class LoadSeatsRequested extends SessionsEvent {
  final String sessionId;

  const LoadSeatsRequested({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class SeatSelected extends SessionsEvent {
  final String seatId;

  const SeatSelected({required this.seatId});

  @override
  List<Object?> get props => [seatId];
}

class SeatDeselected extends SessionsEvent {
  final String seatId;

  const SeatDeselected({required this.seatId});

  @override
  List<Object?> get props => [seatId];
}

class PurchaseTicketsRequested extends SessionsEvent {
  final String sessionId;
  final String customerCpf;
  final String? customerName;

  const PurchaseTicketsRequested({
    required this.sessionId,
    required this.customerCpf,
    this.customerName,
  });

  @override
  List<Object?> get props => [sessionId, customerCpf, customerName];
}

class CancelTicketRequested extends SessionsEvent {
  final String ticketId;

  const CancelTicketRequested({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class ValidateTicketRequested extends SessionsEvent {
  final String ticketId;

  const ValidateTicketRequested({required this.ticketId});

  @override
  List<Object?> get props => [ticketId];
}

class RefreshSessionsRequested extends SessionsEvent {
  const RefreshSessionsRequested();
}
