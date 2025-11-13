import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../shared/utils/extensions/context_extensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../widgets/login_form.dart';

/// Login page
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String routeName = '/login';

  @override
  Widget build(BuildContext context) {
    return const LoginView();
  }
}

/// Login view
class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          state.whenOrNull(
            authenticated: (employee) {
              // Show success message and navigate after frame
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.showSuccessSnackBar('Bem-vindo, ${employee.fullName}!');
                  Navigator.of(context).pushReplacementNamed(AppRoutes.dashboard);
                }
              });
            },
            error: (message) {
              // Log detailed error to console
              print('[Login Error] $message');
              // Show generic error to user
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  context.showErrorSnackBar('Erro ao fazer login. Verifique suas credenciais e tente novamente.');
                }
              });
            },
          );
        },
        builder: (context, state) {
          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Icon(
                      Icons.local_movies_rounded,
                      size: 80,
                      color: context.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),

                    // App name
                    Text(
                      'Backstage Cinema',
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'Sistema de Gestão',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: context.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Login form
                    const LoginForm(),

                    // Loading indicator
                    if (state is AuthLoading) ...[
                      const SizedBox(height: 24),
                      const Center(
                        child: CircularProgressIndicator(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
