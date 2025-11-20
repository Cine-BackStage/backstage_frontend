import 'service_locator.dart';
import '../../core/navigation/navigation_manager.dart';
import '../../adapters/storage/local_storage.dart';
import '../../adapters/http/http_client.dart';
import '../../core/constants/api_constants.dart';
import '../../features/authentication/di/auth_injection_container.dart';
import '../../features/dashboard/di/dashboard_injection_container.dart';
import '../../features/pos/di/pos_injection_container.dart';
import '../../features/sessions/di/sessions_injection_container.dart';
import '../../features/movies/di/movies_injection_container.dart';
import '../../features/rooms/di/rooms_injection_container.dart';
import '../../features/profile/di/profile_injection_container.dart';
import '../../features/inventory/di/inventory_injection_container.dart';
import '../../features/reports/di/reports_injection_container.dart';

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
    // Storage (must be first as HttpClient depends on it)
    final storage = await LocalStorage.getInstance();
    serviceLocator.registerSingleton<LocalStorage>(storage);

    // Navigation
    serviceLocator.registerSingleton<NavigationManager>(NavigationManager());

    // Debug: Print API base URL
    final baseUrl = ApiConstants.baseUrl;
    print('🔗 API Base URL: $baseUrl');

    // HTTP Client with auth interceptor
    serviceLocator.registerSingleton<HttpClient>(
      HttpClient(
        storage: storage,
        baseUrl: baseUrl,
      ),
    );

  }

  /// Initialize feature module dependencies
  static Future<void> _initFeatures() async {
    // Authentication Module
    await AuthInjectionContainer.init();

    // Dashboard Module
    await DashboardInjectionContainer.init();

    // POS Module
    await PosInjectionContainer.init();

    // Sessions Module
    await SessionsInjectionContainer.init();

    // Movies Module
    await MoviesInjectionContainer.init();

    // Rooms Module
    await RoomsInjectionContainer.init();

    // Profile Module
    await ProfileInjectionContainer.init();

    // Inventory Module
    await InventoryInjectionContainer.init();

    // Reports Module
    await ReportsInjectionContainer.init();
  }
}
