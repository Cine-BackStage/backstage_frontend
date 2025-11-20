import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_session_usecase.dart';
import '../../domain/usecases/delete_session_usecase.dart';
import '../../domain/usecases/get_sessions_usecase.dart';
import '../../domain/usecases/update_session_usecase.dart';
import 'session_management_event.dart';
import 'session_management_state.dart';

class SessionManagementBloc
    extends Bloc<SessionManagementEvent, SessionManagementState> {
  final GetSessionsUseCase getSessionsUseCase;
  final CreateSessionUseCase createSessionUseCase;
  final UpdateSessionUseCase updateSessionUseCase;
  final DeleteSessionUseCase deleteSessionUseCase;

  SessionManagementBloc({
    required this.getSessionsUseCase,
    required this.createSessionUseCase,
    required this.updateSessionUseCase,
    required this.deleteSessionUseCase,
  }) : super(const SessionManagementInitial()) {
    on<LoadAllSessionsRequested>(_onLoadAllSessionsRequested);
    on<CreateSessionRequested>(_onCreateSessionRequested);
    on<UpdateSessionRequested>(_onUpdateSessionRequested);
    on<DeleteSessionRequested>(_onDeleteSessionRequested);
    on<RefreshSessionsListRequested>(_onRefreshSessionsListRequested);
  }

  Future<void> _onLoadAllSessionsRequested(
    LoadAllSessionsRequested event,
    Emitter<SessionManagementState> emit,
  ) async {
    emit(const SessionManagementLoading());

    final result = await getSessionsUseCase(
      GetSessionsParams(
        date: event.startDate,
        movieId: event.movieId != null ? int.tryParse(event.movieId!) : null,
        roomId: event.roomId != null ? int.tryParse(event.roomId!) : null,
      ),
    );

    result.fold(
      (failure) => emit(SessionManagementError(failure: failure)),
      (sessions) => emit(SessionManagementLoaded(sessions: sessions)),
    );
  }

  Future<void> _onCreateSessionRequested(
    CreateSessionRequested event,
    Emitter<SessionManagementState> emit,
  ) async {
    // Save current state to restore if error
    final previousState = state;
    emit(const SessionManagementCreating());

    print('📝 Creating session - Movie: ${event.movieId}, Room: ${event.roomId}');

    final result = await createSessionUseCase(
      CreateSessionParams(
        movieId: event.movieId,
        roomId: event.roomId,
        startTime: event.startTime,
        basePrice: event.basePrice,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Error creating session: ${failure.userMessage}');
        // Restore previous state instead of showing error screen
        if (previousState is SessionManagementLoaded) {
          emit(previousState);
        }
        // Then emit error for snackbar
        emit(SessionManagementError(failure: failure));
      },
      (session) {
        print('✅ Session created successfully: ${session.id}');
        emit(SessionManagementCreated(session: session));
        // Automatically refresh the list
        add(const RefreshSessionsListRequested());
      },
    );
  }

  Future<void> _onUpdateSessionRequested(
    UpdateSessionRequested event,
    Emitter<SessionManagementState> emit,
  ) async {
    // Save current state to restore if error
    final previousState = state;
    emit(const SessionManagementUpdating());

    print('🔄 Updating session: ${event.sessionId}');

    final result = await updateSessionUseCase(
      UpdateSessionParams(
        sessionId: event.sessionId,
        movieId: event.movieId,
        roomId: event.roomId,
        startTime: event.startTime,
        basePrice: event.basePrice,
        status: event.status,
      ),
    );

    result.fold(
      (failure) {
        print('❌ Error updating session: ${failure.userMessage}');
        // Restore previous state instead of showing error screen
        if (previousState is SessionManagementLoaded) {
          emit(previousState);
        }
        // Then emit error for snackbar
        emit(SessionManagementError(failure: failure));
      },
      (session) {
        print('✅ Session updated successfully');
        emit(SessionManagementUpdated(session: session));
        // Automatically refresh the list
        add(const RefreshSessionsListRequested());
      },
    );
  }

  Future<void> _onDeleteSessionRequested(
    DeleteSessionRequested event,
    Emitter<SessionManagementState> emit,
  ) async {
    emit(const SessionManagementDeleting());

    final result = await deleteSessionUseCase(
      DeleteSessionParams(sessionId: event.sessionId),
    );

    result.fold(
      (failure) => emit(SessionManagementError(failure: failure)),
      (_) {
        emit(SessionManagementDeleted(sessionId: event.sessionId));
        // Automatically refresh the list
        add(const RefreshSessionsListRequested());
      },
    );
  }

  Future<void> _onRefreshSessionsListRequested(
    RefreshSessionsListRequested event,
    Emitter<SessionManagementState> emit,
  ) async {
    final result = await getSessionsUseCase(GetSessionsParams());

    result.fold(
      (failure) => emit(SessionManagementError(failure: failure)),
      (sessions) => emit(SessionManagementLoaded(sessions: sessions)),
    );
  }
}
