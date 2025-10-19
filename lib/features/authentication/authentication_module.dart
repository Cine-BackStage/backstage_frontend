import '../../core/modules/infinite_module.dart';
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
class AuthenticationModule extends InfiniteModule {
  AuthenticationModule({
    super.key,
    super.navigatorKey,
    super.observers,
    super.initialRoute = '/splash',
  });

  @override
  List<InfiniteChildRoute> get routes => [
        // Splash screen - checks auth status
        InfiniteRoute(
          routeName: '/splash',
          builder: (context, args) => const SplashPage(),
        ),

        // Login screen
        InfiniteRoute(
          routeName: '/login',
          builder: (context, args) => const LoginPage(),
        ),

        // Forgot password screen
        InfiniteRoute(
          routeName: '/forgot-password',
          builder: (context, args) => const ForgotPasswordPage(),
        ),
      ];

  @override
  List<InjectionContainer> get dependencies => [
        () async {
          // TODO: Replace with proper DI container (GetIt)
          // This is a simplified initialization
          // In production, use GetIt to register these dependencies globally
        },
      ];

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
