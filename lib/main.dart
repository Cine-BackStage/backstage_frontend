import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'design_system/theme/app_theme.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/navigation/app_routes.dart';
import 'shared/l10n/generated/app_localizations.dart';
import 'features/design_system_demo/design_system_demo_module.dart';
import 'features/authentication/authentication_module.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'adapters/dependency_injection/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  await _initDependencies();

  runApp(const BackstageApp());
}

/// Initialize dependency injection
Future<void> _initDependencies() async {
  // Register NavigationManager as singleton
  serviceLocator.registerSingleton<NavigationManager>(NavigationManager());

  // TODO: Register other core services when needed
  // final storage = await LocalStorage.getInstance();
  // serviceLocator.registerSingleton<LocalStorage>(storage);
  // serviceLocator.registerSingleton<HttpClient>(HttpClient());
  // serviceLocator.registerSingleton<ConnectivityChecker>(ConnectivityChecker());
  // serviceLocator.registerSingleton<AnalyticsTracker>(AnalyticsTracker());
}

class BackstageApp extends StatefulWidget {
  const BackstageApp({super.key});

  @override
  State<BackstageApp> createState() => _BackstageAppState();
}

class _BackstageAppState extends State<BackstageApp> {
  // Cache module instances to prevent recreation on route changes
  late final AuthenticationModule _authModule;
  late final DesignSystemDemoModule _demoModule;

  @override
  void initState() {
    super.initState();
    _authModule = AuthenticationModule();
    _demoModule = DesignSystemDemoModule();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Backstage Cinema',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.darkTheme,

      // Localization
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'), // Portuguese (Brazil)
        Locale('pt'),       // Portuguese (fallback)
        Locale('en'),       // English
      ],
      locale: const Locale('pt', 'BR'), // Default locale

      // Navigation
      navigatorKey: serviceLocator<NavigationManager>().navigatorKey,
      initialRoute: '/auth', // Start with auth module
      onGenerateRoute: _onGenerateRoute,
    );
  }

  /// Route generator
  /// This is a placeholder implementation for Phase 1
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
      case '/auth':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _authModule,
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardPlaceholder(),
        );

      case '/demo':
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => _demoModule,
        );

      default:
        return MaterialPageRoute(
          builder: (_) => const NotFoundScreen(),
        );
    }
  }
}

/// Placeholder screens for Phase 1
/// These will be replaced with actual implementations in later phases

class SplashPlaceholder extends StatelessWidget {
  const SplashPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    // Simulate splash screen delay
    Future.delayed(const Duration(seconds: 2), () {
      serviceLocator<NavigationManager>().replaceTo(AppRoutes.login);
    });

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'BACKSTAGE CINEMA',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class LoginPlaceholder extends StatelessWidget {
  const LoginPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.login_title,
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 8),
              Text(
                l10n.login_subtitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  serviceLocator<NavigationManager>().replaceTo(AppRoutes.dashboard);
                },
                child: Text(l10n.login_button),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardPlaceholder extends StatelessWidget {
  const DashboardPlaceholder({super.key});

  void _handleLogout(BuildContext context) {
    // Access AuthBloc and dispatch logout event
    final authBloc = AuthenticationModule.authBloc;
    if (authBloc != null) {
      authBloc.add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Check if we can go back in the root navigator
    final canPop = serviceLocator<NavigationManager>().canGoBack();
    final authBloc = AuthenticationModule.authBloc;

    // Wrap in BlocListener to handle logout state changes
    return BlocListener<AuthBloc, AuthState>(
      bloc: authBloc,
      listener: (context, state) {
        if (state is Unauthenticated) {
          // Navigate back to auth module when logged out
          serviceLocator<NavigationManager>().navigateAndRemoveUntil('/auth');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.dashboard_title),
          // Hide back button if dashboard is the root route
          automaticallyImplyLeading: canPop,
          actions: [
            // Logout button
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Sair',
              onPressed: () => _handleLogout(context),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.dashboard_greeting('Usuário'),
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Dashboard implementation coming in Phase 2',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/demo');
                },
                icon: const Icon(Icons.palette),
                label: const Text('View Design System Demo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('404'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                serviceLocator<NavigationManager>().goBack();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
