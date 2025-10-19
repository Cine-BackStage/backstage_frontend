import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/widgets/indicators/loading_spinner.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../../../core/navigation/navigation_manager.dart';
import '../../../../adapters/dependency_injection/service_locator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

/// Splash screen with loading indicator
/// Checks authentication status on startup
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Setup fade-in animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _animationController.forward();

    // Check authentication status
    context.read<AuthBloc>().add(const CheckAuthStatusRequested());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // TODO: Navigate based on user role
          // if (state.user.isAdmin) {
          //   NavigationManager().replaceTo(AppRoutes.dashboard);
          // } else {
          //   NavigationManager().replaceTo(AppRoutes.pos);
          // }

          // For now, go to dashboard for all users
          // Use service locator to access NavigationManager
          // Clear all auth routes from stack
          serviceLocator<NavigationManager>().navigateAndRemoveUntil(
            AppRoutes.dashboard,
          );
        } else if (state is Unauthenticated) {
          // Navigate within auth module to login
          Navigator.of(context).pushReplacementNamed('/auth/login');
        } else if (state is AuthError) {
          // On error, go to login
          Navigator.of(context).pushReplacementNamed('/auth/login');
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Text(
                  'BACKSTAGE CINEMA',
                  style: AppTextStyles.logo.copyWith(
                    fontSize: 36,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing8),

                // Tagline
                Text(
                  'No Drama',
                  style: AppTextStyles.tagline.copyWith(
                    fontSize: 16,
                    color: AppColors.ticketStubBeige,
                  ),
                ),
                const SizedBox(height: AppDimensions.spacing48),

                // Loading indicator (using design system component)
                const LoadingSpinner.large(
                  color: AppColors.goldenReel,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
