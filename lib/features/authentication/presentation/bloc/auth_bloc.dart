import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/get_current_employee_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

/// Authentication BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCurrentEmployeeUseCase getCurrentEmployeeUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentEmployeeUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  /// Handle auth check event
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await checkAuthStatusUseCase.call(const NoParams());

    await result.fold(
      (failure) async {
        emit(const Unauthenticated());
      },
      (isAuthenticated) async {
        if (isAuthenticated) {
          // Get current employee data
          final employeeResult = await getCurrentEmployeeUseCase.call(const NoParams());
          employeeResult.fold(
            (failure) => emit(const Unauthenticated()),
            (employee) => emit(Authenticated(employee)),
          );
        } else {
          emit(const Unauthenticated());
        }
      },
    );
  }

  /// Handle login event
  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final result = await loginUseCase.call(
      LoginParams(
        employeeId: event.employeeId,
        password: event.password,
      ),
    );

    result.fold(
      (failure) {
        // Log detailed error to console
        print('[AuthBloc] Login failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (employee) {
        print('[AuthBloc] Login successful: ${employee.fullName}');
        emit(Authenticated(employee));
      },
    );
  }

  /// Handle logout event
  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    print('[AuthBloc] Logout requested');
    emit(const AuthLoading());

    final result = await logoutUseCase.call(const NoParams());

    result.fold(
      (failure) {
        print('[AuthBloc] Logout failed: ${failure.message}');
        emit(AuthError(failure.message));
      },
      (_) {
        print('[AuthBloc] Logout successful');
        emit(const Unauthenticated());
      },
    );
  }
}
