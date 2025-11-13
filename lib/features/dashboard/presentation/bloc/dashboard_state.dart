import 'package:equatable/equatable.dart';
import '../../domain/entities/dashboard_stats.dart';

/// Dashboard state base class
abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];

  /// Pattern matching - all cases required
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(DashboardStats stats) loaded,
    required T Function(DashboardStats stats) refreshing,
    required T Function(String message) error,
  }) {
    final state = this;
    if (state is DashboardInitial) {
      return initial();
    } else if (state is DashboardLoading) {
      return loading();
    } else if (state is DashboardLoaded) {
      return loaded(state.stats);
    } else if (state is DashboardRefreshing) {
      return refreshing(state.stats);
    } else if (state is DashboardError) {
      return error(state.message);
    }
    throw Exception('Unknown state: $state');
  }

  /// Pattern matching - returns null if no match
  T? whenOrNull<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(DashboardStats stats)? loaded,
    T Function(DashboardStats stats)? refreshing,
    T Function(String message)? error,
  }) {
    final state = this;
    if (state is DashboardInitial && initial != null) {
      return initial();
    } else if (state is DashboardLoading && loading != null) {
      return loading();
    } else if (state is DashboardLoaded && loaded != null) {
      return loaded(state.stats);
    } else if (state is DashboardRefreshing && refreshing != null) {
      return refreshing(state.stats);
    } else if (state is DashboardError && error != null) {
      return error(state.message);
    }
    return null;
  }

  /// Pattern matching - with default orElse callback
  T maybeWhen<T>({
    T Function()? initial,
    T Function()? loading,
    T Function(DashboardStats stats)? loaded,
    T Function(DashboardStats stats)? refreshing,
    T Function(String message)? error,
    required T Function() orElse,
  }) {
    final state = this;
    if (state is DashboardInitial && initial != null) {
      return initial();
    } else if (state is DashboardLoading && loading != null) {
      return loading();
    } else if (state is DashboardLoaded && loaded != null) {
      return loaded(state.stats);
    } else if (state is DashboardRefreshing && refreshing != null) {
      return refreshing(state.stats);
    } else if (state is DashboardError && error != null) {
      return error(state.message);
    }
    return orElse();
  }
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state
class DashboardLoaded extends DashboardState {
  final DashboardStats stats;

  const DashboardLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Refreshing state (shows data while refreshing)
class DashboardRefreshing extends DashboardState {
  final DashboardStats stats;

  const DashboardRefreshing(this.stats);

  @override
  List<Object?> get props => [stats];
}

/// Error state
class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
