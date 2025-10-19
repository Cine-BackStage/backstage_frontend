import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/modules/infinite_module.dart';
import '../../adapters/dependency_injection/service_locator.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/request_password_reset_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/forgot_password_page.dart';

/// Authentication Module
/// Self-contained module for authentication flow using InfiniteModule pattern
class AuthenticationModule extends InfiniteModule {
  AuthenticationModule({
    super.key,
    super.navigatorKey,
    super.observers,
    super.initialRoute = '/auth/splash',
  });

  // Store initialized AuthBloc for use in routes
  // Made public so other modules can access it for logout, etc.
  static AuthBloc? authBloc;

  @override
  List<InfiniteChildRoute> get routes => [
        // Splash screen - checks auth status
        InfiniteRoute(
          routeName: '/auth/splash',
          builder: (context, args) => const SplashPage(),
        ),

        // Login screen
        InfiniteRoute(
          routeName: '/auth/login',
          builder: (context, args) => const LoginPage(),
        ),

        // Forgot password screen
        InfiniteRoute(
          routeName: '/auth/forgot-password',
          builder: (context, args) => const ForgotPasswordPage(),
        ),
      ];

  @override
  List<InjectionContainer> get dependencies => [
        () async {
          // Create AuthBloc using injected dependencies from service locator
          // Note: BLoC is created here (not registered in service locator)
          // because it's tied to this module's lifecycle
          authBloc ??= AuthBloc(
            loginUseCase: serviceLocator<LoginUseCase>(),
            logoutUseCase: serviceLocator<LogoutUseCase>(),
            checkAuthStatusUseCase: serviceLocator<CheckAuthStatusUseCase>(),
            requestPasswordResetUseCase: serviceLocator<RequestPasswordResetUseCase>(),
          );
        },
      ];

  @override
  State<InfiniteModule> createState() => _AuthenticationModuleState();
}

/// Custom state to provide AuthBloc to all routes
class _AuthenticationModuleState extends State<AuthenticationModule> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // Note: widget.start() is already called by InfiniteModule's initState
    // We just need to wait for it to complete before showing the UI
    _waitForInitialization();
  }

  Future<void> _waitForInitialization() async {
    // Wait a frame to allow InfiniteModule's start() to complete
    await Future.delayed(Duration.zero);
    if (mounted && AuthenticationModule.authBloc != null) {
      setState(() {
        _isInitialized = true;
      });
    } else {
      // If still not initialized, wait a bit more and retry
      await Future.delayed(const Duration(milliseconds: 100));
      if (mounted) {
        setState(() {
          _isInitialized = AuthenticationModule.authBloc != null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while initializing dependencies
    if (!_isInitialized || AuthenticationModule.authBloc == null) {
      return const Material(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // Provide AuthBloc to all child routes
    return BlocProvider<AuthBloc>.value(
      value: AuthenticationModule.authBloc!,
      child: PopScope(
        canPop: !(widget.navigatorKey.currentState?.canPop() ?? false),
        onPopInvokedWithResult: (didPop, result) {
          // Handle back button for nested navigation
          if (!didPop && (widget.navigatorKey.currentState?.canPop() ?? false)) {
            widget.navigatorKey.currentState?.pop();
          }
        },
        child: Navigator(
          key: widget.navigatorKey,
          initialRoute: widget.initialRoute ?? widget.routes.first.routeName,
          observers: widget.observers,
          onGenerateRoute: (settings) {
            final routeName = settings.name ?? widget.routes.first.routeName;
            final args = settings.arguments;

            // Find matching route
            final route = widget.routes.firstWhere(
              (r) => r.routeName == routeName,
              orElse: () => widget.routes.first,
            );

            return MaterialPageRoute(
              settings: settings,
              builder: (context) => route.builder(context, args),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.dispose();
    super.dispose();
  }
}
