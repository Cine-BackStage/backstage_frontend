import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session.dart';
import '../../domain/entities/seat.dart';
import '../../domain/entities/ticket.dart';

abstract class SessionsState extends Equatable {
  const SessionsState();

  @override
  List<Object?> get props => [];

  // Pattern matching methods
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Session> sessions) sessionsLoaded,
    required T Function(
      Session session,
      List<Seat> seats,
      List<Seat> selectedSeats,
      double totalPrice,
    ) seatSelectionLoaded,
    required T Function() purchasingTickets,
    required T Function(List<Ticket> tickets) purchaseSuccess,
    required T Function(Failure failure) error,
  }) {
    if (this is SessionsInitial) {
      return initial();
    } else if (this is SessionsLoading) {
      return loading();
    } else if (this is SessionsLoaded) {
      return sessionsLoaded((this as SessionsLoaded).sessions);
    } else if (this is SeatSelectionLoaded) {
      final state = this as SeatSelectionLoaded;
      return seatSelectionLoaded(
        state.session,
        state.seats,
        state.selectedSeats,
        state.totalPrice,
      );
    } else if (this is PurchasingTickets) {
      return purchasingTickets();
    } else if (this is TicketsPurchased) {
      return purchaseSuccess((this as TicketsPurchased).tickets);
    } else if (this is SessionsError) {
      return error((this as SessionsError).failure);
    }
    throw Exception('Invalid state: $runtimeType');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Session> sessions)? sessionsLoaded,
    T Function(
      Session session,
      List<Seat> seats,
      List<Seat> selectedSeats,
      double totalPrice,
    )? seatSelectionLoaded,
    T Function()? purchasingTickets,
    T Function(List<Ticket> tickets)? purchaseSuccess,
    T Function(Failure failure)? error,
  }) {
    if (this is SessionsInitial && initial != null) {
      return initial();
    } else if (this is SessionsLoading && loading != null) {
      return loading();
    } else if (this is SessionsLoaded && sessionsLoaded != null) {
      return sessionsLoaded((this as SessionsLoaded).sessions);
    } else if (this is SeatSelectionLoaded && seatSelectionLoaded != null) {
      final state = this as SeatSelectionLoaded;
      return seatSelectionLoaded(
        state.session,
        state.seats,
        state.selectedSeats,
        state.totalPrice,
      );
    } else if (this is PurchasingTickets && purchasingTickets != null) {
      return purchasingTickets();
    } else if (this is TicketsPurchased && purchaseSuccess != null) {
      return purchaseSuccess((this as TicketsPurchased).tickets);
    } else if (this is SessionsError && error != null) {
      return error((this as SessionsError).failure);
    }
    return null;
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Session> sessions)? sessionsLoaded,
    T Function(
      Session session,
      List<Seat> seats,
      List<Seat> selectedSeats,
      double totalPrice,
    )? seatSelectionLoaded,
    T Function()? purchasingTickets,
    T Function(List<Ticket> tickets)? purchaseSuccess,
    T Function(Failure failure)? error,
    required T Function() orElse,
  }) {
    return whenOrNull(
          initial: initial,
          loading: loading,
          sessionsLoaded: sessionsLoaded,
          seatSelectionLoaded: seatSelectionLoaded,
          purchasingTickets: purchasingTickets,
          purchaseSuccess: purchaseSuccess,
          error: error,
        ) ??
        orElse();
  }
}

class SessionsInitial extends SessionsState {
  const SessionsInitial();
}

class SessionsLoading extends SessionsState {
  const SessionsLoading();
}

class SessionsLoaded extends SessionsState {
  final List<Session> sessions;

  const SessionsLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class SeatSelectionLoaded extends SessionsState {
  final Session session;
  final List<Seat> seats;
  final List<Seat> selectedSeats;
  final double totalPrice;

  const SeatSelectionLoaded({
    required this.session,
    required this.seats,
    required this.selectedSeats,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [session, seats, selectedSeats, totalPrice];

  SeatSelectionLoaded copyWith({
    Session? session,
    List<Seat>? seats,
    List<Seat>? selectedSeats,
    double? totalPrice,
  }) {
    return SeatSelectionLoaded(
      session: session ?? this.session,
      seats: seats ?? this.seats,
      selectedSeats: selectedSeats ?? this.selectedSeats,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

class PurchasingTickets extends SessionsState {
  const PurchasingTickets();
}

class TicketsPurchased extends SessionsState {
  final List<Ticket> tickets;

  const TicketsPurchased({required this.tickets});

  @override
  List<Object?> get props => [tickets];
}

class SessionsError extends SessionsState {
  final Failure failure;

  const SessionsError({required this.failure});

  @override
  List<Object?> get props => [failure];

  /// Get user-friendly error message
  String get message => failure.userMessage;

  /// Check if error is critical
  bool get isCritical => failure.isCritical;
}
