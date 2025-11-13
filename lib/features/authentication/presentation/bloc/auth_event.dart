import 'package:equatable/equatable.dart';

/// Authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app start
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// User requested login
class LoginRequested extends AuthEvent {
  final String employeeId;
  final String password;

  const LoginRequested({
    required this.employeeId,
    required this.password,
  });

  @override
  List<Object?> get props => [employeeId, password];
}

/// User requested logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
