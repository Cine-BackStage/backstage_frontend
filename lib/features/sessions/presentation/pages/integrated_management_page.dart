import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../movies/presentation/bloc/movie_management_bloc.dart';
import '../../../movies/presentation/bloc/movie_management_event.dart';
import '../../../rooms/presentation/bloc/room_management_bloc.dart';
import '../../../rooms/presentation/bloc/room_management_event.dart';
import '../bloc/session_management_bloc.dart';
import '../bloc/session_management_event.dart';
import '../widgets/sessions_tab.dart';
import '../widgets/movies_tab.dart';
import '../widgets/rooms_tab.dart';

/// Integrated management page with tabs for Sessions, Movies, and Rooms
/// Implements cascading refresh when items are deleted
class IntegratedManagementPage extends StatefulWidget {
  const IntegratedManagementPage({super.key});

  @override
  State<IntegratedManagementPage> createState() => _IntegratedManagementPageState();
}

class _IntegratedManagementPageState extends State<IntegratedManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late SessionManagementBloc _sessionBloc;
  late MovieManagementBloc _movieBloc;
  late RoomManagementBloc _roomBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize blocs
    _sessionBloc = serviceLocator<SessionManagementBloc>()
      ..add(const LoadAllSessionsRequested());
    _movieBloc = serviceLocator<MovieManagementBloc>()
      ..add(const LoadMoviesRequested());
    _roomBloc = serviceLocator<RoomManagementBloc>()
      ..add(const LoadRoomsRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Refresh all tabs data - called after cascading deletes
  void _refreshAllTabs() {
    _sessionBloc.add(const RefreshSessionsListRequested());
    _movieBloc.add(const RefreshMoviesRequested());
    _roomBloc.add(const RefreshRoomsRequested());
  }

  /// Refresh sessions tab only - called after movie/room deletes
  void _refreshSessionsTab() {
    _sessionBloc.add(const RefreshSessionsListRequested());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SessionManagementBloc>.value(value: _sessionBloc),
        BlocProvider<MovieManagementBloc>.value(value: _movieBloc),
        BlocProvider<RoomManagementBloc>.value(value: _roomBloc),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Gerenciamento'),
          backgroundColor: AppColors.primary,
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            labelStyle: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppTextStyles.bodyMedium,
            tabs: const [
              Tab(
                icon: Icon(Icons.movie_filter),
                text: 'Sessões',
              ),
              Tab(
                icon: Icon(Icons.movie),
                text: 'Filmes',
              ),
              Tab(
                icon: Icon(Icons.meeting_room),
                text: 'Salas',
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshAllTabs,
              tooltip: 'Atualizar tudo',
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            SessionsTab(
              onRefreshAll: _refreshAllTabs,
            ),
            MoviesTab(
              onMovieDeleted: _refreshSessionsTab,
              onRefreshAll: _refreshAllTabs,
            ),
            RoomsTab(
              onRoomDeleted: _refreshSessionsTab,
              onRefreshAll: _refreshAllTabs,
            ),
          ],
        ),
      ),
    );
  }
}
