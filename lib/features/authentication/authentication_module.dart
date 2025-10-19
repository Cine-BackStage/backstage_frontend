import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../adapters/storage/local_storage.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/auth_local_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/check_auth_status_usecase.dart';
import 'domain/usecases/request_password_reset_usecase.dart';
import 'domain/usecases/get_features_usecase.dart';
import 'presentation/bloc/auth_bloc.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/forgot_password_page.dart';

/// Authentication Module
/// Self-contained module for authentication flow
class AuthenticationModule extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const AuthenticationModule({
    super.key,
    this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthBloc>(
      future: createAuthBloc(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          // Show loading while initializing
          return const Material(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return BlocProvider<AuthBloc>.value(
          value: snapshot.data!,
          child: _AuthNavigator(navigatorKey: navigatorKey),
        );
      },
    );
  }

  /// Create AuthBloc with dependencies
  /// TODO: Move to DI container for better management
  static Future<AuthBloc> createAuthBloc() async {
    // Initialize storage
    final storage = await LocalStorage.getInstance();

    // Initialize datasources
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final localDataSource = AuthLocalDataSourceImpl(storage);

    // Initialize repository
    final repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );

    // Initialize use cases
    final loginUseCase = LoginUseCase(repository);
    final logoutUseCase = LogoutUseCase(repository);
    final checkAuthStatusUseCase = CheckAuthStatusUseCase(repository);
    final requestPasswordResetUseCase = RequestPasswordResetUseCase(repository);

    // Create bloc
    return AuthBloc(
      loginUseCase: loginUseCase,
      logoutUseCase: logoutUseCase,
      checkAuthStatusUseCase: checkAuthStatusUseCase,
      requestPasswordResetUseCase: requestPasswordResetUseCase,
    );
  }

  /// Create GetFeaturesUseCase with dependencies
  /// TODO: Move to DI container
  static Future<GetFeaturesUseCase> createGetFeaturesUseCase() async {
    final storage = await LocalStorage.getInstance();
    final remoteDataSource = AuthRemoteDataSourceImpl();
    final localDataSource = AuthLocalDataSourceImpl(storage);
    final repository = AuthRepositoryImpl(
      remoteDataSource: remoteDataSource,
      localDataSource: localDataSource,
    );
    return GetFeaturesUseCase(repository);
  }
}

/// Internal navigator for authentication module
class _AuthNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState>? navigatorKey;

  const _AuthNavigator({this.navigatorKey});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      initialRoute: '/splash',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/splash':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const SplashPage(),
            );
          case '/login':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const LoginPage(),
            );
          case '/forgot-password':
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const ForgotPasswordPage(),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const SplashPage(),
            );
        }
      },
    );
  }
}
