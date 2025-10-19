import 'package:equatable/equatable.dart';
import '../../domain/entities/credentials.dart';

/// Base authentication event
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check authentication status on app startup
class CheckAuthStatusRequested extends AuthEvent {
  const CheckAuthStatusRequested();
}

/// Login with credentials
class LoginRequested extends AuthEvent {
  final Credentials credentials;

  const LoginRequested(this.credentials);

  @override
  List<Object> get props => [credentials];
}

/// Logout
class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

/// Request password reset
class PasswordResetRequested extends AuthEvent {
  final String cpf;

  const PasswordResetRequested(this.cpf);

  @override
  List<Object> get props => [cpf];
}
