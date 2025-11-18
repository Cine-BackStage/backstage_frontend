import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/seat.dart';
import '../../domain/services/seat_reservation_manager.dart';
import '../../domain/usecases/calculate_ticket_price_usecase.dart';
import '../../domain/usecases/cancel_ticket_usecase.dart';
import '../../domain/usecases/deselect_seat_usecase.dart';
import '../../domain/usecases/get_available_seats_usecase.dart';
import '../../domain/usecases/get_session_details_usecase.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../../domain/usecases/purchase_tickets_usecase.dart';
import '../../domain/usecases/select_seat_usecase.dart';
import '../../domain/usecases/validate_ticket_usecase.dart';
import 'sessions_event.dart';
import 'sessions_state.dart';

class SessionsBloc extends Bloc<SessionsEvent, SessionsState> {
  final GetSessionsUseCase getSessionsUseCase;
  final GetSessionDetailsUseCase getSessionDetailsUseCase;
  final GetAvailableSeatsUseCase getAvailableSeatsUseCase;
  final SelectSeatUseCase selectSeatUseCase;
  final DeselectSeatUseCase deselectSeatUseCase;
  final CalculateTicketPriceUseCase calculateTicketPriceUseCase;
  final PurchaseTicketsUseCase purchaseTicketsUseCase;
  final CancelTicketUseCase cancelTicketUseCase;
  final ValidateTicketUseCase validateTicketUseCase;

  SessionsBloc({
    required this.getSessionsUseCase,
    required this.getSessionDetailsUseCase,
    required this.getAvailableSeatsUseCase,
    required this.selectSeatUseCase,
    required this.deselectSeatUseCase,
    required this.calculateTicketPriceUseCase,
    required this.purchaseTicketsUseCase,
    required this.cancelTicketUseCase,
    required this.validateTicketUseCase,
  }) : super(const SessionsInitial()) {
    on<LoadSessionsRequested>(_onLoadSessionsRequested);
    on<SessionDetailsRequested>(_onSessionDetailsRequested);
    on<LoadSeatsRequested>(_onLoadSeatsRequested);
    on<SeatSelected>(_onSeatSelected);
    on<SeatDeselected>(_onSeatDeselected);
    on<PurchaseTicketsRequested>(_onPurchaseTicketsRequested);
    on<CancelTicketRequested>(_onCancelTicketRequested);
    on<ValidateTicketRequested>(_onValidateTicketRequested);
    on<RefreshSessionsRequested>(_onRefreshSessionsRequested);
  }

  Future<void> _onLoadSessionsRequested(
    LoadSessionsRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await getSessionsUseCase(
      GetSessionsParams(
        date: event.date,
        movieId: event.movieId,
        roomId: event.roomId,
      ),
    );

    result.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (sessions) => emit(SessionsLoaded(sessions: sessions)),
    );
  }

  Future<void> _onSessionDetailsRequested(
    SessionDetailsRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await getSessionDetailsUseCase(
      GetSessionDetailsParams(sessionId: event.sessionId),
    );

    await result.fold(
      (failure) async => emit(SessionsError(failure: failure)),
      (session) async {
        print('[SessionsBloc] Session loaded - basePrice: ${session.basePrice}');

        // After loading session, automatically load seats
        final seatsResult = await getAvailableSeatsUseCase(
          GetAvailableSeatsParams(sessionId: event.sessionId),
        );

        seatsResult.fold(
          (failure) => emit(SessionsError(failure: failure)),
          (seats) {
            print('[SessionsBloc] Loaded ${seats.length} seats');

            // Get locally reserved seats (in current POS session)
            final reservedSeatIds = SeatReservationManager().getReservedSeats(event.sessionId);

            // Apply session basePrice to seats that have price 0
            // AND mark locally reserved seats as RESERVED for UI feedback
            final seatsWithPrice = seats.map((seat) {
              // Check if seat is locally reserved in current session
              final isLocallyReserved = reservedSeatIds.contains(seat.id);
              final effectiveStatus = isLocallyReserved ? 'RESERVED' : seat.status;

              if (seat.price == 0.0) {
                return Seat(
                  id: seat.id,
                  seatNumber: seat.seatNumber,
                  row: seat.row,
                  column: seat.column,
                  type: seat.type,
                  status: effectiveStatus,
                  price: session.basePrice,
                  isAccessible: seat.isAccessible,
                );
              } else if (isLocallyReserved) {
                // Update status for locally reserved seats
                return Seat(
                  id: seat.id,
                  seatNumber: seat.seatNumber,
                  row: seat.row,
                  column: seat.column,
                  type: seat.type,
                  status: effectiveStatus,
                  price: seat.price,
                  isAccessible: seat.isAccessible,
                );
              }
              return seat;
            }).toList();

            if (seatsWithPrice.isNotEmpty) {
              print('[SessionsBloc] First seat price after applying basePrice: ${seatsWithPrice.first.price}');
              if (reservedSeatIds.isNotEmpty) {
                print('[SessionsBloc] Locally reserved seats: ${reservedSeatIds.length}');
              }
            }

            emit(SeatSelectionLoaded(
              session: session,
              seats: seatsWithPrice,
              selectedSeats: const [],
              totalPrice: 0.0,
            ));
          },
        );
      },
    );
  }

  Future<void> _onLoadSeatsRequested(
    LoadSeatsRequested event,
    Emitter<SessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SeatSelectionLoaded) {
      emit(const SessionsLoading());
    }

    final seatsResult = await getAvailableSeatsUseCase(
      GetAvailableSeatsParams(sessionId: event.sessionId),
    );

    seatsResult.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (seats) {
        if (currentState is SeatSelectionLoaded) {
          emit(currentState.copyWith(seats: seats));
        }
      },
    );
  }

  void _onSeatSelected(
    SeatSelected event,
    Emitter<SessionsState> emit,
  ) {
    final currentState = state;
    if (currentState is! SeatSelectionLoaded) return;

    final seat = currentState.seats.firstWhere((s) => s.id == event.seatId);
    print('[SessionsBloc] Selecting seat - id: ${seat.id}, price: ${seat.price}');

    final selectionResult = selectSeatUseCase(
      SelectSeatParams(
        seat: seat,
        currentSelection: currentState.selectedSeats,
      ),
    );

    selectionResult.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (selectedSeats) {
        print('[SessionsBloc] Selected seats count: ${selectedSeats.length}');
        for (final s in selectedSeats) {
          print('[SessionsBloc] Seat ${s.seatNumber}: price = ${s.price}');
        }

        final priceResult = calculateTicketPriceUseCase(
          CalculateTicketPriceParams(selectedSeats: selectedSeats),
        );

        priceResult.fold(
          (failure) => emit(SessionsError(failure: failure)),
          (totalPrice) {
            print('[SessionsBloc] Total price calculated: $totalPrice');
            emit(currentState.copyWith(
              selectedSeats: selectedSeats,
              totalPrice: totalPrice,
            ));
          },
        );
      },
    );
  }

  void _onSeatDeselected(
    SeatDeselected event,
    Emitter<SessionsState> emit,
  ) {
    final currentState = state;
    if (currentState is! SeatSelectionLoaded) return;

    final selectionResult = deselectSeatUseCase(
      DeselectSeatParams(
        seatId: event.seatId,
        currentSelection: currentState.selectedSeats,
      ),
    );

    selectionResult.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (selectedSeats) {
        final priceResult = calculateTicketPriceUseCase(
          CalculateTicketPriceParams(selectedSeats: selectedSeats),
        );

        priceResult.fold(
          (failure) => emit(SessionsError(failure: failure)),
          (totalPrice) => emit(currentState.copyWith(
            selectedSeats: selectedSeats,
            totalPrice: totalPrice,
          )),
        );
      },
    );
  }

  Future<void> _onPurchaseTicketsRequested(
    PurchaseTicketsRequested event,
    Emitter<SessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! SeatSelectionLoaded) return;

    if (currentState.selectedSeats.isEmpty) {
      emit(const SessionsError(
        failure: ValidationFailure(message: 'Selecione pelo menos um assento'),
      ));
      return;
    }

    emit(const PurchasingTickets());

    final seatIds = currentState.selectedSeats.map((seat) => seat.id).toList();

    final result = await purchaseTicketsUseCase(
      PurchaseTicketsParams(
        sessionId: event.sessionId,
        seatIds: seatIds,
        customerCpf: event.customerCpf,
        customerName: event.customerName,
      ),
    );

    result.fold(
      (failure) {
        emit(SessionsError(failure: failure));
        // Return to seat selection state
        emit(currentState);
      },
      (tickets) => emit(TicketsPurchased(tickets: tickets)),
    );
  }

  Future<void> _onCancelTicketRequested(
    CancelTicketRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await cancelTicketUseCase(
      CancelTicketParams(ticketId: event.ticketId),
    );

    result.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (ticket) => emit(const SessionsInitial()),
    );
  }

  Future<void> _onValidateTicketRequested(
    ValidateTicketRequested event,
    Emitter<SessionsState> emit,
  ) async {
    emit(const SessionsLoading());

    final result = await validateTicketUseCase(
      ValidateTicketParams(ticketId: event.ticketId),
    );

    result.fold(
      (failure) => emit(SessionsError(failure: failure)),
      (ticket) => emit(const SessionsInitial()),
    );
  }

  Future<void> _onRefreshSessionsRequested(
    RefreshSessionsRequested event,
    Emitter<SessionsState> emit,
  ) async {
    final currentState = state;
    if (currentState is SessionsLoaded) {
      final result = await getSessionsUseCase(
        GetSessionsParams(),
      );

      result.fold(
        (failure) => emit(SessionsError(failure: failure)),
        (sessions) => emit(SessionsLoaded(sessions: sessions)),
      );
    } else if (currentState is SeatSelectionLoaded) {
      // Refresh seats for current session
      final seatsResult = await getAvailableSeatsUseCase(
        GetAvailableSeatsParams(sessionId: currentState.session.id),
      );

      seatsResult.fold(
        (failure) => emit(SessionsError(failure: failure)),
        (seats) => emit(currentState.copyWith(seats: seats)),
      );
    }
  }
}
