import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/session.dart';

abstract class SessionManagementState extends Equatable {
  const SessionManagementState();

  @override
  List<Object?> get props => [];

  // Pattern matching methods
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(List<Session> sessions) loaded,
    required T Function() creating,
    required T Function(Session session) created,
    required T Function() updating,
    required T Function(Session session) updated,
    required T Function() deleting,
    required T Function(String sessionId) deleted,
    required T Function(Failure failure) error,
  }) {
    if (this is SessionManagementInitial) {
      return initial();
    } else if (this is SessionManagementLoading) {
      return loading();
    } else if (this is SessionManagementLoaded) {
      return loaded((this as SessionManagementLoaded).sessions);
    } else if (this is SessionManagementCreating) {
      return creating();
    } else if (this is SessionManagementCreated) {
      return created((this as SessionManagementCreated).session);
    } else if (this is SessionManagementUpdating) {
      return updating();
    } else if (this is SessionManagementUpdated) {
      return updated((this as SessionManagementUpdated).session);
    } else if (this is SessionManagementDeleting) {
      return deleting();
    } else if (this is SessionManagementDeleted) {
      return deleted((this as SessionManagementDeleted).sessionId);
    } else if (this is SessionManagementError) {
      return error((this as SessionManagementError).failure);
    }
    throw Exception('Invalid state: $runtimeType');
  }

  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Session> sessions)? loaded,
    T Function()? creating,
    T Function(Session session)? created,
    T Function()? updating,
    T Function(Session session)? updated,
    T Function()? deleting,
    T Function(String sessionId)? deleted,
    T Function(Failure failure)? error,
  }) {
    if (this is SessionManagementInitial && initial != null) {
      return initial();
    } else if (this is SessionManagementLoading && loading != null) {
      return loading();
    } else if (this is SessionManagementLoaded && loaded != null) {
      return loaded((this as SessionManagementLoaded).sessions);
    } else if (this is SessionManagementCreating && creating != null) {
      return creating();
    } else if (this is SessionManagementCreated && created != null) {
      return created((this as SessionManagementCreated).session);
    } else if (this is SessionManagementUpdating && updating != null) {
      return updating();
    } else if (this is SessionManagementUpdated && updated != null) {
      return updated((this as SessionManagementUpdated).session);
    } else if (this is SessionManagementDeleting && deleting != null) {
      return deleting();
    } else if (this is SessionManagementDeleted && deleted != null) {
      return deleted((this as SessionManagementDeleted).sessionId);
    } else if (this is SessionManagementError && error != null) {
      return error((this as SessionManagementError).failure);
    }
    return null;
  }

  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(List<Session> sessions)? loaded,
    T Function()? creating,
    T Function(Session session)? created,
    T Function()? updating,
    T Function(Session session)? updated,
    T Function()? deleting,
    T Function(String sessionId)? deleted,
    T Function(Failure failure)? error,
    required T Function() orElse,
  }) {
    return whenOrNull(
          initial: initial,
          loading: loading,
          loaded: loaded,
          creating: creating,
          created: created,
          updating: updating,
          updated: updated,
          deleting: deleting,
          deleted: deleted,
          error: error,
        ) ??
        orElse();
  }
}

class SessionManagementInitial extends SessionManagementState {
  const SessionManagementInitial();
}

class SessionManagementLoading extends SessionManagementState {
  const SessionManagementLoading();
}

class SessionManagementLoaded extends SessionManagementState {
  final List<Session> sessions;

  const SessionManagementLoaded({required this.sessions});

  @override
  List<Object?> get props => [sessions];
}

class SessionManagementCreating extends SessionManagementState {
  const SessionManagementCreating();
}

class SessionManagementCreated extends SessionManagementState {
  final Session session;

  const SessionManagementCreated({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionManagementUpdating extends SessionManagementState {
  const SessionManagementUpdating();
}

class SessionManagementUpdated extends SessionManagementState {
  final Session session;

  const SessionManagementUpdated({required this.session});

  @override
  List<Object?> get props => [session];
}

class SessionManagementDeleting extends SessionManagementState {
  const SessionManagementDeleting();
}

class SessionManagementDeleted extends SessionManagementState {
  final String sessionId;

  const SessionManagementDeleted({required this.sessionId});

  @override
  List<Object?> get props => [sessionId];
}

class SessionManagementError extends SessionManagementState {
  final Failure failure;

  const SessionManagementError({required this.failure});

  @override
  List<Object?> get props => [failure];

  String get message => failure.userMessage;
  bool get isCritical => failure.isCritical;
}
