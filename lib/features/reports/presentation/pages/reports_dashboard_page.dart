import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';
import '../widgets/sales_summary_card.dart';

/// Reports dashboard page
class ReportsDashboardPage extends StatefulWidget {
  const ReportsDashboardPage({super.key});

  @override
  State<ReportsDashboardPage> createState() => _ReportsDashboardPageState();
}

class _ReportsDashboardPageState extends State<ReportsDashboardPage> {
  @override
  void initState() {
    super.initState();
    // Load sales summary on init
    context.read<ReportsBloc>().add(const LoadSalesSummary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<ReportsBloc>().add(const LoadSalesSummary());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sales Summary Section
              BlocBuilder<ReportsBloc, ReportsState>(
                builder: (context, state) {
                  return state.maybeWhen(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    salesSummaryLoaded: (summary) => SalesSummaryCard(summary: summary),
                    error: (message) => Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Erro ao carregar resumo',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              message,
                              style: Theme.of(context).textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                context.read<ReportsBloc>().add(const LoadSalesSummary());
                              },
                              child: const Text('Tentar novamente'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Report Categories
              Text(
                'Relatórios Disponíveis',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),

              // Detailed Sales Report Card
              _ReportCard(
                key: const Key('detailedSalesReportButton'),
                title: 'Vendas Detalhadas',
                description: 'Análise detalhada de vendas por período',
                icon: Icons.analytics,
                color: Colors.blue,
                onTap: () {
                  Navigator.pushNamed(context, '/reports/detailed-sales');
                },
              ),
              const SizedBox(height: 12),

              // Ticket Sales Report Card
              _ReportCard(
                key: const Key('ticketSalesReportButton'),
                title: 'Vendas de Ingressos',
                description: 'Análise de vendas de ingressos por filme',
                icon: Icons.confirmation_number,
                color: Colors.green,
                onTap: () {
                  Navigator.pushNamed(context, '/reports/ticket-sales');
                },
              ),
              const SizedBox(height: 12),

              // Employee Report Card
              _ReportCard(
                key: const Key('employeeReportButton'),
                title: 'Desempenho de Funcionários',
                description: 'Relatório de performance dos funcionários',
                icon: Icons.people,
                color: Colors.orange,
                onTap: () {
                  Navigator.pushNamed(context, '/reports/employees');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Report card widget
class _ReportCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
