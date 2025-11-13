import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'design_system/theme/app_theme.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/navigation/app_routes.dart';
import 'shared/l10n/generated/app_localizations.dart';
import 'features/design_system_demo/design_system_demo_module.dart';
import 'features/authentication/presentation/pages/splash_page.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'adapters/dependency_injection/injection_container.dart';
import 'adapters/dependency_injection/service_locator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize all dependencies via central injection container
  await InjectionContainer.init();

  runApp(const BackstageApp());
}

class BackstageApp extends StatefulWidget {
  const BackstageApp({super.key});

  @override
  State<BackstageApp> createState() => _BackstageAppState();
}

class _BackstageAppState extends State<BackstageApp> {
  // Cache navigator keys to maintain state across route changes
  final GlobalKey<NavigatorState> _demoNavigatorKey =
      GlobalKey<NavigatorState>();

  // Cache routes to prevent duplicate creation with same GlobalKey
  final Map<String, Route<dynamic>> _routeCache = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => serviceLocator<AuthBloc>(),
      child: MaterialApp(
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
          Locale('pt'), // Portuguese (fallback)
          Locale('en'), // English
        ],
        locale: const Locale('pt', 'BR'), // Default locale
        // Navigation
        navigatorKey: serviceLocator<NavigationManager>().navigatorKey,
        initialRoute: AppRoutes.splash, // Start with auth module (splash is '/')
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  /// Route generator
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '/';
    print('[main.dart] _onGenerateRoute called with route: $routeName');

    // Don't cache auth-related routes as they can be removed from the stack
    final shouldCache = routeName == '/demo';

    // Check if route is already cached and return it
    if (shouldCache && _routeCache.containsKey(routeName)) {
      print('[main.dart] Returning cached route for: $routeName');
      return _routeCache[routeName];
    }

    // Create new route
    final Route<dynamic> route;
    switch (routeName) {
      case AppRoutes.splash:
        route = MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashPage(),
        );
        break;

      case AppRoutes.login:
        route = MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPage(),
        );
        break;

      case AppRoutes.dashboard:
        route = MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardPage(),
        );
        break;

      case '/demo':
        print(
          '[main.dart] Creating NEW DesignSystemDemoModule with stable key: $_demoNavigatorKey',
        );
        route = MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              DesignSystemDemoModule(navigatorKey: _demoNavigatorKey),
        );
        break;

      default:
        print('[main.dart] Route not found: $routeName');
        route = MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
        break;
    }

    // Only cache non-auth routes
    if (shouldCache) {
      _routeCache[routeName] = route;
    }
    return route;
  }
}
