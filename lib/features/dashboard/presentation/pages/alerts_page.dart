import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';

/// Alerts page - Shows all system alerts
class AlertsPage extends StatelessWidget {
  const AlertsPage({super.key});

  static const String routeName = '/alerts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return state.maybeWhen(
            loaded: (stats) => _buildAlertsList(context, stats),
            refreshing: (stats) => _buildAlertsList(context, stats),
            loading: () => const Center(child: CircularProgressIndicator()),
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
                    'Erro ao carregar alertas',
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
            orElse: () => const Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _buildAlertsList(BuildContext context, DashboardStats stats) {
    final hasLowStock = stats.inventorySummary.lowStockItems > 0;
    final hasExpiring = stats.inventorySummary.expiringItems > 0;

    // No alerts
    if (!hasLowStock && !hasExpiring) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green.shade400,
            ),
            const SizedBox(height: 24),
            Text(
              'Tudo em ordem!',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Não há alertas no momento',
              style: context.textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<DashboardBloc>().add(const RefreshDashboard());
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header
          Text(
            'Alertas Ativos',
            style: context.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Itens que requerem sua atenção',
            style: context.textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),

          // Inventory Alerts Section
          if (hasLowStock || hasExpiring) ...[
            _buildSectionHeader(
              context,
              icon: Icons.inventory_2,
              title: 'Estoque',
              color: Colors.orange,
            ),
            const SizedBox(height: 12),
          ],

          // Low Stock Alert
          if (hasLowStock)
            _buildAlertCard(
              context,
              title: 'Estoque Baixo',
              message: '${stats.inventorySummary.lowStockItems} ${stats.inventorySummary.lowStockItems == 1 ? 'item está' : 'itens estão'} com estoque baixo',
              icon: Icons.inventory_2_outlined,
              color: Colors.orange,
              severity: 'MÉDIA',
              severityColor: Colors.orange,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.inventoryLowStock);
              },
            ),

          if (hasLowStock && hasExpiring) const SizedBox(height: 12),

          // Expiring Items Alert
          if (hasExpiring)
            _buildAlertCard(
              context,
              title: 'Itens Próximos do Vencimento',
              message: '${stats.inventorySummary.expiringItems} ${stats.inventorySummary.expiringItems == 1 ? 'item expira' : 'itens expiram'} em breve',
              icon: Icons.warning_amber_outlined,
              color: Colors.red,
              severity: 'ALTA',
              severityColor: Colors.red,
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.inventoryExpiring);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCard(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
    required String severity,
    required Color severityColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: context.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            // Severity badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: severityColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                severity,
                                style: TextStyle(
                                  color: severityColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          message,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Arrow icon
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
