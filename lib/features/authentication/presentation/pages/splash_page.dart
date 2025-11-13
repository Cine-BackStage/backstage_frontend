import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Splash page - checks authentication status
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  static const String routeName = '/';

  @override
  Widget build(BuildContext context) {
    // Trigger auth check when splash page is shown
    context.read<AuthBloc>().add(const AuthCheckRequested());
    return const SplashView();
  }
}

/// Splash view
class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          state.when(
            initial: () {
              // Do nothing, waiting for auth check
            },
            loading: () {
              // Do nothing, checking auth
            },
            authenticated: (employee) {
              // Navigate to dashboard
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.showSuccessSnackBar('Bem-vindo de volta, ${employee.fullName}!');
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                }
              });
            },
            unauthenticated: () {
              // Navigate to login page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              });
            },
            error: (message) {
              // On error, go to login
              print('[Splash Error] $message');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed(AppRoutes.login);
                }
              });
            },
          );
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App logo
              Icon(
                Icons.local_movies_rounded,
                size: 100,
                color: context.colorScheme.primary,
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                'Backstage Cinema',
                style: context.textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator
              CircularProgressIndicator(
                color: context.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
