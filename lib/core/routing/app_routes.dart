/// App route definitions
///
/// Centralized routing configuration for the entire application.
/// Routes are organized by feature/module.
class AppRoutes {
  // Private constructor to prevent instantiation
  AppRoutes._();

  // Root routes
  static const String splash = '/';
  static const String login = '/login';

  // Dashboard routes
  static const String dashboard = '/dashboard';

  // POS (Point of Sale) routes
  static const String pos = '/pos';
  static const String posNewSale = '/pos/new-sale';
  static const String posHistory = '/pos/history';

  // Sessions routes
  static const String sessions = '/sessions';
  static const String sessionDetails = '/sessions/:id';
  static const String sessionSeats = '/sessions/:id/seats';
  static const String ticketSales = '/sessions/ticket-sales';

  // Inventory routes
  static const String inventory = '/inventory';
  static const String inventoryDetails = '/inventory/:sku';
  static const String inventoryLowStock = '/inventory/low-stock';
  static const String inventoryExpiring = '/inventory/expiring';
  static const String inventoryAdjustment = '/inventory/adjustment';

  // Customers routes
  static const String customers = '/customers';
  static const String customerDetails = '/customers/:cpf';
  static const String customerCreate = '/customers/create';

  // Movies routes
  static const String movies = '/movies';
  static const String movieDetails = '/movies/:id';

  // Reports routes
  static const String reports = '/reports';
  static const String salesReports = '/reports/sales';
  static const String ticketReports = '/reports/tickets';
  static const String inventoryReports = '/reports/inventory';
  static const String customerReports = '/reports/customers';

  // Profile & Settings routes
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String clockInOut = '/clock-in-out';
  static const String timeEntries = '/time-entries';

  // Utility methods for parameterized routes
  static String sessionDetailsRoute(String id) => '/sessions/$id';
  static String sessionSeatsRoute(String id) => '/sessions/$id/seats';
  static String inventoryDetailsRoute(String sku) => '/inventory/$sku';
  static String customerDetailsRoute(String cpf) => '/customers/$cpf';
  static String movieDetailsRoute(String id) => '/movies/$id';
}
