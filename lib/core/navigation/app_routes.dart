/// Route constants for Backstage Cinema
class AppRoutes {
  AppRoutes._();

  // Auth routes
  static const String splash = '/';
  static const String login = '/login';

  // Main routes
  static const String dashboard = '/dashboard';
  static const String alerts = '/alerts';
  static const String pos = '/pos';
  static const String sessions = '/sessions';
  static const String inventory = '/inventory';
  static const String inventoryLowStock = '/inventory/low-stock';
  static const String inventoryExpiring = '/inventory/expiring';
  static const String reports = '/reports';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // Detail routes
  static const String sessionDetail = '/sessions/:id';
  static const String productDetail = '/inventory/:id';
}
