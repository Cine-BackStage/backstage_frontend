import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../../shared/utils/formatters/currency_formatter.dart';
import '../../../authentication/domain/entities/employee.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/stats_card.dart';
import '../widgets/quick_action_card.dart';
import '../widgets/dashboard_header.dart';

/// Dashboard page - Main landing page after login
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => serviceLocator<DashboardBloc>()
            ..add(const LoadDashboardStats()),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous != current,
        listener: (context, state) {
          if (state is Unauthenticated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
              }
            });
          } else if (state is AuthError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                context.showErrorSnackBar(state.message);
              }
            });
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'),
            scrolledUnderElevation: 0,
            surfaceTintColor: Colors.transparent,
            actions: [
              // Alerts bell with badge
              BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, dashboardState) {
                  int alertCount = 0;

                  dashboardState.whenOrNull(
                    loaded: (stats) {
                      alertCount = stats.inventorySummary.lowStockItems +
                          stats.inventorySummary.expiringItems;
                    },
                    refreshing: (stats) {
                      alertCount = stats.inventorySummary.lowStockItems +
                          stats.inventorySummary.expiringItems;
                    },
                  );

                  return Badge(
                    isLabelVisible: alertCount > 0,
                    label: Text('$alertCount'),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_outlined),
                      onPressed: () {
                        Navigator.of(context).pushNamed(AppRoutes.alerts);
                      },
                      tooltip: 'Alertas',
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(const LogoutRequested());
                },
                tooltip: 'Sair',
              ),
            ],
          ),
          body: const _DashboardBody(),
        ),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final employee = authState.employee;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<DashboardBloc>().add(const RefreshDashboard());
            await Future.delayed(const Duration(seconds: 1));
          },
          child: BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, dashboardState) {
              return dashboardState.when(
                initial: () => const Center(child: CircularProgressIndicator()),
                loading: () => const Center(child: CircularProgressIndicator()),
                loaded: (stats) => _buildDashboardContent(
                  context,
                  employee: employee,
                  stats: stats,
                ),
                refreshing: (stats) => _buildDashboardContent(
                  context,
                  employee: employee,
                  stats: stats,
                  isRefreshing: true,
                ),
                error: (message) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: context.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar dashboard',
                        style: context.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        message,
                        style: context.textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<DashboardBloc>().add(const LoadDashboardStats());
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildDashboardContent(
    BuildContext context, {
    required Employee employee,
    required DashboardStats stats,
    bool isRefreshing = false,
  }) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with greeting and employee info
          DashboardHeader(
            employee: employee,
            onRefresh: () {
              context.read<DashboardBloc>().add(const RefreshDashboard());
            },
          ),

          if (isRefreshing)
            const LinearProgressIndicator(),

          const SizedBox(height: 8),

          // Stats Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visão Geral',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Sales Stats
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    StatsCard(
                      title: 'Vendas Hoje',
                      value: CurrencyFormatter.format(stats.salesSummary.todayRevenue),
                      icon: Icons.attach_money,
                      iconColor: Colors.green,
                      subtitle: '${stats.salesSummary.todayTransactions} transações',
                    ),
                    StatsCard(
                      title: 'Sessões Ativas',
                      value: '${stats.sessionSummary.activeSessionsToday}',
                      icon: Icons.play_circle,
                      iconColor: Colors.blue,
                      subtitle: '${stats.sessionSummary.totalSessionsToday} no total',
                    ),
                    StatsCard(
                      title: 'Itens Baixo Estoque',
                      value: '${stats.inventorySummary.lowStockItems}',
                      icon: Icons.inventory_2,
                      iconColor: Colors.orange,
                      subtitle: '${stats.inventorySummary.totalItems} itens',
                    ),
                    StatsCard(
                      title: 'Clientes Ativos',
                      value: '${stats.activeCustomers}',
                      icon: Icons.people,
                      iconColor: Colors.purple,
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // Quick Actions Section
                Text(
                  'Ações Rápidas',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    QuickActionCard(
                      title: 'Nova Venda',
                      description: 'Iniciar PDV',
                      icon: Icons.point_of_sale,
                      color: Colors.green,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.pos);
                      },
                    ),
                    QuickActionCard(
                      title: 'Sessões',
                      description: 'Ver programação',
                      icon: Icons.movie,
                      color: Colors.blue,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.sessions);
                      },
                    ),
                    QuickActionCard(
                      title: 'Inventário',
                      description: 'Gerenciar estoque',
                      icon: Icons.inventory,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.inventory);
                      },
                    ),
                    QuickActionCard(
                      title: 'Relatórios',
                      description: 'Ver análises',
                      icon: Icons.analytics,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.of(context).pushNamed(AppRoutes.reports);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
