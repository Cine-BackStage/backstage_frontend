import 'dart:developer';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/request_password_reset_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final RequestPasswordResetUseCase requestPasswordResetUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.requestPasswordResetUseCase,
  }) : super(const AuthInitial()) {
    on<CheckAuthStatusRequested>(_onCheckAuthStatusRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
  }

  Future<void> _onCheckAuthStatusRequested(
    CheckAuthStatusRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkAuthStatusUseCase();

    result.fold(
      (failure) {
        log('Auth check failed: ${failure.message}', name: 'AuthBloc');
        emit(const Unauthenticated());
      },
      (user) {
        if (user != null) {
          log('User authenticated: ${user.name}', name: 'AuthBloc');
          emit(Authenticated(user));
        } else {
          log('No user authenticated', name: 'AuthBloc');
          emit(const Unauthenticated());
        }
      },
    );
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // TODO: Add input validation here
    // TODO: Add analytics event for login attempt

    final result = await loginUseCase(event.credentials);

    result.fold(
      (failure) {
        log('Login failed: ${failure.message}', name: 'AuthBloc');
        emit(AuthError(failure.message));
        // Return to unauthenticated after showing error
        emit(const Unauthenticated());
      },
      (user) {
        log('Login successful: ${user.name}', name: 'AuthBloc');
        // TODO: Add analytics event for successful login
        emit(Authenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // TODO: Add analytics event for logout

    final result = await logoutUseCase();

    result.fold(
      (failure) {
        log('Logout failed: ${failure.message}', name: 'AuthBloc');
        // Even if logout fails, clear local state
        emit(const Unauthenticated());
      },
      (_) {
        log('Logout successful', name: 'AuthBloc');
        emit(const Unauthenticated());
      },
    );
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Keep current state during password reset
    final currentState = state;

    final result = await requestPasswordResetUseCase(event.cpf);

    result.fold(
      (failure) {
        log('Password reset failed: ${failure.message}', name: 'AuthBloc');
        emit(AuthError(failure.message));
        // Return to previous state
        if (currentState is Unauthenticated) {
          emit(const Unauthenticated());
        }
      },
      (_) {
        log('Password reset requested successfully', name: 'AuthBloc');
        emit(const PasswordResetSuccess());
        // Return to unauthenticated state
        emit(const Unauthenticated());
      },
    );
  }
}
