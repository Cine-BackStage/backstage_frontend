import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/theme/app_colors.dart';
import '../../../../design_system/theme/app_text_styles.dart';
import '../../../../design_system/theme/app_dimensions.dart';
import '../../../../design_system/widgets/alerts/cine_snackbar.dart';
import '../../../../core/navigation/app_routes.dart';
import '../../domain/entities/credentials.dart';
import '../../domain/entities/feature_info.dart';
import '../../authentication_module.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/features_carousel.dart';
import '../widgets/login_form.dart';

/// Login page with features carousel
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  List<FeatureInfo> _features = [];
  bool _isLoadingFeatures = true;

  @override
  void initState() {
    super.initState();
    _loadFeatures();
  }

  Future<void> _loadFeatures() async {
    // TODO: Move this to a separate use case or BLoC
    final getFeaturesUseCase = await AuthenticationModule.createGetFeaturesUseCase();
    final result = await getFeaturesUseCase();

    // Check if widget is still mounted before calling setState
    if (!mounted) return;

    result.fold(
      (failure) {
        // Failed to load features, use empty list
        setState(() {
          _features = [];
          _isLoadingFeatures = false;
        });
      },
      (features) {
        setState(() {
          _features = features;
          _isLoadingFeatures = false;
        });
      },
    );
  }

  void _handleLogin(String cpf, String password) {
    final credentials = Credentials(cpf: cpf, password: password);
    context.read<AuthBloc>().add(LoginRequested(credentials));
  }

  void _handleForgotPassword() {
    Navigator.pushNamed(context, '/auth/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          // TODO: Navigate based on user role
          // if (state.user.isAdmin) {
          //   Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
          // } else {
          //   Navigator.pushReplacementNamed(context, AppRoutes.pos);
          // }

          // For now, go to dashboard for all users
          Navigator.pushReplacementNamed(context, AppRoutes.dashboard);
        } else if (state is AuthError) {
          CineSnackbar.error(context, message: state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacing24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppDimensions.spacing32),

                  // Logo
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'BACKSTAGE CINEMA',
                          style: AppTextStyles.logo,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppDimensions.spacing8),
                        Text(
                          'No Drama',
                          style: AppTextStyles.tagline.copyWith(
                            color: AppColors.ticketStubBeige,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppDimensions.spacing40),

                  // Features Carousel (using design system FeatureCard)
                  if (!_isLoadingFeatures && _features.isNotEmpty)
                    FeaturesCarousel(features: _features),
                  if (!_isLoadingFeatures && _features.isNotEmpty)
                    const SizedBox(height: AppDimensions.spacing32),

                  // Login Form
                  LoginForm(
                    onLogin: _handleLogin,
                    onForgotPassword: _handleForgotPassword,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
