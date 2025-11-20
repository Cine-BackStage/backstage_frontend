import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../../../authentication/presentation/bloc/auth_bloc.dart';
import '../../../authentication/presentation/bloc/auth_event.dart';
import '../../../authentication/presentation/bloc/auth_state.dart';

/// Dashboard page - Main landing page after login
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const String routeName = '/dashboard';

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only listen when state actually changes
        return previous != current;
      },
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate immediately without waiting for frame
          // The route will be created fresh, not from cache
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
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Trigger logout event
                context.read<AuthBloc>().add(const LogoutRequested());
              },
            ),
          ],
        ),
        body: const _DashboardBody(),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  const _DashboardBody();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.dashboard_rounded,
              size: 100,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Bem-vindo ao Backstage Cinema',
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Dashboard em desenvolvimento',
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            // Placeholder cards
            _buildFeatureCard(
              context,
              icon: Icons.point_of_sale,
              title: 'PDV',
              description: 'Sistema de ponto de venda',
              onTap: () {
                context.showSnackBar('Em desenvolvimento');
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.movie_rounded,
              title: 'Sessões',
              description: 'Gerenciar sessões de cinema',
              onTap: () {
                context.showSnackBar('Em desenvolvimento');
              },
            ),
            const SizedBox(height: 16),
            _buildFeatureCard(
              context,
              icon: Icons.inventory_rounded,
              title: 'Inventário',
              description: 'Controle de estoque',
              onTap: () {
                context.showSnackBar('Em desenvolvimento');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: context.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: context.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
