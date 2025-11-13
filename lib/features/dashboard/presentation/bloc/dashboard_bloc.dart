import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_dashboard_stats_usecase.dart';
import '../../domain/usecases/refresh_dashboard_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

/// Dashboard BLoC
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardStatsUseCase getDashboardStatsUseCase;
  final RefreshDashboardUseCase refreshDashboardUseCase;

  DashboardBloc({
    required this.getDashboardStatsUseCase,
    required this.refreshDashboardUseCase,
  }) : super(const DashboardInitial()) {
    on<LoadDashboardStats>(_onLoadDashboardStats);
    on<RefreshDashboard>(_onRefreshDashboard);
  }

  /// Handle load dashboard stats event
  Future<void> _onLoadDashboardStats(
    LoadDashboardStats event,
    Emitter<DashboardState> emit,
  ) async {
    print('[DashboardBloc] Loading dashboard stats');
    emit(const DashboardLoading());

    final result = await getDashboardStatsUseCase.call(const NoParams());

    result.fold(
      (failure) {
        print('[DashboardBloc] Load failed: ${failure.message}');
        emit(DashboardError(failure.message));
      },
      (stats) {
        print('[DashboardBloc] Load successful');
        emit(DashboardLoaded(stats));
      },
    );
  }

  /// Handle refresh dashboard event
  Future<void> _onRefreshDashboard(
    RefreshDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    print('[DashboardBloc] Refreshing dashboard');

    // If we have data, show refreshing state
    if (state is DashboardLoaded) {
      emit(DashboardRefreshing((state as DashboardLoaded).stats));
    } else {
      emit(const DashboardLoading());
    }

    final result = await refreshDashboardUseCase.call(const NoParams());

    result.fold(
      (failure) {
        print('[DashboardBloc] Refresh failed: ${failure.message}');
        // Keep previous data if available
        if (state is DashboardRefreshing) {
          emit(DashboardLoaded((state as DashboardRefreshing).stats));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (stats) {
        print('[DashboardBloc] Refresh successful');
        emit(DashboardLoaded(stats));
      },
    );
  }
}
