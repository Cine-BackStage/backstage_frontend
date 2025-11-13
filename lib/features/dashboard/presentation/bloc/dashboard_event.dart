import 'package:equatable/equatable.dart';

/// Dashboard events
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Load dashboard statistics
class LoadDashboardStats extends DashboardEvent {
  const LoadDashboardStats();
}

/// Refresh dashboard data
class RefreshDashboard extends DashboardEvent {
  const RefreshDashboard();
}
