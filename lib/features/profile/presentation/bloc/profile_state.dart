import 'package:equatable/equatable.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../domain/entities/settings.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];

  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(Employee employee, Settings settings) loaded,
    required T Function() updatingPassword,
    required T Function() passwordUpdated,
    required T Function(String message) error,
  }) {
    if (this is ProfileInitial) {
      return initial();
    } else if (this is ProfileLoading) {
      return loading();
    } else if (this is ProfileLoaded) {
      final state = this as ProfileLoaded;
      return loaded(state.employee, state.settings);
    } else if (this is ProfileUpdatingPassword) {
      return updatingPassword();
    } else if (this is ProfilePasswordUpdated) {
      return passwordUpdated();
    } else if (this is ProfileError) {
      return error((this as ProfileError).message);
    }
    throw Exception('Unhandled state: $runtimeType');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee, Settings settings)? loaded,
    T Function()? updatingPassword,
    T Function()? passwordUpdated,
    T Function(String message)? error,
  }) {
    if (this is ProfileInitial && initial != null) {
      return initial();
    } else if (this is ProfileLoading && loading != null) {
      return loading();
    } else if (this is ProfileLoaded && loaded != null) {
      final state = this as ProfileLoaded;
      return loaded(state.employee, state.settings);
    } else if (this is ProfileUpdatingPassword && updatingPassword != null) {
      return updatingPassword();
    } else if (this is ProfilePasswordUpdated && passwordUpdated != null) {
      return passwordUpdated();
    } else if (this is ProfileError && error != null) {
      return error((this as ProfileError).message);
    }
    return null;
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(Employee employee, Settings settings)? loaded,
    T Function()? updatingPassword,
    T Function()? passwordUpdated,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    return whenOrNull(
      initial: initial,
      loading: loading,
      loaded: loaded,
      updatingPassword: updatingPassword,
      passwordUpdated: passwordUpdated,
      error: error,
    ) ?? orElse();
  }
}

class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

class ProfileLoaded extends ProfileState {
  final Employee employee;
  final Settings settings;

  const ProfileLoaded({
    required this.employee,
    required this.settings,
  });

  @override
  List<Object?> get props => [employee, settings];
}

class ProfileUpdatingPassword extends ProfileState {
  const ProfileUpdatingPassword();
}

class ProfilePasswordUpdated extends ProfileState {
  const ProfilePasswordUpdated();
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
