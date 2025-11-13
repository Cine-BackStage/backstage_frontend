import 'package:equatable/equatable.dart';
import '../../domain/entities/employee.dart';

/// Authentication state base class
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];

  /// Pattern matching - all cases required
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(Employee employee) authenticated,
    required T Function() unauthenticated,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is AuthInitial) {
      return initial();
    } else if (state is AuthLoading) {
      return loading();
    } else if (state is Authenticated) {
      return authenticated(state.employee);
    } else if (state is Unauthenticated) {
      return unauthenticated();
    } else if (state is AuthError) {
      return error(state.message);
    }
    throw Exception('Unknown state: $state');
  }

  /// Pattern matching - returns null if no match
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
  }) {
    final state = this;
    if (state is AuthInitial && initial != null) {
      return initial();
    } else if (state is AuthLoading && loading != null) {
      return loading();
    } else if (state is Authenticated && authenticated != null) {
      return authenticated(state.employee);
    } else if (state is Unauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (state is AuthError && error != null) {
      return error(state.message);
    }
    return null;
  }

  /// Pattern matching - with default orElse callback
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee)? authenticated,
    T Function()? unauthenticated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is AuthInitial && initial != null) {
      return initial();
    } else if (state is AuthLoading && loading != null) {
      return loading();
    } else if (state is Authenticated && authenticated != null) {
      return authenticated(state.employee);
    } else if (state is Unauthenticated && unauthenticated != null) {
      return unauthenticated();
    } else if (state is AuthError && error != null) {
      return error(state.message);
    }
    return orElse();
  }
}

/// Initial state
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Authenticated state
class Authenticated extends AuthState {
  final Employee employee;

  const Authenticated(this.employee);

  @override
  List<Object?> get props => [employee];
}

/// Unauthenticated state
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
