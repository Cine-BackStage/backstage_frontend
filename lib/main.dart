import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'design_system/theme/app_theme.dart';
import 'core/navigation/navigation_manager.dart';
import 'core/navigation/app_routes.dart';
import 'shared/l10n/generated/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: Initialize dependencies (GetIt)
  // await _initDependencies();

  runApp(const BackstageApp());
}

/// Initialize dependency injection
/// This is a placeholder for Phase 1
// Future<void> _initDependencies() async {
//   final getIt = GetIt.instance;
//
//   // Register singletons
//   getIt.registerSingleton<HttpClient>(HttpClient());
//   final storage = await LocalStorage.getInstance();
//   getIt.registerSingleton<LocalStorage>(storage);
//   getIt.registerSingleton<ConnectivityChecker>(ConnectivityChecker());
//   getIt.registerSingleton<AnalyticsTracker>(AnalyticsTracker());
//   getIt.registerSingleton<NavigationManager>(NavigationManager());
// }

class BackstageApp extends StatelessWidget {
  const BackstageApp({super.key});

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
      navigatorKey: NavigationManager().navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: _onGenerateRoute,
    );
  }

  /// Route generator
  /// This is a placeholder implementation for Phase 1
  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashPlaceholder(),
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginPlaceholder(),
        );

      case AppRoutes.dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardPlaceholder(),
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
      NavigationManager().replaceTo(AppRoutes.login);
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
                  NavigationManager().replaceTo(AppRoutes.dashboard);
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dashboard_title),
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
          ],
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
                NavigationManager().goBack();
              },
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}
