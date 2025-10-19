import 'service_locator.dart';
import '../../core/navigation/navigation_manager.dart';
import '../../adapters/storage/local_storage.dart';
import '../../features/authentication/di/auth_injection_container.dart';

/// Central Dependency Injection Container
/// Coordinates all module injection containers and core services
class InjectionContainer {
  static Future<void> init() async {
    // Core Services
    await _initCore();

    // Feature Modules
    await _initFeatures();
  }

  /// Initialize core services
  static Future<void> _initCore() async {
    // Navigation
    serviceLocator.registerSingleton<NavigationManager>(NavigationManager());

    // Storage
    final storage = await LocalStorage.getInstance();
    serviceLocator.registerSingleton<LocalStorage>(storage);

    // TODO: Add other core services
    // serviceLocator.registerSingleton<HttpClient>(HttpClient());
    // serviceLocator.registerSingleton<ConnectivityChecker>(ConnectivityChecker());
    // serviceLocator.registerSingleton<AnalyticsTracker>(AnalyticsTracker());
  }

  /// Initialize feature module dependencies
  static Future<void> _initFeatures() async {
    // Authentication Module
    await AuthInjectionContainer.init();

    // TODO: Add other feature modules
    // await DashboardInjectionContainer.init();
    // await PosInjectionContainer.init();
    // await InventoryInjectionContainer.init();
  }
}
